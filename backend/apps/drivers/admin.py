# drivers/admin.py
from django import forms
from django.contrib import admin
from .models import Driver, DriverZone
from apps.pricing.models import PricingZone
from apps.core.quartiers_data import get_communes_list
import unicodedata


def normalize_commune(name: str) -> str:
    """Normalise un nom de commune (supprime accents, majuscules)."""
    if not name:
        return ""
    nfkd = unicodedata.normalize('NFKD', name)
    ascii_str = ''.join(c for c in nfkd if not unicodedata.combining(c))
    return ascii_str.upper()


class DriverZoneForm(forms.ModelForm):
    """Formulaire personnalisé avec liste déroulante des communes."""
    
    commune = forms.ChoiceField(
        label="Commune",
        help_text="Sélectionnez une commune parmi les zones tarifaires disponibles"
    )
    
    class Meta:
        model = DriverZone
        fields = '__all__'
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        # Récupérer les communes uniques depuis PricingZone
        pricing_communes = PricingZone.objects.filter(
            is_active=True
        ).values_list('commune', flat=True).distinct().order_by('commune')
        
        # Créer les choix : (valeur_stockée, affichage)
        # La valeur stockée sera normalisée (MAJUSCULES, sans accents)
        choices = [('', '--- Sélectionner une commune ---')]
        for commune in pricing_communes:
            normalized = normalize_commune(commune)
            # Afficher le nom original mais stocker la version normalisée
            choices.append((normalized, commune))
        
        self.fields['commune'].choices = choices
        
        # Si on édite une zone existante, sélectionner la bonne valeur
        if self.instance and self.instance.pk:
            self.initial['commune'] = normalize_commune(self.instance.commune)


@admin.register(Driver)
class DriverAdmin(admin.ModelAdmin):
    list_display = ('user', 'vehicle_type', 'is_available', 'verification_status', 'rating', 'total_deliveries')
    list_filter = ('verification_status', 'vehicle_type', 'is_available')
    search_fields = ('user__email', 'user__first_name', 'user__last_name', 'vehicle_registration')
    readonly_fields = ('created_at', 'updated_at')
    actions = ['verify_drivers', 'reject_drivers']

    def verify_drivers(self, request, queryset):
        updated = queryset.update(verification_status='verified')
        self.message_user(request, f"{updated} livreur(s) vérifié(s).")
    verify_drivers.short_description = "Marquer sélection comme Vérifié"

    def reject_drivers(self, request, queryset):
        updated = queryset.update(verification_status='rejected')
        self.message_user(request, f"{updated} livreur(s) rejeté(s).")
    reject_drivers.short_description = "Marquer sélection comme Rejeté"


@admin.register(DriverZone)
class DriverZoneAdmin(admin.ModelAdmin):
    form = DriverZoneForm  # Utiliser le formulaire personnalisé avec liste déroulante
    list_display = ('driver', 'commune', 'get_commune_display', 'priority', 'created_at')
    list_filter = ('commune', 'priority')
    search_fields = ('driver__user__email', 'driver__user__first_name', 'driver__user__last_name', 'commune')
    autocomplete_fields = ['driver']  # Recherche autocomplete pour le driver
    ordering = ('driver', 'commune')
    
    def get_commune_display(self, obj):
        """Affiche le nom original de la commune avec accents."""
        # Chercher la commune correspondante dans PricingZone
        normalized = normalize_commune(obj.commune)
        pricing_zone = PricingZone.objects.filter(
            commune__iexact=obj.commune
        ).first()
        if pricing_zone:
            return pricing_zone.commune
        # Essayer de trouver par normalisation
        for pz in PricingZone.objects.all():
            if normalize_commune(pz.commune) == normalized:
                return pz.commune
        return obj.commune
    get_commune_display.short_description = "Commune (affichage)"
