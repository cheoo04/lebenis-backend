from django.db.models.signals import post_save, pre_save
from django.dispatch import receiver
from .models import Delivery
from .email_service import send_delivery_pin_email
from apps.core.location_service import LocationService
from apps.pricing.models import PricingZone
import logging
import unicodedata

logger = logging.getLogger(__name__)


def normalize_commune(text):
    """Normalise le nom de commune: minuscule, sans accents"""
    if not text:
        return ''
    text = text.lower().strip()
    text = unicodedata.normalize('NFD', text)
    text = ''.join(c for c in text if unicodedata.category(c) != 'Mn')
    return text


# Coordonnées par défaut des communes d'Abidjan
ABIDJAN_COMMUNES_COORDS = {
    'abobo': (5.4167, -4.0167),
    'adjame': (5.3667, -4.0333),
    'anyama': (5.4833, -4.0500),
    'attecoube': (5.3333, -4.0333),
    'bingerville': (5.3500, -3.8833),
    'cocody': (5.3599, -3.9833),
    'koumassi': (5.2833, -3.9500),
    'marcory': (5.3000, -3.9833),
    'plateau': (5.3167, -4.0167),
    'port-bouet': (5.2500, -3.9333),
    'treichville': (5.2833, -4.0000),
    'yopougon': (5.3500, -4.0833),
    'songon': (5.3167, -4.2500),
    'grand-bassam': (5.2167, -3.7333),
    'assinie': (5.1500, -3.4667),
}


@receiver(pre_save, sender=Delivery)
def auto_geocode_and_calculate_distance(sender, instance, **kwargs):
    """
    Signal pré-sauvegarde pour :
    1. Géocoder automatiquement les adresses si les coordonnées GPS sont manquantes
    2. Calculer automatiquement la distance entre pickup et delivery
    """
    from decimal import Decimal
    location_service = LocationService()
    
    # 1. Géocodage de l'adresse de récupération (pickup)
    if not instance.get_coords('pickup') and instance.pickup_commune:
        commune_norm = normalize_commune(instance.pickup_commune)
        coords_found = False
        
        # Essayer d'abord avec l'adresse complète si disponible
        if instance.pickup_address:
            pickup_full_address = f"{instance.pickup_address}, {instance.pickup_commune}"
            coords = location_service.geocode_address(pickup_full_address)
            if coords:
                instance.pickup_latitude, instance.pickup_longitude = coords
                coords_found = True
                logger.info(f"✅ Adresse pickup géocodée: {pickup_full_address}")
        
        # Si pas de résultat, chercher dans les zones avec normalisation
        if not coords_found:
            for zone in PricingZone.objects.filter(default_latitude__isnull=False):
                if normalize_commune(zone.commune) == commune_norm:
                    instance.pickup_latitude = zone.default_latitude
                    instance.pickup_longitude = zone.default_longitude
                    coords_found = True
                    logger.info(f"✅ Coordonnées zone utilisées pour pickup: {instance.pickup_commune}")
                    break
        
        # Fallback: coordonnées hardcodées d'Abidjan
        if not coords_found and commune_norm in ABIDJAN_COMMUNES_COORDS:
            lat, lng = ABIDJAN_COMMUNES_COORDS[commune_norm]
            instance.pickup_latitude = Decimal(str(lat))
            instance.pickup_longitude = Decimal(str(lng))
            logger.info(f"✅ Coordonnées fallback utilisées pour pickup: {instance.pickup_commune}")
    
    # 2. Géocodage de l'adresse de livraison (delivery)
    if not instance.get_coords('delivery') and instance.delivery_commune:
        commune_norm = normalize_commune(instance.delivery_commune)
        coords_found = False
        
        # Essayer avec l'adresse complète
        delivery_full_address = f"{instance.delivery_address}, {instance.delivery_commune}"
        coords = location_service.geocode_address(delivery_full_address)
        if coords:
            instance.delivery_latitude, instance.delivery_longitude = coords
            coords_found = True
            logger.info(f"✅ Adresse delivery géocodée: {delivery_full_address}")
        
        # Si pas de résultat, chercher dans les zones avec normalisation
        if not coords_found:
            for zone in PricingZone.objects.filter(default_latitude__isnull=False):
                if normalize_commune(zone.commune) == commune_norm:
                    instance.delivery_latitude = zone.default_latitude
                    instance.delivery_longitude = zone.default_longitude
                    coords_found = True
                    logger.info(f"✅ Coordonnées zone utilisées pour delivery: {instance.delivery_commune}")
                    break
        
        # Fallback: coordonnées hardcodées d'Abidjan
        if not coords_found and commune_norm in ABIDJAN_COMMUNES_COORDS:
            lat, lng = ABIDJAN_COMMUNES_COORDS[commune_norm]
            instance.delivery_latitude = Decimal(str(lat))
            instance.delivery_longitude = Decimal(str(lng))
            logger.info(f"✅ Coordonnées fallback utilisées pour delivery: {instance.delivery_commune}")




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

