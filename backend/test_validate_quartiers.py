#!/usr/bin/env python
"""
Script de démonstration de la validation de quartiers
Teste si les quartiers existent dans la base OU sur OpenStreetMap
"""
import os
import sys
import django

# Configuration Django
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from apps.core.quartiers_data import get_quartier_coordinates, search_quartiers
from apps.core.nominatim_service import NominatimService


def validate_quartier(quartier_name, commune_name=None):
    """
    Valide si un quartier existe
    Retourne: (found, source, data, message)
    """
    print(f"\n{'='*70}")
    print(f"🔍 VALIDATION: '{quartier_name}' {f'à {commune_name}' if commune_name else ''}")
    print(f"{'='*70}")
    
    # ÉTAPE 1: Base locale
    print("\n[1/3] Recherche dans la base locale...")
    local_result = get_quartier_coordinates(quartier_name, commune_name)
    
    if local_result and local_result.get('has_gps'):
        print(f"✅ TROUVÉ (avec GPS)")
        print(f"    📍 {local_result['nom']}, {local_result['commune']}")
        print(f"    🗺️  GPS: {local_result['latitude']}, {local_result['longitude']}")
        print(f"    📦 Source: Base locale")
        return True, 'local', local_result, 'Quartier trouvé dans notre base'
    
    if local_result and not local_result.get('has_gps'):
        print(f"⚠️  TROUVÉ (mais sans GPS local)")
        print(f"    📍 {local_result['nom']}, {local_result['commune']}")
        
        # Essayer Nominatim
        print("\n[2/3] Recherche GPS sur OpenStreetMap...")
        nominatim_result = NominatimService.geocode_quartier(
            local_result['nom'], 
            local_result['commune']
        )
        
        if nominatim_result:
            print(f"✅ GPS TROUVÉ sur OpenStreetMap")
            print(f"    🗺️  GPS: {nominatim_result['latitude']}, {nominatim_result['longitude']}")
            print(f"    🌍 {nominatim_result.get('display_name', '')}")
            return True, 'local+nominatim', nominatim_result, 'GPS obtenu via OpenStreetMap'
        else:
            print(f"❌ GPS non disponible sur OpenStreetMap")
            return False, 'local', local_result, 'Quartier connu mais GPS indisponible'
    
    print("❌ Pas dans la base locale")
    
    # ÉTAPE 2: OpenStreetMap direct
    print("\n[2/3] Recherche directe sur OpenStreetMap...")
    address = f"{quartier_name}, {commune_name}, Abidjan" if commune_name else f"{quartier_name}, Abidjan"
    nominatim_result = NominatimService.geocode_address(address)
    
    if nominatim_result:
        lat, lon = nominatim_result  # C'est un tuple (lat, lon)
        print(f"✅ TROUVÉ sur OpenStreetMap")
        print(f"    🗺️  GPS: {lat}, {lon}")
        return True, 'nominatim', {'latitude': lat, 'longitude': lon}, 'Trouvé sur OpenStreetMap'
    
    print("❌ Pas sur OpenStreetMap")
    
    # ÉTAPE 3: Suggestions
    print("\n[3/3] Recherche de suggestions...")
    suggestions = search_quartiers(quartier_name, limit=5)
    
    if suggestions:
        print(f"💡 {len(suggestions)} suggestion(s) trouvée(s):")
        for i, s in enumerate(suggestions, 1):
            gps_icon = "📍" if s.get('has_gps') else "❓"
            print(f"    {i}. {gps_icon} {s['nom']}, {s['commune']}")
    else:
        print("❌ Aucune suggestion trouvée")
    
    return False, None, None, 'Quartier non trouvé'


def main():
    """Tests de validation"""
    print("""
╔════════════════════════════════════════════════════════════════════╗
║   SCRIPT DE VALIDATION DE QUARTIERS D'ABIDJAN                     ║
║   Teste si les quartiers existent (base locale OU OpenStreetMap)  ║
╚════════════════════════════════════════════════════════════════════╝
    """)
    
    # Test 1: Quartier dans base locale avec GPS
    print("\n" + "="*70)
    print("TEST 1: Quartier connu avec GPS local")
    print("="*70)
    validate_quartier("Riviera 2", "Cocody")
    
    # Test 2: Quartier dans base locale SANS GPS (testera Nominatim)
    print("\n" + "="*70)
    print("TEST 2: Quartier connu SANS GPS (utilisera OpenStreetMap)")
    print("="*70)
    validate_quartier("Bahouakoi", "Cocody")
    
    # Test 3: Quartier inconnu mais existant sur OpenStreetMap
    print("\n" + "="*70)
    print("TEST 3: Quartier pas dans notre base (cherche sur OpenStreetMap)")
    print("="*70)
    validate_quartier("Corniche", "Cocody")
    
    # Test 4: Faute de frappe
    print("\n" + "="*70)
    print("TEST 4: Faute de frappe (suggestions)")
    print("="*70)
    validate_quartier("Riveria 2", "Cocody")  # Faute: "Riveria" au lieu de "Riviera"
    
    # Test 5: Quartier totalement inconnu
    print("\n" + "="*70)
    print("TEST 5: Quartier imaginaire")
    print("="*70)
    validate_quartier("Quartier Imaginaire XYZ", "Cocody")
    
    # Test 6: Sans commune (recherche large)
    print("\n" + "="*70)
    print("TEST 6: Recherche sans commune spécifiée")
    print("="*70)
    validate_quartier("Gesco")
    
    print("\n" + "="*70)
    print("✅ TESTS TERMINÉS")
    print("="*70)
    print("""
COMMENT ÇA MARCHE:
1. Le système cherche d'abord dans notre base locale (215 quartiers)
2. Si trouvé AVEC GPS → ✅ Réponse instantanée
3. Si trouvé SANS GPS → Demande les coordonnées à OpenStreetMap
4. Si pas trouvé → Recherche directe sur OpenStreetMap
5. Si toujours pas trouvé → Propose des suggestions

AVANTAGES:
- ✅ RAPIDE: Base locale pour les quartiers populaires
- ✅ COMPLET: OpenStreetMap pour les quartiers inconnus
- ✅ GRATUIT: Nominatim est 100% gratuit et illimité
- ✅ UX: Suggestions en cas de faute de frappe
    """)


if __name__ == '__main__':
    main()
