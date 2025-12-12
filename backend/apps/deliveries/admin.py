from django.contrib import admin
from .models import Delivery
from .models_rating import DeliveryRating


@admin.register(Delivery)
class DeliveryAdmin(admin.ModelAdmin):
    list_display = (
        'tracking_number', 'merchant', 'driver', 'status', 'payment_method',
        'calculated_price', 'assigned_at', 'picked_up_at', 'delivered_at',
        'pickup_commune', 'pickup_quartier', 'delivery_commune', 'delivery_quartier',
    )

    list_filter = ('status', 'payment_method', 'assigned_at', 'is_fragile')
    search_fields = ('tracking_number', 'recipient_name', 'merchant__business_name', 'driver__user__email', 'pickup_commune', 'delivery_commune')

    readonly_fields = ('tracking_number', 'created_at', 'updated_at', 'signature_url', 'photo_url', 'delivery_confirmation_code', 'calculated_price', 'distance_km')

    fieldsets = (
        (None, {'fields': ('tracking_number', 'merchant', 'driver', 'created_by', 'status', 'payment_method')}),
        ('Pickup', {'fields': ('pickup_address', 'pickup_address_details', 'pickup_commune', 'pickup_quartier', 'pickup_latitude', 'pickup_longitude')}),
        ('Delivery', {'fields': ('delivery_address', 'delivery_commune', 'delivery_quartier', 'delivery_latitude', 'delivery_longitude')}),
        ('Destinataire', {'fields': ('recipient_name', 'recipient_phone', 'recipient_alternative_phone')}),
        ('Informations colis', {'fields': ('package_description', 'package_weight_kg', 'package_length_cm', 'package_width_cm', 'package_height_cm', 'is_fragile')}),
        ('Tarif et Paiement', {'fields': ('calculated_price', 'actual_price', 'payment_status', 'cod_amount')}),
        ('Preuve de Livraison', {'fields': ('signature_url', 'photo_url', 'delivery_confirmation_code')}),
        ('Dates', {'fields': ('assigned_at', 'picked_up_at', 'delivered_at', 'cancelled_at')}),
    )

    # Lors de l'enregistrement via l'admin, laisser la logique du modèle gérer la synchronisation
    def save_model(self, request, obj, form, change):
        # Le modèle Delivery.save() synchronisera pickup_commune/quartier et coords si nécessaire
        super().save_model(request, obj, form, change)


@admin.register(DeliveryRating)
class DeliveryRatingAdmin(admin.ModelAdmin):
    list_display = ('delivery', 'driver', 'merchant', 'rated_by', 'rating', 'created_at')
    list_filter = ('rating', 'created_at')
    search_fields = ('delivery__tracking_number', 'driver__user__first_name', 'driver__user__last_name', 'merchant__business_name', 'rated_by__email')
    readonly_fields = ('created_at', 'updated_at')

    fieldsets = (
        ('Évaluation', {
            'fields': ('delivery', 'merchant', 'rated_by', 'driver', 'rating', 'comment')
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
