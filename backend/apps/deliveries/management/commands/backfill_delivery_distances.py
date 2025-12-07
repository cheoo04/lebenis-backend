from django.core.management.base import BaseCommand
from django.db import connection
from apps.deliveries.models import Delivery
from apps.core.location_service import LocationService


class Command(BaseCommand):
    help = 'Backfill distance_km and distance_source for deliveries (uses LocationService)'

    def add_arguments(self, parser):
        parser.add_argument('--batch', type=int, default=100, help='Number of deliveries to process')

    def handle(self, *args, **options):
        limit = options.get('batch') or 100

        # Ensure column exists (safe to run multiple times)
        with connection.cursor() as cur:
            cur.execute("ALTER TABLE deliveries ADD COLUMN IF NOT EXISTS distance_source varchar(50);")

        qs = Delivery.objects.filter(pickup_latitude__isnull=False, pickup_longitude__isnull=False,
                                     delivery_latitude__isnull=False, delivery_longitude__isnull=False).order_by('-created_at')[:limit]
        total = qs.count()
        self.stdout.write(self.style.NOTICE(f'Processing {total} deliveries...'))
        updated = 0
        for d in qs:
            try:
                route = LocationService.get_route(float(d.pickup_latitude), float(d.pickup_longitude),
                                                  float(d.delivery_latitude), float(d.delivery_longitude))
                if route:
                    dist = route.get('distance_km')
                    src = route.get('source')
                    # Update via ORM for better signal handling
                    d.distance_km = dist
                    d.distance_source = src
                    d.save(update_fields=['distance_km', 'distance_source'])
                    updated += 1
            except Exception as e:
                self.stderr.write(f'Error for delivery {d.id}: {e}')

        self.stdout.write(self.style.SUCCESS(f'Done. Updated {updated}/{total} deliveries.'))
