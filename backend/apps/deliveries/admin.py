# deliveries/admin.py
from django.contrib import admin
from .models import Delivery
from .models_rating import DeliveryRating


@admin.register(Delivery)
class DeliveryAdmin(admin.ModelAdmin):
    list_display = ('tracking_number', 'merchant', 'driver', 'status', 'payment_method', 'calculated_price', 'assigned_at', 'delivered_at')
    list_filter = ('status', 'payment_method', 'assigned_at')
    search_fields = ('tracking_number', 'recipient_name', 'merchant__business_name', 'driver__user__email')
    readonly_fields = ('created_at', 'updated_at', 'signature_url', 'photo_url', 'delivery_confirmation_code')
    
    fieldsets = (
        (None, {'fields': ('tracking_number', 'merchant', 'driver', 'status', 'payment_method')}),
        ('Informations colis', {'fields': ('package_description', 'package_weight_kg', 'is_fragile')}),
        ('Adresses', {'fields': ('pickup_address', 'delivery_address', 'delivery_commune', 'delivery_quartier')}),
        ('Destinataire', {'fields': ('recipient_name', 'recipient_phone', 'recipient_alternative_phone')}),
        ('Tarif et Paiement', {'fields': ('calculated_price', 'actual_price', 'payment_status', 'cod_amount')}),
        ('Preuve de Livraison', {'fields': ('signature_url', 'photo_url', 'delivery_confirmation_code')}),
        ('Dates', {'fields': ('assigned_at', 'picked_up_at', 'delivered_at', 'cancelled_at')}),
    )


@admin.register(DeliveryRating)
class DeliveryRatingAdmin(admin.ModelAdmin):
    list_display = ('delivery', 'driver', 'merchant', 'rating', 'created_at')
    list_filter = ('rating', 'created_at')
    search_fields = ('delivery__tracking_number', 'driver__user__first_name', 'driver__user__last_name', 'merchant__business_name')
    readonly_fields = ('created_at', 'updated_at')
    
    fieldsets = (
        ('Évaluation', {
            'fields': ('delivery', 'merchant', 'driver', 'rating', 'comment')
        }),
        ('Critères détaillés', {
            'fields': ('punctuality_rating', 'professionalism_rating', 'care_rating'),
            'classes': ('collapse',)
        }),
        ('Métadonnées', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
