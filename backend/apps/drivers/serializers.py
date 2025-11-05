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
            # Identity Information
            'identity_card_number',
            'identity_card_front',
            'identity_card_back',
            'date_of_birth',
            # Vehicle Documents
            'vehicle_insurance',
            'vehicle_insurance_expiry',
            'vehicle_technical_inspection',
            'vehicle_inspection_expiry',
            'vehicle_gray_card',
            # Banking Information
            'bank_account_name',
            'bank_account_number',
            'bank_name',
            'mobile_money_number',
            'mobile_money_provider',
            # Emergency Contact
            'emergency_contact_name',
            'emergency_contact_phone',
            'emergency_contact_relationship',
            # Professional Information
            'years_of_experience',
            'previous_employer',
            'languages_spoken',
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
