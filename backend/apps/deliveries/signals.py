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
    if not instance.get_coords('pickup'):
        # Essayer d'abord avec l'adresse complète si disponible
        if instance.pickup_address:
            pickup_full_address = f"{instance.pickup_address.street_address}, {instance.pickup_commune}"
            coords = location_service.geocode_address(pickup_full_address)
            if coords:
                instance.pickup_latitude, instance.pickup_longitude = coords
                logger.info(f"✅ Adresse pickup géocodée: {pickup_full_address}")
        
        # Si pas de résultat, utiliser les coordonnées par défaut de la commune
        if not instance.get_coords('pickup') and instance.pickup_commune:
            zone = PricingZone.objects.filter(
                commune__iexact=instance.pickup_commune,
                default_latitude__isnull=False
            ).first()
            if zone:
                instance.pickup_latitude = zone.default_latitude
                instance.pickup_longitude = zone.default_longitude
                logger.info(f"✅ Coordonnées par défaut utilisées pour pickup: {instance.pickup_commune}")
    
    # 2. Géocodage de l'adresse de livraison (delivery)
    if not instance.get_coords('delivery'):
        # Essayer avec l'adresse complète
        delivery_full_address = f"{instance.delivery_address}, {instance.delivery_commune}"
        coords = location_service.geocode_address(delivery_full_address)
        if coords:
            instance.delivery_latitude, instance.delivery_longitude = coords
            logger.info(f"✅ Adresse delivery géocodée: {delivery_full_address}")
        
        # Si pas de résultat, utiliser les coordonnées par défaut de la commune
        if not instance.get_coords('delivery') and instance.delivery_commune:
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
    
    # Envoyer le PIN par email SEULEMENT lors du confirm_pickup (status passe à 'in_progress')
    # et non plus à la création. Cela permet au marchand de recevoir le PIN au bon moment
    # (quand le livreur a récupéré le colis et que la livraison est en cours).
    # L'envoi lors du confirm_pickup est géré dans views.py -> confirm_pickup()
    # Ce signal ne fait plus d'envoi d'email à la création.
    
    # Note: Le PIN est toujours généré à la création pour être disponible,
    # mais l'email n'est envoyé qu'au moment du pickup pour une meilleure UX.

