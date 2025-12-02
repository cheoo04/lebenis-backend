from django.core.mail import send_mail
from django.conf import settings

def send_delivery_pin_email(pin_code, to_email, delivery=None):
    """
    Envoie le code PIN de livraison par email.
    Retourne True si succès, False si échec.
    """
    subject = "Votre code PIN de livraison"
    message = f"Votre code PIN pour la confirmation de livraison est : {pin_code}"
    if delivery:
        message += f"\nNuméro de suivi : {getattr(delivery, 'tracking_number', '')}"
    
    try:
        send_mail(
            subject,
            message,
            settings.DEFAULT_FROM_EMAIL,
            [to_email],
            fail_silently=False,
        )
        return True
    except Exception as e:
        # Log l'erreur mais ne crash pas
        import logging
        logger = logging.getLogger(__name__)
        logger.error(f"Erreur envoi email à {to_email}: {e}")
        return False
