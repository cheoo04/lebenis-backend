# apps/payments/models_payment.py

import uuid
from decimal import Decimal
from django.db import models
from django.core.validators import MinValueValidator
from django.utils import timezone
from apps.deliveries.models import Delivery
from apps.drivers.models import Driver


class Payment(models.Model):
    """
    Représente un paiement pour une livraison.
    Gère les transactions Mobile Money et Cash on Delivery (COD).
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
        related_name='payment',
        help_text='Livraison associée à ce paiement'
    )
    driver = models.ForeignKey(
        Driver,
        on_delete=models.CASCADE,
        related_name='payments',
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
        help_text='Commission LeBeni\'s (10%)'
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
        help_text='Montant que le livreur recevra'
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
        db_table = 'payments'
        verbose_name = 'Paiement'
        verbose_name_plural = 'Paiements'
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
        
        # Calculer commission (10%)
        if not self.platform_commission:
            self.platform_commission = (self.total_amount * Decimal('0.10')).quantize(Decimal('0.01'))
        
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
    Déclenché automatiquement à 23h59 chaque jour.
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
        help_text='Total commission LeBeni\'s (10%)'
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
        help_text='Montant net versé au livreur'
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
