#!/usr/bin/env python3
"""Backfill delivery distances and set a distance_source column.

This script will:
- add SQL column `distance_source` to `deliveries` table if it doesn't exist
- for each delivery with pickup and delivery coords, call LocationService.get_route
  and set `distance_km` and `distance_source` based on the returned route's source

Usage:
  python scripts/backfill_delivery_distances.py --batch 100

Be careful: this will perform many external OSRM/ORS requests depending on batch size.
"""
import os
import sys
import argparse

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
import django
django.setup()

from django.db import connection, transaction
from apps.deliveries.models import Delivery
from apps.core.location_service import LocationService


def ensure_column_exists():
    with connection.cursor() as cur:
        # Postgres supports ADD COLUMN IF NOT EXISTS
        cur.execute("ALTER TABLE deliveries ADD COLUMN IF NOT EXISTS distance_source varchar(50);")
        connection.commit()


def backfill(limit=100):
    qs = Delivery.objects.filter(pickup_latitude__isnull=False, pickup_longitude__isnull=False,
                                 delivery_latitude__isnull=False, delivery_longitude__isnull=False).order_by('-created_at')[:limit]
    print(f"Backfilling {qs.count()} deliveries...")
    updated = 0
    for d in qs:
        try:
            route = LocationService.get_route(float(d.pickup_latitude), float(d.pickup_longitude),
                                              float(d.delivery_latitude), float(d.delivery_longitude))
            if route:
                dist = route.get('distance_km')
                src = route.get('source')
                # Use raw SQL update to avoid requiring Django model field
                with connection.cursor() as cur:
                    cur.execute("UPDATE deliveries SET distance_km = %s, distance_source = %s WHERE id = %s",
                                [dist, src, str(d.id)])
                    connection.commit()
                updated += 1
        except Exception as e:
            print('Error for delivery', d.id, e)

    print('Done. Updated', updated)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--batch', type=int, default=100, help='Number of deliveries to process')
    args = parser.parse_args()

    ensure_column_exists()
    backfill(limit=args.batch)
