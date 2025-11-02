# apps/payments/models.py

from django.db import models
from apps.merchants.models import Merchant
from apps.drivers.models import Driver
from apps.deliveries.models import Delivery
import uuid
from decimal import Decimal
from datetime import datetime


# ==============================================================================
# MODÈLES DE FACTURATION POUR COMMERÇANTS
# ==============================================================================

class Invoice(models.Model):
    """
    Facture mensuelle pour un commerçant.
    Regroupe toutes les livraisons d'une période donnée.
    """
    
    STATUS_CHOICES = [
        ('draft', 'Brouillon'),
        ('sent', 'Envoyée'),
        ('paid', 'Payée'),
        ('overdue', 'En retard'),
        ('cancelled', 'Annulée'),
    ]
    
    PAYMENT_METHOD_CHOICES = [
        ('mobile_money', 'Mobile Money'),
        ('bank_transfer', 'Virement bancaire'),
        ('cash', 'Espèces'),
        ('card', 'Carte bancaire'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    invoice_number = models.CharField(max_length=50, unique=True, db_index=True)
    
    merchant = models.ForeignKey(Merchant, on_delete=models.CASCADE, related_name='invoices')
    
    # Période de facturation
    period_start = models.DateField()
    period_end = models.DateField()
    
    # Détails financiers
    total_deliveries = models.IntegerField(default=0)
    subtotal = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal('0'))
    
    commission_rate = models.DecimalField(max_digits=5, decimal_places=2, default=Decimal('10.00'))
    commission_amount = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal('0'))
    
    tax_rate = models.DecimalField(max_digits=5, decimal_places=2, default=Decimal('0'))
    tax_amount = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal('0'))
    
    discount_amount = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal('0'))
    total_amount = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal('0'))
    
    # Statut et paiement
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='draft')
    due_date = models.DateField()
    
    payment_method = models.CharField(max_length=50, choices=PAYMENT_METHOD_CHOICES, blank=True)
    payment_reference = models.CharField(max_length=100, blank=True)
    paid_at = models.DateTimeField(null=True, blank=True)
    
    # Notes
    notes = models.TextField(blank=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'invoices'
        verbose_name = 'Facture'
        verbose_name_plural = 'Factures'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['merchant', 'status']),
            models.Index(fields=['period_start', 'period_end']),
        ]
    
    def __str__(self):
        return f"{self.invoice_number} - {self.merchant.business_name}"
    
    def calculate_totals(self):
        """Recalcule tous les totaux de la facture"""
        items = self.items.all()
        
        self.total_deliveries = items.count()
        self.subtotal = sum(item.amount for item in items)
        
        # Commission (% du subtotal)
        self.commission_amount = self.subtotal * (self.commission_rate / Decimal('100'))
        
        # Taxe (% du subtotal)
        self.tax_amount = self.subtotal * (self.tax_rate / Decimal('100'))
        
        # Total = Subtotal + Commission + Taxe - Réduction
        self.total_amount = (
            self.subtotal + 
            self.commission_amount + 
            self.tax_amount - 
            self.discount_amount
        )
        
        self.save()
        return self.total_amount
    
    def mark_as_paid(self, payment_method, payment_reference=''):
        """Marque la facture comme payée"""
        from django.utils import timezone
        
        self.status = 'paid'
        self.payment_method = payment_method
        self.payment_reference = payment_reference
        self.paid_at = timezone.now()
        self.save()


class InvoiceItem(models.Model):
    """
    Ligne de facture représentant une livraison facturée.
    """
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    invoice = models.ForeignKey(Invoice, on_delete=models.CASCADE, related_name='items')
    delivery = models.OneToOneField(Delivery, on_delete=models.PROTECT, related_name='invoice_item')
    
    description = models.TextField()
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'invoice_items'
        verbose_name = 'Ligne de facture'
        verbose_name_plural = 'Lignes de factures'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.invoice.invoice_number} - {self.delivery.tracking_number}"


# ==============================================================================
# MODÈLES DE REVENUS POUR LIVREURS
# ==============================================================================

class DriverEarning(models.Model):
    """
    Gain d'un livreur pour une livraison spécifique.
    Inclut le salaire de base + bonus éventuels.
    """
    
    STATUS_CHOICES = [
        ('pending', 'En attente'),
        ('approved', 'Approuvé'),
        ('paid', 'Payé'),
        ('rejected', 'Rejeté'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    driver = models.ForeignKey(Driver, on_delete=models.CASCADE, related_name='earnings')
    delivery = models.OneToOneField(Delivery, on_delete=models.PROTECT, related_name='driver_earning')
    
    # Calcul du gain
    base_earning = models.DecimalField(max_digits=10, decimal_places=2, default=Decimal('0'))
    distance_bonus = models.DecimalField(max_digits=10, decimal_places=2, default=Decimal('0'))
    time_bonus = models.DecimalField(max_digits=10, decimal_places=2, default=Decimal('0'))
    quality_bonus = models.DecimalField(max_digits=10, decimal_places=2, default=Decimal('0'))
    other_bonus = models.DecimalField(max_digits=10, decimal_places=2, default=Decimal('0'))
    
    penalty = models.DecimalField(max_digits=10, decimal_places=2, default=Decimal('0'))
    penalty_reason = models.TextField(blank=True)
    
    total_earning = models.DecimalField(max_digits=10, decimal_places=2, default=Decimal('0'))
    
    # Statut
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    approved_at = models.DateTimeField(null=True, blank=True)
    paid_at = models.DateTimeField(null=True, blank=True)
    
    # Notes
    notes = models.TextField(blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'driver_earnings'
        verbose_name = 'Revenu Livreur'
        verbose_name_plural = 'Revenus Livreurs'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['driver', 'status']),
        ]
    
    def __str__(self):
        return f"{self.driver.user.full_name} - {self.delivery.tracking_number}: {self.total_earning} CFA"
    
    def calculate_total(self):
        """Calcule le total des gains"""
        self.total_earning = (
            self.base_earning +
            self.distance_bonus +
            self.time_bonus +
            self.quality_bonus +
            self.other_bonus -
            self.penalty
        )
        self.save()
        return self.total_earning
    
    def approve(self):
        """Approuve le gain du livreur"""
        from django.utils import timezone
        
        self.status = 'approved'
        self.approved_at = timezone.now()
        self.save()
    
    def mark_as_paid(self):
        """Marque le gain comme payé"""
        from django.utils import timezone
        
        self.status = 'paid'
        self.paid_at = timezone.now()
        self.save()


class DriverPayment(models.Model):
    """
    Paiement groupé pour un livreur.
    Regroupe plusieurs gains (DriverEarning) d'une période donnée.
    """
    
    STATUS_CHOICES = [
        ('pending', 'En attente'),
        ('processing', 'En traitement'),
        ('paid', 'Payé'),
        ('failed', 'Échoué'),
    ]
    
    PAYMENT_METHOD_CHOICES = [
        ('mobile_money', 'Mobile Money'),
        ('bank_transfer', 'Virement bancaire'),
        ('cash', 'Espèces'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    payment_number = models.CharField(max_length=50, unique=True, db_index=True)
    
    driver = models.ForeignKey(Driver, on_delete=models.CASCADE, related_name='payments')
    
    # Période
    period_start = models.DateField()
    period_end = models.DateField()
    
    # Détails
    total_deliveries = models.IntegerField(default=0)
    total_amount = models.DecimalField(max_digits=12, decimal_places=2, default=Decimal('0'))
    
    # Paiement
    payment_method = models.CharField(max_length=50, choices=PAYMENT_METHOD_CHOICES)
    payment_reference = models.CharField(max_length=100, blank=True)
    
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    paid_at = models.DateTimeField(null=True, blank=True)
    
    # Notes
    notes = models.TextField(blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'driver_payments'
        verbose_name = 'Paiement Livreur'
        verbose_name_plural = 'Paiements Livreurs'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['driver', 'status']),
        ]
    
    def __str__(self):
        return f"{self.payment_number} - {self.driver.user.full_name}: {self.total_amount} CFA"
    
    def calculate_total(self):
        """Calcule le total à partir des gains approuvés"""
        # Récupérer tous les gains approuvés de la période pour ce driver
        earnings = DriverEarning.objects.filter(
            driver=self.driver,
            status='approved',
            created_at__gte=self.period_start,
            created_at__lte=self.period_end
        )
        
        self.total_deliveries = earnings.count()
        self.total_amount = sum(e.total_earning for e in earnings)
        self.save()
        
        return self.total_amount
    
    def mark_as_paid(self):
        """Marque le paiement comme payé et met à jour les gains associés"""
        from django.utils import timezone
        
        self.status = 'paid'
        self.paid_at = timezone.now()
        self.save()
        
        # Marquer tous les gains de la période comme payés
        earnings = DriverEarning.objects.filter(
            driver=self.driver,
            status='approved',
            created_at__gte=self.period_start,
            created_at__lte=self.period_end
        )
        
        for earning in earnings:
            earning.mark_as_paid()
