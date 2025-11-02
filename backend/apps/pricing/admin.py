# pricing/admin.py
from django.contrib import admin
from .models import PricingZone, ZonePricingMatrix

@admin.register(PricingZone)
class PricingZoneAdmin(admin.ModelAdmin):
    list_display = ('zone_name', 'commune', 'quartier', 'is_active')
    list_filter = ('commune', 'is_active')
    search_fields = ('zone_name', 'quartier')

@admin.register(ZonePricingMatrix)
class ZonePricingMatrixAdmin(admin.ModelAdmin):
    list_display = ('origin_zone', 'destination_zone', 'base_rate', 'per_kg_rate', 'per_km_rate', 'max_weight_included', 'effective_from', 'effective_to', 'is_active')
    list_filter = ('effective_from', 'effective_to', 'is_active')
    search_fields = ('origin_zone__zone_name', 'destination_zone__zone_name')
