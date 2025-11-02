"""
Endpoints de test pour le système de géolocalisation
À utiliser via Swagger ou Postman
"""
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from decimal import Decimal
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

from apps.core.location_service import LocationService, calculate_delivery_distance
from apps.pricing.calculator import PricingCalculator


@swagger_auto_schema(
    method='post',
    operation_description="Test du calcul de distance entre 2 points GPS",
    request_body=openapi.Schema(
        type=openapi.TYPE_OBJECT,
        required=['pickup_latitude', 'pickup_longitude', 'delivery_latitude', 'delivery_longitude'],
        properties={
            'pickup_latitude': openapi.Schema(type=openapi.TYPE_NUMBER, description='Latitude du point de départ', example=5.3600),
            'pickup_longitude': openapi.Schema(type=openapi.TYPE_NUMBER, description='Longitude du point de départ', example=-4.0083),
            'delivery_latitude': openapi.Schema(type=openapi.TYPE_NUMBER, description='Latitude de la destination', example=5.2893),
            'delivery_longitude': openapi.Schema(type=openapi.TYPE_NUMBER, description='Longitude de la destination', example=-3.9828),
        },
    ),
    responses={
        200: openapi.Response(
            description="Distance calculée avec succès",
            examples={
                "application/json": {
                    "success": True,
                    "distance_km": 10.02,
                    "method": "openrouteservice",
                    "api_key_configured": True,
                    "pickup": {"latitude": 5.36, "longitude": -4.0083},
                    "delivery": {"latitude": 5.2893, "longitude": -3.9828}
                }
            }
        ),
        400: "Paramètres manquants"
    }
)
@api_view(['POST'])
@permission_classes([AllowAny])
def test_calculate_distance(request):
    """
    Test du calcul de distance entre 2 points GPS
    
    POST /api/v1/test/calculate-distance/
    
    Body:
    {
        "pickup_latitude": 5.3600,
        "pickup_longitude": -4.0083,
        "delivery_latitude": 5.2893,
        "delivery_longitude": -3.9828
    }
    """
    
    pickup_lat = request.data.get('pickup_latitude')
    pickup_lon = request.data.get('pickup_longitude')
    delivery_lat = request.data.get('delivery_latitude')
    delivery_lon = request.data.get('delivery_longitude')
    
    if not all([pickup_lat, pickup_lon, delivery_lat, delivery_lon]):
        return Response({
            'success': False,
            'error': 'Tous les champs sont requis: pickup_latitude, pickup_longitude, delivery_latitude, delivery_longitude'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        distance = calculate_delivery_distance(
            pickup_coords=(float(pickup_lat), float(pickup_lon)),
            delivery_coords=(float(delivery_lat), float(delivery_lon))
        )
        
        has_api_key = bool(LocationService.ORS_API_KEY)
        
        return Response({
            'success': True,
            'distance_km': distance,
            'method': 'openrouteservice' if has_api_key else 'haversine',
            'api_key_configured': has_api_key,
            'pickup': {
                'latitude': float(pickup_lat),
                'longitude': float(pickup_lon)
            },
            'delivery': {
                'latitude': float(delivery_lat),
                'longitude': float(delivery_lon)
            }
        }, status=status.HTTP_200_OK)
    
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@swagger_auto_schema(
    method='post',
    operation_description="Test du geocoding (convertir une adresse en coordonnées GPS)",
    request_body=openapi.Schema(
        type=openapi.TYPE_OBJECT,
        required=['address'],
        properties={
            'address': openapi.Schema(type=openapi.TYPE_STRING, description='Adresse à géocoder', example='Cocody'),
            'city': openapi.Schema(type=openapi.TYPE_STRING, description='Ville', example='Abidjan', default='Abidjan'),
        },
    ),
    responses={
        200: openapi.Response(
            description="Adresse géocodée avec succès",
            examples={
                "application/json": {
                    "success": True,
                    "address": "Cocody, Abidjan",
                    "coordinates": {
                        "latitude": 5.30966,
                        "longitude": -4.01266
                    }
                }
            }
        ),
        404: "Adresse introuvable"
    }
)
@api_view(['POST'])
@permission_classes([AllowAny])
def test_geocode_address(request):
    """
    Test du geocoding (adresse → GPS)
    
    POST /api/v1/test/geocode/
    
    Body:
    {
        "address": "Cocody",
        "city": "Abidjan"
    }
    """
    
    address = request.data.get('address')
    city = request.data.get('city', 'Abidjan')
    
    if not address:
        return Response({
            'success': False,
            'error': 'Le champ "address" est requis'
        }, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        coords = LocationService.geocode_address(address, city)
        
        if coords:
            lat, lon = coords
            return Response({
                'success': True,
                'address': f"{address}, {city}",
                'coordinates': {
                    'latitude': lat,
                    'longitude': lon
                }
            }, status=status.HTTP_200_OK)
        else:
            return Response({
                'success': False,
                'error': 'Impossible de géocoder cette adresse'
            }, status=status.HTTP_404_NOT_FOUND)
    
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@swagger_auto_schema(
    method='post',
    operation_description="Test du calcul de prix avec distance GPS calculée automatiquement",
    request_body=openapi.Schema(
        type=openapi.TYPE_OBJECT,
        required=['delivery_commune', 'package_weight_kg'],
        properties={
            'pickup_commune': openapi.Schema(type=openapi.TYPE_STRING, description='Commune de départ', example='Cocody'),
            'pickup_latitude': openapi.Schema(type=openapi.TYPE_NUMBER, description='Latitude du point de départ', example=5.3600),
            'pickup_longitude': openapi.Schema(type=openapi.TYPE_NUMBER, description='Longitude du point de départ', example=-4.0083),
            'delivery_commune': openapi.Schema(type=openapi.TYPE_STRING, description='Commune de livraison', example='Yopougon'),
            'delivery_latitude': openapi.Schema(type=openapi.TYPE_NUMBER, description='Latitude de la destination', example=5.2893),
            'delivery_longitude': openapi.Schema(type=openapi.TYPE_NUMBER, description='Longitude de la destination', example=-3.9828),
            'package_weight_kg': openapi.Schema(type=openapi.TYPE_NUMBER, description='Poids du colis en kg', example=3.5),
            'package_length_cm': openapi.Schema(type=openapi.TYPE_NUMBER, description='Longueur en cm (optionnel)', example=None),
            'package_width_cm': openapi.Schema(type=openapi.TYPE_NUMBER, description='Largeur en cm (optionnel)', example=None),
            'package_height_cm': openapi.Schema(type=openapi.TYPE_NUMBER, description='Hauteur en cm (optionnel)', example=None),
            'is_fragile': openapi.Schema(type=openapi.TYPE_BOOLEAN, description='Colis fragile ?', example=False),
            'scheduling_type': openapi.Schema(type=openapi.TYPE_STRING, description='Type de livraison', example='immediate', enum=['immediate', 'scheduled']),
        },
    ),
    responses={
        200: openapi.Response(
            description="Prix calculé avec succès",
            examples={
                "application/json": {
                    "success": True,
                    "total_price": 7000.0,
                    "breakdown": {
                        "base_rate": 2500.0,
                        "weight_surcharge": 150.0,
                        "volume_surcharge": 0.0,
                        "distance_surcharge": 2004.0,
                        "subtotal": 4654.0,
                        "multiplier": 1.5,
                        "fragile_charge": 0.0,
                        "surcharge_details": ["Livraison immédiate +50%"]
                    },
                    "details": {
                        "origin_zone": "Cocody",
                        "destination_zone": "Yopougon",
                        "distance_km": 10.02,
                        "billable_weight_kg": 3.5
                    }
                }
            }
        ),
        400: "Paramètres invalides"
    }
)
@api_view(['POST'])
@permission_classes([AllowAny])
def test_estimate_price(request):
    """
    Test du calcul de prix avec distance GPS
    
    POST /api/v1/test/estimate-price/
    
    Body:
    {
        "pickup_commune": "Cocody",
        "pickup_latitude": 5.3600,
        "pickup_longitude": -4.0083,
        "delivery_commune": "Yopougon",
        "delivery_latitude": 5.2893,
        "delivery_longitude": -3.9828,
        "package_weight_kg": 3.5,
        "is_fragile": false,
        "scheduling_type": "immediate"
    }
    """
    
    data = request.data
    
    delivery_data = {
        'pickup_commune': data.get('pickup_commune', 'Cocody'),
        'delivery_commune': data.get('delivery_commune'),
        'package_weight_kg': Decimal(str(data.get('package_weight_kg', 1))),
        'package_length_cm': data.get('package_length_cm'),
        'package_width_cm': data.get('package_width_cm'),
        'package_height_cm': data.get('package_height_cm'),
        'is_fragile': data.get('is_fragile', False),
        'scheduling_type': data.get('scheduling_type', 'immediate'),
        'scheduled_pickup_time': data.get('scheduled_pickup_time'),
    }
    
    pickup_lat = data.get('pickup_latitude')
    pickup_lon = data.get('pickup_longitude')
    delivery_lat = data.get('delivery_latitude')
    delivery_lon = data.get('delivery_longitude')
    
    if all([pickup_lat, pickup_lon, delivery_lat, delivery_lon]):
        delivery_data['pickup_coords'] = (float(pickup_lat), float(pickup_lon))
        delivery_data['delivery_coords'] = (float(delivery_lat), float(delivery_lon))
    
    try:
        calculator = PricingCalculator()
        result = calculator.calculate_price(delivery_data)
        
        return Response({
            'success': True,
            **result
        }, status=status.HTTP_200_OK)
    
    except Exception as e:
        return Response({
            'success': False,
            'error': str(e)
        }, status=status.HTTP_400_BAD_REQUEST)


@swagger_auto_schema(
    method='get',
    operation_description="Vérifie la configuration du système de géolocalisation et retourne des coordonnées de test",
    responses={
        200: openapi.Response(
            description="Configuration du système",
            examples={
                "application/json": {
                    "openrouteservice_configured": True,
                    "api_key_preview": "eyJvcmci...",
                    "base_url": "https://api.openrouteservice.org",
                    "test_coordinates": {
                        "cocody": {"lat": 5.36, "lon": -4.0083},
                        "yopougon": {"lat": 5.2893, "lon": -3.9828}
                    },
                    "example_test": {
                        "description": "Utilise ces coordonnées pour tester",
                        "pickup": {"lat": 5.36, "lon": -4.0083},
                        "delivery": {"lat": 5.2893, "lon": -3.9828},
                        "expected_distance": "~10 km"
                    }
                }
            }
        )
    }
)
@api_view(['GET'])
@permission_classes([AllowAny])
def test_location_config(request):
    """
    Vérifie la configuration du système de géolocalisation
    
    GET /api/v1/test/location-config/
    """
    
    has_key = bool(LocationService.ORS_API_KEY)
    
    test_coords = {
        'cocody': {'lat': 5.3600, 'lon': -4.0083},
        'yopougon': {'lat': 5.2893, 'lon': -3.9828},
        'plateau': {'lat': 5.3167, 'lon': -4.0167},
        'marcory': {'lat': 5.2847, 'lon': -4.0064},
        'abobo': {'lat': 5.4333, 'lon': -4.0167},
        'adjame': {'lat': 5.3667, 'lon': -4.0333},
    }
    
    return Response({
        'openrouteservice_configured': has_key,
        'api_key_preview': LocationService.ORS_API_KEY[:20] + '...' if has_key else None,
        'base_url': LocationService.ORS_BASE_URL,
        'test_coordinates': test_coords,
        'example_test': {
            'description': 'Utilise ces coordonnées pour tester',
            'pickup': test_coords['cocody'],
            'delivery': test_coords['yopougon'],
            'expected_distance': '~10 km'
        }
    }, status=status.HTTP_200_OK)
