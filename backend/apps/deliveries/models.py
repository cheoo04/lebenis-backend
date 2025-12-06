# backend/deliveries/models.py
from django.db import models
from apps.merchants.models import Merchant, MerchantAddress
from apps.drivers.models import Driver
from apps.authentication.models import User
import uuid
import random
import string
from datetime import datetime

def generate_tracking_number():
    """Génère un numéro de suivi unique"""
    prefix = 'LB'
    timestamp = str(int(datetime.now().timestamp()))[-8:]
    random_part = ''.join(random.choices(string.digits, k=4))
    return f"{prefix}{timestamp}{random_part}"

class Delivery(models.Model):
    STATUS_CHOICES = [
        ('pending', 'En attente'),
        ('in_progress', 'En cours'),
        ('delivered', 'Livré'),
        ('cancelled', 'Annulé'),
    ]
    
    PAYMENT_METHOD_CHOICES = [
        ('prepaid', 'Prépayé'),
        ('cod', 'Paiement à la livraison'),
    ]
    
    SCHEDULING_CHOICES = [
        ('immediate', 'Immédiat'),
        ('scheduled', 'Planifié'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    tracking_number = models.CharField(max_length=50, unique=True, default=generate_tracking_number)
    
    # Créateur de la livraison (peut être merchant ou individual)
    created_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name='created_deliveries', null=True, blank=True)
    merchant = models.ForeignKey(Merchant, on_delete=models.CASCADE, related_name='deliveries', null=True, blank=True)
    driver = models.ForeignKey(Driver, on_delete=models.SET_NULL, null=True, blank=True, related_name='deliveries')
    
    # Adresse d'enlèvement
    pickup_address = models.ForeignKey(MerchantAddress, on_delete=models.SET_NULL, null=True, blank=True)
    pickup_address_details = models.CharField(max_length=255, blank=True, help_text="Adresse complète si différente des adresses sauvegardées")
    pickup_commune = models.CharField(max_length=100, blank=True, help_text="Commune de départ (ex: Cocody)")
    pickup_latitude = models.DecimalField(max_digits=10, decimal_places=8, null=True, blank=True)
    pickup_longitude = models.DecimalField(max_digits=11, decimal_places=8, null=True, blank=True)
    
    # Adresse de livraison
    delivery_address = models.CharField(max_length=255)
    delivery_commune = models.CharField(max_length=100)
    delivery_quartier = models.CharField(max_length=100, blank=True)
    delivery_latitude = models.DecimalField(max_digits=10, decimal_places=8, null=True, blank=True)
    delivery_longitude = models.DecimalField(max_digits=11, decimal_places=8, null=True, blank=True)
    
    # Détails du colis
    package_description = models.TextField(blank=True)
    package_weight_kg = models.DecimalField(max_digits=5, decimal_places=2)
    package_length_cm = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    # Type de véhicule requis pour la livraison (optionnel)
    required_vehicle_type = models.CharField(
        max_length=50,
        blank=True,
        help_text="Type de véhicule requis (moto, voiture, tricycle, camionnette)",
        choices=[
            ('', 'Indifférent'),
            ('moto', 'Moto'),
            ('voiture', 'Voiture'),
            ('tricycle', 'Tricycle'),
            ('camionnette', 'Camionnette'),
        ]
    )
    package_width_cm = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    package_height_cm = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    package_value = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    is_fragile = models.BooleanField(default=False)
    
    # Destinataire
    recipient_name = models.CharField(max_length=200)
    recipient_phone = models.CharField(max_length=20)
    recipient_alternative_phone = models.CharField(max_length=20, blank=True)
    
    # Tarification
    calculated_price = models.DecimalField(max_digits=10, decimal_places=2)
    actual_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    distance_km = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    
    # Paiement
    payment_method = models.CharField(max_length=20, choices=PAYMENT_METHOD_CHOICES)
    cod_amount = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    payment_status = models.CharField(max_length=20, default='pending')
    
    # Statuts et dates
    status = models.CharField(max_length=50, choices=STATUS_CHOICES, default='pending')
    scheduling_type = models.CharField(max_length=20, choices=SCHEDULING_CHOICES, default='immediate')
    scheduled_pickup_time = models.DateTimeField(null=True, blank=True)
    
    assigned_at = models.DateTimeField(null=True, blank=True)
    picked_up_at = models.DateTimeField(null=True, blank=True)
    delivered_at = models.DateTimeField(null=True, blank=True)
    cancelled_at = models.DateTimeField(null=True, blank=True)
    cancellation_reason = models.TextField(blank=True)
    
    # Preuve de livraison
    signature_url = models.CharField(max_length=500, blank=True)
    photo_url = models.CharField(max_length=500, blank=True)
    delivery_notes = models.TextField(blank=True)
    delivery_confirmation_code = models.CharField(max_length=10, blank=True)

    def generate_confirmation_code(self):
        """Génère un code PIN à 4 chiffres"""
        import random
        return f"{random.randint(1000, 9999)}"
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'deliveries'
        verbose_name = 'Livraison'
        verbose_name_plural = 'Livraisons'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.tracking_number} - {self.status}"
