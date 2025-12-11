"""
Commande pour corriger les livraisons sans coordonnées GPS
et mettre à jour les zones de pricing avec les coordonnées par défaut
"""
from django.core.management.base import BaseCommand
from apps.deliveries.models import Delivery
from apps.pricing.models import PricingZone
from decimal import Decimal
import unicodedata

# Coordonnées par défaut des communes d'Abidjan
ABIDJAN_COMMUNES_COORDS = {
    'abobo': (5.4167, -4.0167),
    'adjame': (5.3667, -4.0333),
    'anyama': (5.4833, -4.0500),
    'attecoube': (5.3333, -4.0333),
    'bingerville': (5.3500, -3.8833),
    'cocody': (5.3599, -3.9833),
    'koumassi': (5.2833, -3.9500),
    'marcory': (5.3000, -3.9833),
    'plateau': (5.3167, -4.0167),
    'port-bouet': (5.2500, -3.9333),
    'treichville': (5.2833, -4.0000),
    'yopougon': (5.3500, -4.0833),
    'songon': (5.3167, -4.2500),
    'grand-bassam': (5.2167, -3.7333),
    'assinie': (5.1500, -3.4667),
}


def normalize(text):
    """Normalise le texte: minuscule, sans accents"""
    if not text:
        return ''
    text = text.lower().strip()
    text = unicodedata.normalize('NFD', text)
    text = ''.join(c for c in text if unicodedata.category(c) != 'Mn')
    return text


class Command(BaseCommand):
    help = 'Corrige les livraisons sans coordonnées GPS et met à jour les zones de pricing'

    def add_arguments(self, parser):
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Affiche les modifications sans les appliquer',
        )

    def handle(self, *args, **options):
        dry_run = options['dry_run']
        
        self.stdout.write(self.style.NOTICE('=== Correction des coordonnées GPS ===\n'))
        
        # 1. Mettre à jour les zones de pricing sans coordonnées
        self.stdout.write('1. Mise à jour des zones de pricing...')
        zones_updated = 0
        for zone in PricingZone.objects.filter(default_latitude__isnull=True):
            commune_norm = normalize(zone.commune)
            if commune_norm in ABIDJAN_COMMUNES_COORDS:
                lat, lng = ABIDJAN_COMMUNES_COORDS[commune_norm]
                if not dry_run:
                    zone.default_latitude = Decimal(str(lat))
                    zone.default_longitude = Decimal(str(lng))
                    zone.save(update_fields=['default_latitude', 'default_longitude'])
                zones_updated += 1
                self.stdout.write(f'  ✓ Zone {zone.commune}: ({lat}, {lng})')
        
        self.stdout.write(self.style.SUCCESS(f'  → {zones_updated} zones mises à jour\n'))
        
        # 2. Corriger les livraisons sans coordonnées pickup
        self.stdout.write('2. Correction des livraisons sans coordonnées pickup...')
        pickup_fixed = 0
        deliveries_no_pickup = Delivery.objects.filter(
            pickup_latitude__isnull=True
        ).exclude(pickup_commune__isnull=True).exclude(pickup_commune='')
        
        for delivery in deliveries_no_pickup:
            commune_norm = normalize(delivery.pickup_commune)
            # Chercher dans les zones
            zone = PricingZone.objects.filter(
                default_latitude__isnull=False
            ).first()
            
            # Chercher une correspondance exacte normalisée
            for z in PricingZone.objects.filter(default_latitude__isnull=False):
                if normalize(z.commune) == commune_norm:
                    zone = z
                    break
            
            if zone and zone.default_latitude:
                if not dry_run:
                    delivery.pickup_latitude = zone.default_latitude
                    delivery.pickup_longitude = zone.default_longitude
                    delivery.save(update_fields=['pickup_latitude', 'pickup_longitude'])
                pickup_fixed += 1
            elif commune_norm in ABIDJAN_COMMUNES_COORDS:
                lat, lng = ABIDJAN_COMMUNES_COORDS[commune_norm]
                if not dry_run:
                    delivery.pickup_latitude = Decimal(str(lat))
                    delivery.pickup_longitude = Decimal(str(lng))
                    delivery.save(update_fields=['pickup_latitude', 'pickup_longitude'])
                pickup_fixed += 1
        
        self.stdout.write(self.style.SUCCESS(f'  → {pickup_fixed} livraisons corrigées (pickup)\n'))
        
        # 3. Corriger les livraisons sans coordonnées delivery
        self.stdout.write('3. Correction des livraisons sans coordonnées delivery...')
        delivery_fixed = 0
        deliveries_no_delivery = Delivery.objects.filter(
            delivery_latitude__isnull=True
        ).exclude(delivery_commune__isnull=True).exclude(delivery_commune='')
        
        for delivery in deliveries_no_delivery:
            commune_norm = normalize(delivery.delivery_commune)
            zone = None
            
            for z in PricingZone.objects.filter(default_latitude__isnull=False):
                if normalize(z.commune) == commune_norm:
                    zone = z
                    break
            
            if zone and zone.default_latitude:
                if not dry_run:
                    delivery.delivery_latitude = zone.default_latitude
                    delivery.delivery_longitude = zone.default_longitude
                    delivery.save(update_fields=['delivery_latitude', 'delivery_longitude'])
                delivery_fixed += 1
            elif commune_norm in ABIDJAN_COMMUNES_COORDS:
                lat, lng = ABIDJAN_COMMUNES_COORDS[commune_norm]
                if not dry_run:
                    delivery.delivery_latitude = Decimal(str(lat))
                    delivery.delivery_longitude = Decimal(str(lng))
                    delivery.save(update_fields=['delivery_latitude', 'delivery_longitude'])
                delivery_fixed += 1
        
        self.stdout.write(self.style.SUCCESS(f'  → {delivery_fixed} livraisons corrigées (delivery)\n'))
        
        # Résumé
        total_still_missing = Delivery.objects.filter(
            pickup_latitude__isnull=True
        ).count() + Delivery.objects.filter(
            delivery_latitude__isnull=True
        ).count()
        
        self.stdout.write(self.style.NOTICE(f'\n=== Résumé ==='))
        self.stdout.write(f'Zones mises à jour: {zones_updated}')
        self.stdout.write(f'Livraisons pickup corrigées: {pickup_fixed}')
        self.stdout.write(f'Livraisons delivery corrigées: {delivery_fixed}')
        self.stdout.write(f'Coordonnées encore manquantes: {total_still_missing}')
        
        if dry_run:
            self.stdout.write(self.style.WARNING('\n⚠️  Mode dry-run: aucune modification appliquée'))
            self.stdout.write('    Relancez sans --dry-run pour appliquer')
