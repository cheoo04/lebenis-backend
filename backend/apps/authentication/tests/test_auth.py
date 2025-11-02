from django.urls import reverse
from rest_framework.test import APITestCase
from rest_framework import status
from authentication.models import User

class AuthenticationTests(APITestCase):
    
    def setUp(self):
        """Configuration initiale avant chaque test"""
        self.register_url = reverse('auth_register')
        self.login_url = reverse('token_obtain_pair')
        self.user_data = {
            'email': 'test@example.com',
            'phone': '+2250700000001',
            'first_name': 'Test',
            'last_name': 'User',
            'user_type': 'merchant',
            'password': 'TestPassword123!',
            'password2': 'TestPassword123!'
        }
    
    def test_user_registration_success(self):
        """Test d'inscription réussie"""
        response = self.client.post(self.register_url, self.user_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(User.objects.count(), 1)
        self.assertEqual(User.objects.get().email, 'test@example.com')
    
    def test_user_registration_password_mismatch(self):
        """Test d'inscription avec mots de passe différents"""
        data = self.user_data.copy()
        data['password2'] = 'DifferentPassword123!'
        response = self.client.post(self.register_url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    
    def test_user_registration_duplicate_email(self):
        """Test d'inscription avec email déjà existant"""
        User.objects.create_user(
            email='test@example.com',
            phone='+2250700000001',
            first_name='Test',
            last_name='User',
            user_type='merchant',
            password='TestPassword123!'
        )
        response = self.client.post(self.register_url, self.user_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    
    def test_user_login_success(self):
        """Test de connexion réussie"""
        # Créer un utilisateur
        User.objects.create_user(
            email='test@example.com',
            phone='+2250700000001',
            first_name='Test',
            last_name='User',
            user_type='merchant',
            password='TestPassword123!'
        )
        
        # Tenter de se connecter
        login_data = {
            'email': 'test@example.com',
            'password': 'TestPassword123!'
        }
        response = self.client.post(self.login_url, login_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('access', response.data)
        self.assertIn('refresh', response.data)
    
    def test_user_login_wrong_password(self):
        """Test de connexion avec mauvais mot de passe"""
        User.objects.create_user(
            email='test@example.com',
            phone='+2250700000001',
            first_name='Test',
            last_name='User',
            user_type='merchant',
            password='TestPassword123!'
        )
        
        login_data = {
            'email': 'test@example.com',
            'password': 'WrongPassword!'
        }
        response = self.client.post(self.login_url, login_data, format='json')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
