from django.core.management.base import BaseCommand
from apps.deliveries.models import Delivery
from apps.pricing.calculator import PricingCalculator
from decimal import Decimal

class Command(BaseCommand):
    help = 'Backfill distance_km for existing deliveries that have no distance recorded'

    def add_arguments(self, parser):
        parser.add_argument('--limit', type=int, default=0, help='Limit number of deliveries to process (0 = all)')

    def handle(self, *args, **options):
        limit = options.get('limit') or 0
        qs = Delivery.objects.filter(distance_km__isnull=True)
        total = qs.count()
        if limit > 0:
            qs = qs[:limit]
        self.stdout.write(f'Found {total} deliveries without distance_km. Processing {qs.count()}...')

        calculator = PricingCalculator()
        updated = 0
        for delivery in qs:
            try:
                # Build minimal pricing_data expected by calculate_price
                pricing_data = {
                    'pickup_commune': delivery.pickup_commune or '',
                    'delivery_commune': delivery.delivery_commune or '',
                    'package_weight_kg': float(delivery.package_weight_kg or 0),
                    'scheduling_type': delivery.scheduling_type or 'immediate',
                }
                # include quartiers if present
                if delivery.pickup_quartier:
                    pricing_data['pickup_quartier'] = delivery.pickup_quartier
                if delivery.delivery_quartier:
                    pricing_data['delivery_quartier'] = delivery.delivery_quartier

                # include coords when available
                if delivery.pickup_latitude is not None and delivery.pickup_longitude is not None:
                    pricing_data['pickup_coords'] = (float(delivery.pickup_latitude), float(delivery.pickup_longitude))
                if delivery.delivery_latitude is not None and delivery.delivery_longitude is not None:
                    pricing_data['delivery_coords'] = (float(delivery.delivery_latitude), float(delivery.delivery_longitude))

                result = calculator.calculate_price(pricing_data)
                distance_km = result.get('details', {}).get('distance_km')
                if distance_km is not None:
                    delivery.distance_km = Decimal(str(distance_km))
                    delivery.save(update_fields=['distance_km'])
                    updated += 1
                    self.stdout.write(f'Updated delivery {delivery.tracking_number}: distance_km={distance_km}')
            except Exception as e:
                self.stderr.write(f'Error processing {delivery.id}: {e}')

        self.stdout.write(self.style.SUCCESS(f'Backfill complete. Updated {updated} deliveries.'))
