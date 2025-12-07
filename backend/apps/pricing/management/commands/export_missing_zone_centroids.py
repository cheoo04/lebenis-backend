from django.core.management.base import BaseCommand
from django.db.models import Q
import csv
import os

from apps.pricing.models import PricingZone


class Command(BaseCommand):
    help = 'Exporte en CSV les PricingZone sans default_latitude ou default_longitude'

    def add_arguments(self, parser):
        parser.add_argument('--output', '-o', type=str, default='missing_pricing_zone_centroids.csv',
                            help='Chemin du fichier CSV de sortie')

    def handle(self, *args, **options):
        output_path = options['output']

        qs = PricingZone.objects.filter(Q(default_latitude__isnull=True) | Q(default_longitude__isnull=True))

        total = qs.count()
        if total == 0:
            self.stdout.write(self.style.SUCCESS('Aucune PricingZone sans centroid trouvée.'))
            return

        # Ensure directory exists
        os.makedirs(os.path.dirname(output_path) or '.', exist_ok=True)

        with open(output_path, 'w', newline='', encoding='utf-8') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(['id', 'zone_name', 'commune', 'quartier', 'default_latitude', 'default_longitude', 'is_active'])
            for z in qs.order_by('commune', 'quartier'):
                writer.writerow([
                    str(z.id),
                    z.zone_name,
                    z.commune,
                    z.quartier or '',
                    '' if z.default_latitude is None else str(z.default_latitude),
                    '' if z.default_longitude is None else str(z.default_longitude),
                    'yes' if z.is_active else 'no'
                ])

        self.stdout.write(self.style.SUCCESS(f'Exporté {total} zones vers "{output_path}"'))
