from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth.password_validation import validate_password
from .models import User


# SERIALIZER POUR AFFICHER LES DONNÉES UTILISATEUR
class UserSerializer(serializers.ModelSerializer):

    """
    Serializer pour afficher les informations d'un utilisateur.
    Utilisé pour GET /api/v1/auth/me/ par exemple.
    """
        
    
    class Meta:
        model = User
        fields = ['id', 'email', 'phone', 'first_name', 'last_name', 'user_type', 'profile_photo', 'is_active', 'is_verified', 'is_staff', 'created_at', 'updated_at']
        # Ces champs ne peuvent PAS être modifiés via l'API        
        read_only_fields = ['id', 'is_active', 'is_verified', 'is_staff', 'created_at', 'updated_at']


# SERIALIZER POUR L'INSCRIPTION (REGISTER)
class UserRegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password], style={'input_type': 'password'}, label="Mot de passe")
    password2 = serializers.CharField(write_only=True, required=True, style={'input_type': 'password'}, label="Confirmer mot de passe")

    class Meta:
        model = User
        fields = ['email', 'phone', 'first_name', 'last_name', 'user_type', 'password', 'password2']

    def validate(self, data):
        if data['password'] != data['password2']:
            raise serializers.ValidationError({"password": "Les mots de passe ne correspondent pas."})
        return data

    def create(self, validated_data):
        # Retire password2 car non nécessaire pour la création
        validated_data.pop('password2')
        # ✅ Crée l'utilisateur avec create_user (du UserManager personnalisé)
        user = User.objects.create_user(
            email=validated_data['email'],
            phone=validated_data['phone'],
            first_name=validated_data['first_name'],
            last_name=validated_data['last_name'],
            user_type=validated_data['user_type'],
            password=validated_data['password'],
        )
        # L'utilisateur est créé avec succès
        return user


# SERIALIZER JWT PERSONNALISÉ (LOGIN)

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """
    Serializer JWT personnalisé pour ajouter des informations supplémentaires
    dans le token et dans la réponse de login.
    
    Hérite de TokenObtainPairSerializer de rest_framework_simplejwt.
    """

    @classmethod
    def get_token(cls, user):
        """
        Personnalise le payload du token JWT avec des informations utilisateur.
        Ces informations seront encodées DANS le token lui-même.
        """
        # Obtient le token de base (avec user_id, exp, iat, etc.)
        token = super().get_token(user)
        
        # Ajoute des claims personnalisés au token
        token['email'] = user.email
        token['user_type'] = user.user_type
        token['full_name'] = f"{user.first_name} {user.last_name}"
        token['is_verified'] = user.is_verified
        
        # Vous pouvez décoder ce token sur Flutter pour récupérer ces infos
        # sans avoir à faire une requête GET /me/
        
        return token
    
    def validate(self, attrs):
        """
        Personnalise la réponse de login pour inclure les infos utilisateur et gère les cas d'utilisateur inactif ou d'identifiants invalides.
        """
        try:
            data = super().validate(attrs)
        except Exception:
            # Email ou mot de passe incorrect
            raise serializers.ValidationError({"detail": "Email ou mot de passe incorrect."})

        # Vérifie si l'utilisateur est actif
        if not self.user.is_active:
            raise serializers.ValidationError({"detail": "Votre compte a été désactivé. Veuillez contacter l’administrateur ou le propriétaire pour plus d’informations."})

        # Ajoute les informations utilisateur à la réponse JSON
        data['user'] = {
            'id': str(self.user.id),
            'email': self.user.email,
            'first_name': self.user.first_name,
            'last_name': self.user.last_name,
            'phone': self.user.phone,
            'user_type': self.user.user_type,
            'is_verified': self.user.is_verified,
            'is_active': self.user.is_active,
        }
        return data

# ============================================================================
# SERIALIZER POUR LE LOGOUT
# ============================================================================

class LogoutSerializer(serializers.Serializer):
    """
    Serializer pour l'endpoint de logout.
    Accepte le refresh token en input et le blackliste.
    """
    
    # ✅ Champ refresh token (obligatoire)
    refresh = serializers.CharField(
        required=True,
        help_text="Le refresh token à invalider"
    )
    
    def validate(self, data):
        """Validation du refresh token"""
        refresh_token = data.get('refresh')
        
        if not refresh_token:
            raise serializers.ValidationError({
                "refresh": "Le refresh token est obligatoire."
            })
        
        return data
