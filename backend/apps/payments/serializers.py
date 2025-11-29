# apps/payments/serializers.py

from rest_framework import serializers
from .models import (
    Invoice, InvoiceItem, DriverEarning, DriverPayment,
    Payment, DailyPayout, TransactionHistory
)
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


# ==============================================================================
# SERIALIZERS POUR PAIEMENTS MOBILE MONEY (PHASE 2)
# ==============================================================================

class PaymentSerializer(serializers.ModelSerializer):
    """Serializer pour les paiements Mobile Money individuels"""
    driver = DriverSerializer(read_only=True)
    delivery = DeliverySerializer(read_only=True)
    
    # Champs calculés
    commission_percentage = serializers.SerializerMethodField()
    
    class Meta:
        model = Payment
        fields = [
            'id', 'driver', 'delivery',
            'total_amount', 'driver_amount', 'platform_commission',
            'commission_percentage',
            'payment_method',
            'status',
            'created_at', 'updated_at'
        ]
        read_only_fields = [
            'id', 'driver_amount', 'platform_commission',
            'created_at', 'updated_at'
        ]
    
    def get_commission_percentage(self, obj):
        """Retourne le pourcentage de commission (20%)"""
        return "20%"


class DailyPayoutSerializer(serializers.ModelSerializer):
    """Serializer pour les paiements journaliers groupés"""
    driver = DriverSerializer(read_only=True)
    
    # Champs calculés
    payment_count = serializers.SerializerMethodField()
    status_display = serializers.SerializerMethodField()
    
    class Meta:
        model = DailyPayout
        fields = [
            'id', 'driver', 'payout_date',
            'total_amount', 'payment_count',
            'payment_method', 'phone_number',
            'status', 'status_display',
            'provider_reference', 'paid_at',
            'created_at', 'updated_at'
        ]
        read_only_fields = [
            'id', 'total_amount', 'payment_count',
            'paid_at', 'created_at', 'updated_at'
        ]
    
    def get_payment_count(self, obj):
        """Nombre de paiements dans ce payout"""
        return obj.payments.count()
    
    def get_status_display(self, obj):
        """Affichage du statut en français"""
        status_map = {
            'pending': 'En attente',
            'processing': 'En traitement',
            'completed': 'Complété',
            'failed': 'Échoué'
        }
        return status_map.get(obj.status, obj.status)


class TransactionHistorySerializer(serializers.ModelSerializer):
    """Serializer pour l'historique des transactions"""
    payment = PaymentSerializer(read_only=True)
    
    # Champs calculés
    transaction_type_display = serializers.SerializerMethodField()
    status_display = serializers.SerializerMethodField()
    
    class Meta:
        model = TransactionHistory
        fields = [
            'id', 'payment', 'transaction_type',
            'transaction_type_display',
            'amount', 'status', 'status_display',
            'provider_reference', 'error_message',
            'created_at'
        ]
        read_only_fields = ['id', 'created_at']
    
    def get_transaction_type_display(self, obj):
        """Affichage du type en français"""
        type_map = {
            'collection': 'Collecte client',
            'disbursement': 'Transfert driver',
            'refund': 'Remboursement'
        }
        return type_map.get(obj.transaction_type, obj.transaction_type)
    
    def get_status_display(self, obj):
        """Affichage du statut en français"""
        status_map = {
            'pending': 'En attente',
            'success': 'Succès',
            'failed': 'Échoué'
        }
        return status_map.get(obj.status, obj.status)


# ==============================================================================
# SERIALIZER POUR INPUT SESSION WAVE
# ==============================================================================

class WaveSessionInputSerializer(serializers.Serializer):
    amount = serializers.DecimalField(max_digits=12, decimal_places=2)
    currency = serializers.CharField(max_length=8)
    error_url = serializers.URLField()
    success_url = serializers.URLField()
