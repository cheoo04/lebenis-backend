from django.test import TestCase


from rest_framework.test import APITestCase, APIClient
from django.urls import reverse
from django.contrib.auth import get_user_model
from apps.pricing.models import PricingZone
from apps.drivers.models import Driver, DriverZone

class PricingZoneWithSelectionAPITestCase(APITestCase):
	def setUp(self):
		User = get_user_model()
		# Créer un utilisateur et un driver
		self.user = User.objects.create_user(username='driver1', password='testpass123')
		self.driver = Driver.objects.create(user=self.user, vehicle_type='moto')

		# Créer deux zones tarifaires
		self.zone1 = PricingZone.objects.create(zone_name='Zone Cocody', commune='Cocody', is_active=True)
		self.zone2 = PricingZone.objects.create(zone_name='Zone Plateau', commune='Plateau', is_active=True)

		# Assigner une zone au driver
		DriverZone.objects.create(driver=self.driver, commune='Cocody')

		self.client = APIClient()
		self.url = reverse('pricingzone-with-selection')

	def test_zones_with_selection_authenticated(self):
		# Authentifier le client
		self.client.force_authenticate(user=self.user)
		response = self.client.get(self.url)
		self.assertEqual(response.status_code, 200)
		data = response.json()
		# On doit avoir les deux zones
		self.assertEqual(len(data), 2)
		# Vérifier le champ selected
		cocody = next(z for z in data if z['commune'] == 'Cocody')
		plateau = next(z for z in data if z['commune'] == 'Plateau')
		self.assertTrue(cocody['selected'])
		self.assertFalse(plateau['selected'])

	def test_zones_with_selection_unauthenticated(self):
		response = self.client.get(self.url)
		self.assertEqual(response.status_code, 401)
