
import pytest
from django.urls import reverse
from rest_framework.test import APIClient
from django.utils import timezone
from apps.authentication.models import User
from apps.merchants.models import Merchant, MerchantAddress
from apps.drivers.models import Driver
from apps.deliveries.models import Delivery
from apps.payments.models import DriverEarning

@pytest.mark.django_db
def test_driver_earning_created_on_delivery_validation():
    # Création d'un commerçant et d'une adresse
    merchant_user = User.objects.create_user(email="merchant@example.com", phone="0100000000", password="testpass", user_type="merchant")
    merchant = Merchant.objects.create(user=merchant_user, business_name="Test Shop")
    pickup_address = MerchantAddress.objects.create(merchant=merchant, street_address="10 rue du test", commune="Cocody")

    # Création d'un livreur et de son profil
    driver_user = User.objects.create_user(email="driver@example.com", phone="0200000000", password="testpass", user_type="driver")
    driver = driver_user.driver_profile
    driver.vehicle_type = "moto"
    driver.save()

    # Création d'une livraison avec tous les champs obligatoires
    delivery = Delivery.objects.create(
        merchant=merchant,
        driver=driver,
        pickup_address=pickup_address,
        pickup_commune="Cocody",
        delivery_address="20 avenue test",
        delivery_commune="Plateau",
        package_weight_kg=2.0,
        calculated_price=1000,
        payment_method="prepaid",
        recipient_name="Client Test",
        recipient_phone="0300000000",
        status="picked_up",
        delivery_confirmation_code="1234"
    )

    # Authentification du livreur
    client = APIClient()
    client.force_authenticate(user=driver_user)

    # Validation de la livraison (POST sur confirm-delivery avec le bon code)
    url = reverse("deliveries:confirm-delivery", args=[delivery.id])
    response = client.post(url, {"confirmation_code": "1234"})
    assert response.status_code == 200

    # Vérifie la création du gain
    earning = DriverEarning.objects.filter(delivery=delivery, driver=driver).first()
    assert earning is not None
    assert earning.base_earning > 0
    assert earning.status == "pending"
