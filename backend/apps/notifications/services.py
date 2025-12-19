# notifications/services.py

import logging
from typing import Optional
from .firebase_service import FirebaseService
from apps.notifications.models import NotificationHistory

logger = logging.getLogger(__name__)


# ============================================================================
# HELPERS POUR LES DIFFÉRENTS TYPES DE NOTIFICATIONS
# ============================================================================

def notify_new_delivery_assignment(driver, delivery):
    """Notifie un livreur d'une nouvelle livraison assignée"""
    if not driver or not getattr(driver, 'user', None):
        return False
    
    # Essayer d'envoyer la notification FCM si le token existe
    success = False
    fcm_token = getattr(driver.user, 'fcm_token', None)
    if fcm_token:
        success = FirebaseService.send_notification(
            fcm_token=fcm_token,
            title="🚚 Nouvelle livraison !",
            body=f"Livraison #{delivery.tracking_number} - {delivery.delivery_commune}",
            data={
                'type': 'new_delivery',
                'delivery_id': str(delivery.id),
                'tracking_number': delivery.tracking_number,
                'action': 'open_delivery_details',
            }
        )

    # Toujours persister la notification dans l'historique (même sans FCM)
    try:
        NotificationHistory.objects.create(
            user=driver.user,
            notification_type='new_delivery',
            title='Nouvelle livraison !',
            body=f"Livraison #{delivery.tracking_number} - {delivery.delivery_commune}",
            data={'delivery_id': str(delivery.id), 'tracking_number': delivery.tracking_number, 'action': 'open_delivery_details'},
            action='open_delivery_details',
            sent_via_fcm=bool(success)
        )
    except Exception:
        logger.exception('Failed to persist notification history for new delivery assignment')

    return success


def notify_delivery_status_change(user, delivery, new_status):
    """Notifie un changement de statut de livraison"""
    if not user:
        return False
    
    # Messages selon le statut
    status_messages = {
        'assigned': f"Livreur assigné à #{delivery.tracking_number}",
        'picked_up': f"Colis récupéré - #{delivery.tracking_number}",
        'in_transit': f"Colis en transit - #{delivery.tracking_number}",
        'delivered': f"✅ Livraison terminée - #{delivery.tracking_number}",
        'cancelled': f"❌ Livraison annulée - #{delivery.tracking_number}",
    }
    
    # Essayer d'envoyer la notification FCM si le token existe
    success = False
    fcm_token = getattr(user, 'fcm_token', None)
    if fcm_token:
        success = FirebaseService.send_notification(
            fcm_token=fcm_token,
            title="📦 Mise à jour livraison",
            body=status_messages.get(new_status, f"Statut modifié: {new_status}"),
            data={
                'type': 'delivery_status_change',
                'delivery_id': str(delivery.id),
                'tracking_number': delivery.tracking_number,
                'new_status': new_status,
                'action': 'open_delivery_details',
            }
        )

    # Toujours persister la notification dans l'historique (même sans FCM)
    try:
        NotificationHistory.objects.create(
            user=user,
            notification_type='delivery_status_change',
            title='Mise à jour livraison',
            body=status_messages.get(new_status, f"Statut modifié: {new_status}"),
            data={
                'delivery_id': str(delivery.id),
                'tracking_number': delivery.tracking_number,
                'new_status': new_status,
                'action': 'open_delivery_details',
            },
            action='open_delivery_details',
            sent_via_fcm=bool(success)
        )
    except Exception:
        logger.exception('Failed to persist notification history for delivery status change')

    return success


def notify_delivery_accepted(merchant, delivery):
    """Notifie le marchand qu'un livreur a accepté sa livraison"""
    if not merchant or not getattr(merchant, 'user', None):
        return False

    driver_name = delivery.driver.user.full_name if delivery.driver and getattr(delivery.driver, 'user', None) else "Livreur"
    
    # Essayer d'envoyer la notification FCM si le token existe
    success = False
    fcm_token = getattr(merchant.user, 'fcm_token', None)
    if fcm_token:
        success = FirebaseService.send_notification(
            fcm_token=fcm_token,
            title="✅ Livreur trouvé !",
            body=f"{driver_name} a accepté la livraison #{delivery.tracking_number}",
            data={
                'type': 'delivery_accepted',
                'delivery_id': str(delivery.id),
                'tracking_number': delivery.tracking_number,
                'driver_id': str(delivery.driver.id) if delivery.driver else None,
                'action': 'open_delivery_details',
            }
        )

    # Toujours persister la notification dans l'historique
    try:
        NotificationHistory.objects.create(
            user=merchant.user,
            notification_type='delivery_accepted',
            title='Livreur trouvé !',
            body=f"{driver_name} a accepté la livraison #{delivery.tracking_number}",
            data={'delivery_id': str(delivery.id), 'tracking_number': delivery.tracking_number, 'driver_id': str(delivery.driver.id) if delivery.driver else None},
            action='open_delivery_details',
            sent_via_fcm=bool(success)
        )
    except Exception:
        logger.exception('Failed to persist notification history for delivery accepted')

    return success


def notify_delivery_rejected(merchant, delivery):
    """Notifie le marchand qu'un livreur a refusé sa livraison"""
    if not merchant or not getattr(merchant, 'user', None):
        return False
    
    # Essayer d'envoyer la notification FCM si le token existe
    success = False
    fcm_token = getattr(merchant.user, 'fcm_token', None)
    if fcm_token:
        success = FirebaseService.send_notification(
            fcm_token=fcm_token,
            title="⚠️ Livraison refusée",
            body=f"Le livreur a refusé #{delivery.tracking_number}. Recherche d'un autre...",
            data={
                'type': 'delivery_rejected',
                'delivery_id': str(delivery.id),
                'tracking_number': delivery.tracking_number,
                'action': 'open_delivery_details',
            }
        )

    # Toujours persister la notification dans l'historique
    try:
        NotificationHistory.objects.create(
            user=merchant.user,
            notification_type='delivery_rejected',
            title='Livraison refusée',
            body=f"Le livreur a refusé #{delivery.tracking_number}. Recherche d'un autre...",
            data={'delivery_id': str(delivery.id), 'tracking_number': delivery.tracking_number},
            action='open_delivery_details',
            sent_via_fcm=bool(success)
        )
    except Exception:
        logger.exception('Failed to persist notification history for delivery rejected')

    return success


def notify_delivery_pin(user, delivery, pin_code):
    """
    Envoie le code PIN de confirmation par notification push.
    Appelé quand le livreur confirme le pickup (récupération du colis).
    
    Args:
        user: L'utilisateur destinataire (marchand ou particulier)
        delivery: L'objet Delivery
        pin_code: Le code PIN à 4 chiffres
    
    Returns:
        bool: True si la notification a été envoyée avec succès
    """
    if not user:
        logger.warning("notify_delivery_pin: no user provided")
        return False
    
    if not pin_code:
        logger.warning(f"notify_delivery_pin: no PIN code for delivery {delivery.id}")
        return False
    
    # Essayer d'envoyer la notification FCM si le token existe
    success = False
    fcm_token = getattr(user, 'fcm_token', None)
    if fcm_token:
        success = FirebaseService.send_notification(
            fcm_token=fcm_token,
            title="📦 Livraison en cours !",
            body=f"Votre code PIN : {pin_code}\nDonnez ce code au livreur à la réception.",
            data={
                'type': 'delivery_pin',
                'delivery_id': str(delivery.id),
                'tracking_number': delivery.tracking_number,
                'pin_code': str(pin_code),
                'action': 'show_pin',
            }
        )
    else:
        logger.warning(f"notify_delivery_pin: no FCM token for user {user.email}")
    
    # Toujours enregistrer dans l'historique (même sans FCM)
    try:
        NotificationHistory.objects.create(
            user=user,
            notification_type='delivery_pin',
            title='Livraison en cours !',
            body=f"Votre code PIN : {pin_code}",
            data={
                'delivery_id': str(delivery.id),
                'tracking_number': delivery.tracking_number,
                'action': 'show_pin',
            },
            action='show_pin',
            sent_via_fcm=bool(success)
        )
    except Exception:
        logger.exception('Failed to persist notification history for delivery PIN')
    
    if success:
        logger.info(f"📲 PIN {pin_code} envoyé par notification push à {user.email} pour livraison {delivery.tracking_number}")
    else:
        logger.warning(f"❌ Échec envoi PIN par notification push à {user.email}")
    
    return success


def notify_rating_received(driver, delivery, rating_value):
    """
    Notifie un livreur qu'il a reçu une notation.
    
    Args:
        driver: L'objet Driver
        delivery: L'objet Delivery
        rating_value: La note reçue (1-5)
    
    Returns:
        bool: True si la notification a été envoyée avec succès
    """
    if not driver or not getattr(driver, 'user', None):
        return False
    
    user = driver.user
    
    # Déterminer le message selon la note
    if rating_value >= 4.5:
        body = f"Excellent ! Vous avez reçu {rating_value}⭐ pour #{delivery.tracking_number}"
    elif rating_value >= 3.5:
        body = f"Bien ! Vous avez reçu {rating_value}⭐ pour #{delivery.tracking_number}"
    else:
        body = f"Vous avez reçu {rating_value}⭐ pour #{delivery.tracking_number}"
    
    # Essayer d'envoyer la notification FCM si le token existe
    success = False
    fcm_token = getattr(user, 'fcm_token', None)
    if fcm_token:
        success = FirebaseService.send_notification(
            fcm_token=fcm_token,
            title="⭐ Nouvelle notation !",
            body=body,
            data={
                'type': 'rating_received',
                'delivery_id': str(delivery.id),
                'tracking_number': delivery.tracking_number,
                'rating': str(rating_value),
                'action': 'view_ratings',
            }
        )
    
    # Toujours persister dans l'historique
    try:
        NotificationHistory.objects.create(
            user=user,
            notification_type='rating_received',
            title='Nouvelle notation !',
            body=body,
            data={
                'delivery_id': str(delivery.id),
                'tracking_number': delivery.tracking_number,
                'rating': str(rating_value),
            },
            action='view_ratings',
            sent_via_fcm=bool(success)
        )
    except Exception:
        logger.exception('Failed to persist notification history for rating received')
    
    return success
