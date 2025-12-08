from rest_framework import serializers
from .models import Delivery
from apps.merchants.serializers import MerchantSerializer
from apps.drivers.serializers import DriverSerializer
from apps.core.quartiers_data import get_quartier_coordinates

class DeliveryCreateSerializer(serializers.ModelSerializer):
    # Accept aliases from new clients: pickup_precision / delivery_precision
    pickup_precision = serializers.CharField(write_only=True, required=False, allow_blank=True)
    delivery_precision = serializers.CharField(write_only=True, required=False, allow_blank=True)

    class Meta:
        model = Delivery
        fields = ['pickup_address', 'pickup_address_details', 'pickup_commune', 'pickup_quartier', 'pickup_latitude', 'pickup_longitude', 'delivery_address', 'delivery_commune', 'delivery_quartier', 'delivery_latitude', 'delivery_longitude', 'package_description', 'package_weight_kg', 'package_length_cm', 'package_width_cm', 'package_height_cm', 'package_value', 'is_fragile', 'recipient_name', 'recipient_phone', 'recipient_alternative_phone', 'payment_method', 'cod_amount', 'scheduling_type', 'scheduled_pickup_time']
    
    def validate_pickup_commune(self, value):
        """Normaliser commune au format Title Case"""
        return value.title() if value else value
    
    def validate_delivery_commune(self, value):
        """Normaliser commune au format Title Case"""
        return value.title() if value else value

    def validate(self, attrs):
        # Map friendly alias keys to legacy model fields so both old and new clients work.
        if 'pickup_precision' in attrs and attrs.get('pickup_precision'):
            if not attrs.get('pickup_address_details'):
                attrs['pickup_address_details'] = attrs.get('pickup_precision')
            # remove alias to avoid confusion later
            attrs.pop('pickup_precision', None)
        if 'delivery_precision' in attrs and attrs.get('delivery_precision'):
            if not attrs.get('delivery_address'):
                attrs['delivery_address'] = attrs.get('delivery_precision')
            attrs.pop('delivery_precision', None)
        """
        Validation additionnelle : si un quartier n'a pas de coordonnées GPS connues
        et qu'aucune latitude/longitude n'est fournie, alors le champ de précision
        doit être obligatoire pour aider le livreur (pickup_address_details ou
        delivery_address selon le cas).
        """
        errors = {}

        # Vérifier pickup
        pickup_quartier = attrs.get('pickup_quartier')
        pickup_lat = attrs.get('pickup_latitude')
        pickup_lon = attrs.get('pickup_longitude')
        pickup_precision = attrs.get('pickup_address_details')
        pickup_commune = attrs.get('pickup_commune')

        if pickup_quartier:
            coords = None
            try:
                coords = get_quartier_coordinates(pickup_quartier, pickup_commune)
            except Exception:
                coords = None

            has_gps = bool(coords and coords.get('has_gps'))
            if not has_gps and (pickup_lat is None or pickup_lon is None):
                # require precision
                if not pickup_precision:
                    errors['pickup_address_details'] = ['Champ requis : précision de l\'adresse lorsqu\'il n\'y a pas de GPS pour le quartier.']

        # Vérifier delivery
        delivery_quartier = attrs.get('delivery_quartier')
        delivery_lat = attrs.get('delivery_latitude')
        delivery_lon = attrs.get('delivery_longitude')
        delivery_precision = attrs.get('delivery_address')
        delivery_commune = attrs.get('delivery_commune')

        if delivery_quartier:
            coords = None
            try:
                coords = get_quartier_coordinates(delivery_quartier, delivery_commune)
            except Exception:
                coords = None

            has_gps = bool(coords and coords.get('has_gps'))
            if not has_gps and (delivery_lat is None or delivery_lon is None):
                if not delivery_precision:
                    errors['delivery_address'] = ['Champ requis : précision de l\'adresse lorsqu\'il n\'y a pas de GPS pour le quartier.']

        if errors:
            raise serializers.ValidationError(errors)

        return attrs

class DeliverySerializer(serializers.ModelSerializer):
    merchant = MerchantSerializer(read_only=True)
    driver = DriverSerializer(read_only=True)
    pickup_precision = serializers.SerializerMethodField(read_only=True)
    delivery_precision = serializers.SerializerMethodField(read_only=True)
    
    class Meta:
        model = Delivery
        fields = [
            'id',
            'tracking_number',
            'merchant',
            'driver',
            'status',
            # Pickup
            'pickup_address',
            'pickup_address_details',
            'pickup_commune',
            'pickup_quartier',
            'pickup_latitude',
            'pickup_longitude',
            'pickup_precision',
            # Delivery
            'delivery_address',
            'delivery_commune',
            'delivery_quartier',
            'delivery_latitude',
            'delivery_longitude',
            'delivery_precision',
            # Package
            'package_description',
            'package_weight_kg',
            'package_length_cm',
            'package_width_cm',
            'package_height_cm',
            'package_value',
            'is_fragile',
            # Recipient
            'recipient_name',
            'recipient_phone',
            'recipient_alternative_phone',
            # Pricing
            'calculated_price',
            'actual_price',
            'distance_km',
            # Payment
            'payment_method',
            'cod_amount',
            'payment_status',
            # Scheduling
            'scheduling_type',
            'scheduled_pickup_time',
            # Timestamps
            'assigned_at',
            'picked_up_at',
            'delivered_at',
            'cancelled_at',
            'cancellation_reason',
            # Proof of delivery
            'signature_url',
            'photo_url',
            'delivery_notes',
            'delivery_confirmation_code',
            # Meta
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'id',
            'tracking_number',
            'status',
            'calculated_price',
            'assigned_at',
            'picked_up_at',
            'delivered_at',
            'cancelled_at',
            'signature_url',
            'photo_url',
            'delivery_confirmation_code',
            'created_at',
            'updated_at'
        ]

    def get_pickup_precision(self, obj):
        """Return the human-provided pickup precision (pickup_address_details) if present."""
        try:
            return obj.pickup_address_details or ''
        except Exception:
            return ''

    def get_delivery_precision(self, obj):
        """Return the human-provided delivery precision (delivery_address) if present."""
        try:
            return obj.delivery_address or ''
        except Exception:
            return ''
