# drivers/admin.py
from django.contrib import admin
from .models import Driver, DriverZone

@admin.register(Driver)
class DriverAdmin(admin.ModelAdmin):
    list_display = ('user', 'vehicle_type', 'is_available', 'verification_status', 'rating', 'total_deliveries')
    list_filter = ('verification_status', 'vehicle_type', 'is_available')
    search_fields = ('user__email', 'user__first_name', 'user__last_name', 'vehicle_registration')
    readonly_fields = ('created_at', 'updated_at')
    actions = ['verify_drivers', 'reject_drivers']

    def verify_drivers(self, request, queryset):
        updated = queryset.update(verification_status='verified')
        self.message_user(request, f"{updated} livreur(s) vérifié(s).")
    verify_drivers.short_description = "Marquer sélection comme Vérifié"

    def reject_drivers(self, request, queryset):
        updated = queryset.update(verification_status='rejected')
        self.message_user(request, f"{updated} livreur(s) rejeté(s).")
    reject_drivers.short_description = "Marquer sélection comme Rejeté"

@admin.register(DriverZone)
class DriverZoneAdmin(admin.ModelAdmin):
    list_display = ('driver', 'commune', 'priority')
    list_filter = ('commune', 'priority')
    search_fields = ('driver__user__email', 'commune')
