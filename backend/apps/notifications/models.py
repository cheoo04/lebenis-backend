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


class NotificationHistory(models.Model):
    """
    Historique des notifications push envoyées (Phase 2).
    Permet aux utilisateurs de consulter toutes leurs notifications passées.
    Compatible avec l'ancien modèle Notification.
    """
    
    NOTIFICATION_TYPE_CHOICES = [
        ('new_delivery', 'Nouvelle livraison'),
        ('delivery_accepted', 'Livraison acceptée'),
        ('delivery_rejected', 'Livraison refusée'),
        ('delivery_status_change', 'Changement de statut'),
        ('payment_received', 'Paiement reçu'),
        ('rating_received', 'Notation reçue'),
        ('system', 'Notification système'),
        ('promo', 'Promotion'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='notification_history',
        help_text='Destinataire de la notification'
    )
    
    # Contenu
    notification_type = models.CharField(
        max_length=50,
        choices=NOTIFICATION_TYPE_CHOICES,
        db_index=True,
        help_text='Type de notification'
    )
    title = models.CharField(
        max_length=255,
        help_text='Titre de la notification'
    )
    body = models.TextField(
        help_text='Corps du message'
    )
    
    # Données additionnelles (pour navigation dans l'app)
    data = models.JSONField(
        default=dict,
        blank=True,
        help_text='Données supplémentaires (delivery_id, action, etc.)'
    )
    
    # Action (pour deep linking)
    action = models.CharField(
        max_length=100,
        blank=True,
        help_text='Action à effectuer (open_delivery_details, etc.)'
    )
    action_url = models.CharField(
        max_length=500,
        blank=True,
        help_text='URL de deep linking'
    )
    
    # Statut
    is_read = models.BooleanField(
        default=False,
        db_index=True,
        help_text='Notification lue ou non'
    )
    read_at = models.DateTimeField(
        null=True,
        blank=True,
        help_text='Date de lecture'
    )
    
    # Envoi
    sent_via_fcm = models.BooleanField(
        default=True,
        help_text='Envoyée via FCM ou notification in-app uniquement'
    )
    fcm_message_id = models.CharField(
        max_length=255,
        blank=True,
        null=True,
        help_text='ID du message FCM (pour tracking)'
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'notification_history'
        verbose_name = 'Historique Notification'
        verbose_name_plural = 'Historique Notifications'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', 'is_read', 'created_at']),
            models.Index(fields=['user', 'notification_type']),
            models.Index(fields=['is_read', 'created_at']),
        ]
    
    def __str__(self):
        return f"{self.title} - {self.user.full_name} ({'lue' if self.is_read else 'non lue'})"
    
    def mark_as_read(self):
        """Marque la notification comme lue"""
        if not self.is_read:
            self.is_read = True
            self.read_at = timezone.now()
            self.save()
    
    @classmethod
    def create_and_send(cls, user, notification_type, title, body, data=None, action=''):
        """
        Crée une notification dans l'historique ET l'envoie via FCM.
        
        Args:
            user: Utilisateur destinataire
            notification_type: Type de notification
            title: Titre
            body: Corps du message
            data: Données additionnelles
            action: Action à effectuer
        
        Returns:
            NotificationHistory instance
        """
        from .firebase_service import FirebaseService
        
        # Créer l'entrée dans l'historique
        notification = cls.objects.create(
            user=user,
            notification_type=notification_type,
            title=title,
            body=body,
            data=data or {},
            action=action
        )
        
        # Envoyer via FCM si l'utilisateur a un token
        if user.fcm_token:
            success = FirebaseService.send_notification(
                fcm_token=user.fcm_token,
                title=title,
                body=body,
                data=data or {}
            )
            notification.sent_via_fcm = success
            notification.save()
        else:
            notification.sent_via_fcm = False
            notification.save()
        
        return notification
    
    @classmethod
    def get_unread_count(cls, user):
        """Compte le nombre de notifications non lues pour un utilisateur"""
        return cls.objects.filter(user=user, is_read=False).count()

