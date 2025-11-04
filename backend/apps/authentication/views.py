from rest_framework import generics, status
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.views import APIView
from .serializers import UserRegisterSerializer, UserSerializer, CustomTokenObtainPairSerializer
from .models import User


# ============================================================================
# VUE POUR L'INSCRIPTION (REGISTER)
# ============================================================================

class UserRegisterView(generics.CreateAPIView):
    """
    POST /api/v1/auth/register/
    
    Permet à un nouvel utilisateur de s'inscrire.
    Pas d'authentification requise (AllowAny).
    Retourne les tokens JWT après inscription réussie.
    """
    serializer_class = UserRegisterSerializer
    permission_classes = [AllowAny]  # Accessible sans authentification
    
    def create(self, request, *args, **kwargs):
        """
        Surcharge pour retourner les tokens JWT après inscription
        """
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        # Générer les tokens JWT pour l'utilisateur créé
        refresh = RefreshToken.for_user(user)
        
        # Ajouter des claims personnalisés au token
        refresh['email'] = user.email
        refresh['user_type'] = user.user_type
        refresh['full_name'] = f"{user.first_name} {user.last_name}"
        refresh['is_verified'] = user.is_verified
        
        # Retourner les tokens + données utilisateur
        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user': {
                'id': str(user.id),
                'email': user.email,
                'first_name': user.first_name,
                'last_name': user.last_name,
                'phone': user.phone,
                'user_type': user.user_type,
                'is_verified': user.is_verified,
                'is_active': user.is_active,
            }
        }, status=status.HTTP_201_CREATED)


# ============================================================================
# VUE POUR RÉCUPÉRER LE PROFIL DE L'UTILISATEUR CONNECTÉ
# ============================================================================

class UserDetailView(generics.RetrieveAPIView):
    """
    GET /api/v1/auth/me/
    
    Retourne les informations de l'utilisateur actuellement connecté.
    Nécessite un token JWT valide dans le header Authorization.

    """
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]  # Authentification obligatoire
    
    def get_object(self):
        """
        Retourne l'utilisateur connecté (self.request.user).
        Pas besoin de passer un ID dans l'URL.
        """
        return self.request.user


# ============================================================================
# VUE POUR LE LOGIN (OBTENTION DES TOKENS JWT)
# ============================================================================

class CustomTokenObtainPairView(TokenObtainPairView):
    """
    POST /api/v1/auth/login/
    
    Permet à un utilisateur de se connecter et d'obtenir des tokens JWT.
    Utilise le serializer personnalisé pour inclure les infos utilisateur.
    """
    serializer_class = CustomTokenObtainPairSerializer  # Utilise le serializer personnalisé
    permission_classes = [AllowAny]  # Accessible sans authentification


# ============================================================================
# VUE POUR RAFRAÎCHIR LE TOKEN D'ACCÈS
# ============================================================================

class CustomTokenRefreshView(TokenRefreshView):
    """
    POST /api/v1/auth/token/refresh/
    
    Permet d'obtenir un nouveau access token en utilisant un refresh token valide.
    Avec ROTATE_REFRESH_TOKENS=True, retourne aussi un nouveau refresh token.
    """
    permission_classes = [AllowAny]  # Accessible sans authentification


# ============================================================================
# VUE POUR LA DÉCONNEXION (LOGOUT)
# ============================================================================

class LogoutView(APIView):
    """
    POST /api/v1/auth/logout/
    
    Invalide le refresh token en l'ajoutant à la blacklist.
    Nécessite le refresh token dans le body.
    """
    permission_classes = [IsAuthenticated]  # Doit être connecté pour se déconnecter
    
    def post(self, request):
        try:
            # Récupère le refresh token depuis le body
            refresh_token = request.data.get("refresh")
            
            if not refresh_token:
                return Response(
                    {"error": "Le refresh token est requis"},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Crée un objet RefreshToken et l'ajoute à la blacklist
            token = RefreshToken(refresh_token)
            token.blacklist()  # Nécessite token_blacklist dans INSTALLED_APPS
            
            return Response(
                {"message": "Déconnexion réussie"},
                status=status.HTTP_205_RESET_CONTENT
            )
        
        except Exception as e:
            return Response(
                {"error": f"Erreur lors de la déconnexion: {str(e)}"},
                status=status.HTTP_400_BAD_REQUEST
            )
