# deliveries/serializers_rating.py

from rest_framework import serializers
from .models_rating import DeliveryRating
from apps.merchants.models import Merchant
from apps.drivers.models import Driver


class DeliveryRatingSerializer(serializers.ModelSerializer):
    """
    Serializer pour les évaluations de livraison.
    """
    merchant_name = serializers.CharField(source='merchant.business_name', read_only=True)
    driver_name = serializers.CharField(source='driver.user.full_name', read_only=True)
    delivery_tracking_number = serializers.CharField(source='delivery.tracking_number', read_only=True)
    
    class Meta:
        model = DeliveryRating
        fields = [
            'id',
            'delivery',
            'delivery_tracking_number',
            'merchant',
            'merchant_name',
            'driver',
            'driver_name',
            'rating',
            'comment',
            'punctuality_rating',
            'professionalism_rating',
            'care_rating',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'merchant', 'driver', 'created_at', 'updated_at']


class DeliveryRatingCreateSerializer(serializers.ModelSerializer):
    """
    Serializer pour créer une évaluation.
    """
    
    class Meta:
        model = DeliveryRating
        fields = [
            'rating',
            'comment',
            'punctuality_rating',
            'professionalism_rating',
            'care_rating',
        ]
    
    def validate_rating(self, value):
        """Valide que la note est entre 1 et 5"""
        if not (1.0 <= float(value) <= 5.0):
            raise serializers.ValidationError("La note doit être entre 1.0 et 5.0")
        return value
    
    def validate(self, data):
        """
        Validation supplémentaire : les critères détaillés doivent être entre 1 et 5
        """
        optional_ratings = [
            'punctuality_rating',
            'professionalism_rating',
            'care_rating',
        ]
        
        for field in optional_ratings:
            if field in data and data[field] is not None:
                if not (1 <= data[field] <= 5):
                    raise serializers.ValidationError({
                        field: "La note doit être entre 1 et 5"
                    })
        
        return data
