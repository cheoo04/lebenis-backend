# apps/payments/models_transaction.py

import uuid
from decimal import Decimal
from django.db import models
from django.core.validators import MinValueValidator
from apps.drivers.models import Driver


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
        related_name='transactions',
        null=True,
        blank=True
    )
    
    # Références
    payment = models.ForeignKey(
        'Payment',
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
