from django.urls import path
from rest_framework_simplejwt.views import TokenVerifyView
from .views import (
    UserRegisterView, 
    UserDetailView, 
    CustomTokenObtainPairView, 
    CustomTokenRefreshView,
    LogoutView,
    RegisterFCMTokenView
)
from .upload_views import upload_profile_photo, delete_profile_photo
from .views_password import (
    PasswordResetRequestView,
    PasswordResetConfirmView,
    ChangePasswordView
)

urlpatterns = [
    # Inscription d'un nouvel utilisateur
    path('register/', UserRegisterView.as_view(), name='auth_register'),

    # Login : obtenir access + refresh tokens
    path('login/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),

    # Rafraîchir l'access token avec le refresh token
    path('token/refresh/', CustomTokenRefreshView.as_view(), name='token_refresh'),

    # Vérifier si un token est valide (optionnel)
    path('token/verify/', TokenVerifyView.as_view(), name='token_verify'),

    # Logout : blacklister le refresh token
    path('logout/', LogoutView.as_view(), name='auth_logout'),

    # Profil de l'utilisateur connecté
    path('me/', UserDetailView.as_view(), name='user_detail'),
    
    # Enregistrer token FCM pour notifications push
    path('register-fcm-token/', RegisterFCMTokenView.as_view(), name='register_fcm_token'),
    
    # Upload / Suppression photo de profil
    path('upload-profile-photo/', upload_profile_photo, name='upload_profile_photo'),
    path('delete-profile-photo/', delete_profile_photo, name='delete_profile_photo'),
    
    # Gestion des mots de passe
    path('password-reset/request/', PasswordResetRequestView.as_view(), name='password_reset_request'),
    path('password-reset/confirm/', PasswordResetConfirmView.as_view(), name='password_reset_confirm'),
    path('change-password/', ChangePasswordView.as_view(), name='change_password'),
]
