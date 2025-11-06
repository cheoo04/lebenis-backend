# drivers/serializers_mobile_money.py

from rest_framework import serializers
from .models import Driver
import re


class MobileMoneySerializer(serializers.ModelSerializer):
    """
    Serializer pour gérer les informations Mobile Money du driver.
    """
    
    class Meta:
        model = Driver
        fields = ['mobile_money_number', 'mobile_money_provider']
    
    def validate_mobile_money_number(self, value):
        """
        Valide le format du numéro Mobile Money.
        
        Formats acceptés :
        - +225 07 12 34 56 78 (Orange CI)
        - +225 05 12 34 56 78 (MTN CI)
        - 0712345678
        - 07 12 34 56 78
        """
        if not value:
            return value
        
        # Nettoyer le numéro (garder seulement les chiffres et +)
        clean_number = re.sub(r'[^\d+]', '', value)
        
        # Formats valides Côte d'Ivoire
        patterns = [
            r'^\+225\d{10}$',       # +225xxxxxxxxxx
            r'^225\d{10}$',         # 225xxxxxxxxxx
            r'^0[0-9]\d{8}$',       # 0xxxxxxxxx (10 chiffres)
            r'^\d{10}$',            # xxxxxxxxxx (10 chiffres)
        ]
        
        is_valid = any(re.match(pattern, clean_number) for pattern in patterns)
        
        if not is_valid:
            raise serializers.ValidationError(
                "Format de numéro invalide. Formats acceptés: "
                "+225 07 12 34 56 78, 0712345678, 07 12 34 56 78"
            )
        
        return value
    
    def validate_mobile_money_provider(self, value):
        """Valide que le provider est dans la liste autorisée"""
        if not value:
            return value
        
        valid_providers = ['orange', 'mtn', 'moov', 'wave']
        
        if value not in valid_providers:
            raise serializers.ValidationError(
                f"Provider invalide. Choix: {', '.join(valid_providers)}"
            )
        
        return value
    
    def validate(self, data):
        """
        Validation croisée : si un champ est fourni, l'autre est requis.
        """
        number = data.get('mobile_money_number')
        provider = data.get('mobile_money_provider')
        
        # Si l'un est fourni, l'autre doit l'être aussi
        if (number and not provider) or (provider and not number):
            raise serializers.ValidationError(
                "Vous devez fournir à la fois le numéro ET le provider Mobile Money"
            )
        
        return data


class DriverMobileMoneyReadSerializer(serializers.ModelSerializer):
    """
    Serializer en lecture seule pour afficher les infos Mobile Money.
    Masque une partie du numéro pour la sécurité.
    """
    mobile_money_number_masked = serializers.SerializerMethodField()
    mobile_money_provider_display = serializers.SerializerMethodField()
    
    class Meta:
        model = Driver
        fields = [
            'mobile_money_number',
            'mobile_money_number_masked',
            'mobile_money_provider',
            'mobile_money_provider_display'
        ]
    
    def get_mobile_money_number_masked(self, obj):
        """Masque le numéro : +225 07 XX XX XX 78"""
        if not obj.mobile_money_number:
            return None
        
        number = obj.mobile_money_number
        # Garder les 4 premiers et 2 derniers chiffres
        if len(number) >= 10:
            return f"{number[:6]}{'X' * (len(number) - 8)}{number[-2:]}"
        return number
    
    def get_mobile_money_provider_display(self, obj):
        """Retourne le nom complet du provider"""
        provider_map = {
            'orange': 'Orange Money',
            'mtn': 'MTN Money',
            'moov': 'Moov Money',
            'wave': 'Wave',
        }
        return provider_map.get(obj.mobile_money_provider, obj.mobile_money_provider)
