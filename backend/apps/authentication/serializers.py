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
    
    # Champs spécifiques pour merchant
    business_name = serializers.CharField(write_only=True, required=False)
    business_type = serializers.CharField(write_only=True, required=False)
    business_address = serializers.CharField(write_only=True, required=False)
    
    # Champs spécifiques pour driver
    vehicle_type = serializers.CharField(write_only=True, required=False)
    driver_license = serializers.CharField(write_only=True, required=False)

    class Meta:
        model = User
        fields = ['email', 'phone', 'first_name', 'last_name', 'user_type', 'password', 'password2', 
                  'business_name', 'business_type', 'business_address',
                  'vehicle_type', 'driver_license']

    def validate(self, data):
        if data['password'] != data['password2']:
            raise serializers.ValidationError({"password": "Les mots de passe ne correspondent pas."})
        
        # Validation spécifique selon user_type
        if data.get('user_type') == 'merchant':
            if not data.get('business_name'):
                raise serializers.ValidationError({"business_name": "Le nom du commerce est requis pour les marchands."})
        
        if data.get('user_type') == 'driver':
            if not data.get('vehicle_type'):
                raise serializers.ValidationError({"vehicle_type": "Le type de véhicule est requis pour les chauffeurs."})
        
        return data

    def create(self, validated_data):
        from apps.merchants.models import Merchant, MerchantAddress
        from apps.drivers.models import Driver
        from apps.individuals.models import Individual
        
        # Extraire les champs spécifiques (seront utilisés pour mise à jour)
        business_name = validated_data.pop('business_name', None)
        business_type = validated_data.pop('business_type', None)
        business_address = validated_data.pop('business_address', None)
        vehicle_type = validated_data.pop('vehicle_type', None)
        driver_license = validated_data.pop('driver_license', None)
        
        # Retire password2 car non nécessaire pour la création
        validated_data.pop('password2')
        
        # Crée l'utilisateur avec create_user (du UserManager personnalisé)
        # Les signals post_save créeront automatiquement Merchant, Driver ou Individual
        user = User.objects.create_user(
            email=validated_data['email'],
            phone=validated_data['phone'],
            first_name=validated_data['first_name'],
            last_name=validated_data['last_name'],
            user_type=validated_data['user_type'],
            password=validated_data['password'],
        )
        
        # Mettre à jour le profil Merchant (créé automatiquement par signal)
        if user.user_type == 'merchant' and business_name:
            merchant = Merchant.objects.get(user=user)
            merchant.business_name = business_name
            merchant.business_type = business_type or ''
            merchant.save(update_fields=['business_name', 'business_type'])
            
            # Créer l'adresse principale si fournie
            if business_address:
                MerchantAddress.objects.create(
                    merchant=merchant,
                    address_name='Adresse principale',
                    street_address=business_address,
                    is_primary=True
                )
        
        # Mettre à jour le profil Driver (créé automatiquement par signal)
        elif user.user_type == 'driver' and vehicle_type:
            driver = Driver.objects.get(user=user)
            driver.vehicle_type = vehicle_type
            if driver_license:
                driver.driver_license = driver_license
            driver.save(update_fields=['vehicle_type', 'driver_license'])
        
        # Les particuliers sont créés automatiquement par signal, pas de mise à jour spéciale
        # elif user.user_type == 'individual':
        #     Individual.objects.get(user=user)  # Juste vérifier qu'il existe
        
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
