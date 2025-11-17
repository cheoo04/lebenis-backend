from django.core.mail import send_mail
from django.conf import settings

def send_delivery_pin_email(pin_code, to_email, delivery=None):
    subject = "Votre code PIN de livraison"
    message = f"Votre code PIN pour la confirmation de livraison est : {pin_code}"
    if delivery:
        message += f"\nNuméro de suivi : {getattr(delivery, 'tracking_number', '')}"
    send_mail(
        subject,
        message,
        settings.DEFAULT_FROM_EMAIL,
        [to_email],
        fail_silently=False,
    )
