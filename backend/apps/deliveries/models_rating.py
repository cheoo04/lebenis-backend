# deliveries/models_rating.py

from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from django.db.models import Avg
import uuid

from apps.authentication.models import User
from apps.merchants.models import Merchant
from apps.drivers.models import Driver
from .models import Delivery


class DeliveryRating(models.Model):
    """
    Évaluation d'un driver par un merchant après une livraison.
    Permet aux marchands de noter la qualité du service.
    """
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Relations
    delivery = models.OneToOneField(
        Delivery, 
        on_delete=models.CASCADE, 
        related_name='rating',
        help_text="Livraison évaluée"
    )
    merchant = models.ForeignKey(
        Merchant, 
        on_delete=models.CASCADE, 
        related_name='ratings_given',
        null=True,
        blank=True,
        help_text="Marchand qui donne la note (null si particulier)"
    )
    rated_by = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='delivery_ratings_given',
        null=True,
        blank=True,
        help_text="Utilisateur qui a donné la note (merchant ou particulier)"
    )
    driver = models.ForeignKey(
        Driver, 
        on_delete=models.CASCADE, 
        related_name='ratings_received',
        help_text="Livreur évalué"
    )
    
    # Évaluation
    rating = models.DecimalField(
        max_digits=2, 
        decimal_places=1,
        validators=[
            MinValueValidator(1.0, message="La note minimum est 1"),
            MaxValueValidator(5.0, message="La note maximum est 5")
        ],
        help_text="Note de 1 à 5"
    )
    comment = models.TextField(
        blank=True,
        help_text="Commentaire optionnel"
    )
    
    # Critères détaillés (optionnels)
    punctuality_rating = models.IntegerField(
        null=True, 
        blank=True,
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        help_text="Ponctualité (1-5)"
    )
    professionalism_rating = models.IntegerField(
        null=True, 
        blank=True,
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        help_text="Professionnalisme (1-5)"
    )
    care_rating = models.IntegerField(
        null=True, 
        blank=True,
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        help_text="Soin du colis (1-5)"
    )
    
    # Métadonnées
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'delivery_ratings'
        verbose_name = 'Évaluation Livraison'
        verbose_name_plural = 'Évaluations Livraisons'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['driver', 'rating']),
            models.Index(fields=['merchant', 'created_at']),
        ]
    
    def __str__(self):
        return f"{self.merchant.business_name} → {self.driver.user.full_name}: {self.rating}⭐"
    
    def save(self, *args, **kwargs):
        """Recalcule le rating moyen du driver après enregistrement"""
        super().save(*args, **kwargs)
        self.update_driver_average_rating()
    
    def update_driver_average_rating(self):
        """
        Recalcule et met à jour le rating moyen du driver.
        Appelé automatiquement après save().
        """
        avg_rating = DeliveryRating.objects.filter(
            driver=self.driver
        ).aggregate(
            avg=Avg('rating')
        )['avg']
        
        if avg_rating is not None:
            self.driver.rating = round(avg_rating, 1)
            self.driver.save(update_fields=['rating'])
