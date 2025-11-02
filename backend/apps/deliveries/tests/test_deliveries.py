from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from authentication.models import User
from merchants.models import Merchant
from deliveries.models import Delivery

class DeliveryTests(APITestCase):
    
    def setUp(self):
        """Configuration initiale"""
        # Créer un utilisateur merchant
        self.merchant_user = User.objects.create_user(
            email='merchant@example.com',
            phone='+2250700000001',
            first_name='Merchant',
            last_name='Test',
            user_type='merchant',
            password='TestPassword123!'
        )
        
        # Créer un profil merchant
        self.merchant = Merchant.objects.create(
            user=self.merchant_user,
            business_name='Test Business',
            verification_status='verified'
        )
        
        # URL de l'API
        self.deliveries_url = reverse('delivery-list')
        
        # Se connecter
        self.client.force_authenticate(user=self.merchant_user)
    
    def test_create_delivery_success(self):
        """Test de création de livraison réussie"""
        delivery_data = {
            'delivery_address': '123 Rue Test',
            'delivery_commune': 'Cocody',
            'delivery_quartier': 'Riviera',
            'package_description': 'Colis de test',
            'package_weight_kg': 2.5,
            'is_fragile': False,
            'recipient_name': 'Client Test',
            'recipient_phone': '+2250700000002',
            'payment_method': 'prepaid',
            'scheduling_type': 'immediate'
        }
        
        response = self.client.post(self.deliveries_url, delivery_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Delivery.objects.count(), 1)
    
    def test_list_deliveries(self):
        """Test de récupération de la liste des livraisons"""
        response = self.client.get(self.deliveries_url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
    
    def test_create_delivery_unauthenticated(self):
        """Test de création sans authentification"""
        self.client.force_authenticate(user=None)
        
        delivery_data = {
            'delivery_address': '123 Rue Test',
            'delivery_commune': 'Cocody',
            'package_weight_kg': 2.5,
            'recipient_name': 'Client Test',
            'recipient_phone': '+2250700000002',
            'payment_method': 'prepaid'
        }
        
        response = self.client.post(self.deliveries_url, delivery_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
