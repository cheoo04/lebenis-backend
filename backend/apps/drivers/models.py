# backend/drivers/models.py
from django.db import models
from apps.authentication.models import User
import uuid

class Driver(models.Model):
    VEHICLE_CHOICES = [
        ('moto', 'Moto'),
        ('voiture', 'Voiture'),
        ('tricycle', 'Tricycle'),
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
