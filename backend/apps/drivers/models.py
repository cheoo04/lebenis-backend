# backend/drivers/models.py
from django.db import models
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
        ('offline', 'Hors ligne'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='driver_profile')
    
    driver_license = models.CharField(max_length=100, blank=True)
    license_expiry = models.DateField(null=True, blank=True)
    vehicle_type = models.CharField(max_length=50, choices=VEHICLE_CHOICES)
    vehicle_registration = models.CharField(max_length=50, blank=True)
    vehicle_capacity_kg = models.DecimalField(max_digits=5, decimal_places=2, default=30.00)
    
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
