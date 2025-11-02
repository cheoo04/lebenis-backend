from rest_framework import serializers
from .models import Driver, DriverZone

class DriverZoneSerializer(serializers.ModelSerializer):
    class Meta:
        model = DriverZone
        fields = ['id', 'commune', 'priority']

class DriverSerializer(serializers.ModelSerializer):
    zones = DriverZoneSerializer(many=True, read_only=True)
    user_email = serializers.EmailField(source='user.email', read_only=True)
    user_full_name = serializers.SerializerMethodField()

    class Meta:
        model = Driver
        fields = ['id', 'user', 'user_email', 'user_full_name', 'driver_license', 'license_expiry', 'vehicle_type', 'vehicle_registration', 'vehicle_capacity_kg', 'verification_status', 'is_available', 'rating', 'total_deliveries', 'successful_deliveries', 'zones', 'created_at', 'updated_at']
        read_only_fields = ['id', 'verification_status', 'rating', 'total_deliveries', 'successful_deliveries', 'created_at', 'updated_at']

    def get_user_full_name(self, obj):
        return f"{obj.user.first_name} {obj.user.last_name}"
