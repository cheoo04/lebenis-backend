from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Delivery
from .email_service import send_delivery_pin_email
import logging

logger = logging.getLogger(__name__)

@receiver(post_save, sender=Delivery)
def ensure_pin_and_send_email(sender, instance, created, **kwargs):
    # Always ensure a PIN is set
    if not instance.delivery_confirmation_code:
        instance.delivery_confirmation_code = instance.generate_confirmation_code()
        instance.save(update_fields=["delivery_confirmation_code"])
    
    # Send email ONLY on creation (not on updates)
    if created:
        try:
            send_delivery_pin_email(instance.delivery_confirmation_code, "yahmardocheek@gmail.com", instance)
            logger.info(f"✅ Email de confirmation envoyé pour la livraison {instance.tracking_number}")
        except Exception as e:
            # Log l'erreur mais ne bloque pas la création de la livraison
            logger.error(f"❌ Erreur envoi email pour {instance.tracking_number}: {e}")
            # L'erreur est ignorée, la livraison est créée quand même
