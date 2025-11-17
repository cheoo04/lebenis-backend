from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Delivery
from .email_service import send_delivery_pin_email

@receiver(post_save, sender=Delivery)
def ensure_pin_and_send_email(sender, instance, created, **kwargs):
    # Always ensure a PIN is set
    if not instance.delivery_confirmation_code:
        instance.delivery_confirmation_code = instance.generate_confirmation_code()
        instance.save(update_fields=["delivery_confirmation_code"])
    # Always send the PIN by email (for test/demo, hardcoded email)
    send_delivery_pin_email(instance.delivery_confirmation_code, "yahmardocheek@gmail.com", instance)
