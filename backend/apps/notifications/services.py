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
    if not driver or not getattr(driver, 'user', None) or not getattr(driver.user, 'fcm_token', None):
        return False
    success = FirebaseService.send_notification(
        fcm_token=driver.user.fcm_token,
        title="🚚 Nouvelle livraison !",
        body=f"Livraison #{delivery.tracking_number} - {delivery.delivery_commune}",
        data={
            'type': 'new_delivery',
            'delivery_id': str(delivery.id),
            'tracking_number': delivery.tracking_number,
            'action': 'open_delivery_details',
        }
    )

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
    if not getattr(user, 'fcm_token', None):
        return False
    
    # Messages selon le statut
    status_messages = {
        'assigned': f"Livreur assigné à #{delivery.tracking_number}",
        'picked_up': f"Colis récupéré - #{delivery.tracking_number}",
        'in_transit': f"Colis en transit - #{delivery.tracking_number}",
        'delivered': f"✅ Livraison terminée - #{delivery.tracking_number}",
        'cancelled': f"❌ Livraison annulée - #{delivery.tracking_number}",
    }
    
    success = FirebaseService.send_notification(
        fcm_token=user.fcm_token,
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

    # Persist the notification in history for audit / debugging (do not re-send FCM here)
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
    if not getattr(merchant.user, 'fcm_token', None):
        return False

    driver_name = delivery.driver.user.full_name if delivery.driver and getattr(delivery.driver, 'user', None) else "Livreur"
    success = FirebaseService.send_notification(
        fcm_token=merchant.user.fcm_token,
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

    try:
        NotificationHistory.objects.create(
            user=merchant.user,
            notification_type='delivery_accepted',
            title='✅ Livreur trouvé !',
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
    if not getattr(merchant.user, 'fcm_token', None):
        return False
    success = FirebaseService.send_notification(
        fcm_token=merchant.user.fcm_token,
        title="⚠️ Livraison refusée",
        body=f"Le livreur a refusé #{delivery.tracking_number}. Recherche d'un autre...",
        data={
            'type': 'delivery_rejected',
            'delivery_id': str(delivery.id),
            'tracking_number': delivery.tracking_number,
            'action': 'open_delivery_details',
        }
    )

    try:
        NotificationHistory.objects.create(
            user=merchant.user,
            notification_type='delivery_rejected',
            title='⚠️ Livraison refusée',
            body=f"Le livreur a refusé #{delivery.tracking_number}. Recherche d'un autre...",
            data={'delivery_id': str(delivery.id), 'tracking_number': delivery.tracking_number},
            action='open_delivery_details',
            sent_via_fcm=bool(success)
        )
    except Exception:
        logger.exception('Failed to persist notification history for delivery rejected')

    return success
