# backend/apps/authentication/models_password.py
from django.db import models
from django.utils import timezone
from datetime import timedelta
import random
import string


class PasswordResetCode(models.Model):
    """Code de réinitialisation de mot de passe (6 chiffres)"""
    email = models.EmailField(db_index=True)
    code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)
    
    class Meta:
        db_table = 'password_reset_codes'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['email', 'code', 'is_used']),
        ]
    
    def save(self, *args, **kwargs):
        """Définir la date d'expiration à 15 minutes"""
        if not self.expires_at:
            self.expires_at = timezone.now() + timedelta(minutes=15)
        super().save(*args, **kwargs)
    
    @property
    def is_expired(self):
        """Vérifier si le code a expiré"""
        return timezone.now() > self.expires_at
    
    @property
    def is_valid(self):
        """Vérifier si le code est valide (non utilisé et non expiré)"""
        return not self.is_used and not self.is_expired
    
    @staticmethod
    def generate_code():
        """Générer un code à 6 chiffres"""
        return ''.join(random.choices(string.digits, k=6))
    
    @classmethod
    def create_for_email(cls, email):
        """Créer un nouveau code pour un email"""
        # Invalider tous les anciens codes pour cet email
        cls.objects.filter(email=email, is_used=False).update(is_used=True)
        
        # Créer un nouveau code
        code = cls.generate_code()
        return cls.objects.create(email=email, code=code)
    
    @classmethod
    def verify_code(cls, email, code):
        """Vérifier un code pour un email"""
        try:
            reset_code = cls.objects.get(
                email=email,
                code=code,
                is_used=False
            )
            
            if reset_code.is_expired:
                return None, "Code expiré. Demandez un nouveau code."
            
            return reset_code, None
            
        except cls.DoesNotExist:
            return None, "Code invalide."
    
    def mark_as_used(self):
        """Marquer le code comme utilisé"""
        self.is_used = True
        self.save(update_fields=['is_used'])
    
    def __str__(self):
        return f"{self.email} - {self.code} ({'utilisé' if self.is_used else 'valide'})"
