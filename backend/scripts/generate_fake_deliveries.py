#!/usr/bin/env python3
"""Génère des livraisons factices dans la base pour tests locaux.

Usage:
  python scripts/generate_fake_deliveries.py --count 50

Par défaut génère 50 livraisons avec des coordonnées aléatoires dans une bbox d'Abidjan.
"""
import os
import sys
import random
import argparse

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
import django
django.setup()

from apps.deliveries.models import Delivery


def random_point_in_bbox(bbox):
    """bbox = (min_lat, min_lon, max_lat, max_lon)"""
    min_lat, min_lon, max_lat, max_lon = bbox
    lat = random.uniform(min_lat, max_lat)
    lon = random.uniform(min_lon, max_lon)
    return round(lat, 6), round(lon, 6)


def create_fake_delivery(bbox, index=0):
    pickup_lat, pickup_lon = random_point_in_bbox(bbox)
    delivery_lat, delivery_lon = random_point_in_bbox(bbox)
    d = Delivery.objects.create(
        pickup_latitude=pickup_lat,
        pickup_longitude=pickup_lon,
        pickup_commune='Zone Test',
        pickup_quartier=f'Quartier {index}',
        delivery_latitude=delivery_lat,
        delivery_longitude=delivery_lon,
        delivery_commune='Zone Test',
        delivery_quartier=f'Quartier {index+100}',
        recipient_name=f'Test Recipient {index}',
        recipient_phone=f'2250{random.randint(10000000,99999999)}',
        package_weight_kg=1.0,
        calculated_price=100.0,
        payment_method='prepaid',
        package_description='Fake delivery for testing',
        recipient_alternative_phone='',
    )
    return d


def main():
    parser = argparse.ArgumentParser(description='Generate fake deliveries for testing')
    parser.add_argument('--count', type=int, default=50, help='Number of deliveries to create')
    parser.add_argument('--bbox', help='BBox min_lat,min_lon,max_lat,max_lon',
                        default='5.15,-4.10,5.45,-3.70')
    args = parser.parse_args()

    bbox_vals = tuple(map(float, args.bbox.split(',')))

    print(f'Creating {args.count} fake deliveries in bbox {bbox_vals} ...')
    created = []
    for i in range(args.count):
        d = create_fake_delivery(bbox_vals, i)
        created.append(str(d.id))
        if (i+1) % 10 == 0:
            print(f'  Created {i+1}')

    print('Done. Created deliveries:')
    for cid in created[:20]:
        print(' -', cid)
    print('Total:', len(created))


if __name__ == '__main__':
    main()
