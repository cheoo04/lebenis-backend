# apps/payments/models.py

from django.db import models
from django.core.validators import MinValueValidator
from apps.merchants.models import Merchant
from apps.drivers.models import Driver
from apps.deliveries.models import Delivery
import uuid
from decimal import Decimal
from datetime import datetime
from django.utils import timezone


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


# ==============================================================================
# MODÈLES MOBILE MONEY & PAIEMENTS EN TEMPS RÉEL (Phase 2)
# ==============================================================================

class Payment(models.Model):
    """
    Paiement Mobile Money pour une livraison (Orange Money, MTN, etc.).
    Gère les transactions en temps réel et COD (Cash on Delivery).
    Commission: 10% pour LeBeni's
    """
    
    PAYMENT_METHOD_CHOICES = [
        ('orange_money', 'Orange Money'),
        ('mtn_money', 'MTN Mobile Money'),
        ('moov_money', 'Moov Money'),
        ('wave', 'Wave'),
        ('cash', 'Cash (COD)'),
    ]
    
    STATUS_CHOICES = [
        ('pending', 'En attente'),
        ('processing', 'En cours'),
        ('completed', 'Complété'),
        ('failed', 'Échoué'),
        ('refunded', 'Remboursé'),
    ]
    
    TRANSACTION_TYPE_CHOICES = [
        ('collection', 'Collecte client'),  # Client → LeBeni's
        ('disbursement', 'Versement livreur'),  # LeBeni's → Livreur
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    delivery = models.OneToOneField(
        Delivery, 
        on_delete=models.CASCADE, 
        related_name='mobile_money_payment',
        help_text='Livraison associée à ce paiement'
    )
    driver = models.ForeignKey(
        Driver,
        on_delete=models.CASCADE,
        related_name='mobile_money_payments',
        help_text='Livreur qui recevra le paiement'
    )
    
    # Montants (en FCFA)
    total_amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        validators=[MinValueValidator(Decimal('0.01'))],
        help_text='Montant total de la livraison (FCFA)'
    )
    platform_commission = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text='Commission LeBeni\'s (20%)'
    )
    transaction_fee = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text='Frais de transaction Mobile Money'
    )
    driver_amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        validators=[MinValueValidator(Decimal('0.00'))],
        help_text='Montant que le livreur recevra (80%)'
    )
    
    # Mobile Money
    payment_method = models.CharField(
        max_length=20,
        choices=PAYMENT_METHOD_CHOICES,
        help_text='Méthode de paiement utilisée'
    )
    transaction_type = models.CharField(
        max_length=20,
        choices=TRANSACTION_TYPE_CHOICES,
        default='collection'
    )
    
    # Références externes (API Mobile Money)
    transaction_id = models.CharField(
        max_length=255,
        blank=True,
        null=True,
        unique=True,
        db_index=True,
        help_text='ID de transaction Mobile Money (Orange/MTN)'
    )
    reference = models.CharField(
        max_length=100,
        blank=True,
        help_text='Référence interne LeBeni\'s'
    )
    external_reference = models.CharField(
        max_length=255,
        blank=True,
        null=True,
        help_text='Référence externe API Mobile Money'
    )
    
    # Statut et tracking
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending',
        db_index=True
    )
    error_message = models.TextField(
        blank=True,
        help_text='Message d\'erreur en cas d\'échec'
    )
    
    # Métadonnées
    metadata = models.JSONField(
        default=dict,
        blank=True,
        help_text='Données supplémentaires (réponse API, etc.)'
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    completed_at = models.DateTimeField(
        null=True,
        blank=True,
        help_text='Date de complétion du paiement'
    )
    failed_at = models.DateTimeField(
        null=True,
        blank=True,
        help_text='Date d\'échec du paiement'
    )
    
    class Meta:
        db_table = 'mobile_money_payments'
        verbose_name = 'Paiement Mobile Money'
        verbose_name_plural = 'Paiements Mobile Money'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['driver', 'status']),
            models.Index(fields=['created_at', 'status']),
            models.Index(fields=['payment_method', 'status']),
        ]
    
    def __str__(self):
        return f"Payment {self.reference} - {self.get_status_display()}"
    
    def save(self, *args, **kwargs):
        """Calcule automatiquement les montants avant sauvegarde"""
        if not self.reference:
            # Générer référence unique
            date_str = timezone.now().strftime('%Y%m%d')
            self.reference = f"PAY-{date_str}-{str(self.id)[:8].upper()}"
        
        # Calculer commission (20%)
        if not self.platform_commission:
            self.platform_commission = (self.total_amount * Decimal('0.20')).quantize(Decimal('0.01'))
        
        # Calculer montant livreur (total - commission - frais)
        self.driver_amount = (
            self.total_amount - self.platform_commission - self.transaction_fee
        ).quantize(Decimal('0.01'))
        
        super().save(*args, **kwargs)
    
    @property
    def is_mobile_money(self):
        """Vérifie si c'est un paiement Mobile Money"""
        return self.payment_method in ['orange_money', 'mtn_money', 'moov_money', 'wave']
    
    @property
    def is_cash(self):
        """Vérifie si c'est un paiement cash"""
        return self.payment_method == 'cash'


class DailyPayout(models.Model):
    """
    Versement journalier groupé pour un livreur.
    Déclenché automatiquement à 23h59 chaque jour via Celery.
    """
    
    STATUS_CHOICES = [
        ('pending', 'En attente'),
        ('processing', 'En cours'),
        ('completed', 'Complété'),
        ('failed', 'Échoué'),
        ('partially_failed', 'Partiellement échoué'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    driver = models.ForeignKey(
        Driver,
        on_delete=models.CASCADE,
        related_name='daily_payouts'
    )
    
    # Période
    payout_date = models.DateField(
        db_index=True,
        help_text='Date du versement (jour des livraisons)'
    )
    
    # Montants
    total_deliveries = models.IntegerField(
        default=0,
        help_text='Nombre de livraisons complétées ce jour'
    )
    total_earnings = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text='Gains totaux avant déductions'
    )
    platform_commission = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text='Total commission LeBeni\'s (20%)'
    )
    transaction_fees = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text='Total frais Mobile Money'
    )
    net_payout = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=Decimal('0.00'),
        help_text='Montant net versé au livreur (80%)'
    )
    
    # Mobile Money
    payment_method = models.CharField(
        max_length=20,
        help_text='Méthode de versement (orange_money, mtn_money, etc.)'
    )
    transaction_id = models.CharField(
        max_length=255,
        blank=True,
        null=True,
        help_text='ID transaction Mobile Money du versement'
    )
    
    # Statut
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending',
        db_index=True
    )
    error_message = models.TextField(blank=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    processed_at = models.DateTimeField(
        null=True,
        blank=True,
        help_text='Date de traitement du versement'
    )
    completed_at = models.DateTimeField(null=True, blank=True)
    
    # Relations
    payments = models.ManyToManyField(
        Payment,
        related_name='daily_payouts',
        help_text='Paiements individuels inclus dans ce versement'
    )
    
    class Meta:
        db_table = 'daily_payouts'
        verbose_name = 'Versement Journalier'
        verbose_name_plural = 'Versements Journaliers'
        ordering = ['-payout_date', '-created_at']
        unique_together = [('driver', 'payout_date')]
        indexes = [
            models.Index(fields=['driver', 'payout_date']),
            models.Index(fields=['status', 'payout_date']),
        ]
    
    def __str__(self):
        return f"Payout {self.driver.user.full_name} - {self.payout_date} ({self.net_payout} FCFA)"


class TransactionHistory(models.Model):
    """
    Historique de toutes les transactions financières.
    Audit trail pour comptabilité et réconciliation.
    """
    
    TRANSACTION_TYPE_CHOICES = [
        ('collection', 'Collecte'),  # Client paie
        ('disbursement', 'Versement'),  # LeBeni's paie livreur
        ('refund', 'Remboursement'),
        ('commission', 'Commission'),
        ('fee', 'Frais'),
    ]
    
    STATUS_CHOICES = [
        ('pending', 'En attente'),
        ('completed', 'Complété'),
        ('failed', 'Échoué'),
        ('cancelled', 'Annulé'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Type et montant
    transaction_type = models.CharField(
        max_length=20,
        choices=TRANSACTION_TYPE_CHOICES,
        db_index=True
    )
    amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        validators=[MinValueValidator(Decimal('0.01'))]
    )
    currency = models.CharField(max_length=3, default='XOF')  # FCFA
    
    # Parties impliquées
    driver = models.ForeignKey(
        Driver,
        on_delete=models.CASCADE,
        related_name='transaction_history',
        null=True,
        blank=True
    )
    
    # Références
    payment = models.ForeignKey(
        Payment,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='transaction_logs'
    )
    external_reference = models.CharField(
        max_length=255,
        blank=True,
        help_text='Référence externe (Orange Money, MTN, etc.)'
    )
    
    # Détails Mobile Money
    provider = models.CharField(
        max_length=50,
        blank=True,
        help_text='Fournisseur Mobile Money'
    )
    phone_number = models.CharField(
        max_length=20,
        blank=True,
        help_text='Numéro ayant effectué la transaction'
    )
    
    # Statut
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending',
        db_index=True
    )
    error_code = models.CharField(max_length=50, blank=True)
    error_message = models.TextField(blank=True)
    
    # Métadonnées
    metadata = models.JSONField(
        default=dict,
        blank=True,
        help_text='Réponse complète de l\'API Mobile Money'
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        db_table = 'transaction_history'
        verbose_name = 'Transaction'
        verbose_name_plural = 'Transactions'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['driver', 'transaction_type', 'created_at']),
            models.Index(fields=['status', 'created_at']),
            models.Index(fields=['provider', 'status']),
        ]
    
    def __str__(self):
        return f"{self.get_transaction_type_display()} - {self.amount} FCFA ({self.status})"
