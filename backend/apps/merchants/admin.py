# merchants/admin.py
from django.contrib import admin
from .models import Merchant, MerchantAddress

@admin.register(Merchant)
class MerchantAdmin(admin.ModelAdmin):
    list_display = ('business_name', 'user', 'verification_status', 'commission_rate', 'current_balance', 'created_at')
    list_filter = ('verification_status',)
    search_fields = ('business_name', 'user__email', 'registration_number')
    readonly_fields = ('created_at', 'updated_at')
    actions = ['verify_merchants', 'reject_merchants']

    def verify_merchants(self, request, queryset):
        updated = queryset.update(verification_status='verified')
        self.message_user(request, f"{updated} commerçant(s) vérifié(s).")
    verify_merchants.short_description = "Marquer sélection comme Vérifié"

    def reject_merchants(self, request, queryset):
        updated = queryset.update(verification_status='rejected')
        self.message_user(request, f"{updated} commerçant(s) rejeté(s).")
    reject_merchants.short_description = "Marquer sélection comme Rejeté"

@admin.register(MerchantAddress)
class MerchantAddressAdmin(admin.ModelAdmin):
    list_display = ('merchant', 'address_name', 'street_address', 'commune', 'quartier', 'is_primary')
    list_filter = ('commune', 'is_primary')
    search_fields = ('street_address', 'merchant__business_name')
