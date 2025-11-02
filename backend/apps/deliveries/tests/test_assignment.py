# backend/apps/deliveries/tests/test_assignment.py

"""
Tests unitaires pour le système d'assignation des livreurs.
Exécuter avec : python manage.py test apps.deliveries.tests.test_assignment
"""

from django.test import TestCase
from django.contrib.auth import get_user_model
from decimal import Decimal
from apps.deliveries.models import Delivery
from apps.deliveries.services import DeliveryAssignmentService
from apps.merchants.models import Merchant, MerchantAddress
from apps.drivers.models import Driver, DriverZone
from apps.pricing.models import PricingZone, ZonePricingMatrix
from datetime import datetime, timedelta

User = get_user_model()


class DeliveryAssignmentTestCase(TestCase):
    """Tests pour le service d'assignation"""
    
    def setUp(self):
        """Prépare les données de test"""
        
        # 1. Créer un merchant
        self.merchant_user = User.objects.create_user(
            email='merchant@test.com',
            phone='+2250123456789',
            password='test123',
            user_type='merchant',
            first_name='Jean',
            last_name='Merchant'
        )
        self.merchant = Merchant.objects.create(
            user=self.merchant_user,
            business_name='Test Business',
            verification_status='verified'
        )
        self.merchant_address = MerchantAddress.objects.create(
            merchant=self.merchant,
            street_address='123 Rue Test',
            commune='Plateau',
            is_primary=True
        )
        
        # 2. Créer des drivers
        # Driver 1 : Disponible, zone Cocody, bon rating
        self.driver1_user = User.objects.create_user(
            email='driver1@test.com',
            phone='+2250987654321',
            password='test123',
            user_type='driver',
            first_name='Kouadio',
            last_name='Yao'
        )
        self.driver1 = Driver.objects.create(
            user=self.driver1_user,
            vehicle_type='moto',
            verification_status='verified',
            is_available=True,
            rating=Decimal('4.8'),
            vehicle_capacity_kg=Decimal('30.00')
        )
        DriverZone.objects.create(driver=self.driver1, commune='Cocody', priority=1)
        
        # Driver 2 : Disponible mais moins bien noté
        self.driver2_user = User.objects.create_user(
            email='driver2@test.com',
            phone='+2250555555555',
            password='test123',
            user_type='driver',
            first_name='Koffi',
            last_name='Kouassi'
        )
        self.driver2 = Driver.objects.create(
            user=self.driver2_user,
            vehicle_type='moto',
            verification_status='verified',
            is_available=True,
            rating=Decimal('4.2'),
            vehicle_capacity_kg=Decimal('30.00')
        )
        DriverZone.objects.create(driver=self.driver2, commune='Cocody', priority=1)
        
        # Driver 3 : Non disponible
        self.driver3_user = User.objects.create_user(
            email='driver3@test.com',
            phone='+2250777777777',
            password='test123',
            user_type='driver',
            first_name='Konan',
            last_name='Aya'
        )
        self.driver3 = Driver.objects.create(
            user=self.driver3_user,
            vehicle_type='moto',
            verification_status='verified',
            is_available=False,  # PAS DISPONIBLE
            rating=Decimal('5.0'),
            vehicle_capacity_kg=Decimal('30.00')
        )
        
        # 3. Créer des zones tarifaires
        zone_plateau = PricingZone.objects.create(
            zone_name='Zone Plateau',
            commune='Plateau',
            is_active=True
        )
        zone_cocody = PricingZone.objects.create(
            zone_name='Zone Cocody',
            commune='Cocody',
            is_active=True
        )
        
        # Matrice tarifaire
        ZonePricingMatrix.objects.create(
            origin_zone=zone_plateau,
            destination_zone=zone_cocody,
            base_rate=Decimal('2000'),
            per_kg_rate=Decimal('200'),
            effective_from=datetime.now().date() - timedelta(days=30),
            is_active=True
        )
        
        # 4. Créer une livraison test
        self.delivery = Delivery.objects.create(
            merchant=self.merchant,
            delivery_address='456 Rue Cocody',
            delivery_commune='Cocody',
            delivery_quartier='Riviera',
            package_weight_kg=Decimal('3.5'),
            recipient_name='Test Client',
            recipient_phone='+2250999999999',
            calculated_price=Decimal('2500'),
            payment_method='prepaid',
            status='pending_assignment'
        )
        
        # 5. Service d'assignation
        self.assignment_service = DeliveryAssignmentService()
    
    def test_auto_assign_selects_best_driver(self):
        """
        Test : L'auto-assignation choisit le meilleur driver disponible
        """
        result = self.assignment_service.assign_driver_automatically(
            delivery_id=self.delivery.id
        )
        
        # Vérifications
        self.assertTrue(result['success'])
        self.assertEqual(result['driver_name'], 'Kouadio Yao')  # Driver1 (meilleur rating)
        
        # Vérifier que la livraison a été assignée
        self.delivery.refresh_from_db()
        self.assertEqual(self.delivery.driver, self.driver1)
        self.assertEqual(self.delivery.status, 'assigned')
        self.assertIsNotNone(self.delivery.assigned_at)
    
    def test_manual_assign_works(self):
        """
        Test : L'assignation manuelle fonctionne correctement
        """
        admin_user = User.objects.create_user(
            email='admin@test.com',
            phone='+2250111111111',
            password='test123',
            user_type='admin',
            first_name='Admin',
            last_name='User'
        )
        
        result = self.assignment_service.assign_driver_manually(
            delivery_id=self.delivery.id,
            driver_id=self.driver2.id,
            assigned_by_user=admin_user
        )
        
        self.assertTrue(result['success'])
        self.assertEqual(result['driver_name'], 'Koffi Kouassi')
        
        self.delivery.refresh_from_db()
        self.assertEqual(self.delivery.driver, self.driver2)
    
    def test_driver_accept_delivery(self):
        """
        Test : Un driver peut accepter une livraison assignée
        """
        # D'abord assigner
        self.assignment_service.assign_driver_manually(
            delivery_id=self.delivery.id,
            driver_id=self.driver1.id,
            assigned_by_user=self.merchant_user  # Peu importe pour ce test
        )
        
        # Accepter
        result = self.assignment_service.driver_accept_delivery(
            delivery_id=self.delivery.id,
            driver=self.driver1
        )
        
        self.assertTrue(result['success'])
        self.assertEqual(result['new_status'], 'pickup_in_progress')
        
        self.delivery.refresh_from_db()
        self.assertEqual(self.delivery.status, 'pickup_in_progress')
    
    def test_driver_reject_delivery(self):
        """
        Test : Un driver peut refuser une livraison
        """
        # Assigner
        self.assignment_service.assign_driver_manually(
            delivery_id=self.delivery.id,
            driver_id=self.driver1.id,
            assigned_by_user=self.merchant_user
        )
        
        # Refuser
        result = self.assignment_service.driver_reject_delivery(
            delivery_id=self.delivery.id,
            driver=self.driver1,
            reason="Je ne suis pas disponible"
        )
        
        self.assertTrue(result['success'])
        self.assertEqual(result['new_status'], 'pending_assignment')
        
        self.delivery.refresh_from_db()
        self.assertIsNone(self.delivery.driver)
        self.assertEqual(self.delivery.status, 'pending_assignment')
    
    def test_reassign_delivery(self):
        """
        Test : Réassignation d'une livraison à un autre driver
        """
        # Assigner au driver1
        self.assignment_service.assign_driver_manually(
            delivery_id=self.delivery.id,
            driver_id=self.driver1.id,
            assigned_by_user=self.merchant_user
        )
        
        # Réassigner au driver2
        result = self.assignment_service.reassign_delivery(
            delivery_id=self.delivery.id,
            new_driver_id=self.driver2.id,
            reason="Le premier driver a un problème"
        )
        
        self.assertTrue(result['success'])
        self.assertEqual(result['old_driver'], 'Kouadio Yao')
        self.assertEqual(result['new_driver'], 'Koffi Kouassi')
        
        self.delivery.refresh_from_db()
        self.assertEqual(self.delivery.driver, self.driver2)
    
    def test_auto_assign_no_available_driver(self):
        """
        Test : Erreur si aucun driver disponible
        """
        # Rendre tous les drivers indisponibles
        Driver.objects.all().update(is_available=False)
        
        with self.assertRaises(Exception) as context:
            self.assignment_service.assign_driver_automatically(
                delivery_id=self.delivery.id
            )
        
        self.assertIn("Aucun livreur disponible", str(context.exception))


class DeliveryQuerySetTestCase(TestCase):
    """Tests pour les filtres par rôle (merchants, drivers)"""
    
    def setUp(self):
        """Prépare les données"""
        # Merchant 1
        self.merchant1_user = User.objects.create_user(
            email='merchant1@test.com',
            phone='+2251111111111',
            password='test123',
            user_type='merchant',
            first_name='Merchant',
            last_name='One'
        )
        self.merchant1 = Merchant.objects.create(
            user=self.merchant1_user,
            business_name='Business 1',
            verification_status='verified'
        )
        
        # Merchant 2
        self.merchant2_user = User.objects.create_user(
            email='merchant2@test.com',
            phone='+2252222222222',
            password='test123',
            user_type='merchant',
            first_name='Merchant',
            last_name='Two'
        )
        self.merchant2 = Merchant.objects.create(
            user=self.merchant2_user,
            business_name='Business 2',
            verification_status='verified'
        )
        
        # Driver
        self.driver_user = User.objects.create_user(
            email='driver@test.com',
            phone='+2253333333333',
            password='test123',
            user_type='driver',
            first_name='Driver',
            last_name='Test'
        )
        self.driver = Driver.objects.create(
            user=self.driver_user,
            vehicle_type='moto',
            verification_status='verified',
            is_available=True
        )
        
        # Livraisons
        self.delivery1 = Delivery.objects.create(
            merchant=self.merchant1,
            driver=self.driver,
            delivery_address='Address 1',
            delivery_commune='Cocody',
            package_weight_kg=Decimal('2.0'),
            recipient_name='Client 1',
            recipient_phone='+2254444444444',
            calculated_price=Decimal('2000'),
            payment_method='prepaid',
            status='assigned'
        )
        
        self.delivery2 = Delivery.objects.create(
            merchant=self.merchant2,  # Autre merchant
            delivery_address='Address 2',
            delivery_commune='Plateau',
            package_weight_kg=Decimal('3.0'),
            recipient_name='Client 2',
            recipient_phone='+2255555555555',
            calculated_price=Decimal('2500'),
            payment_method='cod',
            status='pending_assignment'
        )
    
    def test_merchant_sees_only_their_deliveries(self):
        """
        Test : Un merchant ne voit que ses propres livraisons
        """
        # Simuler le queryset filtré (comme dans DeliveryViewSet.get_queryset)
        deliveries = Delivery.objects.filter(merchant=self.merchant1)
        
        self.assertEqual(deliveries.count(), 1)
        self.assertEqual(deliveries.first(), self.delivery1)
    
    def test_driver_sees_only_assigned_deliveries(self):
        """
        Test : Un driver ne voit que ses livraisons assignées
        """
        deliveries = Delivery.objects.filter(driver=self.driver)
        
        self.assertEqual(deliveries.count(), 1)
        self.assertEqual(deliveries.first(), self.delivery1)


# Pour exécuter les tests :
# python manage.py test apps.deliveries.tests.test_assignment --verbosity=2
