import uuid
from django.db import models
from django.utils import timezone
from apps.authentication.models import User


class Notification(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    notification_type = models.CharField(max_length=50)  # ex: delivery_update, payment, system
    title = models.CharField(max_length=255)
    message = models.TextField()
    related_entity_type = models.CharField(max_length=50, blank=True)
    related_entity_id = models.UUIDField(null=True, blank=True)
    is_read = models.BooleanField(default=False)
    sent_at = models.DateTimeField(auto_now_add=True)
    read_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'notifications'
        verbose_name = 'Notification'
        verbose_name_plural = 'Notifications'
        ordering = ['-sent_at']

    def __str__(self):
        return f"Notification to {self.user.email} - {self.title}"


class DeviceToken(models.Model):
    """
    Stocke les tokens FCM des appareils pour envoyer des notifications push.
    Un utilisateur peut avoir plusieurs appareils (téléphone, tablette).
    """
    
    PLATFORM_CHOICES = [
        ('android', 'Android'),
        ('ios', 'iOS'),
        ('web', 'Web'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='device_tokens')
    token = models.CharField(max_length=255, unique=True)
    platform = models.CharField(max_length=10, choices=PLATFORM_CHOICES, default='android')
    device_name = models.CharField(max_length=100, blank=True)  # ex: "iPhone 13", "Samsung Galaxy"
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    last_used_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'device_tokens'
        verbose_name = 'Device Token'
        verbose_name_plural = 'Device Tokens'
        ordering = ['-last_used_at']
        indexes = [
            models.Index(fields=['user', 'is_active']),
            models.Index(fields=['token']),
        ]
    
    def __str__(self):
        return f"{self.user.email} - {self.platform} ({self.device_name or 'Unknown'})"
    
    def mark_as_used(self):
        """Met à jour la date de dernière utilisation"""
        self.last_used_at = timezone.now()
        self.save(update_fields=['last_used_at'])
    
    def deactivate(self):
        """Désactive le token (appareil déconnecté ou token invalide)"""
        self.is_active = False
        self.save(update_fields=['is_active'])
