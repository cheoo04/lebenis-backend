from rest_framework import viewsets, filters, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django.utils import timezone
import logging

from .models import Notification, DeviceToken, NotificationHistory
from .serializers import (
    NotificationSerializer, DeviceTokenSerializer,
    SendNotificationSerializer, BroadcastNotificationSerializer,
    NotificationHistorySerializer
)
from .firebase_service import FirebaseService
from apps.authentication.models import User
from core.permissions import IsAdmin

logger = logging.getLogger(__name__)


class NotificationViewSet(viewsets.ModelViewSet):
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['title', 'message', 'user__email']
    ordering_fields = ['sent_at']

    def get_permissions(self):
        if self.action in ['send_to_user', 'broadcast']:
            return [IsAdmin()]
        return [permissions.IsAuthenticated()]
    
    def get_queryset(self):
        # Protection pour la génération du schéma Swagger
        if getattr(self, 'swagger_fake_view', False):
            return Notification.objects.none()
        
        # Vérifier que l'utilisateur est authentifié
        user = self.request.user
        if not user.is_authenticated:
            return Notification.objects.none()
        
        # Admins voient toutes les notifications
        if user.is_staff:
            return self.queryset.all()
        
        # Autres utilisateurs voient seulement leurs notifications
        return self.queryset.filter(user=user)
    
    @action(detail=True, methods=['POST'])
    def mark_as_read(self, request, pk=None):
        """
        POST /api/v1/notifications/{id}/mark-as-read/
        
        Marquer une notification comme lue.
        """
        notification = self.get_object()
        
        if notification.user != request.user and not request.user.is_staff:
            return Response(
                {'error': 'Vous ne pouvez pas modifier cette notification'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        notification.is_read = True
        notification.read_at = timezone.now()
        notification.save()
        
        return Response({'success': True, 'message': 'Notification marquée comme lue'})
    
    @action(detail=False, methods=['POST'])
    def register_token(self, request):
        """
        POST /api/v1/notifications/register-token/
        
        Enregistrer le token FCM d'un appareil.
        
        Body:
        {
            "token": "fcm_device_token_here",
            "platform": "android",  // ou "ios", "web"
            "device_name": "Samsung Galaxy S21"  // optionnel
        }
        """
        serializer = DeviceTokenSerializer(data=request.data, context={'request': request})
        serializer.is_valid(raise_exception=True)
        device_token = serializer.save()
        
        logger.info(f"✅ Token FCM enregistré: {request.user.email} - {device_token.platform}")
        
        return Response({
            'success': True,
            'message': 'Token enregistré avec succès',
            'device_token': DeviceTokenSerializer(device_token).data
        })
    
    @action(detail=False, methods=['POST'])
    def delete_token(self, request):
        """
        POST /api/v1/notifications/delete-token/
        
        Supprimer un token FCM (lors de la déconnexion).
        
        Body:
        {
            "token": "fcm_device_token_to_delete"
        }
        """
        token = request.data.get('token')
        
        if not token:
            return Response(
                {'error': 'Le champ token est requis'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        deleted_count = DeviceToken.objects.filter(
            user=request.user,
            token=token
        ).delete()[0]
        
        if deleted_count > 0:
            logger.info(f"✅ Token FCM supprimé: {request.user.email}")
            return Response({'success': True, 'message': 'Token supprimé'})
        else:
            return Response(
                {'error': 'Token introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
    
    @action(detail=False, methods=['GET'])
    def my_tokens(self, request):
        """
        GET /api/v1/notifications/my-tokens/
        
        Liste les tokens FCM de l'utilisateur connecté.
        """
        tokens = DeviceToken.objects.filter(user=request.user, is_active=True)
        serializer = DeviceTokenSerializer(tokens, many=True)
        
        return Response({
            'count': tokens.count(),
            'tokens': serializer.data
        })
    
    @action(detail=False, methods=['POST'], permission_classes=[IsAdmin])
    def send_to_user(self, request):
        """
        POST /api/v1/notifications/send-to-user/
        
        Envoyer une notification à un utilisateur spécifique (admin).
        
        Body:
        {
            "user_id": "uuid",
            "title": "Titre",
            "message": "Message",
            "notification_type": "general",
            "data": {"key": "value"}  // optionnel
        }
        """
        serializer = SendNotificationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        user_id = serializer.validated_data.get('user_id')
        title = serializer.validated_data['title']
        message = serializer.validated_data['message']
        notification_type = serializer.validated_data.get('notification_type', 'general')
        data = serializer.validated_data.get('data', {})
        
        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response(
                {'error': 'Utilisateur introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Créer la notification en base
        notification = Notification.objects.create(
            user=user,
            title=title,
            message=message,
            notification_type=notification_type
        )
        
        # Envoyer les push notifications
        tokens = DeviceToken.objects.filter(user=user, is_active=True)
        
        if tokens.exists():
            token_list = [t.token for t in tokens]
            result = FirebaseService.send_multicast(token_list, title, message, data)
            
            logger.info(
                f"📲 Notification envoyée à {user.email}: "
                f"{result['success_count']} succès, {result['failure_count']} échecs"
            )
        else:
            logger.warning(f"⚠️ Aucun token FCM pour {user.email}")
        
        return Response({
            'success': True,
            'notification': NotificationSerializer(notification).data,
            'push_sent': tokens.count()
        })
    
    @action(detail=False, methods=['POST'], permission_classes=[IsAdmin])
    def broadcast(self, request):
        """
        POST /api/v1/notifications/broadcast/
        
        Envoyer une notification à tous les utilisateurs ou un groupe (admin).
        
        Body:
        {
            "title": "Titre",
            "message": "Message",
            "user_type": "all",  // ou "merchant", "driver"
            "notification_type": "announcement",
            "data": {}  // optionnel
        }
        """
        serializer = BroadcastNotificationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        title = serializer.validated_data['title']
        message = serializer.validated_data['message']
        user_type = serializer.validated_data.get('user_type', 'all')
        notification_type = serializer.validated_data.get('notification_type', 'announcement')
        data = serializer.validated_data.get('data', {})
        
        # Filtrer les utilisateurs
        users_query = User.objects.filter(is_active=True)
        
        if user_type != 'all':
            users_query = users_query.filter(user_type=user_type)
        
        users = users_query.all()
        
        # Créer les notifications en base
        notifications = [
            Notification(
                user=user,
                title=title,
                message=message,
                notification_type=notification_type
            )
            for user in users
        ]
        Notification.objects.bulk_create(notifications)
        
        # Récupérer tous les tokens actifs
        tokens_query = DeviceToken.objects.filter(user__in=users, is_active=True)
        token_list = [t.token for t in tokens_query]
        
        # Envoyer les push notifications
        if token_list:
            result = FirebaseService.send_multicast(token_list, title, message, data)
            
            logger.info(
                f"📢 Broadcast envoyé à {len(users)} utilisateurs ({user_type}): "
                f"{result['success_count']} succès, {result['failure_count']} échecs"
            )
        else:
            result = {'success_count': 0, 'failure_count': 0}
        
        return Response({
            'success': True,
            'users_count': len(users),
            'tokens_count': len(token_list),
            'push_sent': result['success_count'],
            'push_failed': result['failure_count']
        })


class NotificationHistoryViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet pour l'historique des notifications (Phase 2).
    
    Endpoints:
    - GET /notification-history/ - Liste toutes les notifications
    - GET /notification-history/{id}/ - Détails d'une notification
    - POST /notification-history/{id}/mark_as_read/ - Marquer comme lue
    - POST /notification-history/mark_all_as_read/ - Marquer toutes comme lues
    - DELETE /notification-history/{id}/ - Supprimer une notification
    - GET /notification-history/unread_count/ - Nombre de non lues
    """
    
    serializer_class = NotificationHistorySerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        """Retourne seulement les notifications de l'utilisateur connecté"""
        # Protection Swagger: retourne un queryset vide si génération de doc
        if getattr(self, 'swagger_fake_view', False):
            return NotificationHistory.objects.none()
        return NotificationHistory.objects.filter(user=self.request.user)
    
    @action(detail=True, methods=['post'])
    def mark_as_read(self, request, pk=None):
        """
        Marque une notification comme lue.
        
        POST /notification-history/{id}/mark_as_read/
        """
        notification = self.get_object()
        notification.mark_as_read()
        
        serializer = self.get_serializer(notification)
        return Response(serializer.data)
    
    @action(detail=False, methods=['post'])
    def mark_all_as_read(self, request):
        """
        Marque toutes les notifications comme lues.
        
        POST /notification-history/mark_all_as_read/
        """
        count = NotificationHistory.objects.filter(
            user=request.user,
            is_read=False
        ).update(
            is_read=True,
            read_at=timezone.now()
        )
        
        return Response({
            'message': f'{count} notification(s) marquée(s) comme lue(s)',
            'count': count
        })
    
    @action(detail=False, methods=['get'])
    def unread_count(self, request):
        """
        Retourne le nombre de notifications non lues.
        
        GET /notification-history/unread_count/
        """
        count = NotificationHistory.get_unread_count(request.user)
        
        return Response({
            'unread_count': count
        })
    
    def destroy(self, request, *args, **kwargs):
        """
        Supprime une notification.
        
        DELETE /notification-history/{id}/
        """
        notification = self.get_object()
        notification.delete()
        
        return Response(
            {'message': 'Notification supprimée'},
            status=status.HTTP_204_NO_CONTENT
        )

