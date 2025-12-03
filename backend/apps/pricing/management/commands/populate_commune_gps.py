# backend/apps/pricing/management/commands/populate_commune_gps.py
from django.core.management.base import BaseCommand
from apps.pricing.models import PricingZone


class Command(BaseCommand):
    help = 'Remplit les coordonnées GPS par défaut des communes d\'Abidjan'

    # Coordonnées GPS du centre de chaque commune d'Abidjan
    COMMUNE_COORDINATES = {
        'Cocody': (5.3599517, -4.0082563),
        'Plateau': (5.3238889, -4.0127778),
        'Marcory': (5.2927778, -3.9927778),
        'Yopougon': (5.2893189, -4.0744303),
        'Abobo': (5.4236111, -4.0161111),
        'Adjamé': (5.3508333, -4.0236111),
        'Treichville': (5.2827778, -3.9808333),
        'Port-Bouët': (5.2500000, -3.9166667),
        'Attécoubé': (5.3297222, -4.0527778),
        'Koumassi': (5.3083333, -3.9666667),
        'Bingerville': (5.3558333, -3.8955556),
        'Anyama': (5.4947222, -4.0527778),
        'Songon': (5.3166667, -4.2500000),
    }

    def handle(self, *args, **options):
        self.stdout.write('📍 Mise à jour des coordonnées GPS des communes...')
        
        updated = 0
        created = 0
        
        for commune_name, (lat, lon) in self.COMMUNE_COORDINATES.items():
            # Chercher toutes les zones de cette commune
            zones = PricingZone.objects.filter(commune__iexact=commune_name)
            
            if zones.exists():
                # Mettre à jour les zones existantes
                for zone in zones:
                    zone.default_latitude = lat
                    zone.default_longitude = lon
                    zone.save(update_fields=['default_latitude', 'default_longitude'])
                    updated += 1
                    self.stdout.write(self.style.SUCCESS(
                        f'✅ {zone.zone_name} ({commune_name}): ({lat}, {lon})'
                    ))
            else:
                # Créer une zone par défaut pour cette commune
                zone = PricingZone.objects.create(
                    zone_name=f'Zone {commune_name}',
                    commune=commune_name,
                    default_latitude=lat,
                    default_longitude=lon,
                    is_active=True
                )
                created += 1
                self.stdout.write(self.style.SUCCESS(
                    f'🆕 Zone créée: {commune_name} ({lat}, {lon})'
                ))
        
        self.stdout.write(self.style.SUCCESS(
            f'\n🎉 Terminé ! {updated} zones mises à jour, {created} zones créées'
        ))
