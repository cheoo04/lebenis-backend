# pricing/management/commands/populate_pricing.py

from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import date, timedelta
from decimal import Decimal
from apps.pricing.models import PricingZone, ZonePricingMatrix


class Command(BaseCommand):
    """
    Commande Django pour peupler la base de données avec :
    - Zones tarifaires pour Abidjan (Cocody, Plateau, Marcory, etc.)
    - Matrices tarifaires (tarifs entre paires de zones)
    
    Utilisation :
    python manage.py populate_pricing
    
    Cette commande crée des données de test pour tester le calcul de prix.
    """
    
    help = 'Peuple la base avec des données de tarification pour Abidjan'
    
    def handle(self, *args, **options):
        """Main function exécutée par la commande"""
        
        self.stdout.write(
            self.style.SUCCESS('🚀 Démarrage du peuplement des données de tarification...')
        )
        
        # ===================================================================
        # ÉTAPE 1 : Créer les zones tarifaires
        # ===================================================================
        
        self.stdout.write('\n📍 Création des zones tarifaires...')
        
        zones_data = [
            {
                'zone_name': 'Cocody Centre',
                'commune': 'Cocody',
                'quartier': 'Riviera',
                'description': 'Zone centrale de Cocody (Riviera, Petit-Basam)',
            },
            {
                'zone_name': 'Plateau Commercial',
                'commune': 'Plateau',
                'quartier': 'Centre',
                'description': 'Centre-ville, Plateau Administratif',
            },
            {
                'zone_name': 'Marcory Zone 4',
                'commune': 'Marcory',
                'quartier': 'Zone 4',
                'description': 'Marcory Zone 4 et alentours',
            },
            {
                'zone_name': 'Yopougon',
                'commune': 'Yopougon',
                'quartier': '',
                'description': 'Yopougon (Gesco, Azito, etc.)',
            },
            {
                'zone_name': 'Abobo',
                'commune': 'Abobo',
                'quartier': '',
                'description': 'Abobo (Abobo Doumé, etc.)',
            },
            {
                'zone_name': 'Treichville',
                'commune': 'Treichville',
                'quartier': '',
                'description': 'Treichville et environs',
            },
            {
                'zone_name': 'Adjamé',
                'commune': 'Adjamé',
                'quartier': '',
                'description': 'Adjamé (gare routière, etc.)',
            },
        ]
        
        zones = {}
        for zone_data in zones_data:
            zone, created = PricingZone.objects.get_or_create(
                commune=zone_data['commune'],
                defaults={
                    'zone_name': zone_data['zone_name'],
                    'quartier': zone_data.get('quartier', ''),
                    'description': zone_data.get('description', ''),
                    'is_active': True
                }
            )
            zones[zone_data['commune']] = zone
            
            status_text = '✅ Créée' if created else '⚠️ Existe déjà'
            self.stdout.write(f"  {status_text}: {zone.zone_name}")
        
        # ===================================================================
        # ÉTAPE 2 : Créer les matrices tarifaires
        # ===================================================================
        
        self.stdout.write('\n💰 Création des matrices tarifaires...')
        
        today = date.today()
        effective_to = today + timedelta(days=365)  # Valide pour 1 an
        
        pricing_data = [
            # ✅ Tarifs depuis Cocody
            {
                'origin': 'Cocody',
                'destination': 'Plateau',
                'base_rate': Decimal('1500'),
                'per_kg_rate': Decimal('200'),
                'per_km_rate': Decimal('100'),
                'max_weight': Decimal('5.0')
            },
            {
                'origin': 'Cocody',
                'destination': 'Marcory',
                'base_rate': Decimal('2000'),
                'per_kg_rate': Decimal('250'),
                'per_km_rate': Decimal('150'),
                'max_weight': Decimal('3.0')
            },
            {
                'origin': 'Cocody',
                'destination': 'Yopougon',
                'base_rate': Decimal('2500'),
                'per_kg_rate': Decimal('300'),
                'per_km_rate': Decimal('200'),
                'max_weight': Decimal('3.0')
            },
            {
                'origin': 'Cocody',
                'destination': 'Abobo',
                'base_rate': Decimal('3000'),
                'per_kg_rate': Decimal('350'),
                'per_km_rate': Decimal('250'),
                'max_weight': Decimal('2.0')
            },
            
            # ✅ Tarifs depuis Plateau
            {
                'origin': 'Plateau',
                'destination': 'Cocody',
                'base_rate': Decimal('1500'),
                'per_kg_rate': Decimal('200'),
                'per_km_rate': Decimal('100'),
                'max_weight': Decimal('5.0')
            },
            {
                'origin': 'Plateau',
                'destination': 'Marcory',
                'base_rate': Decimal('1000'),
                'per_kg_rate': Decimal('150'),
                'per_km_rate': Decimal('75'),
                'max_weight': Decimal('5.0')
            },
            {
                'origin': 'Plateau',
                'destination': 'Yopougon',
                'base_rate': Decimal('2000'),
                'per_kg_rate': Decimal('250'),
                'per_km_rate': Decimal('150'),
                'max_weight': Decimal('3.0')
            },
            {
                'origin': 'Plateau',
                'destination': 'Adjamé',
                'base_rate': Decimal('1200'),
                'per_kg_rate': Decimal('150'),
                'per_km_rate': Decimal('100'),
                'max_weight': Decimal('5.0')
            },
            
            # ✅ Tarifs depuis Marcory
            {
                'origin': 'Marcory',
                'destination': 'Plateau',
                'base_rate': Decimal('1000'),
                'per_kg_rate': Decimal('150'),
                'per_km_rate': Decimal('75'),
                'max_weight': Decimal('5.0')
            },
            {
                'origin': 'Marcory',
                'destination': 'Abobo',
                'base_rate': Decimal('3000'),
                'per_kg_rate': Decimal('350'),
                'per_km_rate': Decimal('250'),
                'max_weight': Decimal('2.0')
            },
            {
                'origin': 'Marcory',
                'destination': 'Treichville',
                'base_rate': Decimal('1500'),
                'per_kg_rate': Decimal('200'),
                'per_km_rate': Decimal('120'),
                'max_weight': Decimal('4.0')
            },
            
            # ✅ Tarifs depuis Yopougon
            {
                'origin': 'Yopougon',
                'destination': 'Plateau',
                'base_rate': Decimal('2000'),
                'per_kg_rate': Decimal('250'),
                'per_km_rate': Decimal('150'),
                'max_weight': Decimal('3.0')
            },
            {
                'origin': 'Yopougon',
                'destination': 'Cocody',
                'base_rate': Decimal('2500'),
                'per_kg_rate': Decimal('300'),
                'per_km_rate': Decimal('200'),
                'max_weight': Decimal('3.0')
            },
            
            # ✅ Tarifs depuis Abobo
            {
                'origin': 'Abobo',
                'destination': 'Plateau',
                'base_rate': Decimal('1500'),
                'per_kg_rate': Decimal('200'),
                'per_km_rate': Decimal('100'),
                'max_weight': Decimal('5.0')
            },
            {
                'origin': 'Abobo',
                'destination': 'Cocody',
                'base_rate': Decimal('3000'),
                'per_kg_rate': Decimal('350'),
                'per_km_rate': Decimal('250'),
                'max_weight': Decimal('2.0')
            },
        ]
        
        created_count = 0
        for price in pricing_data:
            matrix, created = ZonePricingMatrix.objects.get_or_create(
                origin_zone=zones[price['origin']],
                destination_zone=zones[price['destination']],
                defaults={
                    'base_rate': price['base_rate'],
                    'per_kg_rate': price['per_kg_rate'],
                    'per_km_rate': price['per_km_rate'],
                    'max_weight_included': price['max_weight'],
                    'effective_from': today,
                    'effective_to': effective_to,
                    'is_active': True
                }
            )
            
            if created:
                created_count += 1
                self.stdout.write(
                    f"  ✅ Créé: {price['origin']} → {price['destination']}: "
                    f"{price['base_rate']} CFA (base)"
                )
            else:
                self.stdout.write(
                    f"  ⚠️ Existe: {price['origin']} → {price['destination']}"
                )
        
        # ===================================================================
        # RÉSUMÉ
        # ===================================================================
        
        total_zones = PricingZone.objects.count()
        total_matrices = ZonePricingMatrix.objects.count()
        
        self.stdout.write(
            self.style.SUCCESS(
                f'\n✅ Peuplement terminé!\n'
                f'   • {total_zones} zones créées\n'
                f'   • {total_matrices} matrices tarifaires créées\n'
                f'   • {created_count} nouvelles matrices créées cette exécution'
            )
        )
