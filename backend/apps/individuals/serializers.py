from rest_framework import serializers
from .models import Individual
from apps.authentication.serializers import UserSerializer


class IndividualSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    full_name = serializers.ReadOnlyField()
    phone = serializers.ReadOnlyField()
    email = serializers.ReadOnlyField()
    
    class Meta:
        model = Individual
        fields = [
            'id',
            'user',
            'address',
            'full_name',
            'phone',
            'email',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
