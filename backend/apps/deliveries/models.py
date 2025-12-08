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
    pickup_quartier = models.CharField(max_length=100, blank=True, help_text="Quartier de départ pour plus de précision")
    pickup_latitude = models.DecimalField(max_digits=10, decimal_places=8, null=True, blank=True)
    pickup_longitude = models.DecimalField(max_digits=11, decimal_places=8, null=True, blank=True)
    
    # Adresse de livraison
    delivery_address = models.CharField(max_length=255, blank=True, help_text="Adresse complète (optionnel - la commune et quartier suffisent)")
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
    # Source de la distance calculée: 'osrm', 'openrouteservice', 'fallback_straight_line', 'app_osrm', etc.
    distance_source = models.CharField(max_length=50, null=True, blank=True)
    
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
    # Preuves d'enlèvement (pickup)
    pickup_photo_url = models.CharField(max_length=500, blank=True)
    pickup_signature_url = models.CharField(max_length=500, blank=True)
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

    def save(self, *args, **kwargs):
        """
        Synchronise les champs `pickup_commune`, `pickup_quartier`, `pickup_latitude` et `pickup_longitude`
        depuis la `pickup_address` si cette dernière est fournie et que les champs individuels sont absents.
        Cette logique garantit que le reste du système (prix/zones) dispose toujours des valeurs
        `pickup_commune`/`pickup_quartier` attendues.
        """
        try:
            # Si une adresse merchant est liée, copier les valeurs manquantes
            if self.pickup_address:
                if not self.pickup_commune:
                    self.pickup_commune = (self.pickup_address.commune or '').strip()
                if not self.pickup_quartier:
                    self.pickup_quartier = (self.pickup_address.quartier or '').strip()
                # Copier les coords si elles existent et que le delivery n'en a pas
                try:
                    if (self.pickup_address.latitude is not None and self.pickup_address.longitude is not None) and (
                        (self.pickup_latitude is None) or (self.pickup_longitude is None)
                    ):
                        self.pickup_latitude = self.pickup_address.latitude
                        self.pickup_longitude = self.pickup_address.longitude
                except Exception:
                    # Ne pas bloquer la sauvegarde pour une adresse mal formée
                    pass

            # Si delivery_address is present but delivery_commune empty, try to leave as-is
            # (nous n'écrasons pas delivery_commune automatiquement ici)
        except Exception:
            # Défensive : en cas d'erreur, continuer la sauvegarde normale
            pass

        super().save(*args, **kwargs)

    def get_coords(self, which='pickup'):
        """
        Retourne un tuple (latitude, longitude) en float pour 'pickup' ou 'delivery'.
        Si les coordonnées ne sont pas disponibles ou invalides, retourne None.

        Usage:
            delivery.get_coords('pickup')  -> (lat, lon) | None
            delivery.get_coords('delivery') -> (lat, lon) | None
        """
        try:
            if which == 'pickup':
                lat = self.pickup_latitude
                lon = self.pickup_longitude
            elif which == 'delivery':
                lat = self.delivery_latitude
                lon = self.delivery_longitude
            else:
                return None

            if lat is None or lon is None:
                return None

            return (float(lat), float(lon))
        except (TypeError, ValueError, Exception):
            return None
