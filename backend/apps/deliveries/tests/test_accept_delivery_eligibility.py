"""
Test de validation de l'éligibilité du driver lors de l'acceptation d'une livraison.

Vérifie que :
1. Un driver non vérifié ne peut pas accepter une livraison
2. Un driver hors ligne ne peut pas accepter une livraison
3. Un driver vérifié ET disponible peut accepter une livraison
"""

from django.test import TestCase
from django.contrib.auth import get_user_model
from apps.authentication.models import User
from apps.drivers.models import Driver
from apps.merchants.models import Merchant
from apps.deliveries.models import Delivery
from apps.deliveries.services import DeliveryAssignmentService
from django.core.exceptions import ValidationError

User = get_user_model()


class DriverEligibilityTestCase(TestCase):
    """Tests d'éligibilité du driver pour accepter une livraison"""
    
    def setUp(self):
        """Configuration initiale des tests"""
        # Générer des emails uniques pour éviter les conflits
        import uuid
        unique_id = str(uuid.uuid4())[:8]
        
        # Créer un merchant
        self.merchant_user = User.objects.create_user(
            email=f'merchant{unique_id}@test.com',
            password='password123',
            first_name='Test',
            last_name='Merchant',
            phone=f'+22170{unique_id[:7]}',
            user_type='merchant'
        )
        self.merchant = Merchant.objects.create(
            user=self.merchant_user,
            business_name='Test Business'
        )
        
        # Créer un driver (le signal créera automatiquement le profil driver)
        self.driver_user = User.objects.create_user(
            email=f'driver{unique_id}@test.com',
            password='password123',
            first_name='Test',
            last_name='Driver',
            phone=f'+22171{unique_id[:7]}',
            user_type='driver'
        )
        # Récupérer le driver créé automatiquement par le signal
        self.driver = Driver.objects.get(user=self.driver_user)
        # Mettre à jour avec les valeurs nécessaires
        self.driver.vehicle_type = 'moto'
        self.driver.vehicle_registration = 'AB 1234 CD'
        self.driver.vehicle_capacity_kg = 30.0
        self.driver.verification_status = 'verified'
        self.driver.is_available = True
        self.driver.availability_status = 'available'
        self.driver.save()
        
        # Créer une livraison assignée au driver
        self.delivery = Delivery.objects.create(
            merchant=self.merchant,
            driver=self.driver,
            status='assigned',
            pickup_address='123 Test Street',
            pickup_latitude=14.6937,
            pickup_longitude=-17.4441,
            delivery_address='456 Test Avenue',
            delivery_latitude=14.7167,
            delivery_longitude=-17.4677,
            delivery_commune='Dakar',
            package_description='Test Package',
            package_weight_kg=5.0,
            delivery_price=5000.0,
            driver_commission=1000.0
        )
        
        self.service = DeliveryAssignmentService()
    
    def test_driver_not_verified_cannot_accept(self):
        """Un driver non vérifié ne peut pas accepter une livraison"""
        # Changer le statut de vérification
        self.driver.verification_status = 'pending'
        self.driver.save()
        
        # Tenter d'accepter
        with self.assertRaises(ValidationError) as context:
            self.service.driver_accept_delivery(
                delivery_id=self.delivery.id,
                driver=self.driver
            )
        
        self.assertIn('pas encore vérifié', str(context.exception))
    
    def test_driver_offline_cannot_accept(self):
        """Un driver hors ligne ne peut pas accepter une livraison"""
        # Passer le driver en offline
        self.driver.availability_status = 'offline'
        self.driver.is_available = False
        self.driver.save()
        
        # Tenter d'accepter
        with self.assertRaises(ValidationError) as context:
            self.service.driver_accept_delivery(
                delivery_id=self.delivery.id,
                driver=self.driver
            )
        
        self.assertIn('être en ligne', str(context.exception))
    
    def test_driver_busy_cannot_accept(self):
        """Un driver occupé ne peut pas accepter une livraison"""
        # Passer le driver en busy
        self.driver.availability_status = 'busy'
        self.driver.is_available = False
        self.driver.save()
        
        # Tenter d'accepter
        with self.assertRaises(ValidationError) as context:
            self.service.driver_accept_delivery(
                delivery_id=self.delivery.id,
                driver=self.driver
            )
        
        self.assertIn('être en ligne', str(context.exception))
    
    def test_driver_verified_and_available_can_accept(self):
        """Un driver vérifié ET disponible peut accepter une livraison"""
        # Driver déjà configuré comme vérifié et disponible dans setUp()
        
        # Accepter la livraison
        result = self.service.driver_accept_delivery(
            delivery_id=self.delivery.id,
            driver=self.driver
        )
        
        # Vérifier le résultat
        self.assertTrue(result['success'])
        self.assertEqual(result['new_status'], 'pickup_in_progress')
        
        # Vérifier que la livraison a changé de statut
        self.delivery.refresh_from_db()
        self.assertEqual(self.delivery.status, 'pickup_in_progress')
    
    def test_driver_rejected_cannot_accept(self):
        """Un driver rejeté ne peut pas accepter une livraison"""
        # Changer le statut en rejeté
        self.driver.verification_status = 'rejected'
        self.driver.save()
        
        # Tenter d'accepter
        with self.assertRaises(ValidationError) as context:
            self.service.driver_accept_delivery(
                delivery_id=self.delivery.id,
                driver=self.driver
            )
        
        self.assertIn('pas encore vérifié', str(context.exception))
    
    def test_driver_cannot_accept_unassigned_delivery(self):
        """Un driver ne peut pas accepter une livraison qui ne lui est pas assignée"""
        # Créer un autre driver avec un email unique
        import uuid
        unique_id = str(uuid.uuid4())[:8]
        other_driver_user = User.objects.create_user(
            email=f'other{unique_id}@test.com',
            password='password123',
            first_name='Other',
            last_name='Driver',
            phone=f'+22172{unique_id[:7]}',
            user_type='driver'
        )
        # Récupérer le driver créé automatiquement par le signal
        other_driver = Driver.objects.get(user=other_driver_user)
        other_driver.vehicle_type = 'moto'
        other_driver.vehicle_registration = 'XY 9876 ZZ'
        other_driver.verification_status = 'verified'
        other_driver.is_available = True
        other_driver.availability_status = 'available'
        other_driver.save()
        
        # Tenter d'accepter avec un autre driver
        with self.assertRaises(ValidationError) as context:
            self.service.driver_accept_delivery(
                delivery_id=self.delivery.id,
                driver=other_driver
            )
        
        self.assertIn('pas assignée à vous', str(context.exception))
