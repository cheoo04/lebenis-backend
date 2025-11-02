from rest_framework import serializers
from .models import Delivery
from apps.merchants.serializers import MerchantSerializer
from apps.drivers.serializers import DriverSerializer

class DeliveryCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Delivery
        fields = ['pickup_address', 'delivery_address', 'delivery_commune', 'delivery_quartier', 'package_description', 'package_weight_kg', 'is_fragile', 'recipient_name', 'recipient_phone', 'recipient_alternative_phone', 'payment_method', 'cod_amount', 'scheduling_type', 'scheduled_pickup_time']

class DeliverySerializer(serializers.ModelSerializer):
    merchant = MerchantSerializer(read_only=True)
    driver = DriverSerializer(read_only=True)
    
    class Meta:
        model = Delivery
        fields = [
            'id', 'tracking_number', 'merchant', 'driver', 'status',
            'payment_method', 'calculated_price', 'actual_price', 
            'assigned_at', 'picked_up_at', 'delivered_at', 'package_description',
            'package_weight_kg', 'is_fragile', 'recipient_name', 'recipient_phone',
            'recipient_alternative_phone', 'signature_url', 'photo_url',
            'delivery_confirmation_code', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'tracking_number', 'status', 'calculated_price', 'assigned_at', 'picked_up_at', 'delivered_at', 'signature_url', 'photo_url', 'delivery_confirmation_code', 'created_at', 'updated_at']
