from rest_framework import serializers
from .models import Delivery
from apps.merchants.serializers import MerchantSerializer
from apps.drivers.serializers import DriverSerializer

class DeliveryCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Delivery
        fields = ['pickup_address', 'pickup_address_details', 'pickup_commune', 'pickup_latitude', 'pickup_longitude', 'delivery_address', 'delivery_commune', 'delivery_quartier', 'delivery_latitude', 'delivery_longitude', 'package_description', 'package_weight_kg', 'package_length_cm', 'package_width_cm', 'package_height_cm', 'package_value', 'is_fragile', 'recipient_name', 'recipient_phone', 'recipient_alternative_phone', 'payment_method', 'cod_amount', 'scheduling_type', 'scheduled_pickup_time']

class DeliverySerializer(serializers.ModelSerializer):
    merchant = MerchantSerializer(read_only=True)
    driver = DriverSerializer(read_only=True)
    
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
            'pickup_latitude',
            'pickup_longitude',
            # Delivery
            'delivery_address',
            'delivery_commune',
            'delivery_quartier',
            'delivery_latitude',
            'delivery_longitude',
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
