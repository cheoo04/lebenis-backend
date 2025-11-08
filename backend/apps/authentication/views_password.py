# backend/apps/authentication/views_password.py
from rest_framework import status
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.views import APIView
from django.conf import settings
import logging

from .models import User
from .models_password import PasswordResetCode
from .serializers_password import (
    PasswordResetRequestSerializer,
    PasswordResetConfirmSerializer,
    ChangePasswordSerializer
)
from .email_service import EmailService

logger = logging.getLogger(__name__)


class PasswordResetRequestView(APIView):
    """
    POST /api/v1/auth/password-reset/request/
    
    Demande de réinitialisation de mot de passe.
    Envoie un code à 6 chiffres par email avec template HTML professionnel.
    Protection anti-spam: max 3 demandes par heure.
    """
    permission_classes = [AllowAny]
    
    def post(self, request):
        serializer = PasswordResetRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        email = serializer.validated_data['email']
        
        # Récupérer l'adresse IP de la requête
        ip_address = self._get_client_ip(request)
        
        try:
            # Créer un code de réinitialisation (avec vérification anti-spam)
            reset_code = PasswordResetCode.create_for_email(email, ip_address)
        except ValueError as e:
            # Limite de taux atteinte
            logger.warning(f"⚠️ Limite de réinitialisation atteinte pour {email} depuis {ip_address}")
            return Response(
                {"error": str(e)},
                status=status.HTTP_429_TOO_MANY_REQUESTS
            )
        
        # Récupérer le nom de l'utilisateur pour personnaliser l'email
        try:
            user = User.objects.get(email=email)
            user_name = user.full_name or user.email.split('@')[0]
        except User.DoesNotExist:
            # Ne devrait pas arriver car le serializer vérifie l'existence
            user_name = email.split('@')[0]
        
        # Envoyer l'email avec le nouveau service professionnel
        email_sent = EmailService.send_password_reset_email(
            email=email,
            code=reset_code.code,
            user_name=user_name
        )
        
        if not email_sent and not settings.DEBUG:
            logger.error(f"❌ Échec envoi email pour {email}")
            return Response(
                {"error": "Erreur lors de l'envoi de l'email. Réessayez plus tard."},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
        
        logger.info(f"✅ Code de réinitialisation envoyé à {email}: {reset_code.code}")
        
        return Response({
            "success": True,
            "message": "Un code de réinitialisation a été envoyé à votre email.",
            "email": email,
            # En développement, retourner le code pour tester
            **({"code": reset_code.code} if settings.DEBUG else {})
        })
    
    def _get_client_ip(self, request):
        """Récupérer l'adresse IP du client"""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        return ip


class PasswordResetConfirmView(APIView):
    """
    POST /api/v1/auth/password-reset/confirm/
    
    Confirmer la réinitialisation avec le code et définir un nouveau mot de passe.
    Protection brute-force: max 5 tentatives par code.
    Envoie une notification de changement de mot de passe.
    """
    permission_classes = [AllowAny]
    
    def post(self, request):
        serializer = PasswordResetConfirmSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        email = serializer.validated_data['email']
        code = serializer.validated_data['code']
        new_password = serializer.validated_data['new_password']
        
        # Vérifier le code (avec protection brute-force)
        reset_code, error = PasswordResetCode.verify_code(email, code)
        
        if error:
            # Code invalide, expiré ou trop de tentatives
            return Response(
                {"error": error},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Récupérer l'utilisateur
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            logger.error(f"❌ Utilisateur introuvable pour {email}")
            return Response(
                {"error": "Utilisateur introuvable"},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Changer le mot de passe
        user.set_password(new_password)
        user.save()
        
        # Marquer le code comme utilisé
        reset_code.mark_as_used()
        
        # Envoyer une notification de changement de mot de passe
        user_name = user.full_name or user.email.split('@')[0]
        EmailService.send_password_changed_notification(
            email=email,
            user_name=user_name
        )
        
        logger.info(f"✅ Mot de passe réinitialisé pour {email}")
        
        return Response({
            "success": True,
            "message": "Mot de passe réinitialisé avec succès. Vous pouvez maintenant vous connecter."
        })


class ChangePasswordView(APIView):
    """
    POST /api/v1/auth/change-password/
    
    Changer le mot de passe (utilisateur connecté).
    Envoie une notification de changement de mot de passe.
    """
    permission_classes = [IsAuthenticated]
    
    def post(self, request):
        serializer = ChangePasswordSerializer(
            data=request.data,
            context={'request': request}
        )
        serializer.is_valid(raise_exception=True)
        
        # Changer le mot de passe
        user = request.user
        new_password = serializer.validated_data['new_password']
        user.set_password(new_password)
        user.save()
        
        # Envoyer une notification de changement
        user_name = user.full_name or user.email.split('@')[0]
        EmailService.send_password_changed_notification(
            email=user.email,
            user_name=user_name
        )
        
        logger.info(f"✅ Mot de passe changé pour {user.email}")
        
        return Response({
            "success": True,
            "message": "Mot de passe modifié avec succès."
        })
