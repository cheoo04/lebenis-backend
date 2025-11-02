# apps/payments/serializers.py

from rest_framework import serializers
from .models import Invoice, InvoiceItem, DriverEarning, DriverPayment
from apps.merchants.serializers import MerchantSerializer
from apps.drivers.serializers import DriverSerializer
from apps.deliveries.serializers import DeliverySerializer


# ==============================================================================
# SERIALIZERS POUR FACTURES (MERCHANTS)
# ==============================================================================

class InvoiceItemSerializer(serializers.ModelSerializer):
    """Serializer pour les lignes de facture"""
    delivery = DeliverySerializer(read_only=True)
    
    class Meta:
        model = InvoiceItem
        fields = [
            'id', 'delivery', 'description', 'amount', 'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class InvoiceSerializer(serializers.ModelSerializer):
    """Serializer pour les factures commerçants"""
    merchant = MerchantSerializer(read_only=True)
    items = InvoiceItemSerializer(many=True, read_only=True)
    
    class Meta:
        model = Invoice
        fields = [
            'id', 'invoice_number', 'merchant', 'items',
            'period_start', 'period_end',
            'total_deliveries', 'subtotal', 
            'commission_rate', 'commission_amount',
            'tax_rate', 'tax_amount',
            'discount_amount', 'total_amount',
            'status', 'due_date',
            'payment_method', 'payment_reference', 'paid_at',
            'notes', 'created_at', 'updated_at'
        ]
        read_only_fields = [
            'id', 'invoice_number', 'total_deliveries', 'subtotal',
            'commission_amount', 'tax_amount', 'total_amount',
            'paid_at', 'created_at', 'updated_at'
        ]


class InvoiceCreateSerializer(serializers.ModelSerializer):
    """Serializer pour créer une facture"""
    
    class Meta:
        model = Invoice
        fields = [
            'merchant', 'period_start', 'period_end',
            'commission_rate', 'tax_rate', 'discount_amount',
            'due_date', 'notes'
        ]


class InvoicePaymentSerializer(serializers.Serializer):
    """Serializer pour marquer une facture comme payée"""
    payment_method = serializers.ChoiceField(choices=Invoice.PAYMENT_METHOD_CHOICES)
    payment_reference = serializers.CharField(max_length=100, required=False, allow_blank=True)


# ==============================================================================
# SERIALIZERS POUR REVENUS LIVREURS
# ==============================================================================

class DriverEarningSerializer(serializers.ModelSerializer):
    """Serializer pour les gains des livreurs"""
    driver = DriverSerializer(read_only=True)
    delivery = DeliverySerializer(read_only=True)
    
    class Meta:
        model = DriverEarning
        fields = [
            'id', 'driver', 'delivery',
            'base_earning', 'distance_bonus', 'time_bonus', 
            'quality_bonus', 'other_bonus',
            'penalty', 'penalty_reason', 'total_earning',
            'status', 'approved_at', 'paid_at',
            'notes', 'created_at', 'updated_at'
        ]
        read_only_fields = [
            'id', 'total_earning', 'approved_at', 'paid_at',
            'created_at', 'updated_at'
        ]


class DriverEarningCreateSerializer(serializers.ModelSerializer):
    """Serializer pour créer un gain de livreur"""
    
    class Meta:
        model = DriverEarning
        fields = [
            'driver', 'delivery',
            'base_earning', 'distance_bonus', 'time_bonus',
            'quality_bonus', 'other_bonus',
            'penalty', 'penalty_reason', 'notes'
        ]


class DriverEarningSummarySerializer(serializers.Serializer):
    """Serializer pour le résumé des gains d'un livreur"""
    total_earnings = serializers.DecimalField(max_digits=12, decimal_places=2)
    pending_amount = serializers.DecimalField(max_digits=12, decimal_places=2)
    approved_amount = serializers.DecimalField(max_digits=12, decimal_places=2)
    paid_amount = serializers.DecimalField(max_digits=12, decimal_places=2)
    total_deliveries = serializers.IntegerField()
    pending_deliveries = serializers.IntegerField()


class DriverPaymentSerializer(serializers.ModelSerializer):
    """Serializer pour les paiements groupés aux livreurs"""
    driver = DriverSerializer(read_only=True)
    
    class Meta:
        model = DriverPayment
        fields = [
            'id', 'payment_number', 'driver',
            'period_start', 'period_end',
            'total_deliveries', 'total_amount',
            'payment_method', 'payment_reference',
            'status', 'paid_at', 'notes',
            'created_at', 'updated_at'
        ]
        read_only_fields = [
            'id', 'payment_number', 'total_deliveries', 'total_amount',
            'paid_at', 'created_at', 'updated_at'
        ]


class DriverPaymentCreateSerializer(serializers.ModelSerializer):
    """Serializer pour créer un paiement livreur"""
    
    class Meta:
        model = DriverPayment
        fields = [
            'driver', 'period_start', 'period_end',
            'payment_method', 'payment_reference', 'notes'
        ]
