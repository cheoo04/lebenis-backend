# Script pour tester dynamiquement la permission sur une action custom DRF
from rest_framework.test import APIRequestFactory
from django.contrib.auth import get_user_model
from apps.pricing.views import PricingZoneViewSet

User = get_user_model()

# Remplace par l'email de ton driver
EMAIL = "cheo@gmail.com"

user = User.objects.get(email=EMAIL)

factory = APIRequestFactory()
request = factory.get('/api/v1/pricing/zones/with-selection/')
request.user = user

view = PricingZoneViewSet.as_view({'get': 'with_selection'})

try:
    response = view(request)
    print(f"Réponse HTTP: {response.status_code}")
    print(f"Contenu: {getattr(response, 'data', response.content)}")
except Exception as e:
    print(f"Exception: {e}")
