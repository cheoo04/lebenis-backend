# pricing/serializers.py
from rest_framework import serializers
from .models import PricingZone, ZonePricingMatrix
from apps.drivers.models import Driver, DriverZone


class PricingZoneSerializer(serializers.ModelSerializer):
    """Serializer pour les zones tarifaires"""
    selected = serializers.SerializerMethodField(default=False)

    class Meta:
        model = PricingZone
        fields = ['id', 'zone_name', 'commune', 'quartier', 'description', 'is_active', 'selected']

    def get_selected(self, obj):
        request = self.context.get('request')
        if not request or not request.user or not request.user.is_authenticated:
            return False
        driver = getattr(request.user, 'driver_profile', None)
        if not driver:
            return False
        return DriverZone.objects.filter(driver=driver, commune=obj.commune).exists()


class ZonePricingMatrixSerializer(serializers.ModelSerializer):
    """Serializer pour la matrice tarifaire"""
    origin_zone_name = serializers.CharField(source='origin_zone.zone_name', read_only=True)
    destination_zone_name = serializers.CharField(source='destination_zone.zone_name', read_only=True)

    class Meta:
        model = ZonePricingMatrix
        fields = ['id', 'origin_zone', 'origin_zone_name', 'destination_zone', 'destination_zone_name', 'base_rate', 'per_kg_rate', 'per_km_rate', 'max_weight_included', 'effective_from', 'effective_to', 'is_active']


# ============================================================================
# NOUVEAU : SERIALIZER POUR LE CALCUL DE PRIX
# ============================================================================

class CalculatePriceSerializer(serializers.Serializer):
    """
    Serializer pour valider les données d'entrée pour le calcul de prix.
    
    Utilisé par Swagger pour générer le formulaire d'input.
    Les champs optionnels permettent à l'utilisateur de spécifier ou non.
    """
    
    # CHAMPS OBLIGATOIRES
    pickup_commune = serializers.CharField(
        max_length=100,
        required=True,
        help_text="Commune de départ (ex: 'Cocody')"
    )
    
    delivery_commune = serializers.CharField(
        max_length=100,
        required=True,
        help_text="Commune de destination (ex: 'Plateau')"
    )
    
    package_weight_kg = serializers.DecimalField(
        max_digits=5,
        decimal_places=2,
        required=True,
        coerce_to_string=False,
        help_text="Poids du colis en kg"
    )
    
    # CHAMPS OPTIONNELS (pour poids volumétrique)
    package_length_cm = serializers.DecimalField(
        max_digits=5,
        decimal_places=2,
        required=False,
        allow_null=True,
        coerce_to_string=False,
        help_text="Longueur du colis en cm (optionnel)"
    )
    
    package_width_cm = serializers.DecimalField(
        max_digits=5,
        decimal_places=2,
        required=False,
        allow_null=True,
        coerce_to_string=False,
        help_text="Largeur du colis en cm (optionnel)"
    )
    
    package_height_cm = serializers.DecimalField(
        max_digits=5,
        decimal_places=2,
        required=False,
        allow_null=True,
        coerce_to_string=False,
        help_text="Hauteur du colis en cm (optionnel)"
    )
    
    # CHAMP OPTIONNEL (colis fragile)
    is_fragile = serializers.BooleanField(
        required=False,
        default=False,
        help_text="Le colis est-il fragile? (défaut: false)"
    )
    
    # CHAMP OPTIONNEL (type de livraison)
    scheduling_type = serializers.ChoiceField(
        choices=['immediate', 'scheduled'],
        required=False,
        default='immediate',
        help_text="Type de livraison: 'immediate' ou 'scheduled'"
    )
    
    # CHAMPS OPTIONNELS (pour distance réelle)
    pickup_latitude = serializers.DecimalField(
        max_digits=10,
        decimal_places=8,
        required=False,
        allow_null=True,
        coerce_to_string=False,
        help_text="Latitude du point d'enlèvement (optionnel)"
    )
    
    pickup_longitude = serializers.DecimalField(
        max_digits=11,
        decimal_places=8,
        required=False,
        allow_null=True,
        coerce_to_string=False,
        help_text="Longitude du point d'enlèvement (optionnel)"
    )
    
    delivery_latitude = serializers.DecimalField(
        max_digits=10,
        decimal_places=8,
        required=False,
        allow_null=True,
        coerce_to_string=False,
        help_text="Latitude du point de livraison (optionnel)"
    )
    
    delivery_longitude = serializers.DecimalField(
        max_digits=11,
        decimal_places=8,
        required=False,
        allow_null=True,
        coerce_to_string=False,
        help_text="Longitude du point de livraison (optionnel)"
    )
    
    def validate(self, data):
        """
        Validation personnalisée des données.
        Vous pouvez ajouter des vérifications métier ici.
        """
        # Exemple : Vérifier que les communes ne sont pas identiques
        if data['pickup_commune'].lower() == data['delivery_commune'].lower():
            raise serializers.ValidationError(
                "La commune de départ ne peut pas être identique à celle d'arrivée"
            )
        
        # Vérifier que le poids est positif
        if data['package_weight_kg'] <= 0:
            raise serializers.ValidationError(
                "Le poids doit être positif"
            )
        
        return data
