import uuid
from django.db import models
from django.utils import timezone
from apps.authentication.models import User
from apps.deliveries.models import Delivery


class ChatRoom(models.Model):
    """
    Salle de chat entre un livreur et un client/support.
    Liée à une livraison spécifique.
    """
    
    ROOM_TYPE_CHOICES = [
        ('delivery', 'Livraison (Driver-Client)'),
        ('support', 'Support (Driver-Admin)'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Type de conversation
    room_type = models.CharField(
        max_length=20,
        choices=ROOM_TYPE_CHOICES,
        default='delivery',
        db_index=True
    )
    
    # Participants
    driver = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='driver_chats',
        help_text='Livreur participant'
    )
    other_user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='other_user_chats',
        help_text='Client ou Admin'
    )
    
    # Livraison associée (si applicable)
    delivery = models.ForeignKey(
        Delivery,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='chat_rooms',
        help_text='Livraison concernée (si room_type=delivery)'
    )
    
    # Firebase Realtime Database path
    firebase_path = models.CharField(
        max_length=255,
        unique=True,
        db_index=True,
        help_text='Chemin dans Firebase: /chats/{uuid}'
    )
    
    # Métadonnées
    last_message_text = models.TextField(blank=True, help_text='Dernier message')
    last_message_at = models.DateTimeField(null=True, blank=True)
    last_message_sender_id = models.UUIDField(null=True, blank=True)
    
    # Compteurs de messages non lus (pour chaque participant)
    driver_unread_count = models.IntegerField(default=0)
    other_user_unread_count = models.IntegerField(default=0)
    
    # Statut
    is_active = models.BooleanField(default=True)
    is_archived = models.BooleanField(default=False)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'chat_rooms'
        verbose_name = 'Chat Room'
        verbose_name_plural = 'Chat Rooms'
        ordering = ['-last_message_at', '-created_at']
        indexes = [
            models.Index(fields=['driver', 'is_active']),
            models.Index(fields=['other_user', 'is_active']),
            models.Index(fields=['delivery']),
            models.Index(fields=['-last_message_at']),
        ]
        # Une seule room par combinaison driver-other_user-delivery
        unique_together = [['driver', 'other_user', 'delivery']]
    
    def __str__(self):
        if self.delivery:
            return f"Chat {self.room_type}: {self.driver.full_name} - {self.other_user.full_name} (#{self.delivery.tracking_number})"
        return f"Chat {self.room_type}: {self.driver.full_name} - {self.other_user.full_name}"
    
    def save(self, *args, **kwargs):
        # Générer firebase_path si pas encore défini
        if not self.firebase_path:
            self.firebase_path = f'/chats/{self.id}'
        super().save(*args, **kwargs)
    
    def increment_unread_for_user(self, user_id):
        """Incrémente le compteur de non lus pour un utilisateur"""
        if str(user_id) == str(self.driver_id):
            self.driver_unread_count += 1
        else:
            self.other_user_unread_count += 1
        self.save(update_fields=['driver_unread_count', 'other_user_unread_count'])
    
    def mark_as_read_for_user(self, user_id):
        """Marque tous les messages comme lus pour un utilisateur"""
        if str(user_id) == str(self.driver_id):
            self.driver_unread_count = 0
            self.save(update_fields=['driver_unread_count'])
        else:
            self.other_user_unread_count = 0
            self.save(update_fields=['other_user_unread_count'])


class ChatMessage(models.Model):
    """
    Message dans une salle de chat.
    Stocké en DB pour backup et recherche, mais sync temps réel via Firebase.
    """
    
    MESSAGE_TYPE_CHOICES = [
        ('text', 'Texte'),
        ('image', 'Image'),
        ('location', 'Position GPS'),
        ('system', 'Message système'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    chat_room = models.ForeignKey(
        ChatRoom,
        on_delete=models.CASCADE,
        related_name='messages'
    )
    
    sender = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='sent_messages'
    )
    
    # Contenu
    message_type = models.CharField(
        max_length=20,
        choices=MESSAGE_TYPE_CHOICES,
        default='text'
    )
    text = models.TextField(blank=True, help_text='Contenu du message')
    
    # Médias (optionnel)
    image_url = models.URLField(blank=True, max_length=500)
    
    # Position GPS (optionnel)
    latitude = models.DecimalField(
        max_digits=10,
        decimal_places=8,
        null=True,
        blank=True
    )
    longitude = models.DecimalField(
        max_digits=11,
        decimal_places=8,
        null=True,
        blank=True
    )
    
    # Métadonnées
    is_read = models.BooleanField(default=False)
    read_at = models.DateTimeField(null=True, blank=True)
    
    # Firebase sync
    is_synced_to_firebase = models.BooleanField(default=False)
    
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'chat_messages'
        verbose_name = 'Chat Message'
        verbose_name_plural = 'Chat Messages'
        ordering = ['created_at']
        indexes = [
            models.Index(fields=['chat_room', 'created_at']),
            models.Index(fields=['sender', 'created_at']),
            models.Index(fields=['is_read']),
        ]
    
    def __str__(self):
        return f"{self.sender.full_name}: {self.text[:50]}"
    
    def mark_as_read(self):
        """Marque le message comme lu"""
        if not self.is_read:
            self.is_read = True
            self.read_at = timezone.now()
            self.save(update_fields=['is_read', 'read_at'])
