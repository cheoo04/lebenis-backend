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
    profile_photo = serializers.CharField(
        source='user.profile_photo',
        required=False,
        allow_blank=True,
        allow_null=True
    )
    def update(self, instance, validated_data):
        """
        Permet de mettre à jour le Driver ET l'User (pour profile_photo)
        Accepte profile_photo à la racine OU dans user.
        """
        # Accepte profile_photo à la racine OU dans user
        profile_photo = None
        # 1. Si envoyé à la racine
        if 'profile_photo' in validated_data:
            profile_photo = validated_data.pop('profile_photo')
        # 2. Si envoyé dans user
        user_data = validated_data.pop('user', None)
        if user_data and 'profile_photo' in user_data:
            profile_photo = user_data.get('profile_photo')

        # Mise à jour du Driver (véhicule, etc.)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()

        # Mise à jour du User (profile_photo)
        if profile_photo is not None:
            instance.user.profile_photo = profile_photo
            instance.user.save()

        return instance

    def to_representation(self, instance):
        data = super().to_representation(instance)
        # Patch: if user.is_verified, force verification_status to 'verified'
        user = instance.user
        if hasattr(user, 'is_verified') and user.is_verified:
            data['verification_status'] = 'verified'
        return data

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
