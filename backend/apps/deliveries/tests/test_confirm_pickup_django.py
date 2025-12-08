from django.test import TestCase
from unittest.mock import patch
from rest_framework.test import APIClient
from apps.authentication.models import User
from apps.merchants.models import Merchant, MerchantAddress
from apps.deliveries.models import Delivery


class ConfirmPickupTestCase(TestCase):
    def setUp(self):
        # Merchant and pickup address
        self.merchant_user = User.objects.create_user(email="md@example.com", phone="0790000000", password="pw", user_type="merchant", first_name='M', last_name='M')
        self.merchant, _ = Merchant.objects.get_or_create(user=self.merchant_user, defaults={
            'business_name': 'ShopD'
        })
        # Use get_or_create for address to avoid duplicates if signals created one
        self.pickup_address, _ = MerchantAddress.objects.get_or_create(
            merchant=self.merchant,
            street_address="1 rue",
            defaults={'commune': 'Cocody', 'latitude': 5.0, 'longitude': -4.0}
        )

        # Driver
        self.driver_user = User.objects.create_user(email="dd@example.com", phone="0780000000", password="pw", user_type="driver", first_name='D', last_name='D')
        self.driver = self.driver_user.driver_profile
        self.driver.vehicle_type = 'moto'
        self.driver.current_latitude = 5.0
        self.driver.current_longitude = -4.0
        self.driver.save()

        # Delivery assigned to driver
        self.delivery = Delivery.objects.create(
            merchant=self.merchant,
            driver=self.driver,
            pickup_address=self.pickup_address,
            pickup_commune="Cocody",
            pickup_latitude=5.0,
            pickup_longitude=-4.0,
            delivery_address="20 ave",
            delivery_commune="Plateau",
            package_weight_kg=1.0,
            calculated_price=500,
            payment_method="prepaid",
            recipient_name="Client",
            recipient_phone="0780000000",
            status="assigned",
        )

        self.client = APIClient()
        self.client.force_authenticate(user=self.driver_user)

    def test_confirm_pickup_with_routed_distance_allows_pickup(self):
        url = f'/api/v1/deliveries/{self.delivery.id}/confirm-pickup/'
        with patch('apps.deliveries.views.LocationService.get_route') as mock_route:
            mock_route.return_value = {'distance_km': 0.01}
            response = self.client.post(url, {})

        self.assertEqual(response.status_code, 200)
        self.delivery.refresh_from_db()
        self.assertEqual(self.delivery.status, 'in_progress')

    def test_confirm_pickup_with_routed_distance_too_far_blocks(self):
        url = f'/api/v1/deliveries/{self.delivery.id}/confirm-pickup/'
        with patch('apps.deliveries.views.LocationService.get_route') as mock_route:
            mock_route.return_value = {'distance_km': 100.0}
            response = self.client.post(url, {})

        self.assertEqual(response.status_code, 400)

    def test_confirm_pickup_routing_raises_falls_back_to_geodesic(self):
        url = f'/api/v1/deliveries/{self.delivery.id}/confirm-pickup/'
        with patch('apps.deliveries.views.LocationService.get_route', side_effect=Exception('route fail')):
            with patch('apps.deliveries.views.geodesic') as mock_geo:
                class Dummy:
                    km = 50.0
                mock_geo.return_value = Dummy()
                response = self.client.post(url, {})

        self.assertEqual(response.status_code, 400)
