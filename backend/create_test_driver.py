#!/usr/bin/env python
"""
Script pour créer un compte driver de test
Usage: python manage.py shell < create_test_driver.py
"""

import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')
django.setup()

from apps.authentication.models import User
from apps.drivers.models import Driver
from decimal import Decimal

def create_test_driver():
    """Crée un driver de test pour le développement"""
    
    # Données du driver
    email = "driver.test@lebenis.com"
    password = "Test123456!"
    phone = "+2250101010101"
    
    print(f"\n🚗 Création du driver de test...")
    print(f"📧 Email: {email}")
    print(f"📱 Téléphone: {phone}")
    print(f"🔑 Mot de passe: {password}")
    
    # Vérifier si l'utilisateur existe déjà
    if User.objects.filter(email=email).exists():
        print(f"\n⚠️  L'utilisateur {email} existe déjà.")
        user = User.objects.get(email=email)
        
        # Vérifier si le profil driver existe
        if hasattr(user, 'driver_profile'):
            driver = user.driver_profile
            print(f"✅ Profil driver existant trouvé (ID: {driver.id})")
        else:
            # Créer le profil driver manquant
            print("📝 Création du profil driver...")
            driver = Driver.objects.create(
                user=user,
                license_number="TEST-LIC-001",
                vehicle_type="moto",
                vehicle_registration="AA-001-BB",
                is_available=True,
                latitude=5.3599517,  # Abidjan Plateau
                longitude=-4.0082563
            )
            print(f"✅ Profil driver créé (ID: {driver.id})")
    else:
        # Créer l'utilisateur
        print(f"\n📝 Création de l'utilisateur...")
        user = User.objects.create_user(
            email=email,
            password=password,
            first_name="Test",
            last_name="Driver",
            phone=phone,
            user_type="driver",
            is_verified=True,
            is_active=True
        )
        print(f"✅ Utilisateur créé (ID: {user.id})")
        
        # Créer le profil driver
        print(f"📝 Création du profil driver...")
        driver = Driver.objects.create(
            user=user,
            license_number="TEST-LIC-001",
            vehicle_type="moto",
            vehicle_registration="AA-001-BB",
            is_available=True,
            latitude=5.3599517,  # Abidjan Plateau
            longitude=-4.0082563,
            balance=Decimal('0.00')
        )
        print(f"✅ Profil driver créé (ID: {driver.id})")
    
    # Afficher le récapitulatif
    print("\n" + "="*60)
    print("✅ DRIVER DE TEST CRÉÉ AVEC SUCCÈS")
    print("="*60)
    print(f"\n📋 Informations de connexion:")
    print(f"   Email: {email}")
    print(f"   Mot de passe: {password}")
    print(f"   User Type: driver")
    print(f"   User ID: {user.id}")
    print(f"   Driver ID: {driver.id}")
    print(f"\n🗺️  Localisation:")
    print(f"   Latitude: {driver.latitude}")
    print(f"   Longitude: {driver.longitude}")
    print(f"   Disponible: {'Oui' if driver.is_available else 'Non'}")
    print(f"\n🚗 Véhicule:")
    print(f"   Type: {driver.get_vehicle_type_display()}")
    print(f"   Immatriculation: {driver.vehicle_registration}")
    print(f"   Permis: {driver.license_number}")
    print(f"\n💰 Solde: {driver.balance} FCFA")
    print("\n" + "="*60)
    print("\n📱 Vous pouvez maintenant vous connecter avec ce compte")
    print("   dans l'application driver Flutter.\n")

if __name__ == '__main__':
    create_test_driver()
