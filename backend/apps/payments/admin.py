# apps/payments/admin.py

from django.contrib import admin
from .models import Invoice, InvoiceItem, DriverEarning, DriverPayment


@admin.register(Invoice)
class InvoiceAdmin(admin.ModelAdmin):
    list_display = [
        'invoice_number', 'merchant', 'status', 
        'total_amount', 'due_date', 'paid_at', 'created_at'
    ]
    list_filter = ['status', 'created_at', 'due_date']
    search_fields = ['invoice_number', 'merchant__business_name']
    readonly_fields = [
        'invoice_number', 'total_deliveries', 'subtotal',
        'commission_amount', 'tax_amount', 'total_amount',
        'paid_at', 'created_at', 'updated_at'
    ]
    fieldsets = (
        ('Informations de base', {
            'fields': ('invoice_number', 'merchant', 'status')
        }),
        ('Période', {
            'fields': ('period_start', 'period_end')
        }),
        ('Montants', {
            'fields': (
                'total_deliveries', 'subtotal',
                'commission_rate', 'commission_amount',
                'tax_rate', 'tax_amount',
                'discount_amount', 'total_amount'
            )
        }),
        ('Paiement', {
            'fields': ('due_date', 'payment_method', 'payment_reference', 'paid_at')
        }),
        ('Notes', {
            'fields': ('notes',)
        }),
        ('Dates', {
            'fields': ('created_at', 'updated_at')
        }),
    )


@admin.register(InvoiceItem)
class InvoiceItemAdmin(admin.ModelAdmin):
    list_display = ['invoice', 'delivery', 'amount', 'created_at']
    list_filter = ['created_at']
    search_fields = ['invoice__invoice_number', 'delivery__tracking_number']
    readonly_fields = ['created_at']


@admin.register(DriverEarning)
class DriverEarningAdmin(admin.ModelAdmin):
    list_display = [
        'driver', 'delivery', 'total_earning',
        'status', 'approved_at', 'paid_at', 'created_at'
    ]
    list_filter = ['status', 'created_at', 'approved_at']
    search_fields = ['driver__user__first_name', 'driver__user__last_name', 'delivery__tracking_number']
    readonly_fields = ['total_earning', 'approved_at', 'paid_at', 'created_at', 'updated_at']
    fieldsets = (
        ('Informations de base', {
            'fields': ('driver', 'delivery', 'status')
        }),
        ('Gains', {
            'fields': (
                'base_earning', 'distance_bonus', 'time_bonus',
                'quality_bonus', 'other_bonus'
            )
        }),
        ('Pénalités', {
            'fields': ('penalty', 'penalty_reason')
        }),
        ('Total', {
            'fields': ('total_earning',)
        }),
        ('Statut', {
            'fields': ('approved_at', 'paid_at')
        }),
        ('Notes', {
            'fields': ('notes',)
        }),
        ('Dates', {
            'fields': ('created_at', 'updated_at')
        }),
    )


@admin.register(DriverPayment)
class DriverPaymentAdmin(admin.ModelAdmin):
    list_display = [
        'payment_number', 'driver', 'total_amount',
        'status', 'paid_at', 'created_at'
    ]
    list_filter = ['status', 'created_at']
    search_fields = ['payment_number', 'driver__user__first_name', 'driver__user__last_name']
    readonly_fields = [
        'payment_number', 'total_deliveries', 'total_amount',
        'paid_at', 'created_at', 'updated_at'
    ]
    fieldsets = (
        ('Informations de base', {
            'fields': ('payment_number', 'driver', 'status')
        }),
        ('Période', {
            'fields': ('period_start', 'period_end')
        }),
        ('Montants', {
            'fields': ('total_deliveries', 'total_amount')
        }),
        ('Paiement', {
            'fields': ('payment_method', 'payment_reference', 'paid_at')
        }),
        ('Notes', {
            'fields': ('notes',)
        }),
        ('Dates', {
            'fields': ('created_at', 'updated_at')
        }),
    )

