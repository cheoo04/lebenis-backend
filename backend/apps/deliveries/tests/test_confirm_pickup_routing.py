import pytest
import os
from types import SimpleNamespace
from unittest.mock import patch
from django.urls import reverse
from rest_framework.test import APIClient
from apps.authentication.models import User
from apps.merchants.models import Merchant, MerchantAddress
from apps.drivers.models import Driver
from apps.deliveries.models import Delivery


@pytest.mark.django_db
def test_confirm_pickup_within_routed_distance_succeeds(monkeypatch):
    # Set small proximity threshold for test
    monkeypatch.setenv('PICKUP_PROXIMITY_KM', '0.2')

    # Create merchant, address
    merchant_user = User.objects.create_user(email="m@example.com", phone="0700000000", password="pw", user_type="merchant", first_name='M', last_name='M')
    merchant = Merchant.objects.create(user=merchant_user, business_name="Shop")
    pickup_address = MerchantAddress.objects.create(merchant=merchant, street_address="1 rue", commune="Cocody", latitude=5.345678, longitude=-4.012345)

    # Create driver and set location
    driver_user = User.objects.create_user(email="d@example.com", phone="0710000000", password="pw", user_type="driver", first_name='D', last_name='D')
    driver = driver_user.driver_profile
    driver.vehicle_type = 'moto'
    driver.current_latitude = 5.345000
    driver.current_longitude = -4.012000
    driver.save()

    # Create delivery assigned to driver with pickup coords
    delivery = Delivery.objects.create(
        merchant=merchant,
        driver=driver,
        pickup_address=pickup_address,
        pickup_commune="Cocody",
        pickup_latitude=5.345678,
        pickup_longitude=-4.012345,
        delivery_address="20 ave",
        delivery_commune="Plateau",
        package_weight_kg=1.0,
        calculated_price=500,
        payment_method="prepaid",
        recipient_name="Client",
        recipient_phone="0780000000",
        status="assigned",
    )

    client = APIClient()
    client.force_authenticate(user=driver_user)

    url = f'/api/v1/deliveries/{delivery.id}/confirm-pickup/'

    # Mock routing service to return small distance
    with patch('apps.deliveries.views.LocationService.get_route') as mock_route:
        mock_route.return_value = {'distance_km': 0.05}
        response = client.post(url, {})

    assert response.status_code == 200
    data = response.json()
    assert data.get('success') is True
    # Refresh from DB
    delivery.refresh_from_db()
    assert delivery.status == 'in_progress'


@pytest.mark.django_db
def test_confirm_pickup_too_far_returns_400(monkeypatch):
    monkeypatch.setenv('PICKUP_PROXIMITY_KM', '0.2')

    merchant_user = User.objects.create_user(email="m2@example.com", phone="0700000001", password="pw", user_type="merchant", first_name='M2', last_name='M2')
    merchant = Merchant.objects.create(user=merchant_user, business_name="Shop2")
    pickup_address = MerchantAddress.objects.create(merchant=merchant, street_address="2 rue", commune="Cocody", latitude=5.000000, longitude=-4.000000)

    driver_user = User.objects.create_user(email="d2@example.com", phone="0710000001", password="pw", user_type="driver", first_name='D2', last_name='D2')
    driver = driver_user.driver_profile
    driver.vehicle_type = 'moto'
    driver.current_latitude = 6.000000
    driver.current_longitude = -5.000000
    driver.save()

    delivery = Delivery.objects.create(
        merchant=merchant,
        driver=driver,
        pickup_address=pickup_address,
        pickup_commune="Cocody",
        pickup_latitude=5.0,
        pickup_longitude=-4.0,
        delivery_address="Somewhere",
        delivery_commune="Plateau",
        package_weight_kg=1.0,
        calculated_price=500,
        payment_method="prepaid",
        recipient_name="Client2",
        recipient_phone="0780000001",
        status="assigned",
    )

    client = APIClient()
    client.force_authenticate(user=driver_user)
    url = f'/api/v1/deliveries/{delivery.id}/confirm-pickup/'

    with patch('apps.deliveries.views.LocationService.get_route') as mock_route:
        mock_route.return_value = {'distance_km': 50.0}
        response = client.post(url, {})

    assert response.status_code == 400
    data = response.json()
    assert 'distance_km' in data


@pytest.mark.django_db
def test_confirm_pickup_routing_fails_fallback_to_geodesic(monkeypatch):
    monkeypatch.setenv('PICKUP_PROXIMITY_KM', '0.2')

    merchant_user = User.objects.create_user(email="m3@example.com", phone="0700000002", password="pw", user_type="merchant", first_name='M3', last_name='M3')
    merchant = Merchant.objects.create(user=merchant_user, business_name="Shop3")
    pickup_address = MerchantAddress.objects.create(merchant=merchant, street_address="3 rue", commune="Cocody", latitude=5.000000, longitude=-4.000000)

    driver_user = User.objects.create_user(email="d3@example.com", phone="0710000002", password="pw", user_type="driver", first_name='D3', last_name='D3')
    driver = driver_user.driver_profile
    driver.vehicle_type = 'moto'
    driver.current_latitude = 6.000000
    driver.current_longitude = -5.000000
    driver.save()

    delivery = Delivery.objects.create(
        merchant=merchant,
        driver=driver,
        pickup_address=pickup_address,
        pickup_commune="Cocody",
        pickup_latitude=5.0,
        pickup_longitude=-4.0,
        delivery_address="Else",
        delivery_commune="Plateau",
        package_weight_kg=1.0,
        calculated_price=500,
        payment_method="prepaid",
        recipient_name="Client3",
        recipient_phone="0780000002",
        status="assigned",
    )

    client = APIClient()
    client.force_authenticate(user=driver_user)
    url = f'/api/v1/deliveries/{delivery.id}/confirm-pickup/'

    # Make routing raise, and patch geodesic to return a large km value
    with patch('apps.deliveries.views.LocationService.get_route', side_effect=Exception('route fail')):
        with patch('apps.deliveries.views.geodesic') as mock_geo:
            mock_geo.return_value = SimpleNamespace(km=100.0)
            response = client.post(url, {})

    assert response.status_code == 400
    data = response.json()
    assert 'distance_km' in data
