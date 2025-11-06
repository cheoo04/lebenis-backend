# backend/apps/authentication/email_service.py
"""
Service d'envoi d'emails pour l'authentification
Utilise des templates HTML professionnels
"""
from django.core.mail import EmailMultiAlternatives
from django.template.loader import render_to_string
from django.utils.html import strip_tags
from django.conf import settings
import logging

logger = logging.getLogger(__name__)


class EmailService:
    """Service centralisé pour l'envoi d'emails d'authentification"""
    
    @staticmethod
    def send_password_reset_email(email: str, code: str, user_name: str = None) -> bool:
        """
        Envoyer un email de réinitialisation de mot de passe avec code
        
        Args:
            email: Email du destinataire
            code: Code de réinitialisation à 6 chiffres
            user_name: Nom de l'utilisateur (optionnel)
            
        Returns:
            bool: True si l'email a été envoyé avec succès
        """
        try:
            subject = "🔐 Réinitialisation de votre mot de passe - LeBeni's"
            
            # Contexte pour le template
            context = {
                'code': code,
                'user_name': user_name or 'Utilisateur',
                'validity_minutes': 15,
                'support_email': 'support@lebenis.com',
                'app_name': "LeBeni's",
            }
            
            # Générer le contenu HTML depuis le template
            html_content = render_to_string(
                'emails/password_reset.html',
                context
            )
            
            # Générer la version texte (fallback)
            text_content = strip_tags(html_content)
            
            # Créer l'email multipart (HTML + texte)
            email_message = EmailMultiAlternatives(
                subject=subject,
                body=text_content,
                from_email=settings.DEFAULT_FROM_EMAIL,
                to=[email]
            )
            
            # Attacher la version HTML
            email_message.attach_alternative(html_content, "text/html")
            
            # Envoyer
            email_message.send(fail_silently=False)
            
            logger.info(f"✅ Email de réinitialisation envoyé à {email}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erreur envoi email à {email}: {e}")
            return False
    
    @staticmethod
    def send_password_changed_notification(email: str, user_name: str = None) -> bool:
        """
        Envoyer une notification de changement de mot de passe
        
        Args:
            email: Email du destinataire
            user_name: Nom de l'utilisateur (optionnel)
            
        Returns:
            bool: True si l'email a été envoyé avec succès
        """
        try:
            subject = "✅ Votre mot de passe a été modifié - LeBeni's"
            
            context = {
                'user_name': user_name or 'Utilisateur',
                'support_email': 'support@lebenis.com',
                'app_name': "LeBeni's",
            }
            
            html_content = render_to_string(
                'emails/password_changed.html',
                context
            )
            
            text_content = strip_tags(html_content)
            
            email_message = EmailMultiAlternatives(
                subject=subject,
                body=text_content,
                from_email=settings.DEFAULT_FROM_EMAIL,
                to=[email]
            )
            
            email_message.attach_alternative(html_content, "text/html")
            email_message.send(fail_silently=False)
            
            logger.info(f"✅ Notification de changement de mot de passe envoyée à {email}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erreur envoi notification à {email}: {e}")
            return False
    
    @staticmethod
    def send_welcome_email(email: str, user_name: str, role: str) -> bool:
        """
        Envoyer un email de bienvenue
        
        Args:
            email: Email du destinataire
            user_name: Nom de l'utilisateur
            role: Rôle de l'utilisateur (driver, merchant)
            
        Returns:
            bool: True si l'email a été envoyé avec succès
        """
        try:
            subject = f"🎉 Bienvenue sur LeBeni's !"
            
            context = {
                'user_name': user_name,
                'role': role,
                'support_email': 'support@lebenis.com',
                'app_name': "LeBeni's",
            }
            
            html_content = render_to_string(
                'emails/welcome.html',
                context
            )
            
            text_content = strip_tags(html_content)
            
            email_message = EmailMultiAlternatives(
                subject=subject,
                body=text_content,
                from_email=settings.DEFAULT_FROM_EMAIL,
                to=[email]
            )
            
            email_message.attach_alternative(html_content, "text/html")
            email_message.send(fail_silently=False)
            
            logger.info(f"✅ Email de bienvenue envoyé à {email}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erreur envoi email de bienvenue à {email}: {e}")
            return False
