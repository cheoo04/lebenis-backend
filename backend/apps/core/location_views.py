"""
API Views pour le service de localisation des quartiers
Endpoints pour géocoder les quartiers d'Abidjan

Ces endpoints sont utilisés par les apps Flutter (merchant_app, driver_app)
pour obtenir les coordonnées GPS des adresses de livraison.
"""
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status
from .nominatim_service import NominatimService
from .quartiers_data import (
    get_all_quartiers,
    get_quartiers_by_commune,
    get_quartier_coordinates,
    search_quartiers,
    get_communes_list,
)
import logging
import sentry_sdk

logger = logging.getLogger(__name__)


@api_view(['GET'])
@permission_classes([AllowAny])
def list_quartiers(request):
    """
    GET /api/v1/locations/quartiers/
    GET /api/v1/locations/quartiers/?commune=Cocody
    
    Liste tous les quartiers ou filtre par commune.
    Données locales (rapide, pas d'appel externe).
    
    Query params:
        commune: Filtrer par commune (optionnel)
    
    Response:
    {
        "count": 45,
        "quartiers": [
            {
                "nom": "Riviera 2",
                "commune": "COCODY",
                "latitude": 5.3679,
                "longitude": -3.985
            },
            ...
        ]
    }
    """
    commune = request.query_params.get('commune')
    
    if commune:
        quartiers = get_quartiers_by_commune(commune)
    else:
        quartiers = get_all_quartiers()
    
    return Response({
        'count': len(quartiers),
        'quartiers': quartiers
    })


@api_view(['GET'])
@permission_classes([AllowAny])
def search_quartiers_view(request):
    """
    GET /api/v1/locations/quartiers/search/?q=Riviera
    
    Recherche des quartiers par nom (pour autocomplete).
    Utilise les données locales (instantané).
    
    Query params:
        q: Texte de recherche (min 2 caractères)
        limit: Nombre max de résultats (défaut: 10)
    
    Response:
    {
        "query": "Riviera",
        "count": 5,
        "results": [
            {
                "nom": "Riviera 1",
                "commune": "COCODY",
                "latitude": 5.3651,
                "longitude": -3.9917
            },
            ...
        ]
    }
    """
    query = request.query_params.get('q', '').strip()
    limit = int(request.query_params.get('limit', 10))
    
    if len(query) < 2:
        return Response(
            {'error': 'Le paramètre "q" doit contenir au moins 2 caractères'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    results = search_quartiers(query, limit)
    
    return Response({
        'query': query,
        'count': len(results),
        'results': results
    })


@api_view(['POST'])
@permission_classes([AllowAny])
def geocode_quartier(request):
    """
    POST /api/v1/locations/geocode-quartier/
    
    Géocode un quartier pour obtenir ses coordonnées GPS.
    
    1. Cherche d'abord dans la base locale (instantané)
    2. Si non trouvé, utilise Nominatim (gratuit)
    
    Body:
    {
        "quartier": "Riviera 2",
        "commune": "Cocody"
    }
    
    Response (succès):
    {
        "success": true,
        "quartier": "Riviera 2",
        "commune": "COCODY",
        "latitude": 5.3679,
        "longitude": -3.985,
        "source": "local"  // ou "nominatim"
    }
    
    Response (échec):
    {
        "success": false,
        "error": "Quartier non trouvé"
    }
    """
    quartier = request.data.get('quartier', '').strip()
    commune = request.data.get('commune', '').strip()
    
    if not quartier:
        return Response(
            {'success': False, 'error': 'Le champ "quartier" est requis'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    if not commune:
        return Response(
            {'success': False, 'error': 'Le champ "commune" est requis'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Étape 1: Chercher dans la base locale (instantané)
    local_result = get_quartier_coordinates(quartier, commune)
    
    if local_result:
        return Response({
            'success': True,
            'quartier': local_result['nom'],
            'commune': local_result['commune'],
            'latitude': local_result['latitude'],
            'longitude': local_result['longitude'],
            'source': 'local'
        })
    
    # Étape 2: Utiliser Nominatim si non trouvé localement
    nominatim_result = NominatimService.geocode_quartier(quartier, commune)
    
    if nominatim_result:
        return Response({
            'success': True,
            'quartier': quartier,
            'commune': commune.upper(),
            'latitude': nominatim_result['latitude'],
            'longitude': nominatim_result['longitude'],
            'display_name': nominatim_result.get('display_name', ''),
            'source': 'nominatim'
        })
    
    # Échec : quartier non trouvé
    return Response({
        'success': False,
        'error': f'Impossible de trouver "{quartier}" à {commune}. Vérifiez l\'orthographe.',
        'suggestions': search_quartiers(quartier[:3], 5) if len(quartier) >= 3 else []
    }, status=status.HTTP_404_NOT_FOUND)


@api_view(['POST'])
@permission_classes([AllowAny])
def geocode_address_nominatim(request):
    """
    POST /api/v1/locations/geocode-address/
    
    Géocode une adresse libre avec Nominatim.
    Alternative gratuite à OpenRouteService.
    
    Body:
    {
        "address": "Rue des Jardins, Cocody",
        "city": "Abidjan"  // optionnel
    }
    
    Response:
    {
        "success": true,
        "address": "Rue des Jardins, Cocody",
        "latitude": 5.3679,
        "longitude": -3.985
    }
    """
    address = request.data.get('address', '').strip()
    city = request.data.get('city', 'Abidjan').strip()
    
    if not address:
        return Response(
            {'success': False, 'error': 'Le champ "address" est requis'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    result = NominatimService.geocode_address(address, city)
    
    if result:
        lat, lon = result
        return Response({
            'success': True,
            'address': address,
            'city': city,
            'latitude': lat,
            'longitude': lon
        })
    else:
        return Response({
            'success': False,
            'error': 'Impossible de géocoder cette adresse'
        }, status=status.HTTP_404_NOT_FOUND)


@api_view(['POST'])
@permission_classes([AllowAny])
def reverse_geocode_nominatim(request):
    """
    POST /api/v1/locations/reverse-geocode/
    
    Convertit des coordonnées GPS en adresse.
    Utile pour afficher l'adresse après sélection sur carte.
    
    Body:
    {
        "latitude": 5.3679,
        "longitude": -3.985
    }
    
    Response:
    {
        "success": true,
        "latitude": 5.3679,
        "longitude": -3.985,
        "address": "Riviera 2, Cocody, Abidjan, Côte d'Ivoire"
    }
    """
    latitude = request.data.get('latitude')
    longitude = request.data.get('longitude')
    
    if latitude is None or longitude is None:
        return Response(
            {'success': False, 'error': 'Les champs "latitude" et "longitude" sont requis'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        lat = float(latitude)
        lon = float(longitude)
    except (TypeError, ValueError):
        return Response(
            {'success': False, 'error': 'Coordonnées invalides'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    address = NominatimService.reverse_geocode(lat, lon)
    
    if address:
        return Response({
            'success': True,
            'latitude': lat,
            'longitude': lon,
            'address': address
        })
    else:
        return Response({
            'success': False,
            'error': 'Impossible de trouver une adresse pour ces coordonnées'
        }, status=status.HTTP_404_NOT_FOUND)


@api_view(['GET'])
@permission_classes([AllowAny])
def list_communes_available(request):
    """
    GET /api/v1/locations/communes/
    
    Liste toutes les communes disponibles avec leurs quartiers.
    
    Response:
    {
        "count": 13,
        "communes": ["COCODY", "PLATEAU", "YOPOUGON", ...]
    }
    """
    communes = get_communes_list()
    
    return Response({
        'count': len(communes),
        'communes': communes
    })


@api_view(['GET'])
@permission_classes([AllowAny])
def search_suggestions(request):
    """
    GET /api/v1/locations/suggestions/?q=Riviera
    
    Recherche des suggestions d'adresses avec Nominatim.
    Pour l'autocomplete dans les apps Flutter.
    
    Query params:
        q: Texte de recherche
        limit: Nombre max de résultats (défaut: 5)
    
    Response:
    {
        "query": "Riviera",
        "count": 3,
        "suggestions": [
            {
                "display_name": "Riviera 2, Cocody, Abidjan",
                "latitude": 5.3679,
                "longitude": -3.985
            },
            ...
        ]
    }
    """
    query = request.query_params.get('q', '').strip()
    limit = int(request.query_params.get('limit', 5))
    
    if len(query) < 3:
        return Response(
            {'error': 'Le paramètre "q" doit contenir au moins 3 caractères'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # D'abord chercher dans les données locales (plus rapide)
    local_results = search_quartiers(query, limit)
    
    # Formater comme suggestions
    suggestions = []
    for q in local_results:
        suggestions.append({
            'display_name': f"{q['nom']}, {q['commune']}, Abidjan",
            'latitude': q['latitude'],
            'longitude': q['longitude'],
            'source': 'local'
        })
    
    # Si pas assez de résultats locaux, compléter avec Nominatim
    if len(suggestions) < limit:
        nominatim_results = NominatimService.search_suggestions(query, limit - len(suggestions))
        for r in nominatim_results:
            suggestions.append({
                'display_name': r['display_name'],
                'latitude': r['latitude'],
                'longitude': r['longitude'],
                'source': 'nominatim'
            })
    
    return Response({
        'query': query,
        'count': len(suggestions),
        'suggestions': suggestions
    })


@api_view(['POST'])
@permission_classes([AllowAny])
def validate_quartier_exists(request):
    """
    POST /api/v1/locations/validate-quartier/
    
    Valide si un quartier existe dans notre base OU sur OpenStreetMap.
    L'utilisateur peut taper n'importe quel nom de quartier.
    
    Body:
    {
        "quartier": "Riviera 2",
        "commune": "Cocody"  // optionnel
    }
    
    Response (trouvé dans base locale):
    {
        "success": true,
        "found": true,
        "source": "local",
        "message": "✅ Quartier trouvé dans notre base",
        "quartier": {
            "nom": "Riviera 2",
            "commune": "COCODY",
            "latitude": 5.3679,
            "longitude": -3.985,
            "has_gps": true
        }
    }
    
    Response (trouvé sur OpenStreetMap):
    {
        "success": true,
        "found": true,
        "source": "nominatim",
        "message": "✅ Quartier trouvé sur OpenStreetMap",
        "quartier": {
            "nom": "Riviera 2",
            "commune": "Cocody",
            "latitude": 5.3679,
            "longitude": -3.985,
            "display_name": "Riviera 2, Cocody, Abidjan, Côte d'Ivoire"
        }
    }
    
    Response (non trouvé):
    {
        "success": false,
        "found": false,
        "message": "❌ Quartier non trouvé",
        "suggestions": [
            {"nom": "Riviera 1", "commune": "COCODY"},
            {"nom": "Riviera 3", "commune": "COCODY"}
        ]
    }
    """
    quartier = request.data.get('quartier', '').strip()
    commune = request.data.get('commune', '').strip()
    
    if not quartier:
        return Response(
            {'success': False, 'error': 'Le champ "quartier" est requis'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # ÉTAPE 1: Chercher dans la base locale
    local_result = get_quartier_coordinates(quartier, commune if commune else None)
    
    if local_result and local_result.get('has_gps'):
        # Trouvé avec GPS
        return Response({
            'success': True,
            'found': True,
            'source': 'local',
            'message': '✅ Quartier trouvé dans notre base (avec GPS)',
            'quartier': {
                'nom': local_result['nom'],
                'commune': local_result['commune'],
                'latitude': local_result['latitude'],
                'longitude': local_result['longitude'],
                'has_gps': True
            }
        })
    
    if local_result and not local_result.get('has_gps'):
        # Trouvé mais sans GPS → vérifier sur Nominatim
        nominatim_result = NominatimService.geocode_quartier(
            local_result['nom'], 
            local_result['commune']
        )
        
        if nominatim_result:
            return Response({
                'success': True,
                'found': True,
                'source': 'local+nominatim',
                'message': '✅ Quartier trouvé (coordonnées via OpenStreetMap)',
                'quartier': {
                    'nom': local_result['nom'],
                    'commune': local_result['commune'],
                    'latitude': nominatim_result['latitude'],
                    'longitude': nominatim_result['longitude'],
                    'display_name': nominatim_result.get('display_name', ''),
                    'has_gps': True
                }
            })
    
    # ÉTAPE 2: Recherche directe sur Nominatim
    address_to_search = f"{quartier}, {commune}, Abidjan" if commune else f"{quartier}, Abidjan"
    nominatim_result = NominatimService.geocode_address(address_to_search)
    
    if nominatim_result:
        return Response({
            'success': True,
            'found': True,
            'source': 'nominatim',
            'message': '✅ Quartier trouvé sur OpenStreetMap',
            'quartier': {
                'nom': quartier,
                'commune': commune.upper() if commune else 'ABIDJAN',
                'latitude': nominatim_result['latitude'],
                'longitude': nominatim_result['longitude'],
                'display_name': nominatim_result.get('display_name', ''),
                'has_gps': True
            }
        })
    
    # ÉTAPE 3: Non trouvé → suggestions
    suggestions = search_quartiers(quartier, limit=5)
    
    return Response({
        'success': False,
        'found': False,
        'message': f'❌ "{quartier}" non trouvé. Vérifiez l\'orthographe.',
        'suggestions': [
            {
                'nom': s['nom'], 
                'commune': s['commune'],
                'has_gps': s.get('has_gps', False)
            } 
            for s in suggestions
        ]
    }, status=status.HTTP_404_NOT_FOUND)


# ============= ROUTING API =============

@api_view(['POST'])
@permission_classes([AllowAny])
def get_route(request):
    """
    POST /api/v1/locations/route/
    
    Calcule l'itinéraire réel entre 2 points.
    Utilise OSRM (gratuit) ou OpenRouteService.
    
    Body:
    {
        "origin": {"lat": 5.36, "lng": -4.01},
        "destination": {"lat": 5.29, "lng": -3.98},
        "waypoints": [{"lat": 5.32, "lng": -4.00}]  // optionnel
    }
    
    Response:
    {
        "success": true,
        "source": "osrm",
        "distance_km": 15.3,
        "duration_min": 28.5,
        "polyline_points": [
            {"lat": 5.36, "lng": -4.01},
            {"lat": 5.358, "lng": -4.008},
            ...
        ],
        "encoded_polyline": "_~r~Fvnp`N..."
    }
    """
    from .location_service import LocationService
    
    origin = request.data.get('origin')
    destination = request.data.get('destination')
    
    if not origin or not destination:
        return Response({
            'success': False,
            'error': 'Les champs "origin" et "destination" sont requis'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        origin_lat = float(origin.get('lat') or origin.get('latitude'))
        origin_lon = float(origin.get('lng') or origin.get('longitude'))
        dest_lat = float(destination.get('lat') or destination.get('latitude'))
        dest_lon = float(destination.get('lng') or destination.get('longitude'))
    except (TypeError, ValueError, AttributeError):
        return Response({
            'success': False,
            'error': 'Coordonnées invalides'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    result = LocationService.get_route(
        start_lat=origin_lat,
        start_lon=origin_lon,
        end_lat=dest_lat,
        end_lon=dest_lon
    )
    
    if result:
        return Response({
            'success': True,
            'distance_km': result.get('distance_km'),
            'duration_min': result.get('duration_min'),
            'polyline_points': result.get('polyline_points', []),
            'geometry': result.get('geometry'),
            'steps': result.get('steps', []),
            'source': result.get('source', 'unknown')
        })
    else:
        return Response({
            'success': False,
            'error': 'Impossible de calculer l\'itinéraire'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@api_view(['POST'])
@permission_classes([AllowAny])
def get_delivery_route(request):
    """
    POST /api/v1/locations/delivery-route/
    
    Calcule l'itinéraire complet pour une livraison.
    Inclut optionnellement la position du livreur.
    
    Body:
    {
        "pickup": {"lat": 5.36, "lng": -4.01},
        "delivery": {"lat": 5.29, "lng": -3.98},
        "driver": {"lat": 5.35, "lng": -4.00}  // optionnel
    }
    
    Response:
    {
        "success": true,
        "total_distance_km": 18.5,
        "total_duration_min": 35.2,
        "legs": [
            {
                "name": "driver_to_pickup",
                "label": "Vers point de récupération",
                "distance_km": 3.2,
                ...
            },
            {
                "name": "pickup_to_delivery",
                "label": "Vers destination",
                "distance_km": 15.3,
                ...
            }
        ],
        "all_polyline_points": [...]
    }
    """
    from .location_service import LocationService
    
    pickup = request.data.get('pickup')
    delivery = request.data.get('delivery')
    driver = request.data.get('driver')
    
    if not pickup or not delivery:
        # Log minimal context for debugging (avoid PII in logs)
        logger.debug('get_delivery_route: missing pickup or delivery', extra={'pickup_present': bool(pickup), 'delivery_present': bool(delivery)})
        try:
            sentry_sdk.capture_event({
                'message': 'get_delivery_route: missing pickup or delivery',
                'level': 'warning',
                'tags': {'endpoint': 'delivery-route', 'error': 'missing_fields'},
                'extra': {'pickup_present': bool(pickup), 'delivery_present': bool(delivery)}
            })
        except Exception:
            logger.debug('sentry capture failed in get_delivery_route')

        return Response({
            'success': False,
            'error': 'Les champs "pickup" et "delivery" sont requis'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    # Safe float parsing helper to avoid TypeError when values are None
    def _to_float_from(obj, *keys):
        if not isinstance(obj, dict):
            return None
        for k in keys:
            v = obj.get(k)
            if v is None:
                continue
            try:
                return float(v)
            except (TypeError, ValueError):
                return None
        return None

    pickup_lat = _to_float_from(pickup, 'lat', 'latitude')
    pickup_lon = _to_float_from(pickup, 'lng', 'longitude')
    delivery_lat = _to_float_from(delivery, 'lat', 'latitude')
    delivery_lon = _to_float_from(delivery, 'lng', 'longitude')

    if pickup_lat is None or pickup_lon is None or delivery_lat is None or delivery_lon is None:
        # Detailed invalid coords handling
        logger.debug('get_delivery_route: invalid coordinates', extra={'payload_keys': list(request.data.keys())})
        try:
            sentry_sdk.capture_event({
                'message': 'get_delivery_route: invalid coordinates',
                'level': 'warning',
                'tags': {'endpoint': 'delivery-route', 'error': 'invalid_coords'},
                'extra': {'payload_keys': list(request.data.keys())}
            })
        except Exception:
            logger.debug('sentry capture failed in get_delivery_route invalid coords')

        return Response({
            'success': False,
            'error': 'Coordonnées invalides: vérifiez que les champs lat/lng sont fournis et numériques'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    driver_lat = driver_lon = None
    if driver:
        try:
            driver_lat = float(driver.get('lat') or driver.get('latitude'))
            driver_lon = float(driver.get('lng') or driver.get('longitude'))
        except (TypeError, ValueError, AttributeError):
            pass  # Ignorer la position du driver si invalide
    
    # Calculer la route
    legs = []
    all_points = []
    total_distance = 0
    total_duration = 0
    
    # Segment 1: Driver -> Pickup (si driver fourni)
    if driver_lat is not None and driver_lon is not None:
        route1 = LocationService.get_route(driver_lat, driver_lon, pickup_lat, pickup_lon)
        if route1:
            legs.append({
                'name': 'driver_to_pickup',
                'label': 'Vers point de récupération',
                'distance_km': route1.get('distance_km', 0),
                'duration_min': route1.get('duration_min', 0),
                'polyline_points': route1.get('polyline_points', []),
            })
            all_points.extend(route1.get('polyline_points', []))
            total_distance += route1.get('distance_km', 0)
            total_duration += route1.get('duration_min', 0)
    
    # Segment 2: Pickup -> Delivery
    route2 = LocationService.get_route(pickup_lat, pickup_lon, delivery_lat, delivery_lon)
    if route2:
        legs.append({
            'name': 'pickup_to_delivery',
            'label': 'Vers destination',
            'distance_km': route2.get('distance_km', 0),
            'duration_min': route2.get('duration_min', 0),
            'polyline_points': route2.get('polyline_points', []),
        })
        points2 = route2.get('polyline_points', [])
        if points2:
            # Éviter les doublons
            all_points.extend(points2[1:] if all_points else points2)
        total_distance += route2.get('distance_km', 0)
        total_duration += route2.get('duration_min', 0)
    
    if legs:
        return Response({
            'success': True,
            'total_distance_km': round(total_distance, 2),
            'total_duration_min': round(total_duration, 1),
            'legs': legs,
            'all_polyline_points': all_points,
            'points_count': len(all_points)
        })
    else:
        return Response({
            'success': False,
            'error': 'Impossible de calculer l\'itinéraire'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)