# backend/apps/merchants/signals.py
from django.db.models.signals import post_save
from django.dispatch import receiver
from apps.authentication.models import User
from .models import Merchant


@receiver(post_save, sender=User)
def create_merchant_profile(sender, instance, created, **kwargs):
    """
    Signal pour créer automatiquement un profil Merchant 
    lorsqu'un utilisateur avec user_type='merchant' est créé.
    """
    if created and instance.user_type == 'merchant':
        import logging
        logger = logging.getLogger('django')
        try:
            Merchant.objects.create(
                user=instance,
                business_name='',  # Sera mis à jour via le serializer
                business_type='',
                verification_status='pending',
            )
            logger.info(f"[SIGNAL] Profil Merchant créé automatiquement pour {instance.email} (user_id={instance.id})")
        except Exception as e:
            logger.error(f"[SIGNAL] Erreur création profil Merchant pour {instance.email} (user_id={instance.id}): {e}")
