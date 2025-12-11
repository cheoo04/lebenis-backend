# pricing/calculator.py

from decimal import Decimal
from datetime import datetime
from django.db import models
from .models import PricingZone, ZonePricingMatrix
from django.core.exceptions import ValidationError
from apps.core.location_service import LocationService
import unicodedata
import logging
import json

logger = logging.getLogger(__name__)

# ⚠️ IMPORTANT: Vous aviez une mauvaise import
# from backend.apps.drivers import models
# Changé pour:
# from django.db import models


def normalize_commune_name(name):
    """
    Normalise un nom de commune pour la recherche case-insensitive et sans accents.
    Exemples:
    - "PORT-BOUET" -> "port-bouet"
    - "Port-Bouët" -> "port-bouet"
    - "COCODY" -> "cocody"
    """
    # Supprimer les accents
    nfkd_form = unicodedata.normalize('NFKD', name)
    text_without_accents = ''.join([c for c in nfkd_form if not unicodedata.combining(c)])
    # Convertir en minuscules et supprimer les espaces extras
    return text_without_accents.lower().strip()


class PricingCalculator:
    """
    Service de calcul de prix pour les livraisons.
    Gère les surcharges, les zones tarifaires et les calculs complexes.
    """
    
    # Surcharges configurables (peuvent être modifiées selon vos besoins)
    SURCHARGES = {
        'immediate_delivery': Decimal('1.5'),    # +50% pour livraison immédiate
        'night_delivery': Decimal('2.0'),        # +100% pour livraison de nuit
        'weekend_delivery': Decimal('1.3'),      # +30% pour livraison weekend
        'fragile_items': Decimal('500'),         # +500 CFA fixe pour colis fragile
    }
    
    def __init__(self):
        """Initialisation du calculatrice"""
        pass
    
    def get_zone_from_commune(self, commune):
        """
        Récupère la zone tarifaire depuis le nom de la commune.
        Normalise le nom pour ignorer les accents et la casse.
        
        Args:
            commune (str): Nom de la commune (ex: "Cocody", "PORT-BOUET", "Port-Bouët")
            
        Returns:
            PricingZone: Zone trouvée
            
        Raises:
            ValidationError: Si la commune n'existe pas
        """
        try:
            # Cherche la zone avec insensibilité à la casse ET aux accents
            normalized_input = normalize_commune_name(commune)
            
            # Récupérer toutes les communes et chercher par normalisation
            all_zones = PricingZone.objects.filter(is_active=True)
            zone = None
            
            for z in all_zones:
                if normalize_commune_name(z.commune) == normalized_input:
                    zone = z
                    break
            
            if not zone:
                # REFUSE la commune invalide
                available_communes = sorted(set(
                    PricingZone.objects.filter(is_active=True).values_list('commune', flat=True)
                ))
                
                communes_list = ', '.join(available_communes)
                
                raise ValidationError(
                    f"Commune '{commune}' n'existe pas. "
                    f"Communes disponibles: {communes_list}"
                )
            
            return zone
        
        except PricingZone.DoesNotExist:
            raise ValidationError(f"Commune '{commune}' introuvable")
        except ValidationError:
            raise
        except Exception as e:
            raise ValidationError(f"Erreur lors de la recherche de zone: {str(e)}")
    
    def get_zone_from_quartier(self, quartier, commune):
        """
        Récupère la zone tarifaire en utilisant d'abord le quartier, avec fallback sur la commune.
        
        Args:
            quartier (str): Nom du quartier (optionnel)
            commune (str): Nom de la commune (obligatoire)
            
        Returns:
            PricingZone: Zone trouvée (soit le quartier spécifique, soit la commune)
        """
        try:
            # Si quartier est fourni, chercher d'abord avec quartier + commune
            if quartier and quartier.strip():
                normalized_quartier = normalize_commune_name(quartier)
                normalized_commune = normalize_commune_name(commune)
                
                # Chercher une zone avec ce quartier ET cette commune
                all_zones = PricingZone.objects.filter(is_active=True)
                for z in all_zones:
                    if (z.quartier and normalize_commune_name(z.commune) == normalized_commune and 
                        normalize_commune_name(z.quartier) == normalized_quartier):
                        return z
            
            # Fallback: utiliser la commune
            return self.get_zone_from_commune(commune)
        
        except ValidationError:
            raise
        except Exception as e:
            # En cas d'erreur, fallback sur la commune
            return self.get_zone_from_commune(commune)
    
    def get_pricing_matrix(self, origin_zone, destination_zone):
        """
        Récupère la matrice tarifaire pour deux zones.
        Vérifie que les dates sont valides (effective_from <= today <= effective_to).
        
        Args:
            origin_zone (PricingZone): Zone de départ
            destination_zone (PricingZone): Zone d'arrivée
            
        Returns:
            ZonePricingMatrix: Matrice tarifaire trouvée ou tarif par défaut
        """
        today = datetime.now().date()
        
        # Cherche la matrice tarifaire valide
        pricing = ZonePricingMatrix.objects.filter(
            origin_zone=origin_zone,
            destination_zone=destination_zone,
            is_active=True,
            effective_from__lte=today  # Date d'effet <= aujourd'hui
        ).filter(
            # effective_to >= aujourd'hui OU effective_to = NULL (pas de fin)
            models.Q(effective_to__gte=today) | models.Q(effective_to__isnull=True)
        ).first()
        
        if not pricing:
            # Retourne un tarif par défaut si aucune matrice trouvée
            return self.get_default_pricing()
        
        return pricing
    
    def get_default_pricing(self):
        """
        Retourne une tarification par défaut quand aucune matrice tarifaire existe.
        
        Returns:
            DefaultPricing: Objet avec les tarifs par défaut
        """
        class DefaultPricing:
            """Classe simple pour retourner les tarifs par défaut"""
            base_rate = Decimal('2000')           # Tarif de base : 2000 CFA
            per_kg_rate = Decimal('200')          # 200 CFA par kg supplémentaire
            per_km_rate = Decimal('100')          # 100 CFA par km
            max_weight_included = Decimal('5.0')  # 5 kg inclus dans le tarif de base
        
        return DefaultPricing()
    
    def calculate_weight_surcharge(self, weight_kg, max_included, per_kg_rate):
        """
        Calcule la surcharge pour le poids supplémentaire.
        Formule: (poids_réel - poids_inclus) × tarif_par_kg
        
        Args:
            weight_kg (Decimal): Poids réel du colis en kg
            max_included (Decimal): Poids inclus dans le tarif de base
            per_kg_rate (Decimal): Tarif par kg supplémentaire
            
        Returns:
            Decimal: Surcharge de poids (0 si poids <= max_included)
        """
        if weight_kg <= max_included:
            return Decimal('0')
        
        extra_weight = weight_kg - max_included
        return extra_weight * per_kg_rate
    
    def calculate_volumetric_weight(self, length_cm, width_cm, height_cm):
        """
        Calcule le poids volumétrique.
        Formule standard: (L × W × H) / 5000
        Utile pour les colis volumineux mais légers.
        
        Args:
            length_cm (Decimal): Longueur en cm
            width_cm (Decimal): Largeur en cm
            height_cm (Decimal): Hauteur en cm
            
        Returns:
            Decimal: Poids volumétrique en kg (0 si dimensions manquantes)
        """
        # Vérifie que toutes les dimensions sont fournies
        if not all([length_cm, width_cm, height_cm]):
            return Decimal('0')
        
        # Convertit en Decimal si nécessaire
        length_cm = Decimal(str(length_cm)) if length_cm else Decimal('0')
        width_cm = Decimal(str(width_cm)) if width_cm else Decimal('0')
        height_cm = Decimal(str(height_cm)) if height_cm else Decimal('0')
        
        # Formule : (L x W x H) / 5000
        volumetric = (length_cm * width_cm * height_cm) / Decimal('5000')
        
        return volumetric
    
    def calculate_distance(self, origin_coords, destination_coords):
        """
        Calcule la distance entre deux points GPS (latitude, longitude).
        Utilise LocationService avec OpenRouteService ou fallback haversine.
        
        Args:
            origin_coords (tuple): (latitude, longitude) du départ
            destination_coords (tuple): (latitude, longitude) de l'arrivée
            
        Returns:
            Decimal: Distance en km (par défaut 10 km si coords manquantes)
        """
        # Vérifie que les deux coordonnées sont fournies
        if not all([origin_coords, destination_coords]):
            logger.debug("calculate_distance: coords missing, using default 10km", extra={
                'origin_coords': origin_coords,
                'destination_coords': destination_coords
            })
            return Decimal('10')  # Distance par défaut

        try:
            # Utilise le nouveau LocationService
            origin_lat, origin_lon = origin_coords
            dest_lat, dest_lon = destination_coords

            distance_km = LocationService.get_distance(
                origin_lat, origin_lon,
                dest_lat, dest_lon,
                use_api=True  # Utilise OpenRouteService si clé API disponible
            )

            logger.debug("calculate_distance: computed", extra={
                'origin_coords': origin_coords,
                'destination_coords': destination_coords,
                'distance_km': distance_km
            })

            return Decimal(str(distance_km))

        except Exception as e:
            # Log the exception with context for troubleshooting and return default distance
            try:
                logger.exception("calculate_distance failed: using default 10km", extra={
                    'origin_coords': origin_coords,
                    'destination_coords': destination_coords
                })
            except Exception:
                # Some logging handlers may not accept 'extra' keys; fall back to simple log
                logger.exception("calculate_distance failed: using default 10km")
            return Decimal('10')
    
    def calculate_price(self, delivery_data):
        """
        Calcule le prix TOTAL d'une livraison.
        Prend en compte : zones (quartiers avec fallback communes), poids, volume, distance, surcharges contextuelles.
        
        Args:
            delivery_data (dict): Dictionnaire avec les données de livraison :
                - pickup_commune: str (commune de départ, ex: "Cocody")
                - pickup_quartier: str (quartier optionnel pour plus de précision)
                - delivery_commune: str (commune d'arrivée, ex: "Plateau")
                - delivery_quartier: str (quartier optionnel pour plus de précision)
                - package_weight_kg: Decimal ou float
                - package_length_cm: Decimal ou float (optionnel)
                - package_width_cm: Decimal ou float (optionnel)
                - package_height_cm: Decimal ou float (optionnel)
                - is_fragile: bool
                - scheduling_type: str ('immediate' ou 'scheduled')
                - scheduled_pickup_time: datetime (optionnel, pour nuit/weekend)
                - pickup_coords: tuple (lat, lng) (optionnel, pour distance réelle)
                - delivery_coords: tuple (lat, lng) (optionnel, pour distance réelle)
        
        Returns:
            dict: Détail complet du calcul avec :
                - total_price: prix final
                - breakdown: détail des surcharges
                - details: infos sur la livraison
        """
        
        # ═══════════════════════════════════════════════════════════════════
        # ÉTAPE 1 : Identifier les zones tarifaires (quartiers avec fallback communes)
        # ═══════════════════════════════════════════════════════════════════
        
        # Valider les communes obligatoires
        pickup_commune = delivery_data.get('pickup_commune')
        delivery_commune = delivery_data.get('delivery_commune')
        
        if not pickup_commune or (isinstance(pickup_commune, str) and not pickup_commune.strip()):
            raise ValidationError("pickup_commune est obligatoire")
        if not delivery_commune or (isinstance(delivery_commune, str) and not delivery_commune.strip()):
            raise ValidationError("delivery_commune est obligatoire")
        
        # Récupérer les quartiers optionnels pour plus de précision
        pickup_quartier = delivery_data.get('pickup_quartier')
        delivery_quartier = delivery_data.get('delivery_quartier')
        
        # Utiliser les quartiers avec fallback sur communes
        origin_zone = self.get_zone_from_quartier(pickup_quartier, str(pickup_commune))
        destination_zone = self.get_zone_from_quartier(delivery_quartier, str(delivery_commune))
        
        # ═══════════════════════════════════════════════════════════════════
        # ÉTAPE 2 : Récupérer la matrice tarifaire
        # ═══════════════════════════════════════════════════════════════════
        
        pricing = self.get_pricing_matrix(origin_zone, destination_zone)
        
        # ═══════════════════════════════════════════════════════════════════
        # ÉTAPE 3 : Tarif de base
        # ═══════════════════════════════════════════════════════════════════
        
        base_rate = Decimal(str(pricing.base_rate))
        
        # ═══════════════════════════════════════════════════════════════════
        # ÉTAPE 4 : Surcharge de poids
        # ═══════════════════════════════════════════════════════════════════
        
        weight_kg = Decimal(str(delivery_data['package_weight_kg']))
        
        weight_surcharge = self.calculate_weight_surcharge(
            weight_kg,
            Decimal(str(pricing.max_weight_included)),
            Decimal(str(pricing.per_kg_rate))
        )
        
        # ═══════════════════════════════════════════════════════════════════
        # ÉTAPE 5 : Surcharge volumétrique
        # ═══════════════════════════════════════════════════════════════════
        
        volumetric_weight = self.calculate_volumetric_weight(
            delivery_data.get('package_length_cm'),
            delivery_data.get('package_width_cm'),
            delivery_data.get('package_height_cm')
        )
        
        # Utiliser le poids le plus élevé (réel ou volumétrique)
        billable_weight = max(weight_kg, volumetric_weight)
        
        volume_surcharge = Decimal('0')
        if billable_weight > weight_kg:
            extra = billable_weight - weight_kg
            volume_surcharge = extra * Decimal(str(pricing.per_kg_rate))
        
        # ═══════════════════════════════════════════════════════════════════
        # ÉTAPE 6 : Surcharge de distance
        # ═══════════════════════════════════════════════════════════════════
        
        # Prefer explicit coords passed by client; otherwise try zone centroids (quartier -> commune)
        pickup_coords = delivery_data.get('pickup_coords')
        delivery_coords = delivery_data.get('delivery_coords')

        try:
            if not pickup_coords:
                if origin_zone and getattr(origin_zone, 'default_latitude', None) is not None and getattr(origin_zone, 'default_longitude', None) is not None:
                    pickup_coords = (float(origin_zone.default_latitude), float(origin_zone.default_longitude))
                    logger.debug("Using origin zone coords for pricing", extra={'pickup_coords': pickup_coords, 'origin_zone_id': getattr(origin_zone, 'id', None)})

            if not delivery_coords:
                if destination_zone and getattr(destination_zone, 'default_latitude', None) is not None and getattr(destination_zone, 'default_longitude', None) is not None:
                    delivery_coords = (float(destination_zone.default_latitude), float(destination_zone.default_longitude))
                    logger.debug("Using destination zone coords for pricing", extra={'delivery_coords': delivery_coords, 'destination_zone_id': getattr(destination_zone, 'id', None)})

        except Exception:
            logger.exception("Erreur en récupérant les coordonnées depuis les zones; fallback maintenu")

        # Déterminer la source des coordonnées (client, zone, fallback)
        provided_pickup = True if delivery_data.get('pickup_coords') else False
        provided_delivery = True if delivery_data.get('delivery_coords') else False

        try:
            if provided_pickup:
                pickup_source = 'client'
            elif pickup_coords:
                pickup_source = 'zone'
            else:
                pickup_source = 'fallback'

            if provided_delivery:
                delivery_source = 'client'
            elif delivery_coords:
                delivery_source = 'zone'
            else:
                delivery_source = 'fallback'
        except Exception:
            pickup_source = 'unknown'
            delivery_source = 'unknown'

        # Log chosen coord sources and coords before computing distance
        try:
            logger.info(
                "calculate_price: computing distance",
                extra={
                    'pickup_source': pickup_source,
                    'delivery_source': delivery_source,
                    'pickup_coords': pickup_coords,
                    'delivery_coords': delivery_coords,
                    'origin_zone_id': getattr(origin_zone, 'id', None),
                    'destination_zone_id': getattr(destination_zone, 'id', None),
                }
            )
        except Exception:
            # Some logging handlers may not accept extra; fallback to simple log
            logger.info("calculate_price: computing distance pickup_source=%s delivery_source=%s pickup_coords=%s delivery_coords=%s", pickup_source, delivery_source, pickup_coords, delivery_coords)

        # Enfin, calculer la distance (LocationService gère le fallback haversine ou valeur par défaut)
        try:
            distance_km = self.calculate_distance(pickup_coords, delivery_coords)
        except Exception:
            # calculate_distance already logs exceptions; ensure a fallback value
            distance_km = Decimal('10')

        logger.info("calculate_price: distance result", extra={'distance_km': float(distance_km)})

        distance_surcharge = distance_km * Decimal(str(pricing.per_km_rate))
        
        # ═══════════════════════════════════════════════════════════════════
        # ÉTAPE 7 : Calcul du sous-total
        # ═══════════════════════════════════════════════════════════════════
        
        subtotal = base_rate + weight_surcharge + volume_surcharge + distance_surcharge
        
        # ═══════════════════════════════════════════════════════════════════
        # ÉTAPE 8 : Surcharges contextuelles (multiplicateurs)
        # ═══════════════════════════════════════════════════════════════════
        
        multiplier = Decimal('1.0')
        surcharge_details = []
        
        # Livraison immédiate : +50%
        if delivery_data.get('scheduling_type') == 'immediate':
            multiplier *= self.SURCHARGES['immediate_delivery']
            surcharge_details.append('Livraison immédiate +50%')
        
        # Livraison de nuit (20h - 6h) : +100%
        scheduled_time = delivery_data.get('scheduled_pickup_time')
        if scheduled_time and (scheduled_time.hour >= 20 or scheduled_time.hour < 6):
            multiplier *= self.SURCHARGES['night_delivery']
            surcharge_details.append('Livraison de nuit +100%')
        
        # Weekend (samedi/dimanche) : +30%
        if scheduled_time and scheduled_time.weekday() >= 5:  # 5=Samedi, 6=Dimanche
            multiplier *= self.SURCHARGES['weekend_delivery']
            surcharge_details.append('Livraison weekend +30%')
        
        # ═══════════════════════════════════════════════════════════════════
        # ÉTAPE 9 : Surcharge pour colis fragile
        # ═══════════════════════════════════════════════════════════════════
        
        fragile_charge = Decimal('0')
        if delivery_data.get('is_fragile'):
            fragile_charge = self.SURCHARGES['fragile_items']
            surcharge_details.append('Colis fragile +500 CFA')
        
        # ═══════════════════════════════════════════════════════════════════
        # ÉTAPE 10 : Calcul final
        # ═══════════════════════════════════════════════════════════════════
        
        total_price = (subtotal * multiplier) + fragile_charge
        
        # ═══════════════════════════════════════════════════════════════════
        # ÉTAPE 11 : Arrondir au multiple de 50 CFA le plus proche
        # ═══════════════════════════════════════════════════════════════════
        # Exemple : 2345 CFA → 2350 CFA ; 2340 CFA → 2350 CFA
        
        total_price = (total_price / 50).quantize(Decimal('1')) * 50
        
        # ═══════════════════════════════════════════════════════════════════
        # ÉTAPE 12 : Retourner le détail complet
        # ═══════════════════════════════════════════════════════════════════
        
        return {
            'total_price': float(total_price),
            'breakdown': {
                'base_rate': float(base_rate),
                'weight_surcharge': float(weight_surcharge),
                'volume_surcharge': float(volume_surcharge),
                'distance_surcharge': float(distance_surcharge),
                'subtotal': float(subtotal),
                'multiplier': float(multiplier),
                'fragile_charge': float(fragile_charge),
                'surcharge_details': surcharge_details,
            },
            'details': {
                'origin_zone': origin_zone.zone_name,
                'destination_zone': destination_zone.zone_name,
                'distance_km': float(distance_km),
                'billable_weight_kg': float(billable_weight),
                'used_coords_source': {
                    'pickup': pickup_source,
                    'delivery': delivery_source
                },
                'used_coords': {
                    'pickup': list(pickup_coords) if pickup_coords else None,
                    'delivery': list(delivery_coords) if delivery_coords else None
                }
            }
        }
