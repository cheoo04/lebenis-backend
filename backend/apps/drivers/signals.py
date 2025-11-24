# backend/apps/drivers/signals.py
from django.db.models.signals import post_save
from django.dispatch import receiver
from apps.authentication.models import User
from .models import Driver


@receiver(post_save, sender=User)
def create_driver_profile(sender, instance, created, **kwargs):
    """
    Signal pour créer automatiquement un profil Driver 
    lorsqu'un utilisateur avec user_type='driver' est créé.
    """
    if created and instance.user_type == 'driver':
        import logging
        logger = logging.getLogger('django')
        try:
            Driver.objects.create(
                user=instance,
                vehicle_type='moto',  # Valeur par défaut
                vehicle_capacity_kg=50.00,
                verification_status='pending',  # En attente de vérification
                is_available=False,
                availability_status='offline'
            )
            logger.info(f"[SIGNAL] Profil Driver créé automatiquement pour {instance.email} (user_id={instance.id})")
        except Exception as e:
            logger.error(f"[SIGNAL] Erreur création profil Driver pour {instance.email} (user_id={instance.id}): {e}")
