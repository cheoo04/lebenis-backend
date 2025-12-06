"""
Service de géocodage avec Nominatim (OpenStreetMap)
GRATUIT et ILLIMITÉ (max 1 requête/seconde)

Ce service permet de :
- Géocoder une adresse (adresse -> coordonnées GPS)
- Faire du reverse geocoding (coordonnées GPS -> adresse)
- Rechercher des quartiers d'Abidjan avec leurs coordonnées

Aucune clé API requise !
"""
import logging
import requests
import time
from typing import Optional, Tuple, List, Dict
from django.core.cache import cache

logger = logging.getLogger(__name__)


class NominatimService:
    """
    Service de géocodage gratuit utilisant Nominatim (OpenStreetMap)
    
    Avantages:
    - 100% gratuit
    - Pas de limite mensuelle
    - Bonne couverture d'Abidjan
    
    Règles d'utilisation:
    - Max 1 requête par seconde (géré automatiquement)
    - User-Agent standard (navigateur)
    """
    
    BASE_URL = 'https://nominatim.openstreetmap.org'
    # User-Agent navigateur standard (évite les blocages 503)
    USER_AGENT = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    CACHE_TIMEOUT = 86400  # 24 heures
    
    # Dernière requête (pour respecter la limite 1/sec)
    _last_request_time = 0
    
    @classmethod
    def _wait_for_rate_limit(cls):
        """
        Attend le temps nécessaire pour respecter la limite de 1 req/sec
        Évite de se faire bloquer par Nominatim
        """
        current_time = time.time()
        time_since_last = current_time - cls._last_request_time
        
        if time_since_last < 1:
            time.sleep(1 - time_since_last)
        
        cls._last_request_time = time.time()
    
    @classmethod
    def geocode_quartier(
        cls, 
        quartier: str, 
        commune: str, 
        city: str = "Abidjan"
    ) -> Optional[Dict]:
        """
        Géocode un quartier pour obtenir ses coordonnées GPS
        
        Args:
            quartier: Nom du quartier (ex: "Riviera 2")
            commune: Nom de la commune (ex: "Cocody")
            city: Ville (défaut: Abidjan)
        
        Returns:
            Dict avec {latitude, longitude, display_name} ou None si échec
        
        Example:
            >>> result = NominatimService.geocode_quartier("Riviera 2", "Cocody")
            >>> print(result)  # {'latitude': 5.365, 'longitude': -4.008, ...}
        """
        # Clé de cache pour éviter les requêtes répétées
        cache_key = f"nominatim_geo_{quartier}_{commune}_{city}".lower().replace(' ', '_')
        cached_result = cache.get(cache_key)
        
        if cached_result:
            logger.info(f"✅ Cache hit pour {quartier}, {commune}")
            return cached_result
        
        try:
            cls._wait_for_rate_limit()
            
            # Construire la requête
            # Format simplifié pour meilleure compatibilité
            # Essayer plusieurs variantes
            queries_to_try = [
                f"{quartier}, {commune}, {city}",  # Simple
                f"{quartier} {commune} {city}",    # Sans virgules
                f"{quartier}, {city}",              # Sans commune
            ]
            
            headers = {
                'User-Agent': cls.USER_AGENT,
                'Accept': 'application/json',
                'Accept-Language': 'fr-FR,fr;q=0.9,en;q=0.8'
            }
            
            result = None
            
            # Essayer les différentes variantes
            for query in queries_to_try:
                params = {
                    'q': query,
                    'format': 'json',
                    'limit': 1,
                    'countrycodes': 'ci',  # Restreindre à la Côte d'Ivoire
                }
                
                try:
                    response = requests.get(
                        f'{cls.BASE_URL}/search',
                        params=params,
                        headers=headers,
                        timeout=15
                    )
                    
                    if response.status_code == 200:
                        data = response.json()
                        if data:
                            result = data[0]
                            break
                    elif response.status_code == 503:
                        logger.warning(f"⚠️ Nominatim surchargé (503), attente 2 secondes...")
                        time.sleep(2)
                        continue
                    elif response.status_code == 429:
                        logger.warning(f"⚠️ Trop de requêtes (429), attente 3 secondes...")
                        time.sleep(3)
                        continue
                        
                except requests.RequestException:
                    continue
            
            # Traiter le résultat si trouvé
            if result:
                location_data = {
                    'latitude': float(result['lat']),
                    'longitude': float(result['lon']),
                    'display_name': result.get('display_name', ''),
                    'quartier': quartier,
                    'commune': commune,
                    'city': city,
                    'success': True
                }
                
                # Mettre en cache
                cache.set(cache_key, location_data, cls.CACHE_TIMEOUT)
                
                logger.info(f"✅ Géocodé: {quartier}, {commune} -> ({location_data['latitude']}, {location_data['longitude']})")
                return location_data
            else:
                logger.warning(f"⚠️ Aucun résultat pour: {quartier}, {commune}")
                return None
                
        except requests.RequestException as e:
            logger.error(f"❌ Erreur réseau Nominatim: {e}")
            return None
        except Exception as e:
            logger.error(f"❌ Erreur inattendue: {e}")
            return None
    
    @classmethod
    def geocode_address(
        cls, 
        address: str, 
        city: str = "Abidjan"
    ) -> Optional[Tuple[float, float]]:
        """
        Géocode une adresse libre (alternative à OpenRouteService)
        
        Args:
            address: Adresse complète
            city: Ville (défaut: Abidjan)
        
        Returns:
            Tuple (latitude, longitude) ou None si échec
        """
        cache_key = f"nominatim_addr_{address}_{city}".lower().replace(' ', '_')
        cached_result = cache.get(cache_key)
        
        if cached_result:
            return cached_result
        
        try:
            cls._wait_for_rate_limit()
            
            # Essayer plusieurs formats
            queries = [
                f"{address}, {city}",
                f"{address} {city}",
            ]
            
            headers = {
                'User-Agent': cls.USER_AGENT,
                'Accept': 'application/json',
                'Accept-Language': 'fr-FR,fr;q=0.9,en;q=0.8'
            }
            
            result = None
            
            for query in queries:
                params = {
                    'q': query,
                    'format': 'json',
                    'limit': 1,
                    'countrycodes': 'ci',
                }
                
                try:
                    response = requests.get(
                        f'{cls.BASE_URL}/search',
                        params=params,
                        headers=headers,
                        timeout=15
                    )
                    
                    if response.status_code == 200:
                        data = response.json()
                        if data:
                            result = data[0]
                            break
                    elif response.status_code in [503, 429]:
                        time.sleep(2)
                        continue
                        
                except requests.RequestException:
                    continue
            
            if result:
                lat = float(result['lat'])
                lon = float(result['lon'])
                
                # Mettre en cache
                cache.set(cache_key, (lat, lon), cls.CACHE_TIMEOUT)
                
                logger.info(f"✅ Adresse géocodée: {address} -> ({lat}, {lon})")
                return (lat, lon)
            else:
                logger.warning(f"⚠️ Aucun résultat pour: {address}")
                return None
                
        except Exception as e:
            logger.error(f"❌ Erreur geocoding: {e}")
            return None
    
    @classmethod
    def reverse_geocode(
        cls, 
        latitude: float, 
        longitude: float
    ) -> Optional[str]:
        """
        Convertit des coordonnées GPS en adresse lisible
        
        Args:
            latitude: Latitude
            longitude: Longitude
        
        Returns:
            Adresse formatée ou None si échec
        """
        cache_key = f"nominatim_rev_{latitude:.6f}_{longitude:.6f}"
        cached_result = cache.get(cache_key)
        
        if cached_result:
            return cached_result
        
        try:
            cls._wait_for_rate_limit()
            
            params = {
                'lat': latitude,
                'lon': longitude,
                'format': 'json',
                'zoom': 18,  # Niveau de détail
            }
            
            headers = {
                'User-Agent': cls.USER_AGENT,
                'Accept': 'application/json',
                'Accept-Language': 'fr-FR,fr;q=0.9,en;q=0.8'
            }
            
            response = requests.get(
                f'{cls.BASE_URL}/reverse',
                params=params,
                headers=headers,
                timeout=15
            )
            
            if response.status_code == 200:
                data = response.json()
                
                if 'display_name' in data:
                    address = data['display_name']
                    
                    # Mettre en cache
                    cache.set(cache_key, address, cls.CACHE_TIMEOUT)
                    
                    logger.info(f"✅ Reverse geocode: ({latitude}, {longitude}) -> {address}")
                    return address
                else:
                    return None
            elif response.status_code in [503, 429]:
                logger.warning(f"⚠️ Nominatim temporairement indisponible ({response.status_code})")
                return None
            else:
                logger.warning(f"⚠️ Erreur HTTP {response.status_code}")
                return None
                
        except Exception as e:
            logger.error(f"❌ Erreur reverse geocoding: {e}")
            return None
    
    @classmethod
    def search_suggestions(
        cls, 
        query: str, 
        limit: int = 5
    ) -> List[Dict]:
        """
        Recherche des suggestions d'adresses (pour autocomplete)
        
        Args:
            query: Texte de recherche (ex: "Riviera")
            limit: Nombre max de résultats
        
        Returns:
            Liste de suggestions [{display_name, lat, lon}, ...]
        """
        if len(query) < 3:
            return []
        
        cache_key = f"nominatim_search_{query}_{limit}".lower().replace(' ', '_')
        cached_result = cache.get(cache_key)
        
        if cached_result:
            return cached_result
        
        try:
            cls._wait_for_rate_limit()
            
            # Ajouter Abidjan pour restreindre la recherche
            full_query = f"{query}, Abidjan, Côte d'Ivoire"
            
            params = {
                'q': full_query,
                'format': 'json',
                'limit': limit,
                'countrycodes': 'ci',
            }
            
            headers = {
                'User-Agent': cls.USER_AGENT,
                'Accept': 'application/json'
            }
            
            response = requests.get(
                f'{cls.BASE_URL}/search',
                params=params,
                headers=headers,
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                
                suggestions = []
                for item in data:
                    suggestions.append({
                        'display_name': item.get('display_name', ''),
                        'latitude': float(item['lat']),
                        'longitude': float(item['lon']),
                        'type': item.get('type', ''),
                    })
                
                # Mettre en cache (5 minutes pour les suggestions)
                cache.set(cache_key, suggestions, 300)
                
                return suggestions
            else:
                return []
                
        except Exception as e:
            logger.error(f"❌ Erreur recherche: {e}")
            return []
