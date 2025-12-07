#!/usr/bin/env python3
import os
import sys
import json
import requests
import argparse
import csv
from datetime import datetime

# Initialiser Django
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
# The Django settings module for this project is `config.settings` (see manage.py)
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
import django
django.setup()

from apps.core.location_service import LocationService
from apps.deliveries.models import Delivery

def _call_osrm_direct(start_lat, start_lon, end_lat, end_lon, timeout=10):
    osrm_url = f"https://router.project-osrm.org/route/v1/driving/{start_lon},{start_lat};{end_lon},{end_lat}"
    params = {
        'overview': 'full',
        'geometries': 'polyline',
        'steps': 'true',
        'annotations': 'true'
    }
    try:
        r = requests.get(osrm_url, params=params, timeout=timeout)
        if r.status_code != 200:
            return {'status': r.status_code}
        d = r.json()
        if not d.get('routes'):
            return {'status': 200, 'no_routes': True}
        route = d['routes'][0]
        distance_km = round(route.get('distance', 0) / 1000.0, 2)
        duration_min = round(route.get('duration', 0) / 60.0, 1)
        geom = route.get('geometry', '')
        points = LocationService._decode_polyline(geom, precision=5)
        return {
            'status': 200,
            'distance_km': distance_km,
            'duration_min': duration_min,
            'points_count': len(points),
            'points': points,
        }
    except Exception as e:
        return {'error': str(e)}


def compare(start_lat, start_lon, end_lat, end_lon):
    """Compare backend LocationService.get_route with OSRM direct. Returns a dict with results."""
    print(f"Comparing route for: ({start_lat},{start_lon}) -> ({end_lat},{end_lon})")

    backend = LocationService.get_route(start_lat, start_lon, end_lat, end_lon)
    backend_summary = None
    if backend:
        backend_summary = {
            'source': backend.get('source'),
            'distance_km': backend.get('distance_km'),
            'duration_min': backend.get('duration_min'),
            'points_count': len(backend.get('polyline_points') or []),
            'points': backend.get('polyline_points') or [],
        }

    print('\nBACKEND (LocationService.get_route)')
    if backend_summary:
        print(' source:', backend_summary.get('source'))
        print(' distance_km:', backend_summary.get('distance_km'))
        print(' duration_min:', backend_summary.get('duration_min'))
        print(' points_count:', backend_summary.get('points_count'))
    else:
        print(' backend returned None')

    osrm_res = _call_osrm_direct(start_lat, start_lon, end_lat, end_lon)
    print('\nOSRM DIRECT')
    if osrm_res.get('status'):
        print(' status_code:', osrm_res.get('status'))
    if osrm_res.get('distance_km') is not None:
        print(' distance_km:', osrm_res.get('distance_km'))
        print(' duration_min:', osrm_res.get('duration_min'))
        print(' points_count:', osrm_res.get('points_count'))

    if backend_summary and backend_summary.get('points'):
        print('\nBackend sample points (first 5):')
        print(json.dumps(backend_summary.get('points')[:5], indent=2))

    return {'backend': backend_summary, 'osrm': osrm_res}

def _coords_from_delivery(delivery_id):
    try:
        d = Delivery.objects.get(id=delivery_id)
        pickup = d.get_coords('pickup')
        delivery = d.get_coords('delivery')
        if pickup and delivery:
            return pickup[0], pickup[1], delivery[0], delivery[1]
    except Exception as e:
        print('Error fetching delivery', delivery_id, e)
    return None


def run_for_delivery(delivery_id):
    coords = _coords_from_delivery(delivery_id)
    if not coords:
        print('No coordinates for delivery', delivery_id)
        return None
    start_lat, start_lon, end_lat, end_lon = coords
    return compare(start_lat, start_lon, end_lat, end_lon)


def batch_compare(limit=100, output_file=None):
    qs = Delivery.objects.filter(pickup_latitude__isnull=False, pickup_longitude__isnull=False,
                                 delivery_latitude__isnull=False, delivery_longitude__isnull=False).order_by('-created_at')[:limit]
    rows = []
    for d in qs:
        coords = d.get_coords('pickup')
        dest = d.get_coords('delivery')
        if not coords or not dest:
            continue
        start_lat, start_lon = coords
        end_lat, end_lon = dest
        res = compare(start_lat, start_lon, end_lat, end_lon)
        backend = res.get('backend') or {}
        osrm = res.get('osrm') or {}
        match = False
        try:
            match = (round(float(backend.get('distance_km') or 0),2) == round(float(osrm.get('distance_km') or 0),2))
        except Exception:
            match = False
        rows.append({
            'delivery_id': str(d.id),
            'backend_source': backend.get('source') if backend else '',
            'backend_distance_km': backend.get('distance_km') if backend else '',
            'backend_duration_min': backend.get('duration_min') if backend else '',
            'backend_points_count': backend.get('points_count') if backend else '',
            'osrm_distance_km': osrm.get('distance_km') if osrm else '',
            'osrm_duration_min': osrm.get('duration_min') if osrm else '',
            'osrm_points_count': osrm.get('points_count') if osrm else '',
            'match': match,
        })

    if output_file:
        os.makedirs(os.path.dirname(output_file), exist_ok=True)
        with open(output_file, 'w', newline='') as fh:
            writer = csv.DictWriter(fh, fieldnames=[
                'delivery_id','backend_source','backend_distance_km','backend_duration_min','backend_points_count',
                'osrm_distance_km','osrm_duration_min','osrm_points_count','match'
            ])
            writer.writeheader()
            for r in rows:
                writer.writerow(r)
        print('Wrote CSV to', output_file)

    return rows


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Compare backend LocationService routes with OSRM')
    parser.add_argument('--delivery-id', help='UUID of a Delivery to compare')
    parser.add_argument('--batch', type=int, help='Compare last N deliveries', default=0)
    parser.add_argument('--output', help='CSV output file for batch mode', default='data/route_comparison.csv')
    args = parser.parse_args()

    if args.delivery_id:
        run_for_delivery(args.delivery_id)
    elif args.batch and args.batch > 0:
        rows = batch_compare(limit=args.batch, output_file=os.path.join(os.path.dirname(__file__), '..', args.output))
        print(f'Processed {len(rows)} deliveries')
    else:
        # default sample coords (from DB scan)
        start_lat = float(os.environ.get('START_LAT', '5.294'))
        start_lon = float(os.environ.get('START_LON', '-4.004'))
        end_lat = float(os.environ.get('END_LAT', '5.298'))
        end_lon = float(os.environ.get('END_LON', '-3.992'))
        compare(start_lat, start_lon, end_lat, end_lon)
