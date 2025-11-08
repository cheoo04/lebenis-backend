# test_django_ssl.py
from django.core.mail import send_mail
from config.settings import base

print("=== Test Django avec SendGrid SSL ===\n")
print(f"Configuration actuelle:")
print(f"  EMAIL_HOST: {base.EMAIL_HOST}")
print(f"  EMAIL_PORT: {base.EMAIL_PORT}")
print(f"  EMAIL_USE_SSL: {base.EMAIL_USE_SSL}")
print(f"  EMAIL_USE_TLS: {base.EMAIL_USE_TLS}")
print(f"  DEFAULT_FROM_EMAIL: {base.DEFAULT_FROM_EMAIL}\n")

try:
    result = send_mail(
        subject="Test Django - SendGrid SSL Port 465",
        message="Email de test avec Django configuré en SSL (port 465)",
        from_email=base.DEFAULT_FROM_EMAIL,
        recipient_list=["yahmardinho@gmail.com"],
        fail_silently=False,
    )
    print(f"✅ send_mail() a retourné: {result}")
    print("⏳ Vérifie l'Activity Feed SendGrid et ta boîte email")
except Exception as e:
    print(f"❌ Erreur: {e}")
    import traceback
    traceback.print_exc()
