"""
Service de géolocalisation et calcul de distances
Utilise OpenRouteService (gratuit, pas de carte bancaire)
Avec fallback sur formule haversine si l'API est indisponible

Ce service unifié gère:
- Calcul de distance entre 2 points GPS
- Calcul d'itinéraires avec polylines (pour affichage sur carte)
- Geocoding: convertir adresse -> coordonnées GPS
"""
import os
import logging
from math import radians, cos, sin, asin, sqrt
from typing import Tuple, Optional, Dict, List
import requests
from django.conf import settings
from django.core.cache import cache

logger = logging.getLogger(__name__)


class LocationService:
    """
    Service unifié pour géolocalisation, distances et itinéraires
    
    Fonctionnalités:
    - Calcul de distance entre 2 points GPS (OpenRouteService ou haversine)
    - Calcul d'itinéraires avec polylines (OSRM gratuit ou OpenRouteService)
    - Geocoding: convertir adresse -> coordonnées GPS
    - Cache des résultats pour économiser les appels API
    """
    
    ORS_API_KEY = os.getenv('OPENROUTESERVICE_API_KEY', '')
    ORS_BASE_URL = 'https://api.openrouteservice.org'
    
    # OSRM Demo Server (gratuit, pas de clé API)
    OSRM_BASE_URL = 'https://router.project-osrm.org'
    
    ROUTE_CACHE_TIMEOUT = 3600  # 1 heure pour les routes
    
    @classmethod
    def haversine_distance(cls, lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """
        Calcule la distance à vol d'oiseau entre 2 points GPS (formule haversine)
        
        Args:
            lat1, lon1: Coordonnées du point 1
            lat2, lon2: Coordonnées du point 2
        
        Returns:
            Distance en kilomètres
        """
        # Convertir en radians
        lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
        
        # Formule haversine
        dlon = lon2 - lon1
        dlat = lat2 - lat1
        a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
        c = 2 * asin(sqrt(a))
        
        # Rayon de la Terre en km
        r = 6371
        
        return round(c * r, 2)
    
    @classmethod
    def get_distance(
        cls, 
        pickup_lat: float, 
        pickup_lon: float, 
        delivery_lat: float, 
        delivery_lon: float,
        use_api: bool = True
    ) -> float:
        """
        Calcule la distance réelle entre 2 points
        
        Args:
            pickup_lat, pickup_lon: Coordonnées du point de départ
            delivery_lat, delivery_lon: Coordonnées de la destination
            use_api: Si True, utilise OpenRouteService, sinon haversine
        
        Returns:
            Distance en kilomètres (par route si API, à vol d'oiseau sinon)
        """
        # Si pas de clé API ou si use_api=False, utiliser haversine
        if not cls.ORS_API_KEY or not use_api:
            logger.info("Utilisation de la formule haversine (distance à vol d'oiseau)")
            distance = cls.haversine_distance(pickup_lat, pickup_lon, delivery_lat, delivery_lon)
            # Ajouter 20% pour approximer la distance réelle par route
            return round(distance * 1.2, 2)
        
        # Utiliser OpenRouteService pour distance réelle par route
        try:
            url = f"{cls.ORS_BASE_URL}/v2/directions/driving-car"
            headers = {
                'Authorization': cls.ORS_API_KEY,
                'Content-Type': 'application/json'
            }
            body = {
                'coordinates': [
                    [pickup_lon, pickup_lat],    # Point de départ [longitude, latitude]
                    [delivery_lon, delivery_lat]  # Destination [longitude, latitude]
                ],
                'radiuses': [1000, 1000]  # Augmenter le rayon de recherche à 1km
            }
            
            response = requests.post(url, json=body, headers=headers, timeout=5)
            
            if response.status_code == 200:
                data = response.json()
                # Distance en mètres, convertir en km
                distance_m = data['routes'][0]['summary']['distance']
                distance_km = round(distance_m / 1000, 2)
                logger.info(f"Distance calculée via OpenRouteService: {distance_km} km")
                return distance_km
            else:
                # Erreur API (404, 400, etc.) - utiliser haversine en silence
                # Pas besoin de logger l'erreur car c'est normal (coordonnées pas sur route)
                distance = cls.haversine_distance(pickup_lat, pickup_lon, delivery_lat, delivery_lon)
                return round(distance * 1.2, 2)
                
        except Exception as e:
            logger.error(f"Erreur OpenRouteService: {e}, fallback sur haversine")
            # Fallback sur haversine en cas d'erreur
            distance = cls.haversine_distance(pickup_lat, pickup_lon, delivery_lat, delivery_lon)
            return round(distance * 1.2, 2)
    
    @classmethod
    def geocode_address(cls, address: str, city: str = "Abidjan") -> Optional[Tuple[float, float]]:
        """
        Convertit une adresse en coordonnées GPS
        
        Args:
            address: Adresse à géocoder
            city: Ville (défaut: Abidjan)
        
        Returns:
            Tuple (latitude, longitude) ou None si échec
        """
        if not cls.ORS_API_KEY:
            logger.warning("Pas de clé OpenRouteService, geocoding impossible")
            return None
        
        try:
            url = f"{cls.ORS_BASE_URL}/geocode/search"
            params = {
                'api_key': cls.ORS_API_KEY,
                'text': f"{address}, {city}",
                'boundary.country': 'CI',  # Côte d'Ivoire
                'size': 1  # Seulement le meilleur résultat
            }
            
            response = requests.get(url, params=params, timeout=5)
            
            if response.status_code == 200:
                data = response.json()
                if data['features']:
                    coords = data['features'][0]['geometry']['coordinates']
                    # OpenRouteService retourne [longitude, latitude]
                    lon, lat = coords
                    logger.info(f"Adresse géocodée: {address} -> ({lat}, {lon})")
                    return (lat, lon)
                else:
                    logger.warning(f"Aucun résultat pour l'adresse: {address}")
                    return None
            else:
                logger.error(f"Geocoding erreur {response.status_code}")
                return None
                
        except Exception as e:
            logger.error(f"Erreur geocoding: {e}")
            return None
    
    @classmethod
    def reverse_geocode(cls, lat: float, lon: float) -> Optional[str]:
        """
        Convertit des coordonnées GPS en adresse
        
        Args:
            lat, lon: Coordonnées GPS
        
        Returns:
            Adresse formatée ou None si échec
        """
        if not cls.ORS_API_KEY:
            logger.warning("Pas de clé OpenRouteService, reverse geocoding impossible")
            return None
        
        try:
            url = f"{cls.ORS_BASE_URL}/geocode/reverse"
            params = {
                'api_key': cls.ORS_API_KEY,
                'point.lat': lat,
                'point.lon': lon,
                'size': 1
            }
            
            response = requests.get(url, params=params, timeout=5)
            
            if response.status_code == 200:
                data = response.json()
                if data['features']:
                    properties = data['features'][0]['properties']
                    # Construire l'adresse
                    parts = []
                    if properties.get('name'):
                        parts.append(properties['name'])
                    if properties.get('locality'):
                        parts.append(properties['locality'])
                    if properties.get('region'):
                        parts.append(properties['region'])
                    
                    address = ', '.join(parts)
                    logger.info(f"Coordonnées ({lat}, {lon}) -> {address}")
                    return address
                else:
                    return None
            else:
                logger.error(f"Reverse geocoding erreur {response.status_code}")
                return None
                
        except Exception as e:
            logger.error(f"Erreur reverse geocoding: {e}")
            return None


    # ==========================================
    # MÉTHODES DE ROUTING (itinéraires avec polylines)
    # ==========================================
    
    @classmethod
    def _decode_polyline(cls, polyline_str: str, precision: int = 5) -> List[Tuple[float, float]]:
        """
        Décode une polyline encodée (format Google) en liste de coordonnées
        
        Args:
            polyline_str: Chaîne polyline encodée
            precision: Précision (5 pour OSRM, 6 pour certains autres services)
            
        Returns:
            Liste de tuples (latitude, longitude)
        """
        try:
            # Import polyline uniquement si nécessaire
            import polyline as pl
            decoded = pl.decode(polyline_str, precision)
            return [(lat, lon) for lat, lon in decoded]
        except ImportError:
            logger.warning("Package 'polyline' non installé, décodage manuel")
            return cls._decode_polyline_manual(polyline_str, precision)
        except Exception as e:
            logger.error(f"Erreur décodage polyline: {e}")
            return []
    
    @classmethod
    def _decode_polyline_manual(cls, polyline_str: str, precision: int = 5) -> List[Tuple[float, float]]:
        """
        Décodage manuel de polyline sans dépendance externe
        """
        coordinates = []
        index = 0
        lat = 0
        lng = 0
        
        while index < len(polyline_str):
            # Latitude
            shift = 0
            result = 0
            while True:
                b = ord(polyline_str[index]) - 63
                index += 1
                result |= (b & 0x1f) << shift
                shift += 5
                if b < 0x20:
                    break
            lat += (~(result >> 1) if result & 1 else result >> 1)
            
            # Longitude
            shift = 0
            result = 0
            while True:
                b = ord(polyline_str[index]) - 63
                index += 1
                result |= (b & 0x1f) << shift
                shift += 5
                if b < 0x20:
                    break
            lng += (~(result >> 1) if result & 1 else result >> 1)
            
            factor = 10 ** precision
            coordinates.append((lat / factor, lng / factor))
        
        return coordinates
    
    @classmethod
    def get_route(
        cls,
        start_lat: float,
        start_lon: float,
        end_lat: float,
        end_lon: float,
        use_cache: bool = True
    ) -> Optional[Dict]:
        """
        Calcule un itinéraire entre 2 points avec polyline pour affichage carte
        
        Utilise OSRM (gratuit) en priorité, avec fallback sur OpenRouteService
        
        Args:
            start_lat, start_lon: Coordonnées du point de départ
            end_lat, end_lon: Coordonnées du point d'arrivée
            use_cache: Utiliser le cache (défaut: True)
        
        Returns:
            Dict avec:
            - distance_km: Distance en kilomètres
            - duration_min: Durée estimée en minutes
            - polyline_points: Liste de (lat, lon) pour tracer la route
            - geometry: Polyline encodée originale
            - steps: Étapes de navigation (si disponibles)
            
            ou None si erreur
        """
        # Vérifier le cache
        if use_cache:
            cache_key = f"route:{start_lat:.5f},{start_lon:.5f}:{end_lat:.5f},{end_lon:.5f}"
            cached = cache.get(cache_key)
            if cached:
                logger.info("Route trouvée en cache")
                return cached
        
        # Essayer OSRM d'abord (gratuit, pas de clé API)
        result = cls._get_route_osrm(start_lat, start_lon, end_lat, end_lon)
        
        # Fallback sur OpenRouteService si OSRM échoue
        if not result and cls.ORS_API_KEY:
            logger.info("OSRM indisponible, essai OpenRouteService...")
            result = cls._get_route_ors(start_lat, start_lon, end_lat, end_lon)
        
        # Fallback sur ligne droite si tout échoue
        if not result:
            logger.warning("Aucun service de routing disponible, calcul ligne droite")
            distance = cls.haversine_distance(start_lat, start_lon, end_lat, end_lon)
            result = {
                'distance_km': distance,
                'duration_min': int(distance * 3),  # Estimation ~20 km/h en ville
                'polyline_points': [(start_lat, start_lon), (end_lat, end_lon)],
                'geometry': None,
                'steps': [],
                'source': 'fallback_straight_line'
            }
        
        # Mettre en cache
        if use_cache and result:
            cache.set(cache_key, result, cls.ROUTE_CACHE_TIMEOUT)
        
        return result
    
    @classmethod
    def _get_route_osrm(
        cls,
        start_lat: float,
        start_lon: float,
        end_lat: float,
        end_lon: float
    ) -> Optional[Dict]:
        """
        Obtenir un itinéraire via OSRM (gratuit, Open Source)
        
        OSRM utilise le format: longitude,latitude (inverse de la convention habituelle)
        """
        try:
            # OSRM: coordinates format is lon,lat
            url = f"{cls.OSRM_BASE_URL}/route/v1/driving/{start_lon},{start_lat};{end_lon},{end_lat}"
            
            params = {
                'overview': 'full',
                'geometries': 'polyline',
                'steps': 'true',
                'annotations': 'true'
            }
            
            response = requests.get(url, params=params, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                
                if data.get('code') == 'Ok' and data.get('routes'):
                    route = data['routes'][0]
                    
                    # Décoder la polyline
                    geometry = route.get('geometry', '')
                    polyline_points = cls._decode_polyline(geometry, precision=5)
                    
                    # Extraire les étapes de navigation
                    steps = []
                    for leg in route.get('legs', []):
                        for step in leg.get('steps', []):
                            if step.get('maneuver'):
                                steps.append({
                                    'instruction': step.get('name', ''),
                                    'distance_m': step.get('distance', 0),
                                    'duration_s': step.get('duration', 0),
                                    'maneuver': step['maneuver'].get('type', ''),
                                    'modifier': step['maneuver'].get('modifier', ''),
                                })
                    
                    result = {
                        'distance_km': round(route['distance'] / 1000, 2),
                        'duration_min': round(route['duration'] / 60, 1),
                        'polyline_points': polyline_points,
                        'geometry': geometry,
                        'steps': steps,
                        'source': 'osrm'
                    }
                    
                    logger.info(f"Route OSRM: {result['distance_km']} km, {result['duration_min']} min, {len(polyline_points)} points")
                    return result
                else:
                    logger.warning(f"OSRM response invalide: {data.get('code')}")
                    return None
            else:
                logger.error(f"OSRM erreur HTTP {response.status_code}")
                return None
                
        except requests.exceptions.Timeout:
            logger.error("OSRM timeout")
            return None
        except Exception as e:
            logger.error(f"Erreur OSRM: {e}")
            return None
    
    @classmethod
    def _get_route_ors(
        cls,
        start_lat: float,
        start_lon: float,
        end_lat: float,
        end_lon: float
    ) -> Optional[Dict]:
        """
        Obtenir un itinéraire via OpenRouteService (nécessite clé API)
        """
        if not cls.ORS_API_KEY:
            return None
            
        try:
            url = f"{cls.ORS_BASE_URL}/v2/directions/driving-car"
            
            headers = {
                'Authorization': cls.ORS_API_KEY,
                'Content-Type': 'application/json'
            }
            
            # ORS utilise [lon, lat]
            body = {
                'coordinates': [
                    [start_lon, start_lat],
                    [end_lon, end_lat]
                ],
                'instructions': True,
                'geometry': True
            }
            
            response = requests.post(url, headers=headers, json=body, timeout=10)
            
            if response.status_code == 200:
                data = response.json()
                
                if data.get('routes'):
                    route = data['routes'][0]
                    summary = route.get('summary', {})
                    
                    # Décoder la géométrie (ORS utilise precision 5)
                    geometry = route.get('geometry', '')
                    polyline_points = cls._decode_polyline(geometry, precision=5)
                    
                    # Extraire les étapes
                    steps = []
                    for segment in route.get('segments', []):
                        for step in segment.get('steps', []):
                            steps.append({
                                'instruction': step.get('instruction', ''),
                                'distance_m': step.get('distance', 0),
                                'duration_s': step.get('duration', 0),
                                'maneuver': step.get('type', 0),
                            })
                    
                    result = {
                        'distance_km': round(summary.get('distance', 0) / 1000, 2),
                        'duration_min': round(summary.get('duration', 0) / 60, 1),
                        'polyline_points': polyline_points,
                        'geometry': geometry,
                        'steps': steps,
                        'source': 'openrouteservice'
                    }
                    
                    logger.info(f"Route ORS: {result['distance_km']} km, {result['duration_min']} min")
                    return result
                    
            logger.error(f"ORS erreur {response.status_code}: {response.text[:200]}")
            return None
            
        except Exception as e:
            logger.error(f"Erreur OpenRouteService: {e}")
            return None
    
    @classmethod
    def get_delivery_route(
        cls,
        merchant_lat: float,
        merchant_lon: float,
        pickup_lat: float,
        pickup_lon: float,
        delivery_lat: float,
        delivery_lon: float
    ) -> Dict:
        """
        Calcule l'itinéraire complet d'une livraison:
        Commerçant -> Point de collecte -> Point de livraison
        
        Args:
            merchant_lat, merchant_lon: Position du commerçant
            pickup_lat, pickup_lon: Point de collecte
            delivery_lat, delivery_lon: Destination finale
        
        Returns:
            Dict avec:
            - legs: Liste des segments de route
            - total_distance_km: Distance totale
            - total_duration_min: Durée totale estimée
            - all_points: Tous les points pour affichage carte
        """
        legs = []
        all_points = []
        total_distance = 0
        total_duration = 0
        
        # Segment 1: Commerçant -> Collecte
        route1 = cls.get_route(merchant_lat, merchant_lon, pickup_lat, pickup_lon)
        if route1:
            legs.append({
                'name': 'Vers point de collecte',
                'start': {'lat': merchant_lat, 'lon': merchant_lon},
                'end': {'lat': pickup_lat, 'lon': pickup_lon},
                **route1
            })
            all_points.extend(route1.get('polyline_points', []))
            total_distance += route1.get('distance_km', 0)
            total_duration += route1.get('duration_min', 0)
        
        # Segment 2: Collecte -> Livraison
        route2 = cls.get_route(pickup_lat, pickup_lon, delivery_lat, delivery_lon)
        if route2:
            legs.append({
                'name': 'Vers destination',
                'start': {'lat': pickup_lat, 'lon': pickup_lon},
                'end': {'lat': delivery_lat, 'lon': delivery_lon},
                **route2
            })
            # Éviter les doublons de points
            points2 = route2.get('polyline_points', [])
            if points2:
                all_points.extend(points2[1:])  # Skip first point (already in route1)
            total_distance += route2.get('distance_km', 0)
            total_duration += route2.get('duration_min', 0)
        
        return {
            'legs': legs,
            'total_distance_km': round(total_distance, 2),
            'total_duration_min': round(total_duration, 1),
            'all_points': all_points,
            'points_count': len(all_points)
        }


# Fonction helper pour faciliter l'utilisation
def calculate_delivery_distance(
    pickup_coords: Tuple[float, float],
    delivery_coords: Tuple[float, float]
) -> float:
    """
    Calcule la distance entre 2 points de livraison
    
    Args:
        pickup_coords: (latitude, longitude) du point de départ
        delivery_coords: (latitude, longitude) de la destination
    
    Returns:
        Distance en kilomètres
    
    Example:
        >>> distance = calculate_delivery_distance(
        ...     pickup_coords=(5.3600, -4.0083),  # Cocody
        ...     delivery_coords=(5.2893, -3.9828)  # Yopougon
        ... )
        >>> print(f"Distance: {distance} km")
    """
    pickup_lat, pickup_lon = pickup_coords
    delivery_lat, delivery_lon = delivery_coords
    
    return LocationService.get_distance(
        pickup_lat, pickup_lon,
        delivery_lat, delivery_lon
    )


def calculate_delivery_route(
    pickup_coords: Tuple[float, float],
    delivery_coords: Tuple[float, float]
) -> Optional[Dict]:
    """
    Calcule l'itinéraire complet avec polyline pour une livraison
    
    Args:
        pickup_coords: (latitude, longitude) du point de départ
        delivery_coords: (latitude, longitude) de la destination
    
    Returns:
        Dict avec distance_km, duration_min, polyline_points, etc.
    
    Example:
        >>> route = calculate_delivery_route(
        ...     pickup_coords=(5.3600, -4.0083),  # Cocody
        ...     delivery_coords=(5.2893, -3.9828)  # Yopougon
        ... )
        >>> print(f"Distance: {route['distance_km']} km")
        >>> print(f"Durée: {route['duration_min']} min")
        >>> print(f"Points: {len(route['polyline_points'])}")
    """
    pickup_lat, pickup_lon = pickup_coords
    delivery_lat, delivery_lon = delivery_coords
    
    return LocationService.get_route(
        pickup_lat, pickup_lon,
        delivery_lat, delivery_lon
    )
