"""
GPS Location Tracking Models
Stores location history for drivers with adaptive tracking
"""
from django.db import models
from django.utils import timezone
from apps.drivers.models import Driver


class LocationUpdate(models.Model):
    """
    Stores GPS location updates from drivers
    Supports adaptive tracking based on driver status
    """
    driver = models.ForeignKey(
        Driver,
        on_delete=models.CASCADE,
        related_name='location_updates'
    )
    latitude = models.DecimalField(
        max_digits=10,
        decimal_places=8,
        help_text='Latitude GPS'
    )
    longitude = models.DecimalField(
        max_digits=11,
        decimal_places=8,
        help_text='Longitude GPS'
    )
    accuracy = models.FloatField(
        null=True,
        blank=True,
        help_text='Précision GPS en mètres'
    )
    speed = models.FloatField(
        null=True,
        blank=True,
        help_text='Vitesse en m/s'
    )
    heading = models.FloatField(
        null=True,
        blank=True,
        help_text='Direction en degrés (0-360)'
    )
    altitude = models.FloatField(
        null=True,
        blank=True,
        help_text='Altitude en mètres'
    )
    
    # Tracking context
    driver_status = models.CharField(
        max_length=20,
        help_text='Statut du chauffeur au moment de la mise à jour'
    )
    is_moving = models.BooleanField(
        default=False,
        help_text='Indique si le chauffeur est en mouvement'
    )
    battery_level = models.IntegerField(
        null=True,
        blank=True,
        help_text='Niveau de batterie (0-100)'
    )
    
    # Metadata
    timestamp = models.DateTimeField(
        default=timezone.now,
        db_index=True,
        help_text='Horodatage de la mise à jour'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-timestamp']
        indexes = [
            models.Index(fields=['driver', '-timestamp']),
            models.Index(fields=['driver', 'driver_status']),
            models.Index(fields=['-timestamp']),
        ]
        verbose_name = 'Location Update'
        verbose_name_plural = 'Location Updates'
    
    def __str__(self):
        return f"{self.driver.user.get_full_name()} - {self.timestamp}"
    
    @property
    def coordinates(self):
        """Return coordinates as tuple"""
        return (float(self.latitude), float(self.longitude))


class LocationTrackingSession(models.Model):
    """
    Tracks GPS tracking sessions for analytics and debugging
    """
    driver = models.ForeignKey(
        Driver,
        on_delete=models.CASCADE,
        related_name='tracking_sessions'
    )
    
    started_at = models.DateTimeField(
        default=timezone.now,
        db_index=True
    )
    ended_at = models.DateTimeField(
        null=True,
        blank=True
    )
    
    # Session statistics
    total_updates = models.IntegerField(default=0)
    average_accuracy = models.FloatField(null=True, blank=True)
    total_distance_km = models.FloatField(
        default=0.0,
        help_text='Distance totale parcourue pendant la session'
    )
    
    # Session metadata
    initial_battery_level = models.IntegerField(null=True, blank=True)
    final_battery_level = models.IntegerField(null=True, blank=True)
    
    class Meta:
        ordering = ['-started_at']
        indexes = [
            models.Index(fields=['driver', '-started_at']),
        ]
        verbose_name = 'Tracking Session'
        verbose_name_plural = 'Tracking Sessions'
    
    def __str__(self):
        return f"{self.driver.user.get_full_name()} - Session {self.started_at}"
    
    @property
    def duration(self):
        """Calculate session duration"""
        if self.ended_at:
            return self.ended_at - self.started_at
        return timezone.now() - self.started_at
    
    @property
    def battery_consumption(self):
        """Calculate battery consumption during session"""
        if self.initial_battery_level and self.final_battery_level:
            return self.initial_battery_level - self.final_battery_level
        return None
