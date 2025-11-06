"""
Service pour envoyer des notifications push lors de nouveaux messages de chat
"""
import logging
from typing import TYPE_CHECKING
from django.contrib.auth import get_user_model
from apps.notifications.models import DeviceToken
from firebase_admin import messaging
import firebase_admin

if TYPE_CHECKING:
    from django.contrib.auth.models import AbstractUser
    User = AbstractUser
else:
    User = get_user_model()

logger = logging.getLogger(__name__)


class ChatPushNotificationService:
    """
    Service centralisé pour envoyer des notifications push de chat
    """
    
    @staticmethod
    def send_new_message_notification(
        recipient_user: User,
        sender_name: str,
        message_text: str,
        chat_room_id: str,
        message_id: str
    ) -> bool:
        """
        Envoie une notification push pour un nouveau message de chat
        
        Args:
            recipient_user: Utilisateur destinataire
            sender_name: Nom de l'expéditeur
            message_text: Texte du message (tronqué si trop long)
            chat_room_id: ID de la conversation
            message_id: ID du message
            
        Returns:
            bool: True si au moins une notification envoyée avec succès
        """
        # Récupérer tous les tokens actifs de l'utilisateur
        device_tokens = DeviceToken.objects.filter(
            user=recipient_user,
            is_active=True
        )
        
        if not device_tokens.exists():
            logger.warning(f"⚠️ Aucun token FCM pour {recipient_user.email}")
            return False
        
        # Tronquer le message si trop long
        display_message = message_text[:100] + '...' if len(message_text) > 100 else message_text
        
        # Préparer les données de notification
        notification_data = {
            'type': 'new_chat_message',
            'chat_room_id': str(chat_room_id),
            'message_id': str(message_id),
            'sender_name': sender_name,
        }
        
        success_count = 0
        
        for device_token in device_tokens:
            try:
                # Créer le message Firebase
                message = messaging.Message(
                    notification=messaging.Notification(
                        title=f'💬 {sender_name}',
                        body=display_message,
                    ),
                    data=notification_data,
                    token=device_token.token,
                    android=messaging.AndroidConfig(
                        priority='high',
                        notification=messaging.AndroidNotification(
                            icon='ic_notification',
                            color='#2196F3',
                            sound='default',
                            channel_id='chat_messages',
                        ),
                    ),
                    apns=messaging.APNSConfig(
                        payload=messaging.APNSPayload(
                            aps=messaging.Aps(
                                alert=messaging.ApsAlert(
                                    title=f'💬 {sender_name}',
                                    body=display_message,
                                ),
                                badge=1,
                                sound='default',
                            ),
                        ),
                    ),
                )
                
                # Envoyer
                response = messaging.send(message)
                logger.info(f"✅ Notification envoyée à {recipient_user.email}: {response}")
                success_count += 1
                
                # Mettre à jour last_used_at
                device_token.mark_as_used()
                
            except messaging.UnregisteredError:
                logger.warning(f"⚠️ Token invalide/désabonné: {device_token.token[:20]}...")
                device_token.deactivate()
                
            except Exception as e:
                logger.error(f"❌ Erreur envoi notification: {e}")
        
        return success_count > 0
    
    @staticmethod
    def send_typing_notification(
        recipient_user: User,
        sender_name: str,
        chat_room_id: str
    ) -> bool:
        """
        Envoie une notification silencieuse pour indiquer que quelqu'un écrit
        (notification data-only, pas d'affichage visible)
        
        Args:
            recipient_user: Utilisateur destinataire
            sender_name: Nom de l'expéditeur
            chat_room_id: ID de la conversation
            
        Returns:
            bool: True si envoyé avec succès
        """
        device_tokens = DeviceToken.objects.filter(
            user=recipient_user,
            is_active=True
        )
        
        if not device_tokens.exists():
            return False
        
        notification_data = {
            'type': 'typing_indicator',
            'chat_room_id': str(chat_room_id),
            'sender_name': sender_name,
            'is_typing': 'true',
        }
        
        success_count = 0
        
        for device_token in device_tokens:
            try:
                # Message silencieux (data-only)
                message = messaging.Message(
                    data=notification_data,
                    token=device_token.token,
                    android=messaging.AndroidConfig(
                        priority='high',
                    ),
                    apns=messaging.APNSConfig(
                        headers={
                            'apns-priority': '10',
                        },
                        payload=messaging.APNSPayload(
                            aps=messaging.Aps(
                                content_available=True,
                            ),
                        ),
                    ),
                )
                
                messaging.send(message)
                success_count += 1
                
            except Exception as e:
                logger.error(f"❌ Erreur envoi typing notification: {e}")
        
        return success_count > 0
