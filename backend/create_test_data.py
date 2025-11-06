#!/usr/bin/env python
"""
Script pour créer des données de test complètes
Usage: python manage.py shell < create_test_data.py
"""

import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')
django.setup()

from apps.authentication.models import User
from apps.drivers.models import Driver
from apps.merchants.models import Merchant
from apps.deliveries.models import Delivery
from decimal import Decimal
from django.utils import timezone
from datetime import timedelta

def create_test_data():
    """Crée un jeu de données de test complet"""
    
    print("\n" + "="*60)
    print("🎯 CRÉATION DES DONNÉES DE TEST")
    print("="*60 + "\n")
    
    # =====================================================================
    # 1. DRIVER DE TEST
    # =====================================================================
    print("👤 [1/5] Création du driver de test...")
    driver_email = "driver.test@lebenis.com"
    driver_password = "Test123456!"
    
    if User.objects.filter(email=driver_email).exists():
        driver_user = User.objects.get(email=driver_email)
        driver = driver_user.driver_profile
        print(f"   ✅ Driver existant: {driver_user.get_full_name()}")
    else:
        driver_user = User.objects.create_user(
            email=driver_email,
            password=driver_password,
            first_name="Test",
            last_name="Driver",
            phone="+2250101010101",
            user_type="driver",
            is_verified=True,
            is_active=True
        )
        driver = Driver.objects.create(
            user=driver_user,
            license_number="TEST-LIC-001",
            vehicle_type="moto",
            vehicle_registration="AA-001-BB",
            is_available=True,
            latitude=5.3599517,
            longitude=-4.0082563,
            balance=Decimal('15000.00')
        )
        print(f"   ✅ Driver créé: {driver_user.get_full_name()}")
    
    # =====================================================================
    # 2. MARCHANDS DE TEST
    # =====================================================================
    print("\n🏪 [2/5] Création des marchands de test...")
    merchants_data = [
        {
            "email": "restaurant.test@lebenis.com",
            "first_name": "Restaurant",
            "last_name": "Chez Ali",
            "phone": "+2250202020202",
            "business_name": "Restaurant Chez Ali",
            "business_type": "restaurant",
            "address": "Marcory Zone 4, Abidjan",
            "lat": 5.3116854,
            "lng": -4.0137341
        },
        {
            "email": "pharmacy.test@lebenis.com",
            "first_name": "Pharmacie",
            "last_name": "du Centre",
            "phone": "+2250303030303",
            "business_name": "Pharmacie du Centre",
            "business_type": "pharmacy",
            "address": "Plateau, Abidjan",
            "lat": 5.3236066,
            "lng": -4.0139508
        },
    ]
    
    merchants = []
    for data in merchants_data:
        if User.objects.filter(email=data['email']).exists():
            merchant_user = User.objects.get(email=data['email'])
            merchant = merchant_user.merchant_profile
            print(f"   ✅ Marchand existant: {merchant.business_name}")
        else:
            merchant_user = User.objects.create_user(
                email=data['email'],
                password="Test123456!",
                first_name=data['first_name'],
                last_name=data['last_name'],
                phone=data['phone'],
                user_type="merchant",
                is_verified=True,
                is_active=True
            )
            merchant = Merchant.objects.create(
                user=merchant_user,
                business_name=data['business_name'],
                business_type=data['business_type'],
                business_address=data['address'],
                latitude=data['lat'],
                longitude=data['lng'],
                is_active=True
            )
            print(f"   ✅ Marchand créé: {merchant.business_name}")
        merchants.append(merchant)
    
    # =====================================================================
    # 3. LIVRAISONS DE TEST
    # =====================================================================
    print("\n🚚 [3/4] Création des livraisons de test...")
    
    deliveries_data = [
        {
            "merchant": merchants[0],
            "status": "assigned",
            "recipient_name": "Jean Kouassi",
            "recipient_phone": "+2250707070701",
            "delivery_address": "Cocody Riviera 2",
            "delivery_lat": 5.3599517,
            "delivery_lng": -4.0082563,
            "description": "Plat de poulet braisé avec attiéké",
            "delivery_fee": 1500,
            "days_ago": 0,
        },
        {
            "merchant": merchants[1],
            "status": "pickup_in_progress",
            "recipient_name": "Marie Koffi",
            "recipient_phone": "+2250707070702",
            "delivery_address": "Yopougon Mamie Adjoua",
            "delivery_lat": 5.3435565,
            "delivery_lng": -4.0742166,
            "description": "Médicaments de pharmacie",
            "delivery_fee": 2000,
            "days_ago": 0,
        },
        {
            "merchant": merchants[0],
            "status": "delivered",
            "recipient_name": "Kouadio Ange",
            "recipient_phone": "+2250707070703",
            "delivery_address": "Abobo Gare",
            "delivery_lat": 5.4199974,
            "delivery_lng": -4.0199999,
            "description": "Commande restaurant",
            "delivery_fee": 2500,
            "days_ago": 1,
        },
        {
            "merchant": merchants[1],
            "status": "delivered",
            "recipient_name": "Diabaté Fatou",
            "recipient_phone": "+2250707070704",
            "delivery_address": "Adjamé Liberté",
            "delivery_lat": 5.3599517,
            "delivery_lng": -4.0282563,
            "description": "Commande pharmacie urgente",
            "delivery_fee": 1800,
            "days_ago": 2,
        },
        {
            "merchant": merchants[0],
            "status": "delivered",
            "recipient_name": "Traoré Sekou",
            "recipient_phone": "+2250707070705",
            "delivery_address": "Marcory Biétry",
            "delivery_lat": 5.3116854,
            "delivery_lng": -4.0037341,
            "description": "Grande commande restaurant",
            "delivery_fee": 3000,
            "days_ago": 3,
        },
    ]
    
    deliveries_created = 0
    for data in deliveries_data:
        created_at = timezone.now() - timedelta(days=data['days_ago'])
        
        delivery = Delivery.objects.create(
            merchant=data['merchant'],
            driver=driver,
            status=data['status'],
            recipient_name=data['recipient_name'],
            recipient_phone=data['recipient_phone'],
            delivery_address=data['delivery_address'],
            delivery_latitude=data['delivery_lat'],
            delivery_longitude=data['delivery_lng'],
            package_description=data['description'],
            delivery_fee=Decimal(str(data['delivery_fee'])),
            created_at=created_at,
            updated_at=created_at
        )
        
        # Mettre à jour les timestamps pour les livraisons terminées
        if data['status'] == 'delivered':
            delivery.accepted_at = created_at + timedelta(minutes=5)
            delivery.picked_up_at = created_at + timedelta(minutes=15)
            delivery.delivered_at = created_at + timedelta(minutes=45)
            delivery.save()
        elif data['status'] == 'pickup_in_progress':
            delivery.accepted_at = created_at + timedelta(minutes=2)
            delivery.save()
        elif data['status'] == 'assigned':
            delivery.accepted_at = created_at + timedelta(minutes=1)
            delivery.save()
        
        deliveries_created += 1
        status_emoji = {
            'assigned': '📌',
            'pickup_in_progress': '🏃',
            'delivered': '✅'
        }.get(data['status'], '📦')
        
        print(f"   {status_emoji} Livraison {data['status']}: {data['recipient_name']} ({data['delivery_fee']} FCFA)")
    
    print(f"\n   ✅ {deliveries_created} livraisons créées")
    
    # =====================================================================
    # 5. RÉCAPITULATIF
    # =====================================================================
    print("\n" + "="*60)
    print("✅ DONNÉES DE TEST CRÉÉES AVEC SUCCÈS")
    print("="*60)
    
    print(f"\n👤 DRIVER:")
    print(f"   Email: {driver_email}")
    print(f"   Mot de passe: {driver_password}")
    print(f"   Solde: {driver.balance} FCFA")
    print(f"   Livraisons: {Delivery.objects.filter(driver=driver).count()}")
    
    print(f"\n🏪 MARCHANDS ({len(merchants)}):")
    for merchant in merchants:
        print(f"   - {merchant.business_name}")
        print(f"     Email: {merchant.user.email}")
        print(f"     Livraisons: {Delivery.objects.filter(merchant=merchant).count()}")
    
    print(f"\n🚚 LIVRAISONS:")
    for status in ['assigned', 'pickup_in_progress', 'in_transit', 'delivered']:
        count = Delivery.objects.filter(status=status).count()
        if count > 0:
            print(f"   - {status}: {count}")
    
    print("\n" + "="*60)
    print("🎉 Vous pouvez maintenant tester l'application !")
    print("="*60 + "\n")

if __name__ == '__main__':
    create_test_data()
