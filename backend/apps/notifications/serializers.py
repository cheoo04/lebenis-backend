from rest_framework import serializers
from .models import Notification, DeviceToken


class NotificationSerializer(serializers.ModelSerializer):
    """Serializer pour les notifications"""
    user_email = serializers.EmailField(source='user.email', read_only=True)

    class Meta:
        model = Notification
        fields = [
            'id', 'user', 'user_email', 'notification_type', 'title', 'message',
            'related_entity_type', 'related_entity_id',
            'is_read', 'sent_at', 'read_at'
        ]
        read_only_fields = ['id', 'user', 'sent_at', 'read_at']


class DeviceTokenSerializer(serializers.ModelSerializer):
    """Serializer pour enregistrer/gérer les tokens FCM"""
    
    class Meta:
        model = DeviceToken
        fields = [
            'id', 'token', 'platform', 'device_name',
            'is_active', 'created_at', 'last_used_at'
        ]
        read_only_fields = ['id', 'is_active', 'created_at', 'last_used_at']
    
    def create(self, validated_data):
        """Crée ou met à jour le token pour l'utilisateur"""
        user = self.context['request'].user
        token = validated_data['token']
        
        # Vérifier si le token existe déjà
        device_token, created = DeviceToken.objects.update_or_create(
            token=token,
            defaults={
                'user': user,
                'platform': validated_data.get('platform', 'android'),
                'device_name': validated_data.get('device_name', ''),
                'is_active': True
            }
        )
        
        return device_token


class SendNotificationSerializer(serializers.Serializer):
    """Serializer pour envoyer une notification à un utilisateur"""
    
    user_id = serializers.UUIDField(required=False)
    title = serializers.CharField(max_length=255)
    message = serializers.CharField()
    notification_type = serializers.CharField(max_length=50, default='general')
    data = serializers.JSONField(required=False, default=dict)


class BroadcastNotificationSerializer(serializers.Serializer):
    """Serializer pour envoyer une notification à tous les utilisateurs"""
    
    title = serializers.CharField(max_length=255)
    message = serializers.CharField()
    notification_type = serializers.CharField(max_length=50, default='general')
    user_type = serializers.ChoiceField(
        choices=['all', 'merchant', 'driver'],
        default='all'
    )
    data = serializers.JSONField(required=False, default=dict)

