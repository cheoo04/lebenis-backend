# backend/apps/authentication/views_password.py
from rest_framework import status
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.views import APIView
from django.core.mail import send_mail
from django.conf import settings
import logging

from .models import User
from .models_password import PasswordResetCode
from .serializers_password import (
    PasswordResetRequestSerializer,
    PasswordResetConfirmSerializer,
    ChangePasswordSerializer
)

logger = logging.getLogger(__name__)


class PasswordResetRequestView(APIView):
    """
    POST /api/v1/auth/password-reset/request/
    
    Demande de réinitialisation de mot de passe.
    Envoie un code à 6 chiffres par email (ou SMS dans une version future).
    """
    permission_classes = [AllowAny]
    
    def post(self, request):
        serializer = PasswordResetRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        email = serializer.validated_data['email']
        
        # Créer un code de réinitialisation
        reset_code = PasswordResetCode.create_for_email(email)
        
        # Envoyer l'email avec le code
        try:
            self._send_reset_email(email, reset_code.code)
            logger.info(f"✅ Code de réinitialisation envoyé à {email}: {reset_code.code}")
        except Exception as e:
            logger.error(f"❌ Erreur envoi email: {e}")
            # En développement, on continue quand même
            if not settings.DEBUG:
                return Response(
                    {"error": "Erreur lors de l'envoi de l'email"},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR
                )
        
        return Response({
            "success": True,
            "message": "Un code de réinitialisation a été envoyé à votre email.",
            "email": email,
            # En développement, retourner le code pour tester
            **({"code": reset_code.code} if settings.DEBUG else {})
        })
    
    def _send_reset_email(self, email, code):
        """Envoyer l'email avec le code"""
        subject = "Réinitialisation de mot de passe - LeBeni's"
        message = f"""
Bonjour,

Vous avez demandé la réinitialisation de votre mot de passe.

Votre code de vérification est : {code}

Ce code est valide pendant 15 minutes.

Si vous n'avez pas demandé cette réinitialisation, ignorez cet email.

Cordialement,
L'équipe LeBeni's
        """
        
        send_mail(
            subject=subject,
            message=message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[email],
            fail_silently=False,
        )


class PasswordResetConfirmView(APIView):
    """
    POST /api/v1/auth/password-reset/confirm/
    
    Confirmer la réinitialisation avec le code et définir un nouveau mot de passe.
    """
    permission_classes = [AllowAny]
    
    def post(self, request):
        serializer = PasswordResetConfirmSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        email = serializer.validated_data['email']
        code = serializer.validated_data['code']
        new_password = serializer.validated_data['new_password']
        
        # Vérifier le code
        reset_code, error = PasswordResetCode.verify_code(email, code)
        
        if error:
            return Response(
                {"error": error},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Récupérer l'utilisateur
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            return Response(
                {"error": "Utilisateur introuvable"},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Changer le mot de passe
        user.set_password(new_password)
        user.save()
        
        # Marquer le code comme utilisé
        reset_code.mark_as_used()
        
        logger.info(f"✅ Mot de passe réinitialisé pour {email}")
        
        return Response({
            "success": True,
            "message": "Mot de passe réinitialisé avec succès. Vous pouvez maintenant vous connecter."
        })


class ChangePasswordView(APIView):
    """
    POST /api/v1/auth/change-password/
    
    Changer le mot de passe (utilisateur connecté).
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
        
        logger.info(f"✅ Mot de passe changé pour {user.email}")
        
        return Response({
            "success": True,
            "message": "Mot de passe modifié avec succès."
        })
