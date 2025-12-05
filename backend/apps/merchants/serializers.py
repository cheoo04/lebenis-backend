from rest_framework import serializers
from .models import Merchant, MerchantAddress
from apps.authentication.serializers import UserSerializer

class MerchantAddressSerializer(serializers.ModelSerializer):
    class Meta:
        model = MerchantAddress
        fields = ['id', 'address_name', 'street_address', 'commune', 'quartier', 'city', 'country', 'latitude', 'longitude', 'is_primary']

class MerchantSerializer(serializers.ModelSerializer):
    addresses = MerchantAddressSerializer(many=True, read_only=True)
    user = UserSerializer(read_only=True)  # Inclure les détails complets de l'utilisateur

    class Meta:
        model = Merchant
        fields = ['id', 'user', 'business_name', 'business_type', 'registration_number', 'tax_id', 'verification_status', 'rejection_reason', 'documents_url', 'rccm_document', 'id_document', 'commission_rate', 'current_balance', 'addresses', 'created_at', 'updated_at']
        read_only_fields = ['id', 'user', 'verification_status', 'commission_rate', 'current_balance', 'created_at', 'updated_at']
