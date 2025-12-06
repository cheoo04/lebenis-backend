# merchants/admin.py
from django.contrib import admin
from django.utils import timezone
from .models import Merchant, MerchantAddress

@admin.register(Merchant)
class MerchantAdmin(admin.ModelAdmin):
    list_display = ('business_name', 'user', 'verification_status', 'verification_date', 'commission_rate', 'created_at')
    list_filter = ('verification_status',)
    search_fields = ('business_name', 'user__email', 'registration_number')
    readonly_fields = ('created_at', 'updated_at', 'verification_date')
    fieldsets = (
        ('Information commerciale', {
            'fields': ('user', 'business_name', 'business_type', 'registration_number', 'tax_id')
        }),
        ('Vérification', {
            'fields': ('verification_status', 'verification_date', 'rejection_reason')
        }),
        ('Documents', {
            'fields': ('rccm_document', 'id_document', 'documents_url')
        }),
        ('Paramètres commerciaux', {
            'fields': ('commission_rate', 'credit_limit')
        }),
        ('Dates', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    actions = ['verify_merchants', 'reject_merchants']

    def verify_merchants(self, request, queryset):
        updated = 0
        for merchant in queryset:
            merchant.verification_status = 'verified'
            merchant.verification_date = timezone.now()
            merchant.save()
            updated += 1
        self.message_user(request, f"{updated} commerçant(s) vérifié(s).")
    verify_merchants.short_description = "Marquer sélection comme Vérifié"

    def reject_merchants(self, request, queryset):
        # Ouvrir une page pour demander la raison du rejet
        updated = 0
        for merchant in queryset:
            merchant.verification_status = 'rejected'
            merchant.save()
            updated += 1
        self.message_user(request, f"{updated} commerçant(s) rejeté(s).")
    reject_merchants.short_description = "Marquer sélection comme Rejeté"

@admin.register(MerchantAddress)
class MerchantAddressAdmin(admin.ModelAdmin):
    list_display = ('merchant', 'address_name', 'street_address', 'commune', 'quartier', 'is_primary')
    list_filter = ('commune', 'is_primary')
    search_fields = ('street_address', 'merchant__business_name')
