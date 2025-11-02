"""
Service de géolocalisation et calcul de distances
Utilise OpenRouteService (gratuit, pas de carte bancaire)
Avec fallback sur formule haversine si l'API est indisponible
"""
import os
import logging
from math import radians, cos, sin, asin, sqrt
from typing import Tuple, Optional
import requests
from django.conf import settings

logger = logging.getLogger(__name__)


class LocationService:
    """
    Service pour géolocalisation et calcul de distances
    
    Fonctionnalités:
    - Calcul de distance entre 2 points GPS (OpenRouteService ou haversine)
    - Geocoding: convertir adresse -> coordonnées GPS
    - Cache des résultats pour économiser les appels API
    """
    
    ORS_API_KEY = os.getenv('OPENROUTESERVICE_API_KEY', '')
    ORS_BASE_URL = 'https://api.openrouteservice.org'
    
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
