from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q, Sum
from django.utils import timezone
import logging
import sentry_sdk

from .models import ChatRoom, ChatMessage
from .serializers import (
    ChatRoomListSerializer, ChatRoomDetailSerializer, CreateChatRoomSerializer,
    ChatMessageSerializer, SendMessageSerializer, MarkAsReadSerializer
)
from .firebase_service import FirebaseChatService
from .push_notification_service import ChatPushNotificationService
from apps.authentication.models import User
from apps.deliveries.models import Delivery

logger = logging.getLogger(__name__)


class ChatRoomViewSet(viewsets.ModelViewSet):
    """
    ViewSet pour gérer les conversations (chat rooms).
    
    Endpoints:
    - GET /chat/rooms/ - Liste des conversations
    - GET /chat/rooms/{id}/ - Détails d'une conversation
    - POST /chat/rooms/ - Créer une conversation
    - POST /chat/rooms/{id}/mark_as_read/ - Marquer comme lu
    - POST /chat/rooms/{id}/archive/ - Archiver
    """
    
    permission_classes = [IsAuthenticated]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['delivery__tracking_number', 'other_user__full_name']
    ordering_fields = ['last_message_at', 'created_at']
    ordering = ['-last_message_at']
    
    def get_queryset(self):
        """Retourne les conversations de l'utilisateur connecté"""
        # Protection Swagger: retourne un queryset vide si génération de doc
        if getattr(self, 'swagger_fake_view', False):
            return ChatRoom.objects.none()
        
        user = self.request.user
        
        # Filtrer selon le type d'utilisateur
        if hasattr(user, 'driver_profile'):
            # Si c'est un driver, il est toujours dans le champ 'driver'
            queryset = ChatRoom.objects.filter(driver=user, is_active=True)
        else:
            # Sinon, il est dans 'other_user'
            queryset = ChatRoom.objects.filter(other_user=user, is_active=True)
        
        # Filtrer par type de room si spécifié
        room_type = self.request.query_params.get('room_type')
        if room_type:
            queryset = queryset.filter(room_type=room_type)
        
        # Filtrer par delivery si spécifié
        delivery_id = self.request.query_params.get('delivery_id')
        if delivery_id:
            queryset = queryset.filter(delivery_id=delivery_id)
        
        # Inclure ou non les archivées
        include_archived = self.request.query_params.get('include_archived', 'false')
        if include_archived.lower() != 'true':
            queryset = queryset.filter(is_archived=False)
        
        return queryset.select_related('driver', 'other_user', 'delivery')
    
    def get_serializer_class(self):
        if self.action == 'list':
            return ChatRoomListSerializer
        elif self.action == 'create':
            return CreateChatRoomSerializer
        return ChatRoomDetailSerializer
    
    def create(self, request):
        """
        Crée une nouvelle conversation (ou retourne une existante).
        
        POST /chat/rooms/
        Body: {
            "other_user_id": "uuid",
            "delivery_id": "uuid" (optionnel),
            "room_type": "delivery" ou "support",
            "initial_message": "..." (optionnel)
        }
        """
        serializer = CreateChatRoomSerializer(data=request.data)
        try:
            serializer.is_valid(raise_exception=True)
        except Exception as e:
            # Log payload keys and user for easier debugging of 400s
            try:
                logger.warning('Create chat room validation failed', extra={
                    'user_id': str(request.user.id) if hasattr(request, 'user') and request.user else None,
                    'payload_keys': list(request.data.keys()) if isinstance(request.data, dict) else None,
                    'serializer_errors': serializer.errors if hasattr(serializer, 'errors') else None,
                })
            except Exception:
                logger.warning('Create chat room validation failed (could not log extra context)')
            try:
                sentry_sdk.capture_event({
                    'message': 'create_chat_room: serializer validation error',
                    'level': 'warning',
                    'tags': {'endpoint': 'chat/rooms', 'error': 'validation'},
                    'extra': {
                        'payload': request.data if isinstance(request.data, dict) else str(request.data),
                        'user_id': str(request.user.id) if hasattr(request, 'user') and request.user else None,
                        'serializer_errors': serializer.errors if hasattr(serializer, 'errors') else None,
                    }
                })
            except Exception:
                logger.debug('sentry capture failed in chat.create validation')
            raise
        
        other_user_id = serializer.validated_data['other_user_id']
        delivery_id = serializer.validated_data.get('delivery_id')
        room_type = serializer.validated_data.get('room_type', 'delivery')
        initial_message = serializer.validated_data.get('initial_message')
        
        # Vérifier que l'utilisateur connecté est un driver OU un marchand
        user = request.user
        is_driver = hasattr(user, 'driver_profile')
        is_merchant = hasattr(user, 'merchant_profile')
        
        if not is_driver and not is_merchant:
            return Response(
                {'error': 'Seuls les drivers et marchands peuvent créer des conversations'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Vérifier que l'autre utilisateur existe
        try:
            other_user = User.objects.get(id=other_user_id)
        except User.DoesNotExist:
            return Response(
                {'error': 'Utilisateur introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Vérifier la livraison si fournie
        delivery = None
        if delivery_id:
            try:
                delivery = Delivery.objects.get(id=delivery_id)
            except Delivery.DoesNotExist:
                return Response(
                    {'error': 'Livraison introuvable'},
                    status=status.HTTP_404_NOT_FOUND
                )
        
        # Déterminer qui est le driver et qui est l'autre utilisateur
        # Si l'utilisateur actuel est un driver, il est le driver de la conversation
        # Sinon (marchand), l'autre utilisateur doit être un driver
        if is_driver:
            driver_user = user
            other_user_in_room = other_user
        else:
            # L'utilisateur actuel est un marchand, l'autre doit être un driver
            if not hasattr(other_user, 'driver_profile'):
                return Response(
                    {'error': 'Le destinataire doit être un livreur'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            driver_user = other_user
            other_user_in_room = user
        
        # Chercher une conversation existante
        existing_room = ChatRoom.objects.filter(
            driver=driver_user,
            other_user=other_user_in_room,
            delivery=delivery
        ).first()
        
        if existing_room:
            # Retourner la conversation existante
            serializer = ChatRoomDetailSerializer(
                existing_room,
                context={'request': request}
            )
            return Response(serializer.data)
        
        # Créer une nouvelle conversation
        chat_room = ChatRoom.objects.create(
            room_type=room_type,
            driver=driver_user,
            other_user=other_user_in_room,
            delivery=delivery
        )
        
        # Créer dans Firebase
        FirebaseChatService.create_chat_room(
            str(chat_room.id),
            {
                'room_type': room_type,
                'driver_id': str(driver_user.id),
                'other_user_id': str(other_user_in_room.id),
                'delivery_id': str(delivery.id) if delivery else None,
            }
        )
        
        # Envoyer le message initial si fourni
        if initial_message:
            message = ChatMessage.objects.create(
                chat_room=chat_room,
                sender=user,
                message_type='text',
                text=initial_message
            )
            
            # Sync avec Firebase
            FirebaseChatService.send_message(
                str(chat_room.id),
                {
                    'id': str(message.id),
                    'sender_id': str(user.id),
                    'message_type': 'text',
                    'text': initial_message,
                    'timestamp': message.created_at.isoformat(),
                }
            )
            
            # Mettre à jour last_message
            chat_room.last_message_text = initial_message
            chat_room.last_message_at = message.created_at
            chat_room.last_message_sender_id = user.id
            chat_room.other_user_unread_count = 1
            chat_room.save()
        
        serializer = ChatRoomDetailSerializer(chat_room, context={'request': request})
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
    @action(detail=True, methods=['POST'], url_path='mark-as-read')
    def mark_as_read(self, request, pk=None):
        """
        Marque tous les messages d'une conversation comme lus.
        
        POST /chat/rooms/{id}/mark-as-read/
        """
        chat_room = self.get_object()
        user = request.user
        
        # Marquer comme lu dans la DB
        chat_room.mark_as_read_for_user(user.id)
        
        logger.info(f"✓ Conversation {chat_room.id} marquée comme lue par {user.full_name}")
        
        return Response({
            'success': True,
            'message': 'Conversation marquée comme lue'
        })
    
    @action(detail=True, methods=['POST'])
    def archive(self, request, pk=None):
        """
        Archive ou désarchive une conversation.
        
        POST /chat/rooms/{id}/archive/
        Body: { "archive": true/false }
        """
        chat_room = self.get_object()
        archive = request.data.get('archive', True)
        
        chat_room.is_archived = archive
        chat_room.save()
        
        return Response({
            'success': True,
            'message': f"Conversation {'archivée' if archive else 'désarchivée'}"
        })
    
    @action(detail=False, methods=['get'], url_path='unread-count')
    def unread_count(self, request):
        """
        Retourne le nombre total de messages non lus.

        GET /chat/rooms/unread-count/
        """
        user = request.user
        
        if hasattr(user, 'driver_profile'):
            total_unread = ChatRoom.objects.filter(
                driver=user,
                is_active=True
            ).aggregate(total=Sum('driver_unread_count'))['total'] or 0
        else:
            total_unread = ChatRoom.objects.filter(
                other_user=user,
                is_active=True
            ).aggregate(total=Sum('other_user_unread_count'))['total'] or 0
        
        return Response({'unread_count': total_unread})


class ChatMessageViewSet(viewsets.ModelViewSet):
    """
    ViewSet pour gérer les messages (backup DB + API REST).
    
    Note: Le chat temps réel utilise Firebase.
    Cette API sert de backup et pour l'historique.
    
    Endpoints:
    - GET /chat/messages/ - Liste des messages d'une room
    - POST /chat/messages/ - Envoyer un message
    - POST /chat/messages/mark_as_read/ - Marquer comme lu
    """
    
    serializer_class = ChatMessageSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Retourne les messages des conversations de l'utilisateur"""
        # Protection Swagger: retourne un queryset vide si génération de doc
        if getattr(self, 'swagger_fake_view', False):
            return ChatMessage.objects.none()
        
        user = self.request.user
        chat_room_id = self.request.query_params.get('chat_room_id')
        
        if chat_room_id:
            # Messages d'une conversation spécifique
            queryset = ChatMessage.objects.filter(chat_room_id=chat_room_id)
        else:
            # Toutes les conversations de l'utilisateur
            if hasattr(user, 'driver_profile'):
                room_ids = ChatRoom.objects.filter(driver=user).values_list('id', flat=True)
            else:
                room_ids = ChatRoom.objects.filter(other_user=user).values_list('id', flat=True)
            
            queryset = ChatMessage.objects.filter(chat_room_id__in=room_ids)
        
        return queryset.select_related('chat_room', 'sender').order_by('created_at')
    
    def create(self, request):
        """
        Envoie un message (sync Firebase + DB).
        
        POST /chat/messages/
        Body: {
            "chat_room_id": "uuid",
            "message_type": "text" | "image" | "location",
            "text": "...",
            "image_url": "..." (optionnel),
            "latitude": 12.34 (optionnel),
            "longitude": 56.78 (optionnel)
        }
        """
        serializer = SendMessageSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        chat_room_id = serializer.validated_data['chat_room_id']
        user = request.user
        
        # Vérifier que la conversation existe et que l'utilisateur y participe
        try:
            chat_room = ChatRoom.objects.get(id=chat_room_id)
            if user.id not in [chat_room.driver_id, chat_room.other_user_id]:
                return Response(
                    {'error': 'Vous ne participez pas à cette conversation'},
                    status=status.HTTP_403_FORBIDDEN
                )
        except ChatRoom.DoesNotExist:
            return Response(
                {'error': 'Conversation introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Créer le message en DB
        message = ChatMessage.objects.create(
            chat_room=chat_room,
            sender=user,
            message_type=serializer.validated_data['message_type'],
            text=serializer.validated_data.get('text', ''),
            image_url=serializer.validated_data.get('image_url', ''),
            latitude=serializer.validated_data.get('latitude'),
            longitude=serializer.validated_data.get('longitude'),
        )
        
        # Sync avec Firebase
        success = FirebaseChatService.send_message(
            str(chat_room.id),
            {
                'id': str(message.id),
                'sender_id': str(user.id),
                'message_type': message.message_type,
                'text': message.text,
                'image_url': message.image_url,
                'latitude': message.latitude,
                'longitude': message.longitude,
                'timestamp': message.created_at.isoformat(),
            }
        )
        
        if success:
            message.is_synced_to_firebase = True
            message.save()
        
        # Mettre à jour la conversation
        chat_room.last_message_text = message.text[:100]
        chat_room.last_message_at = message.created_at
        chat_room.last_message_sender_id = user.id
        
        # Identifier le destinataire
        recipient = chat_room.other_user if user.id == chat_room.driver_id else chat_room.driver
        
        chat_room.increment_unread_for_user(recipient.id)
        chat_room.save()
        
        # Envoyer une notification push au destinataire
        try:
            sender_name = user.first_name if hasattr(user, 'first_name') and user.first_name else "Nouveau message"
            message_preview = message.text if message.message_type == 'text' else f"📷 Image" if message.message_type == 'image' else "📍 Position"
            
            ChatPushNotificationService.send_new_message_notification(
                recipient_user=recipient,
                sender_name=sender_name,
                message_text=message_preview,
                chat_room_id=str(chat_room.id),
                message_id=str(message.id)
            )
            logger.info(f"✅ Notification push envoyée pour message {message.id}")
        except Exception as e:
            logger.error(f"❌ Erreur envoi notification push: {e}")
        
        serializer = ChatMessageSerializer(message, context={'request': request})
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
    @action(detail=False, methods=['POST'], url_path='mark-as-read')
    def mark_as_read(self, request):
        """
        Marque des messages comme lus.
        
        POST /chat/messages/mark-as-read/
        Body: {
            "message_ids": ["uuid1", "uuid2", ...] (optionnel),
            "chat_room_id": "uuid" (optionnel - marque tous les messages de la room)
        }
        """
        serializer = MarkAsReadSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        message_ids = serializer.validated_data.get('message_ids', [])
        chat_room_id = serializer.validated_data.get('chat_room_id')
        
        if chat_room_id:
            # Marquer tous les messages d'une conversation
            messages = ChatMessage.objects.filter(
                chat_room_id=chat_room_id,
                is_read=False
            ).exclude(sender=request.user)
        elif message_ids:
            # Marquer des messages spécifiques
            messages = ChatMessage.objects.filter(
                id__in=message_ids,
                is_read=False
            )
        else:
            return Response(
                {'error': 'Fournir message_ids ou chat_room_id'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Marquer comme lus
        count = messages.update(is_read=True, read_at=timezone.now())
        
        # Marquer aussi dans Firebase
        for message in messages:
            FirebaseChatService.mark_message_as_read(
                str(message.chat_room_id),
                str(message.id)
            )
        
        return Response({
            'success': True,
            'count': count,
            'message': f'{count} message(s) marqué(s) comme lu(s)'
        })


from django.db import models  # Import manquant
