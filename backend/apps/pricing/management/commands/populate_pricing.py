# pricing/management/commands/populate_pricing.py

from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import date, timedelta
from decimal import Decimal
from apps.pricing.models import PricingZone, ZonePricingMatrix


class Command(BaseCommand):
    """
    Commande Django pour peupler la base de données avec :
    - Zones tarifaires pour Abidjan et environs (17 zones)
    - Matrices tarifaires basées sur le SYSTÈME B GÉOGRAPHIQUE
    
    SYSTÈME B GÉOGRAPHIQUE (6 groupes basés sur la proximité réelle) :
    - Groupe 1 (Est proche)    : Cocody, Bingerville
    - Groupe 2 (Centre)        : Plateau, Adjamé, Attécoubé
    - Groupe 3 (Sud)           : Marcory, Treichville, Koumassi, Port-Bouët
    - Groupe 4 (Ouest)         : Yopougon, Songon, Dabou, Jacqueville
    - Groupe 5 (Nord)          : Abobo, Anyama
    - Groupe 6 (Est lointain)  : Grand-Bassam, Bonoua
    
    TARIFS :
    - Même groupe = 1500 FCFA
    - Groupes voisins = 2000 FCFA
    - Groupes éloignés = 2500 FCFA
    
    POIDS (Option 4) :
    - 10 kg inclus
    - +50 FCFA par kg au-delà de 10 kg
    
    Utilisation :
    python manage.py populate_pricing
    """
    
    help = 'Peuple la base avec des données de tarification pour Abidjan (Système B géographique)'
    
    # SYSTÈME B GÉOGRAPHIQUE - 6 groupes basés sur la proximité
    GROUPES = {
        1: ['Cocody', 'Bingerville'],                            # Est proche
        2: ['Plateau', 'Adjamé', 'Attécoubé'],                   # Centre
        3: ['Marcory', 'Treichville', 'Koumassi', 'Port-Bouët'], # Sud
        4: ['Yopougon', 'Songon', 'Dabou', 'Jacqueville'],       # Ouest
        5: ['Abobo', 'Anyama'],                                   # Nord
        6: ['Grand-Bassam', 'Bonoua'],                           # Est lointain
    }
    
    # Adjacence entre groupes (groupes voisins)
    ADJACENT = {
        1: [2, 5, 6],     # Est proche → Centre, Nord, Est lointain
        2: [1, 3, 4, 5],  # Centre → Est proche, Sud, Ouest, Nord
        3: [1, 2],        # Sud → Est proche, Centre
        4: [2, 5],        # Ouest → Centre, Nord
        5: [1, 2, 4],     # Nord → Est proche, Centre, Ouest
        6: [1, 3],        # Est lointain → Est proche, Sud
    }
    
    # Tarifs
    TARIFS = {
        'meme_groupe': Decimal('1500'),      # Même groupe
        'groupe_voisin': Decimal('2000'),    # Groupes adjacents
        'groupe_eloigne': Decimal('2500'),   # Groupes éloignés
    }
    
    # Configuration poids (Option 4)
    MAX_WEIGHT_INCLUDED = Decimal('10.0')  # 10 kg inclus
    PER_KG_RATE = Decimal('50')            # +50 FCFA/kg au-delà
    
    def get_groupe_number(self, commune):
        """Retourne le numéro de groupe (1-6) pour une commune"""
        for groupe, communes in self.GROUPES.items():
            if commune in communes:
                return groupe
        return 2  # Groupe par défaut (Centre)
    
    def get_tarif_deplacement(self, origin_commune, dest_commune):
        """
        Retourne le tarif basé sur le déplacement entre groupes géographiques.
        
        - Même groupe = 1500 FCFA
        - Groupes voisins = 2000 FCFA
        - Groupes éloignés = 2500 FCFA
        """
        g1 = self.get_groupe_number(origin_commune)
        g2 = self.get_groupe_number(dest_commune)
        
        if g1 == g2:
            return self.TARIFS['meme_groupe']  # 1500 FCFA
        elif g2 in self.ADJACENT.get(g1, []):
            return self.TARIFS['groupe_voisin']  # 2000 FCFA
        else:
            return self.TARIFS['groupe_eloigne']  # 2500 FCFA
    
    def handle(self, *args, **options):
        """Main function exécutée par la commande"""
        
        self.stdout.write(
            self.style.SUCCESS('🚀 Démarrage du peuplement des données de tarification (Système B)...')
        )
        
        # ===================================================================
        # ÉTAPE 1 : Créer les zones tarifaires (17 zones)
        # ===================================================================
        
        self.stdout.write('\n📍 Création des 17 zones tarifaires...')
        
        zones_data = [
            # Groupe 1 - Est proche
            {'zone_name': 'Cocody', 'commune': 'Cocody', 'quartier': '', 'description': 'Cocody - Groupe 1 (Est proche)'},
            {'zone_name': 'Bingerville', 'commune': 'Bingerville', 'quartier': '', 'description': 'Bingerville - Groupe 1 (Est proche)'},
            
            # Groupe 2 - Centre
            {'zone_name': 'Plateau', 'commune': 'Plateau', 'quartier': '', 'description': 'Plateau - Groupe 2 (Centre)'},
            {'zone_name': 'Adjamé', 'commune': 'Adjamé', 'quartier': '', 'description': 'Adjamé - Groupe 2 (Centre)'},
            {'zone_name': 'Attécoubé', 'commune': 'Attécoubé', 'quartier': '', 'description': 'Attécoubé - Groupe 2 (Centre)'},
            
            # Groupe 3 - Sud
            {'zone_name': 'Marcory', 'commune': 'Marcory', 'quartier': '', 'description': 'Marcory - Groupe 3 (Sud)'},
            {'zone_name': 'Treichville', 'commune': 'Treichville', 'quartier': '', 'description': 'Treichville - Groupe 3 (Sud)'},
            {'zone_name': 'Koumassi', 'commune': 'Koumassi', 'quartier': '', 'description': 'Koumassi - Groupe 3 (Sud)'},
            {'zone_name': 'Port-Bouët', 'commune': 'Port-Bouët', 'quartier': '', 'description': 'Port-Bouët - Groupe 3 (Sud)'},
            
            # Groupe 4 - Ouest
            {'zone_name': 'Yopougon', 'commune': 'Yopougon', 'quartier': '', 'description': 'Yopougon - Groupe 4 (Ouest)'},
            {'zone_name': 'Songon', 'commune': 'Songon', 'quartier': '', 'description': 'Songon - Groupe 4 (Ouest)'},
            {'zone_name': 'Dabou', 'commune': 'Dabou', 'quartier': '', 'description': 'Dabou - Groupe 4 (Ouest)'},
            {'zone_name': 'Jacqueville', 'commune': 'Jacqueville', 'quartier': '', 'description': 'Jacqueville - Groupe 4 (Ouest)'},
            
            # Groupe 5 - Nord
            {'zone_name': 'Abobo', 'commune': 'Abobo', 'quartier': '', 'description': 'Abobo - Groupe 5 (Nord)'},
            {'zone_name': 'Anyama', 'commune': 'Anyama', 'quartier': '', 'description': 'Anyama - Groupe 5 (Nord)'},
            
            # Groupe 6 - Est lointain
            {'zone_name': 'Grand-Bassam', 'commune': 'Grand-Bassam', 'quartier': '', 'description': 'Grand-Bassam - Groupe 6 (Est lointain)'},
            {'zone_name': 'Bonoua', 'commune': 'Bonoua', 'quartier': '', 'description': 'Bonoua - Groupe 6 (Est lointain)'},
        ]
        
        zones = {}
        for zone_data in zones_data:
            zone, created = PricingZone.objects.update_or_create(
                commune=zone_data['commune'],
                defaults={
                    'zone_name': zone_data['zone_name'],
                    'quartier': zone_data.get('quartier', ''),
                    'description': zone_data.get('description', ''),
                    'is_active': True
                }
            )
            zones[zone_data['commune']] = zone
            
            status_text = '✅ Créée' if created else '🔄 Mise à jour'
            self.stdout.write(f"  {status_text}: {zone.zone_name}")
        
        # ===================================================================
        # ÉTAPE 2 : Créer les matrices tarifaires (Système B géographique)
        # ===================================================================
        
        self.stdout.write('\n💰 Création des matrices tarifaires (Système B géographique)...')
        
        today = date.today()
        effective_to = today + timedelta(days=365 * 10)  # Valide pour 10 ans
        
        # Toutes les communes
        all_communes = list(zones.keys())
        
        created_count = 0
        updated_count = 0
        
        # Créer les matrices pour toutes les combinaisons origine -> destination
        for origin_commune in all_communes:
            for dest_commune in all_communes:
                # Obtenir le tarif basé sur le groupe géographique
                base_rate = self.get_tarif_deplacement(origin_commune, dest_commune)
                
                matrix, created = ZonePricingMatrix.objects.update_or_create(
                    origin_zone=zones[origin_commune],
                    destination_zone=zones[dest_commune],
                    defaults={
                        'base_rate': base_rate,
                        'per_kg_rate': self.PER_KG_RATE,           # +50 FCFA par kg au-delà de 10kg
                        'per_km_rate': Decimal('0'),               # Pas de surcharge au km
                        'max_weight_included': self.MAX_WEIGHT_INCLUDED,  # 10 kg inclus
                        'effective_from': today,
                        'effective_to': effective_to,
                        'is_active': True
                    }
                )
                
                if created:
                    created_count += 1
                else:
                    updated_count += 1
        
        self.stdout.write(f"\n  ✅ {created_count} matrices créées")
        self.stdout.write(f"  🔄 {updated_count} matrices mises à jour")
        
        # ===================================================================
        # RÉSUMÉ DES TARIFS
        # ===================================================================
        
        total_zones = PricingZone.objects.count()
        total_matrices = ZonePricingMatrix.objects.count()
        
        self.stdout.write(
            self.style.SUCCESS(
                f'\n✅ Peuplement terminé!\n\n'
                f'📋 SYSTÈME B GÉOGRAPHIQUE (tarifs par groupe):\n\n'
                f'  🟢 Même groupe = 1500 FCFA\n'
                f'     Ex: Cocody → Bingerville, Yopougon → Songon\n\n'
                f'  🟡 Groupes voisins = 2000 FCFA\n'
                f'     Ex: Cocody → Adjamé, Abobo → Yopougon\n\n'
                f'  🔴 Groupes éloignés = 2500 FCFA\n'
                f'     Ex: Yopougon → Cocody, Abobo → Port-Bouët\n\n'
                f'📍 GROUPES GÉOGRAPHIQUES (17 communes):\n'
                f'  Groupe 1 (Est proche)   : Cocody, Bingerville\n'
                f'  Groupe 2 (Centre)       : Plateau, Adjamé, Attécoubé\n'
                f'  Groupe 3 (Sud)          : Marcory, Treichville, Koumassi, Port-Bouët\n'
                f'  Groupe 4 (Ouest)        : Yopougon, Songon, Dabou, Jacqueville\n'
                f'  Groupe 5 (Nord)         : Abobo, Anyama\n'
                f'  Groupe 6 (Est lointain) : Grand-Bassam, Bonoua\n\n'
                f'📦 POIDS (Option 4):\n'
                f'  • 10 kg inclus\n'
                f'  • +50 FCFA par kg au-delà de 10 kg\n'
            )
        )
