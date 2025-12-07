from django.db.models.signals import post_save, pre_save
from django.dispatch import receiver
from .models import Delivery
from .email_service import send_delivery_pin_email
from apps.core.location_service import LocationService
from apps.pricing.models import PricingZone
import logging

logger = logging.getLogger(__name__)


@receiver(pre_save, sender=Delivery)
def auto_geocode_and_calculate_distance(sender, instance, **kwargs):
    """
    Signal pré-sauvegarde pour :
    1. Géocoder automatiquement les adresses si les coordonnées GPS sont manquantes
    2. Calculer automatiquement la distance entre pickup et delivery
    """
    location_service = LocationService()
    needs_save = False
    
    # 1. Géocodage de l'adresse de récupération (pickup)
    if not instance.pickup_latitude or not instance.pickup_longitude:
        # Essayer d'abord avec l'adresse complète si disponible
        if instance.pickup_address:
            pickup_full_address = f"{instance.pickup_address.street_address}, {instance.pickup_commune}"
            coords = location_service.geocode_address(pickup_full_address)
            if coords:
                instance.pickup_latitude, instance.pickup_longitude = coords
                logger.info(f"✅ Adresse pickup géocodée: {pickup_full_address}")
        
        # Si pas de résultat, utiliser les coordonnées par défaut de la commune
        if not instance.pickup_latitude and instance.pickup_commune:
            zone = PricingZone.objects.filter(
                commune__iexact=instance.pickup_commune,
                default_latitude__isnull=False
            ).first()
            if zone:
                instance.pickup_latitude = zone.default_latitude
                instance.pickup_longitude = zone.default_longitude
                logger.info(f"✅ Coordonnées par défaut utilisées pour pickup: {instance.pickup_commune}")
    
    # 2. Géocodage de l'adresse de livraison (delivery)
    if not instance.delivery_latitude or not instance.delivery_longitude:
        # Essayer avec l'adresse complète
        delivery_full_address = f"{instance.delivery_address}, {instance.delivery_commune}"
        coords = location_service.geocode_address(delivery_full_address)
        if coords:
            instance.delivery_latitude, instance.delivery_longitude = coords
            logger.info(f"✅ Adresse delivery géocodée: {delivery_full_address}")
        
        # Si pas de résultat, utiliser les coordonnées par défaut de la commune
        if not instance.delivery_latitude and instance.delivery_commune:
            zone = PricingZone.objects.filter(
                commune__iexact=instance.delivery_commune,
                default_latitude__isnull=False
            ).first()
            if zone:
                instance.delivery_latitude = zone.default_latitude
                instance.delivery_longitude = zone.default_longitude
                logger.info(f"✅ Coordonnées par défaut utilisées pour delivery: {instance.delivery_commune}")


@receiver(post_save, sender=Delivery)
def ensure_pin_and_send_email(sender, instance, created, **kwargs):
    # Always ensure a PIN is set
    if not instance.delivery_confirmation_code:
        instance.delivery_confirmation_code = instance.generate_confirmation_code()
        instance.save(update_fields=["delivery_confirmation_code"])
    
    # Send email ONLY on creation (not on updates)
    if created:
        try:
            # Récupérer l'email du destinataire
            recipient_email = None
            
            # 1. Si c'est un merchant, utiliser l'email du merchant
            if instance.merchant:
                recipient_email = instance.merchant.user.email
            
            # 2. Si c'est un particulier, utiliser l'email du créateur
            elif instance.created_by:
                recipient_email = instance.created_by.email
            
            # 3. Fallback (ne devrait pas arriver ici)
            if not recipient_email:
                logger.warning(f"⚠️ Aucun email trouvé pour la livraison {instance.tracking_number}")
                return
            
            send_delivery_pin_email(instance.delivery_confirmation_code, recipient_email, instance)
            logger.info(f"✅ Email de confirmation envoyé à {recipient_email} pour la livraison {instance.tracking_number}")
        except Exception as e:
            # Log l'erreur mais ne bloque pas la création de la livraison
            logger.error(f"❌ Erreur envoi email pour {instance.tracking_number}: {e}")
            # L'erreur est ignorée, la livraison est créée quand même
