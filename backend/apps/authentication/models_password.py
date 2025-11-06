# backend/apps/authentication/models_password.py
from django.db import models
from django.utils import timezone
from django.core.cache import cache
from datetime import timedelta
import random
import string
import logging

logger = logging.getLogger(__name__)


class PasswordResetCode(models.Model):
    """Code de réinitialisation de mot de passe (6 chiffres)"""
    email = models.EmailField(db_index=True)
    code = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    
    # Constantes de sécurité
    MAX_REQUESTS_PER_HOUR = 3  # Max 3 demandes par heure par email
    MAX_ATTEMPTS_PER_CODE = 5  # Max 5 tentatives de validation par code
    CODE_VALIDITY_MINUTES = 15  # Code valide 15 minutes
    
    class Meta:
        db_table = 'password_reset_codes'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['email', 'code', 'is_used']),
            models.Index(fields=['email', 'created_at']),
        ]
    
    def save(self, *args, **kwargs):
        """Définir la date d'expiration à 15 minutes"""
        if not self.expires_at:
            self.expires_at = timezone.now() + timedelta(minutes=self.CODE_VALIDITY_MINUTES)
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
    def can_request_reset(cls, email: str) -> tuple[bool, str]:
        """
        Vérifier si un email peut demander un nouveau code (protection anti-spam)
        
        Returns:
            (can_request: bool, error_message: str)
        """
        # Vérifier le cache pour les limites de taux
        cache_key = f'password_reset_requests_{email}'
        request_count = cache.get(cache_key, 0)
        
        if request_count >= cls.MAX_REQUESTS_PER_HOUR:
            return False, f"Trop de demandes. Réessayez dans 1 heure."
        
        # Vérifier les demandes récentes en base de données
        one_hour_ago = timezone.now() - timedelta(hours=1)
        recent_requests = cls.objects.filter(
            email=email,
            created_at__gte=one_hour_ago
        ).count()
        
        if recent_requests >= cls.MAX_REQUESTS_PER_HOUR:
            return False, f"Trop de demandes. Réessayez dans 1 heure."
        
        return True, ""
    
    @classmethod
    def create_for_email(cls, email: str, ip_address: str = None):
        """
        Créer un nouveau code pour un email avec protection anti-spam
        
        Args:
            email: Email de l'utilisateur
            ip_address: Adresse IP de la requête (optionnel)
            
        Returns:
            PasswordResetCode instance ou None si limite atteinte
        """
        # Vérifier les limites
        can_request, error = cls.can_request_reset(email)
        if not can_request:
            logger.warning(f"⚠️ Limite de réinitialisation atteinte pour {email}")
            raise ValueError(error)
        
        # Invalider tous les anciens codes pour cet email
        cls.objects.filter(email=email, is_used=False).update(is_used=True)
        
        # Créer un nouveau code
        code = cls.generate_code()
        reset_code = cls.objects.create(
            email=email,
            code=code,
            ip_address=ip_address
        )
        
        # Incrémenter le compteur de requêtes dans le cache
        cache_key = f'password_reset_requests_{email}'
        cache.set(cache_key, cache.get(cache_key, 0) + 1, timeout=3600)  # 1 heure
        
        logger.info(f"✅ Code de réinitialisation créé pour {email}")
        return reset_code
    
    @classmethod
    def verify_code(cls, email: str, code: str):
        """
        Vérifier un code pour un email avec protection contre les attaques brute-force
        
        Returns:
            (reset_code: PasswordResetCode | None, error: str | None)
        """
        # Vérifier les tentatives dans le cache
        attempts_key = f'password_reset_attempts_{email}_{code}'
        attempts = cache.get(attempts_key, 0)
        
        if attempts >= cls.MAX_ATTEMPTS_PER_CODE:
            logger.warning(f"⚠️ Trop de tentatives pour {email} avec code {code}")
            return None, "Trop de tentatives. Code invalidé. Demandez un nouveau code."
        
        try:
            reset_code = cls.objects.get(
                email=email,
                code=code,
                is_used=False
            )
            
            if reset_code.is_expired:
                logger.info(f"⚠️ Code expiré pour {email}")
                return None, "Code expiré. Demandez un nouveau code."
            
            # Réinitialiser le compteur de tentatives en cas de succès
            cache.delete(attempts_key)
            logger.info(f"✅ Code vérifié avec succès pour {email}")
            return reset_code, None
            
        except cls.DoesNotExist:
            # Incrémenter le compteur de tentatives échouées
            cache.set(attempts_key, attempts + 1, timeout=3600)  # 1 heure
            logger.warning(f"⚠️ Code invalide pour {email} (tentative {attempts + 1})")
            return None, f"Code invalide. {cls.MAX_ATTEMPTS_PER_CODE - attempts - 1} tentative(s) restante(s)."
    
    def mark_as_used(self):
        """Marquer le code comme utilisé"""
        self.is_used = True
        self.save(update_fields=['is_used'])
        logger.info(f"✅ Code marqué comme utilisé pour {self.email}")
    
    def __str__(self):
        return f"{self.email} - {self.code} ({'utilisé' if self.is_used else 'valide'})"
