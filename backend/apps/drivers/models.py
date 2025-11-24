# backend/drivers/models.py
from django.db import models
from django.core.validators import RegexValidator
from apps.authentication.models import User
import uuid

class Driver(models.Model):
    VEHICLE_CHOICES = [
        ('moto', 'Moto'),
        ('voiture', 'Voiture'),
        ('tricycle', 'Tricycle'),
        ('camionnette', 'Camionnette'),
    ]
    
    STATUS_CHOICES = [
        ('pending', 'En attente'),
        ('verified', 'Vérifié'),
        ('rejected', 'Rejeté'),
    ]
    
    AVAILABILITY_CHOICES = [
        ('available', 'Disponible'),
        ('busy', 'Occupé'),
        ('on_break', 'En pause'),
        ('offline', 'Hors ligne'),
    ]
    
    # Validation pour les plaques d'immatriculation
    VEHICLE_PLATE_VALIDATOR = RegexValidator(
        regex=r'^([A-Z]{2}\s\d{4}\s[A-Z]{2}|[A-Z]{2}\s\d{4}\s[A-Z]|\d{2}\s[A-Z]{2}\s\d{4})$',
        message=(
            "Format invalide. Formats acceptés: "
            "CEDEAO (AB 1234 CD), Sénégal (DK 1234 A), "
            "Côte d'Ivoire (12 AB 3456)"
        ),
        code='invalid_plate'
    )
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='driver_profile')
    
    driver_license = models.CharField(max_length=100, blank=True)
    license_expiry = models.DateField(null=True, blank=True)
    
    # Documents d'identité (SÉCURITÉ)
    identity_card_number = models.CharField(max_length=50, blank=True, help_text="Numéro CNI/Passeport")
    identity_card_front = models.URLField(max_length=500, blank=True, null=True, help_text="Photo recto CNI")
    identity_card_back = models.URLField(max_length=500, blank=True, null=True, help_text="Photo verso CNI")
    date_of_birth = models.DateField(null=True, blank=True)
    
    # Véhicule
    vehicle_type = models.CharField(max_length=50, choices=VEHICLE_CHOICES)
    vehicle_registration = models.CharField(
        max_length=50, 
        blank=True,
        validators=[VEHICLE_PLATE_VALIDATOR],
        help_text="Plaque d'immatriculation (ex: AB 1234 CD)"
    )
    vehicle_capacity_kg = models.DecimalField(max_digits=5, decimal_places=2, default=30.00)
    
    # Documents véhicule (CONFORMITÉ)
    vehicle_insurance = models.URLField(max_length=500, blank=True, null=True, help_text="Document assurance")
    vehicle_insurance_expiry = models.DateField(null=True, blank=True)
    vehicle_technical_inspection = models.URLField(max_length=500, blank=True, null=True, help_text="Visite technique")
    vehicle_inspection_expiry = models.DateField(null=True, blank=True)
    vehicle_gray_card = models.URLField(max_length=500, blank=True, null=True, help_text="Carte grise")
    vehicle_vignette = models.URLField(max_length=500, blank=True, null=True, help_text="Document vignette")
    vehicle_vignette_expiry = models.DateField(null=True, blank=True, help_text="Date d'expiration de la vignette")
    
    # Informations bancaires (PAIEMENTS)
    bank_account_name = models.CharField(max_length=200, blank=True)
    bank_account_number = models.CharField(max_length=50, blank=True)
    bank_name = models.CharField(max_length=100, blank=True)
    mobile_money_number = models.CharField(max_length=20, blank=True)
    mobile_money_provider = models.CharField(
        max_length=50,
        choices=[
            ('orange', 'Orange Money'),
            ('mtn', 'MTN Money'),
            ('moov', 'Moov Money'),
            ('wave', 'Wave'),
        ],
        blank=True
    )
    
    # Contact d'urgence (SÉCURITÉ)
    emergency_contact_name = models.CharField(max_length=200, blank=True)
    emergency_contact_phone = models.CharField(max_length=20, blank=True)
    emergency_contact_relationship = models.CharField(max_length=100, blank=True)
    
    # Professionnel
    years_of_experience = models.IntegerField(default=0, help_text="Années d'expérience en livraison")
    previous_employer = models.CharField(max_length=200, blank=True)
    languages_spoken = models.JSONField(default=list, blank=True, help_text="Liste des langues parlées")
    
    verification_status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    is_available = models.BooleanField(default=False)
    availability_status = models.CharField(
        max_length=20, 
        choices=AVAILABILITY_CHOICES, 
        default='offline',
        help_text='Statut de disponibilité: available, busy, offline'
    )
    
    current_latitude = models.DecimalField(max_digits=10, decimal_places=8, null=True, blank=True)
    current_longitude = models.DecimalField(max_digits=11, decimal_places=8, null=True, blank=True)
    
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=5.00)
    total_deliveries = models.IntegerField(default=0)
    successful_deliveries = models.IntegerField(default=0)
    
    # Gestion des pauses (Phase 2)
    is_on_break = models.BooleanField(
        default=False,
        help_text='Indique si le livreur est en pause'
    )
    break_started_at = models.DateTimeField(
        null=True,
        blank=True,
        help_text='Heure de début de la pause'
    )
    total_break_duration_today = models.DurationField(
        null=True,
        blank=True,
        help_text='Durée totale des pauses aujourd\'hui'
    )
    last_break_reset = models.DateField(
        null=True,
        blank=True,
        help_text='Dernière réinitialisation du compteur de pauses'
    )
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'drivers'
        verbose_name = 'Livreur'
        verbose_name_plural = 'Livreurs'
    
    def __str__(self):
        return f"{self.user.full_name} - {self.vehicle_type}"
    
    @property
    def max_package_dimensions(self):
        """
        Retourne les dimensions maximales (L x l x h en cm) que ce véhicule peut transporter
        Format: {'length': cm, 'width': cm, 'height': cm}
        """
        dimensions = {
            'moto': {'length': 50, 'width': 40, 'height': 50},  # Petit coffre ou sac à dos
            'tricycle': {'length': 120, 'width': 80, 'height': 80},  # Caisse arrière
            'voiture': {'length': 150, 'width': 100, 'height': 100},  # Coffre standard
            'camionnette': {'length': 300, 'width': 150, 'height': 150},  # Benne/caisse
        }
        return dimensions.get(self.vehicle_type, dimensions['moto'])
    
    @property
    def default_capacity_kg(self):
        """
        Retourne la capacité par défaut selon le type de véhicule
        """
        capacities = {
            'moto': 15.0,  # 15kg max
            'tricycle': 100.0,  # 100kg
            'voiture': 200.0,  # 200kg (coffre + banquette)
            'camionnette': 500.0,  # 500kg
        }
        return capacities.get(self.vehicle_type, 30.0)
    
    def can_handle_package(self, package_weight, package_length=None, package_width=None, package_height=None):
        """
        Vérifie si ce véhicule peut transporter un colis donné
        
        Args:
            package_weight: Poids en kg
            package_length: Longueur en cm (optionnel)
            package_width: Largeur en cm (optionnel)
            package_height: Hauteur en cm (optionnel)
        
        Returns:
            bool: True si le véhicule peut transporter le colis
        """
        # Vérifier le poids
        if package_weight > self.vehicle_capacity_kg:
            return False
        
        # Si dimensions fournies, vérifier qu'elles rentrent
        if package_length or package_width or package_height:
            max_dims = self.max_package_dimensions
            
            if package_length and package_length > max_dims['length']:
                return False
            if package_width and package_width > max_dims['width']:
                return False
            if package_height and package_height > max_dims['height']:
                return False
        
        return True

class DriverZone(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    driver = models.ForeignKey(Driver, on_delete=models.CASCADE, related_name='zones')
    commune = models.CharField(max_length=100)
    priority = models.IntegerField(default=1)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'driver_zones'
        verbose_name = 'Zone Livreur'
        verbose_name_plural = 'Zones Livreurs'
        unique_together = ['driver', 'commune']
    
    def __str__(self):
        return f"{self.driver.user.full_name} - {self.commune}"
