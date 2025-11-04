from rest_framework import serializers
from .models import Driver, DriverZone
from apps.authentication.serializers import UserSerializer

class DriverZoneSerializer(serializers.ModelSerializer):
    class Meta:
        model = DriverZone
        fields = ['id', 'commune', 'priority']

class DriverSerializer(serializers.ModelSerializer):
    zones = DriverZoneSerializer(many=True, read_only=True)
    user = UserSerializer(read_only=True)
    phone = serializers.CharField(source='user.phone', read_only=True)
    profile_photo = serializers.CharField(source='user.profile_photo', read_only=True)

    class Meta:
        model = Driver
        fields = [
            'id',
            'user',
            'phone',
            'driver_license',
            'license_expiry',
            'vehicle_type',
            'vehicle_registration',
            'vehicle_capacity_kg',
            'verification_status',
            'is_available',
            'availability_status',
            'current_latitude',
            'current_longitude',
            'rating',
            'total_deliveries',
            'successful_deliveries',
            'zones',
            'profile_photo',
            'created_at',
            'updated_at'
        ]
        read_only_fields = [
            'id',
            'verification_status',
            'rating',
            'total_deliveries',
            'successful_deliveries',
            'created_at',
            'updated_at'
        ]
