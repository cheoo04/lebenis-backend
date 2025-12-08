from django.db import models
from apps.authentication.models import User
import uuid


class Individual(models.Model):
    """
    Modèle pour les particuliers (clients individuels) qui peuvent demander des livraisons.
    Contrairement aux marchands, ils n'ont pas de documents professionnels à fournir.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='individual_profile')
    
    # Informations personnelles (certaines viennent déjà du User)
    address = models.TextField(blank=True, null=True, help_text="Adresse principale du particulier")
    
    # Métadonnées
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'individuals'
        verbose_name = 'Particulier'
        verbose_name_plural = 'Particuliers'
        ordering = ['-created_at']
    
    def __str__(self):
        # Certains User personnalisés n'exposent pas get_full_name();
        # essayer plusieurs fallbacks pour obtenir un nom lisible
        name = None
        try:
            get_full = getattr(self.user, 'get_full_name', None)
            if callable(get_full):
                name = get_full()
        except Exception:
            name = None

        if not name:
            name = getattr(self.user, 'full_name', None)

        if not name:
            parts = [getattr(self.user, 'first_name', '') or '', getattr(self.user, 'last_name', '') or '']
            candidate = ' '.join(p for p in parts if p).strip()
            name = candidate or getattr(self.user, 'email', '')

        return f"{name} - {getattr(self.user, 'email', '')}"
    
    @property
    def full_name(self):
        return f"{self.user.first_name} {self.user.last_name}".strip() or self.user.email
    
    @property
    def phone(self):
        return getattr(self.user, 'phone', '')
    
    @property
    def email(self):
        return self.user.email
