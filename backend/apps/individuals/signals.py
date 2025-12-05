from django.db.models.signals import post_save
from django.dispatch import receiver
from apps.authentication.models import User
from .models import Individual
import logging

logger = logging.getLogger(__name__)


@receiver(post_save, sender=User)
def create_individual_profile(sender, instance, created, **kwargs):
    """
    Signal qui crée automatiquement un profil Individual
    quand un utilisateur de type 'individual' est créé.
    """
    if created and instance.user_type == 'individual':
        Individual.objects.create(user=instance)
        logger.info(f"✅ Profil Individual créé pour {instance.email}")
