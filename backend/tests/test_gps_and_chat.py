"""
Tests pour le système GPS et Chat de LeBeni's

Ce script teste:
1. L'envoi de position GPS du driver vers le backend
2. L'envoi de messages de type "location" dans le chat
3. La récupération des coordonnées du driver par le merchant

Usage:
    cd /home/cheoo/transferer/lebenis_project/backend
    python -m pytest tests/test_gps_and_chat.py -v

Ou pour tester manuellement:
    python tests/test_gps_and_chat.py
"""

import os
import sys
import django
from datetime import datetime, timedelta
from decimal import Decimal
from uuid import uuid4

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
django.setup()

from django.contrib.auth import get_user_model
from django.test import TestCase as DjangoTestCase
from rest_framework.test import APIClient
from apps.drivers.models import Driver
from apps.drivers.gps_tracking_service import GPSTrackingService
from apps.drivers.location_models import LocationUpdate, LocationTrackingSession
from apps.chat.models import ChatRoom, ChatMessage
from apps.deliveries.models import Delivery
from apps.merchants.models import Merchant

User = get_user_model()


class GPSTrackingTests(DjangoTestCase):
    """Tests pour le système de tracking GPS"""
    
    def setUp(self):
        """Créer un driver de test"""
        self.user = User.objects.create_user(
            email='driver_test@lebenis.com',
            password='testpass123',
            first_name='Test',
            last_name='Driver',
            phone='+22500000001',
        )
        self.driver = Driver.objects.create(
            user=self.user,
            vehicle_type='moto',
            verification_status='verified',
            availability_status='available',
        )
        self.client = APIClient()
        self.client.force_authenticate(user=self.user)
    
    def test_update_driver_location(self):
        """Test: Le driver peut envoyer sa position GPS"""
        latitude = 5.3364
        longitude = -4.0267
        
        response = self.client.post('/api/v1/drivers/gps/update-location/', {
            'latitude': latitude,
            'longitude': longitude,
            'accuracy': 10.5,
            'speed': 5.2,
            'heading': 90.0,
            'altitude': 100.0,
            'battery_level': 85,
        })
        
        self.assertEqual(response.status_code, 201)
        self.assertTrue(response.data.get('success'))
        self.assertIn('location', response.data)
        self.assertIn('next_update_interval_seconds', response.data)
        
        self.driver.refresh_from_db()
        self.assertAlmostEqual(float(self.driver.current_latitude), latitude, places=4)
        self.assertAlmostEqual(float(self.driver.current_longitude), longitude, places=4)
    
    def test_location_history_created(self):
        """Test: L'historique des positions est créé"""
        positions = [
            (5.3364, -4.0267),
            (5.3370, -4.0270),
            (5.3380, -4.0280),
        ]
        
        for lat, lon in positions:
            GPSTrackingService.update_driver_location(
                driver=self.driver,
                latitude=lat,
                longitude=lon,
                speed=2.5,
            )
        
        history = LocationUpdate.objects.filter(driver=self.driver)
        self.assertEqual(history.count(), 3)
    
    def test_tracking_intervals(self):
        """Test: Les intervalles de tracking sont corrects selon le statut"""
        interval_moving = GPSTrackingService.get_tracking_interval('busy', is_moving=True)
        self.assertEqual(interval_moving, 30)
        
        interval_stopped = GPSTrackingService.get_tracking_interval('available', is_moving=False)
        self.assertEqual(interval_stopped, 10)
        
        interval_offline = GPSTrackingService.get_tracking_interval('offline', is_moving=False)
        self.assertEqual(interval_offline, 300)
    
    def test_movement_detection(self):
        """Test: Détection du mouvement basée sur la vitesse"""
        location_moving = GPSTrackingService.update_driver_location(
            driver=self.driver,
            latitude=5.3364,
            longitude=-4.0267,
            speed=5.0,
        )
        self.assertTrue(location_moving.is_moving)
        
        location_static = GPSTrackingService.update_driver_location(
            driver=self.driver,
            latitude=5.3365,
            longitude=-4.0268,
            speed=0.5,
        )
        self.assertFalse(location_static.is_moving)


class ChatLocationMessageTests(DjangoTestCase):
    """Tests pour l'envoi de messages de localisation dans le chat"""
    
    def setUp(self):
        """Créer un driver, un merchant et une conversation de test"""
        self.driver_user = User.objects.create_user(
            email='driver_chat@lebenis.com',
            password='testpass123',
            first_name='Chat',
            last_name='Driver',
            phone='+22500000002',
        )
        self.driver = Driver.objects.create(
            user=self.driver_user,
            vehicle_type='moto',
            verification_status='verified',
            availability_status='available',
        )
        
        self.merchant_user = User.objects.create_user(
            email='merchant_chat@lebenis.com',
            password='testpass123',
            first_name='Chat',
            last_name='Merchant',
            phone='+22500000003',
        )
        self.merchant = Merchant.objects.create(
            user=self.merchant_user,
            business_name='Test Business',
            business_type='restaurant',
            verification_status='approved',
        )
        
        self.chat_room = ChatRoom.objects.create(
            driver=self.driver_user,
            other_user=self.merchant_user,
            room_type='delivery',
            firebase_path=f'/chats/{uuid4()}',
        )
        
        self.driver_client = APIClient()
        self.driver_client.force_authenticate(user=self.driver_user)
        
        self.merchant_client = APIClient()
        self.merchant_client.force_authenticate(user=self.merchant_user)
    
    def test_send_location_message(self):
        """Test: Le driver peut envoyer sa position GPS via le chat"""
        response = self.driver_client.post('/api/v1/chat/messages/', {
            'chat_room_id': str(self.chat_room.id),
            'message_type': 'location',
            'text': 'Ma position actuelle',
            'latitude': 5.3364,
            'longitude': -4.0267,
        })
        
        self.assertEqual(response.status_code, 201)
        self.assertEqual(response.data['message_type'], 'location')
        self.assertIsNotNone(response.data['latitude'])
        self.assertIsNotNone(response.data['longitude'])
    
    def test_location_message_contains_coordinates(self):
        """Test: Les coordonnées sont bien stockées dans le message"""
        message = ChatMessage.objects.create(
            chat_room=self.chat_room,
            sender=self.driver_user,
            message_type='location',
            text='Position GPS',
            latitude=Decimal('5.3364'),
            longitude=Decimal('-4.0267'),
        )
        
        self.assertEqual(float(message.latitude), 5.3364)
        self.assertEqual(float(message.longitude), -4.0267)
    
    def test_merchant_receives_location(self):
        """Test: Le merchant peut voir la position du driver"""
        ChatMessage.objects.create(
            chat_room=self.chat_room,
            sender=self.driver_user,
            message_type='location',
            text='Je suis ici',
            latitude=Decimal('5.3364'),
            longitude=Decimal('-4.0267'),
        )
        
        response = self.merchant_client.get(
            f'/api/v1/chat/messages/?chat_room_id={self.chat_room.id}'
        )
        
        self.assertEqual(response.status_code, 200)
        messages = response.data.get('results', [])
        self.assertGreater(len(messages), 0)
        
        location_msg = messages[0]
        self.assertEqual(location_msg['message_type'], 'location')
        self.assertIsNotNone(location_msg['latitude'])
        self.assertIsNotNone(location_msg['longitude'])


class MerchantDriverTrackingTests(DjangoTestCase):
    """Tests pour le suivi du driver par le merchant"""
    
    def setUp(self):
        """Créer une livraison avec driver assigné"""
        self.driver_user = User.objects.create_user(
            email='driver_tracking@lebenis.com',
            password='testpass123',
            first_name='Track',
            last_name='Driver',
            phone='+22500000004',
        )
        self.driver = Driver.objects.create(
            user=self.driver_user,
            vehicle_type='moto',
            verification_status='verified',
            availability_status='busy',
            current_latitude=Decimal('5.3364'),
            current_longitude=Decimal('-4.0267'),
        )
        
        self.merchant_user = User.objects.create_user(
            email='merchant_tracking@lebenis.com',
            password='testpass123',
            first_name='Track',
            last_name='Merchant',
            phone='+22500000005',
        )
        self.merchant = Merchant.objects.create(
            user=self.merchant_user,
            business_name='Tracking Business',
            business_type='restaurant',
            verification_status='approved',
        )
        
        self.delivery = Delivery.objects.create(
            merchant=self.merchant,
            driver=self.driver,
            status='picked_up',
            recipient_name='Test Recipient',
            recipient_phone='+22500000006',
            pickup_address='123 Test Street',
            delivery_address='456 Delivery Ave',
            pickup_latitude=Decimal('5.3300'),
            pickup_longitude=Decimal('-4.0200'),
            delivery_latitude=Decimal('5.3500'),
            delivery_longitude=Decimal('-4.0400'),
        )
        
        self.merchant_client = APIClient()
        self.merchant_client.force_authenticate(user=self.merchant_user)
    
    def test_delivery_includes_driver_location(self):
        """Test: Les détails de la livraison incluent la position du driver"""
        response = self.merchant_client.get(f'/api/v1/deliveries/{self.delivery.id}/')
        
        self.assertEqual(response.status_code, 200)
        driver_data = response.data.get('driver')
        self.assertIsNotNone(driver_data)
        
        self.assertIn('current_latitude', driver_data)
        self.assertIn('current_longitude', driver_data)
        self.assertAlmostEqual(float(driver_data['current_latitude']), 5.3364, places=4)
        self.assertAlmostEqual(float(driver_data['current_longitude']), -4.0267, places=4)
    
    def test_driver_location_updates_visible(self):
        """Test: Les mises à jour de position sont visibles par le merchant"""
        new_lat, new_lon = 5.3400, -4.0300
        self.driver.current_latitude = Decimal(str(new_lat))
        self.driver.current_longitude = Decimal(str(new_lon))
        self.driver.save()
        
        response = self.merchant_client.get(f'/api/v1/deliveries/{self.delivery.id}/')
        
        self.assertEqual(response.status_code, 200)
        driver_data = response.data.get('driver')
        self.assertAlmostEqual(float(driver_data['current_latitude']), new_lat, places=4)
        self.assertAlmostEqual(float(driver_data['current_longitude']), new_lon, places=4)


def print_system_analysis():
    """Affiche une analyse du système GPS et Chat"""
    print("""
================================================================================
                    ANALYSE DU SYSTEME GPS ET MESSAGERIE
================================================================================

SYSTEME GPS DRIVER -> BACKEND
================================================================================

1. ENVOI DE POSITION (Driver App -> Backend)
   
   Endpoint: POST /api/v1/drivers/gps/update-location/
   
   Payload envoye par le driver:
   {
     "latitude": 5.3364,
     "longitude": -4.0267,
     "accuracy": 10.5,       // Precision GPS en metres
     "speed": 5.2,           // Vitesse en m/s
     "heading": 90.0,        // Direction en degres
     "altitude": 100.0,      // Altitude en metres
     "battery_level": 85,    // Niveau batterie
     "timestamp": "2024-..."  // Horodatage
   }
   
   Reponse du backend:
   {
     "success": true,
     "location": { ... },
     "next_update_interval_seconds": 30  // Intervalle recommande
   }

2. INTERVALLES ADAPTATIFS
   
   +------------------+----------------+-----------------+
   | Statut Driver    | Mouvement      | Intervalle      |
   +------------------+----------------+-----------------+
   | busy (en route)  | En mouvement   | 30 secondes     |
   | busy/available   | Arrete         | 10 secondes     |
   | offline          | -              | 5 minutes       |
   +------------------+----------------+-----------------+

3. STOCKAGE DES DONNEES
   
   - Driver.current_latitude / current_longitude : Position actuelle
   - LocationUpdate : Historique des positions
   - LocationTrackingSession : Sessions de tracking

================================================================================

SYSTEME DE MESSAGERIE AVEC PARTAGE DE POSITION
================================================================================

1. ENVOI DE MESSAGE LOCATION (Driver -> Merchant via Chat)
   
   Endpoint: POST /api/v1/chat/messages/
   
   Payload:
   {
     "chat_room_id": "uuid-de-la-conversation",
     "message_type": "location",
     "text": "Ma position actuelle",
     "latitude": 5.3364,
     "longitude": -4.0267
   }
   
   Types de messages supportes:
   - "text" : Message texte simple
   - "image" : Message avec image
   - "location" : Message avec coordonnees GPS
   - "system" : Message systeme

2. SYNCHRONISATION TEMPS REEL (Firebase)
   
   Structure Firebase:
   /chat_rooms/{chat_room_id}/
     +-- metadata/
     |     +-- lastMessage
     |     +-- lastMessageAt
     |     +-- lastMessageSenderId
     +-- messages/
           +-- {message_id}/
                 +-- senderId
                 +-- senderName
                 +-- type
                 +-- text
                 +-- latitude
                 +-- longitude
                 +-- timestamp
                 +-- isRead

================================================================================

TRACKING MERCHANT (Suivi de livraison)
================================================================================

1. RECUPERATION POSITION DRIVER
   
   Endpoint: GET /api/v1/deliveries/{id}/
   
   Reponse incluant le driver:
   {
     "id": "...",
     "status": "picked_up",
     "driver": {
       "id": "...",
       "user_id": "...",
       "current_latitude": 5.3364,
       "current_longitude": -4.0267,
       "name": "John Driver",
       ...
     },
     ...
   }

2. TRACKING EN TEMPS REEL (Merchant App)
   
   - Polling toutes les 10 secondes via deliveryDetailProvider
   - Affichage sur carte OSM (OpenStreetMap)
   - Route calculee via OSRM (Open Source Routing Machine)
   - Marqueurs: Pickup (vert), Driver (bleu), Delivery (rouge)

================================================================================

NOTIFICATIONS PUSH
================================================================================

Lors de l'envoi d'un message location:
1. Message sauvegarde en DB (ChatMessage)
2. Sync avec Firebase Realtime Database
3. Notification push envoyee au destinataire
4. Message preview: "Position"

================================================================================
""")


if __name__ == '__main__':
    print_system_analysis()
    
    print("\nExecution des tests...\n")
    
    import unittest
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()
    
    suite.addTests(loader.loadTestsFromTestCase(GPSTrackingTests))
    suite.addTests(loader.loadTestsFromTestCase(ChatLocationMessageTests))
    suite.addTests(loader.loadTestsFromTestCase(MerchantDriverTrackingTests))
    
    runner = unittest.TextTestRunner(verbosity=2)
    runner.run(suite)
