"""
Tests pour le service de localisation des quartiers
Teste les endpoints et les services Nominatim

Exécuter avec:
    python manage.py test apps.core.tests_location -v 2
    
Ou tester manuellement:
    python backend/test_location_service.py
"""
import requests
import json

# Configuration
BASE_URL = "http://localhost:8000/api/v1/locations"


def test_list_quartiers():
    """Test GET /api/v1/locations/quartiers/"""
    print("\n" + "="*50)
    print("TEST 1: Liste tous les quartiers")
    print("="*50)
    
    response = requests.get(f"{BASE_URL}/quartiers/")
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ {data['count']} quartiers trouvés")
        print(f"   Exemples: {data['quartiers'][:3]}")
    else:
        print(f"❌ Erreur: {response.text}")


def test_list_quartiers_by_commune():
    """Test GET /api/v1/locations/quartiers/?commune=Cocody"""
    print("\n" + "="*50)
    print("TEST 2: Quartiers de Cocody")
    print("="*50)
    
    response = requests.get(f"{BASE_URL}/quartiers/", params={'commune': 'Cocody'})
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ {data['count']} quartiers à Cocody")
        for q in data['quartiers'][:5]:
            print(f"   - {q['nom']} ({q['latitude']}, {q['longitude']})")
    else:
        print(f"❌ Erreur: {response.text}")


def test_search_quartiers():
    """Test GET /api/v1/locations/quartiers/search/?q=Riviera"""
    print("\n" + "="*50)
    print("TEST 3: Recherche 'Riviera'")
    print("="*50)
    
    response = requests.get(f"{BASE_URL}/quartiers/search/", params={'q': 'Riviera'})
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ {data['count']} résultats pour '{data['query']}'")
        for q in data['results']:
            print(f"   - {q['nom']}, {q['commune']}")
    else:
        print(f"❌ Erreur: {response.text}")


def test_geocode_quartier_local():
    """Test POST /api/v1/locations/geocode-quartier/ (données locales)"""
    print("\n" + "="*50)
    print("TEST 4: Géocoder 'Riviera 2' (données locales)")
    print("="*50)
    
    response = requests.post(
        f"{BASE_URL}/geocode-quartier/",
        json={'quartier': 'Riviera 2', 'commune': 'Cocody'}
    )
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ Trouvé!")
        print(f"   Quartier: {data['quartier']}")
        print(f"   Commune: {data['commune']}")
        print(f"   GPS: ({data['latitude']}, {data['longitude']})")
        print(f"   Source: {data['source']}")
    else:
        print(f"❌ Erreur: {response.text}")


def test_geocode_quartier_nominatim():
    """Test POST /api/v1/locations/geocode-quartier/ (via Nominatim)"""
    print("\n" + "="*50)
    print("TEST 5: Géocoder 'Cité SIR' (via Nominatim)")
    print("="*50)
    
    response = requests.post(
        f"{BASE_URL}/geocode-quartier/",
        json={'quartier': 'Cité SIR', 'commune': 'Yopougon'}
    )
    print(f"Status: {response.status_code}")
    
    data = response.json()
    if data.get('success'):
        print(f"✅ Trouvé!")
        print(f"   GPS: ({data['latitude']}, {data['longitude']})")
        print(f"   Source: {data['source']}")
    else:
        print(f"⚠️ Non trouvé: {data.get('error')}")
        if data.get('suggestions'):
            print(f"   Suggestions: {data['suggestions']}")


def test_geocode_address():
    """Test POST /api/v1/locations/geocode-address/"""
    print("\n" + "="*50)
    print("TEST 6: Géocoder adresse libre")
    print("="*50)
    
    response = requests.post(
        f"{BASE_URL}/geocode-address/",
        json={'address': 'Aéroport Félix Houphouët-Boigny', 'city': 'Abidjan'}
    )
    print(f"Status: {response.status_code}")
    
    data = response.json()
    if data.get('success'):
        print(f"✅ Trouvé!")
        print(f"   GPS: ({data['latitude']}, {data['longitude']})")
    else:
        print(f"⚠️ Non trouvé: {data.get('error')}")


def test_reverse_geocode():
    """Test POST /api/v1/locations/reverse-geocode/"""
    print("\n" + "="*50)
    print("TEST 7: Reverse geocoding (GPS → Adresse)")
    print("="*50)
    
    response = requests.post(
        f"{BASE_URL}/reverse-geocode/",
        json={'latitude': 5.3679, 'longitude': -3.985}
    )
    print(f"Status: {response.status_code}")
    
    data = response.json()
    if data.get('success'):
        print(f"✅ Adresse trouvée!")
        print(f"   {data['address']}")
    else:
        print(f"⚠️ Non trouvé: {data.get('error')}")


def test_list_communes():
    """Test GET /api/v1/locations/communes/"""
    print("\n" + "="*50)
    print("TEST 8: Liste des communes")
    print("="*50)
    
    response = requests.get(f"{BASE_URL}/communes/")
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ {data['count']} communes disponibles")
        print(f"   {data['communes']}")
    else:
        print(f"❌ Erreur: {response.text}")


def test_search_suggestions():
    """Test GET /api/v1/locations/suggestions/?q=Riviera"""
    print("\n" + "="*50)
    print("TEST 9: Suggestions (autocomplete)")
    print("="*50)
    
    response = requests.get(f"{BASE_URL}/suggestions/", params={'q': 'Angré'})
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        print(f"✅ {data['count']} suggestions pour '{data['query']}'")
        for s in data['suggestions'][:5]:
            print(f"   - {s['display_name']} ({s['source']})")
    else:
        print(f"❌ Erreur: {response.text}")


def main():
    """Exécute tous les tests"""
    print("\n🚀 TESTS DU SERVICE DE LOCALISATION")
    print("="*50)
    print("Assurez-vous que le serveur Django est lancé sur localhost:8000")
    print("="*50)
    
    try:
        test_list_quartiers()
        test_list_quartiers_by_commune()
        test_search_quartiers()
        test_geocode_quartier_local()
        test_geocode_quartier_nominatim()
        test_geocode_address()
        test_reverse_geocode()
        test_list_communes()
        test_search_suggestions()
        
        print("\n" + "="*50)
        print("✅ TOUS LES TESTS TERMINÉS")
        print("="*50)
        
    except requests.ConnectionError:
        print("\n❌ Erreur: Impossible de se connecter au serveur")
        print("   Lancez: python manage.py runserver")
    except Exception as e:
        print(f"\n❌ Erreur inattendue: {e}")


if __name__ == "__main__":
    main()
