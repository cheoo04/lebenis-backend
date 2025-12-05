# apps/merchants/utils.py

import logging
from apps.notifications.firebase_service import FirebaseService
from apps.notifications.models import Notification

logger = logging.getLogger(__name__)


def send_merchant_notification(user, title, body, notification_type, data=None):
    """
    Envoie une notification push et sauvegarde dans la DB.
    
    Args:
        user: Instance User du merchant
        title: Titre de la notification
        body: Corps de la notification
        notification_type: Type (merchant_approved, merchant_rejected, etc.)
        data: Données supplémentaires pour la notification push
    
    Returns:
        bool: True si succès, False sinon
    """
    try:
        # 1. Sauvegarder la notification dans la DB
        notification = Notification.objects.create(
            user=user,
            notification_type=notification_type,
            title=title,
            message=body,
            related_entity_type='merchant',
            related_entity_id=user.merchant_profile.id if hasattr(user, 'merchant_profile') else None,
        )
        logger.info(f"✅ Notification créée en DB: {notification.id}")
        
        # 2. Envoyer notification push si le user a un FCM token
        if user.fcm_token:
            success = FirebaseService.send_notification(
                fcm_token=user.fcm_token,
                title=title,
                body=body,
                data=data or {}
            )
            if success:
                logger.info(f"✅ Push notification envoyée à {user.email}")
            else:
                logger.warning(f"⚠️ Échec envoi push à {user.email}")
            return success
        else:
            logger.info(f"ℹ️ Pas de FCM token pour {user.email}, notification sauvegardée uniquement")
            return True  # Succès quand même car sauvegardé en DB
            
    except Exception as e:
        logger.error(f"❌ Erreur envoi notification: {str(e)}")
        return False


def notify_merchant_approved(merchant):
    """
    Notifie le merchant que son compte a été approuvé.
    
    Args:
        merchant: Instance Merchant
    
    Returns:
        bool: True si succès
    """
    return send_merchant_notification(
        user=merchant.user,
        title="✅ Compte approuvé !",
        body=f"Félicitations ! Votre compte {merchant.business_name} a été approuvé. Vous pouvez maintenant créer des livraisons.",
        notification_type="merchant_approved",
        data={
            'type': 'merchant_approved',
            'merchant_id': str(merchant.id),
            'action': 'open_dashboard',
        }
    )


def notify_merchant_rejected(merchant, rejection_reason):
    """
    Notifie le merchant que son compte a été rejeté.
    
    Args:
        merchant: Instance Merchant
        rejection_reason: Raison du rejet
    
    Returns:
        bool: True si succès
    """
    return send_merchant_notification(
        user=merchant.user,
        title="❌ Compte rejeté",
        body=f"Votre demande a été rejetée. Raison: {rejection_reason}",
        notification_type="merchant_rejected",
        data={
            'type': 'merchant_rejected',
            'merchant_id': str(merchant.id),
            'rejection_reason': rejection_reason,
            'action': 'open_rejected_screen',
        }
    )


def notify_merchant_documents_received(merchant):
    """
    Notifie le merchant que ses documents ont bien été reçus.
    
    Args:
        merchant: Instance Merchant
    
    Returns:
        bool: True si succès
    """
    return send_merchant_notification(
        user=merchant.user,
        title="📄 Documents reçus",
        body="Nous avons bien reçu vos documents. Notre équipe les examine actuellement.",
        notification_type="merchant_documents_received",
        data={
            'type': 'merchant_documents_received',
            'merchant_id': str(merchant.id),
            'action': 'open_profile',
        }
    )


def notify_merchant_invoice_paid(merchant, invoice):
    """
    Notifie le merchant qu'une facture a été payée.
    
    Args:
        merchant: Instance Merchant
        invoice: Instance Invoice
    
    Returns:
        bool: True si succès
    """
    return send_merchant_notification(
        user=merchant.user,
        title="💰 Facture payée",
        body=f"Votre facture {invoice.invoice_number} de {invoice.total_amount} FCFA a été payée avec succès.",
        notification_type="merchant_invoice_paid",
        data={
            'type': 'merchant_invoice_paid',
            'merchant_id': str(merchant.id),
            'invoice_id': str(invoice.id),
            'action': 'open_invoice_details',
        }
    )


def notify_merchant_new_delivery_assigned(merchant, delivery):
    """
    Notifie le merchant qu'un driver a accepté sa livraison.
    
    Args:
        merchant: Instance Merchant
        delivery: Instance Delivery
    
    Returns:
        bool: True si succès
    """
    driver_name = delivery.driver.user.get_full_name() if delivery.driver else "Un livreur"
    
    return send_merchant_notification(
        user=merchant.user,
        title="🚚 Livraison assignée",
        body=f"{driver_name} a accepté votre livraison #{delivery.tracking_number}",
        notification_type="merchant_delivery_assigned",
        data={
            'type': 'merchant_delivery_assigned',
            'merchant_id': str(merchant.id),
            'delivery_id': str(delivery.id),
            'tracking_number': delivery.tracking_number,
            'action': 'open_delivery_details',
        }
    )
