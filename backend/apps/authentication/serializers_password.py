# backend/apps/authentication/serializers_password.py
from rest_framework import serializers
from django.contrib.auth.password_validation import validate_password
from .models import User


class PasswordResetRequestSerializer(serializers.Serializer):
    """Demande de réinitialisation de mot de passe"""
    email = serializers.EmailField()
    
    def validate_email(self, value):
        """Vérifier que l'email existe"""
        if not User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Aucun compte n'est associé à cet email.")
        return value


class PasswordResetConfirmSerializer(serializers.Serializer):
    """Confirmation de réinitialisation avec code"""
    email = serializers.EmailField()
    code = serializers.CharField(max_length=6, min_length=6)
    new_password = serializers.CharField(
        write_only=True,
        required=True,
        validators=[validate_password],
        style={'input_type': 'password'}
    )
    
    def validate_code(self, value):
        """Vérifier que le code est numérique"""
        if not value.isdigit():
            raise serializers.ValidationError("Le code doit être composé de 6 chiffres.")
        return value


class ChangePasswordSerializer(serializers.Serializer):
    """Changement de mot de passe (utilisateur connecté)"""
    old_password = serializers.CharField(required=True, style={'input_type': 'password'})
    new_password = serializers.CharField(
        required=True,
        validators=[validate_password],
        style={'input_type': 'password'}
    )
    new_password_confirm = serializers.CharField(required=True, style={'input_type': 'password'})
    
    def validate(self, data):
        """Vérifier que les nouveaux mots de passe correspondent"""
        if data['new_password'] != data['new_password_confirm']:
            raise serializers.ValidationError({"new_password": "Les mots de passe ne correspondent pas."})
        return data
    
    def validate_old_password(self, value):
        """Vérifier l'ancien mot de passe"""
        user = self.context['request'].user
        if not user.check_password(value):
            raise serializers.ValidationError("Mot de passe incorrect.")
        return value
