from rest_framework import serializers
from .models import ChatRoom, ChatMessage
from apps.authentication.models import User


class ChatParticipantSerializer(serializers.ModelSerializer):
    """Serializer pour les participants d'un chat"""
    
    class Meta:
        model = User
        fields = ['id', 'full_name', 'phone', 'user_type']


class ChatRoomListSerializer(serializers.ModelSerializer):
    """Serializer pour la liste des conversations"""
    
    driver_info = ChatParticipantSerializer(source='driver', read_only=True)
    other_user_info = ChatParticipantSerializer(source='other_user', read_only=True)
    delivery_tracking_number = serializers.CharField(
        source='delivery.tracking_number',
        read_only=True,
        allow_null=True
    )
    unread_count = serializers.SerializerMethodField()
    
    class Meta:
        model = ChatRoom
        fields = [
            'id', 'room_type', 'driver_info', 'other_user_info',
            'delivery', 'delivery_tracking_number', 'firebase_path',
            'last_message_text', 'last_message_at', 'last_message_sender_id',
            'unread_count', 'is_active', 'is_archived',
            'created_at', 'updated_at'
        ]
    
    def get_unread_count(self, obj):
        """Retourne le nombre de messages non lus pour l'utilisateur actuel"""
        request = self.context.get('request')
        if not request or not request.user:
            return 0
        
        user_id = str(request.user.id)
        if user_id == str(obj.driver_id):
            return obj.driver_unread_count
        else:
            return obj.other_user_unread_count


class ChatRoomDetailSerializer(serializers.ModelSerializer):
    """Serializer détaillé pour une conversation"""
    
    driver_info = ChatParticipantSerializer(source='driver', read_only=True)
    other_user_info = ChatParticipantSerializer(source='other_user', read_only=True)
    delivery_info = serializers.SerializerMethodField()
    unread_count = serializers.SerializerMethodField()
    
    class Meta:
        model = ChatRoom
        fields = [
            'id', 'room_type', 'driver_info', 'other_user_info',
            'delivery', 'delivery_info', 'firebase_path',
            'last_message_text', 'last_message_at', 'last_message_sender_id',
            'driver_unread_count', 'other_user_unread_count', 'unread_count',
            'is_active', 'is_archived', 'created_at', 'updated_at'
        ]
    
    def get_delivery_info(self, obj):
        if obj.delivery:
            return {
                'id': str(obj.delivery.id),
                'tracking_number': obj.delivery.tracking_number,
                'status': obj.delivery.status,
                'pickup_address': obj.delivery.pickup_address,
                'delivery_address': obj.delivery.delivery_address,
            }
        return None
    
    def get_unread_count(self, obj):
        """Retourne le nombre de messages non lus pour l'utilisateur actuel"""
        request = self.context.get('request')
        if not request or not request.user:
            return 0
        
        user_id = str(request.user.id)
        if user_id == str(obj.driver_id):
            return obj.driver_unread_count
        else:
            return obj.other_user_unread_count


class CreateChatRoomSerializer(serializers.Serializer):
    """Serializer pour créer une nouvelle conversation"""
    
    other_user_id = serializers.UUIDField(required=True)
    # Accept either a UUID string, null, or an empty string from clients.
    # We'll normalize to `None` or a UUID string in `validate_delivery_id`.
    delivery_id = serializers.CharField(required=False, allow_null=True, allow_blank=True)
    room_type = serializers.ChoiceField(
        choices=['delivery', 'support'],
        default='delivery'
    )
    initial_message = serializers.CharField(
        required=False,
        allow_blank=True,
        max_length=1000
    )

    def validate_delivery_id(self, value):
        """Normalize delivery_id: accept None/empty string, or a valid UUID string.

        Returns None when the client sends null/empty, otherwise the canonical
        UUID string. Returns None (instead of raising error) for invalid UUID format
        to be more lenient with mobile clients.
        """
        import logging
        logger = logging.getLogger('apps.chat.serializers')
        
        if value is None or (isinstance(value, str) and value.strip() == ''):
            return None
        
        # Si la valeur est "null" ou "undefined" (string), traiter comme None
        if isinstance(value, str) and value.strip().lower() in ('null', 'undefined', 'none'):
            return None

        # If it's already a UUID instance (unlikely), cast to str
        try:
            import uuid
            # uuid.UUID will raise ValueError for invalid formats
            return str(uuid.UUID(str(value)))
        except Exception:
            # Log the invalid value for debugging
            logger.warning(f'Invalid delivery_id received, treating as None: {value!r}')
            # Return None instead of raising error - be lenient
            return None


class ChatMessageSerializer(serializers.ModelSerializer):
    """Serializer pour les messages (backup DB)"""
    
    sender_info = ChatParticipantSerializer(source='sender', read_only=True)
    
    class Meta:
        model = ChatMessage
        fields = [
            'id', 'chat_room', 'sender', 'sender_info',
            'message_type', 'text', 'image_url',
            'latitude', 'longitude',
            'is_read', 'read_at', 'is_synced_to_firebase',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'sender', 'created_at', 'updated_at']


class SendMessageSerializer(serializers.Serializer):
    """Serializer pour envoyer un message"""
    
    chat_room_id = serializers.UUIDField(required=True)
    message_type = serializers.ChoiceField(
        choices=['text', 'image', 'location'],
        default='text'
    )
    text = serializers.CharField(required=False, allow_blank=True, max_length=5000)
    image_url = serializers.URLField(required=False, allow_blank=True)
    latitude = serializers.DecimalField(
        required=False,
        max_digits=10,
        decimal_places=8,
        allow_null=True
    )
    longitude = serializers.DecimalField(
        required=False,
        max_digits=11,
        decimal_places=8,
        allow_null=True
    )
    
    def validate(self, data):
        """Valider que le contenu correspond au type"""
        message_type = data.get('message_type')
        
        if message_type == 'text' and not data.get('text'):
            raise serializers.ValidationError("Le texte est requis pour un message texte")
        
        if message_type == 'image' and not data.get('image_url'):
            raise serializers.ValidationError("L'URL de l'image est requise")
        
        if message_type == 'location':
            if not data.get('latitude') or not data.get('longitude'):
                raise serializers.ValidationError(
                    "Les coordonnées GPS sont requises pour un message de localisation"
                )
        
        return data


class MarkAsReadSerializer(serializers.Serializer):
    """Serializer pour marquer des messages comme lus"""
    
    message_ids = serializers.ListField(
        child=serializers.UUIDField(),
        required=False,
        allow_empty=True
    )
    chat_room_id = serializers.UUIDField(required=False, allow_null=True)
