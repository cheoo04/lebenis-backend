from django.test import TestCase
from apps.pricing.calculator import PricingCalculator
from apps.pricing.models import PricingZone
from unittest.mock import patch


class PricingDistanceTests(TestCase):
    @patch('apps.core.location_service.LocationService.get_distance')
    def test_client_coords_used_and_distance(self, mock_get_distance):
        """Si le client fournit des coords, on les utilise et la distance provient de LocationService."""
        mock_get_distance.return_value = 5.5

        # s'assurer que les communes existent comme zones
        PricingZone.objects.create(zone_name='Zone Cocody', commune='Cocody', is_active=True)
        PricingZone.objects.create(zone_name='Zone Plateau', commune='Plateau', is_active=True)

        calculator = PricingCalculator()
        delivery_data = {
            'pickup_commune': 'Cocody',
            'delivery_commune': 'Plateau',
            'package_weight_kg': 1,
            'pickup_coords': (5.35, -3.98),
            'delivery_coords': (5.32, -4.02),
            'scheduling_type': 'immediate'
        }

        res = calculator.calculate_price(delivery_data)

        self.assertAlmostEqual(res['details']['distance_km'], 5.5)
        self.assertEqual(res['details']['used_coords_source']['pickup'], 'client')
        self.assertEqual(res['details']['used_coords_source']['delivery'], 'client')

    @patch('apps.core.location_service.LocationService.get_distance')
    def test_zone_centroid_used_when_no_client_coords(self, mock_get_distance):
        """Si pas de coords fournis par le client, on utilise les centroides de zone (quartier->commune)."""
        mock_get_distance.return_value = 3.3

        # Créer des zones avec centroides
        PricingZone.objects.create(zone_name='Zone A', commune='CommA', default_latitude=5.1, default_longitude=-3.9, is_active=True)
        PricingZone.objects.create(zone_name='Zone B', commune='CommB', default_latitude=5.2, default_longitude=-4.0, is_active=True)

        calculator = PricingCalculator()
        delivery_data = {
            'pickup_commune': 'CommA',
            'delivery_commune': 'CommB',
            'package_weight_kg': 2,
            'scheduling_type': 'immediate'
        }

        res = calculator.calculate_price(delivery_data)

        self.assertAlmostEqual(res['details']['distance_km'], 3.3)
        self.assertEqual(res['details']['used_coords_source']['pickup'], 'zone')
        self.assertEqual(res['details']['used_coords_source']['delivery'], 'zone')
        self.assertEqual(res['details']['used_coords']['pickup'], [5.1, -3.9])

    def test_fallback_distance_when_no_coords(self):
        """Si aucune coordonnée ni centroid n'est disponible, distance par défaut = 10 km."""
        # Créer des zones sans centroides
        PricingZone.objects.create(zone_name='Zone C', commune='CommC', is_active=True)
        PricingZone.objects.create(zone_name='Zone D', commune='CommD', is_active=True)

        calculator = PricingCalculator()
        delivery_data = {
            'pickup_commune': 'CommC',
            'delivery_commune': 'CommD',
            'package_weight_kg': 1,
            'scheduling_type': 'immediate'
        }

        res = calculator.calculate_price(delivery_data)

        self.assertAlmostEqual(res['details']['distance_km'], 10.0)
        self.assertEqual(res['details']['used_coords_source']['pickup'], 'fallback')
        self.assertEqual(res['details']['used_coords_source']['delivery'], 'fallback')
