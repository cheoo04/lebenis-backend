# backend/merchants/models.py
from django.db import models
from apps.authentication.models import User
import uuid

class Merchant(models.Model):
    STATUS_CHOICES = [
        ('pending', 'En attente'),
        ('verified', 'Vérifié'),
        ('rejected', 'Rejeté'),
    ]
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='merchant_profile')
    business_name = models.CharField(max_length=255, verbose_name="Nom de l'entreprise")
    business_type = models.CharField(max_length=100, blank=True)
    registration_number = models.CharField(max_length=100, unique=True, blank=True, null=True)
    tax_id = models.CharField(max_length=100, blank=True)
    
    verification_status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    verification_date = models.DateTimeField(null=True, blank=True)
    rejection_reason = models.TextField(blank=True, verbose_name="Raison du rejet")
    
    # Documents
    documents_url = models.CharField(max_length=500, blank=True, verbose_name="URL des documents")
    rccm_document = models.CharField(max_length=500, blank=True, verbose_name="Document RCCM")
    id_document = models.CharField(max_length=500, blank=True, verbose_name="Pièce d'identité")
    
    commission_rate = models.DecimalField(max_digits=5, decimal_places=2, default=10.00)
    credit_limit = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    current_balance = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'merchants'
        verbose_name = 'Commerçant'
        verbose_name_plural = 'Commerçants'
        ordering = ['-created_at']
    
    def __str__(self):
        return self.business_name

class MerchantAddress(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    merchant = models.ForeignKey(Merchant, on_delete=models.CASCADE, related_name='addresses')
    address_name = models.CharField(max_length=100, blank=True)
    street_address = models.CharField(max_length=255)
    commune = models.CharField(max_length=100)
    quartier = models.CharField(max_length=100, blank=True)
    city = models.CharField(max_length=100, default='Abidjan')
    country = models.CharField(max_length=100, default='Côte d\'Ivoire')
    
    latitude = models.DecimalField(max_digits=10, decimal_places=8, null=True, blank=True)
    longitude = models.DecimalField(max_digits=11, decimal_places=8, null=True, blank=True)
    
    is_primary = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'merchant_addresses'
        verbose_name = 'Adresse Commerçant'
        verbose_name_plural = 'Adresses Commerçants'
    
    def __str__(self):
        return f"{self.merchant.business_name} - {self.commune}"
