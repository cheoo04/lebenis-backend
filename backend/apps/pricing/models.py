# pricing/models.py
from django.db import models
import uuid

class PricingZone(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    zone_name = models.CharField(max_length=100)
    commune = models.CharField(max_length=100)
    quartier = models.CharField(max_length=100, blank=True, null=True)
    description = models.TextField(blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'pricing_zones'
        verbose_name = 'Zone Tarifaire'
        verbose_name_plural = 'Zones Tarifaires'
    
    def __str__(self):
        return f"{self.zone_name} - {self.commune}"

class ZonePricingMatrix(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    origin_zone = models.ForeignKey(PricingZone, related_name='origin_matrix', on_delete=models.CASCADE)
    destination_zone = models.ForeignKey(PricingZone, related_name='destination_matrix', on_delete=models.CASCADE)
    base_rate = models.DecimalField(max_digits=10, decimal_places=2)
    per_kg_rate = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    per_km_rate = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    max_weight_included = models.DecimalField(max_digits=5, decimal_places=2, default=5.0)
    effective_from = models.DateField()
    effective_to = models.DateField(blank=True, null=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'zone_pricing_matrix'
        verbose_name = 'Tarification Zone'
        verbose_name_plural = 'Tarifications Zones'
    
    def __str__(self):
        return f"{self.origin_zone.zone_name} → {self.destination_zone.zone_name}: {self.base_rate} CFA"
