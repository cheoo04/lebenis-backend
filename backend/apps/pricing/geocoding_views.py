# backend/apps/pricing/views.py - Ajouter cet endpoint
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status
from .models import PricingZone
from apps.core.location_service import LocationService


@api_view(['GET'])
@permission_classes([AllowAny])
def get_commune_coordinates(request):
    """
    GET /api/v1/pricing/communes/coordinates/?commune=Cocody
    
    Retourne les coordonnées GPS d'une commune.
    Utile pour l'app Flutter lors de la sélection d'une commune.
    """
    commune = request.query_params.get('commune')
    
    if not commune:
        return Response(
            {'error': 'Paramètre "commune" requis'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    # Chercher la zone avec coordonnées
    zone = PricingZone.objects.filter(
        commune__iexact=commune,
        default_latitude__isnull=False,
        default_longitude__isnull=False
    ).first()
    
    if zone:
        return Response({
            'commune': zone.commune,
            'latitude': float(zone.default_latitude),
            'longitude': float(zone.default_longitude),
            'zone_name': zone.zone_name
        })
    else:
        return Response(
            {'error': f'Commune "{commune}" introuvable ou sans coordonnées'},
            status=status.HTTP_404_NOT_FOUND
        )


@api_view(['GET'])
@permission_classes([AllowAny])
def list_communes_with_gps(request):
    """
    GET /api/v1/pricing/communes/
    
    Liste toutes les communes disponibles avec leurs coordonnées GPS.
    """
    zones = PricingZone.objects.filter(
        is_active=True,
        default_latitude__isnull=False,
        default_longitude__isnull=False
    ).values(
        'commune', 'default_latitude', 'default_longitude', 'zone_name'
    ).distinct()
    
    communes = []
    seen_communes = set()
    
    for zone in zones:
        commune_name = zone['commune']
        if commune_name not in seen_communes:
            communes.append({
                'commune': commune_name,
                'latitude': float(zone['default_latitude']),
                'longitude': float(zone['default_longitude']),
                'zone_name': zone['zone_name']
            })
            seen_communes.add(commune_name)
    
    return Response({
        'count': len(communes),
        'communes': communes
    })


@api_view(['POST'])
@permission_classes([AllowAny])
def geocode_address(request):
    """
    POST /api/v1/pricing/geocode/
    
    Body:
    {
        "address": "Rue des Jardins, Cocody",
        "city": "Abidjan"  # optionnel
    }
    
    Retourne les coordonnées GPS d'une adresse.
    """
    address = request.data.get('address')
    city = request.data.get('city', 'Abidjan')
    
    if not address:
        return Response(
            {'error': 'Champ "address" requis'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    location_service = LocationService()
    coords = location_service.geocode_address(address, city)
    
    if coords:
        lat, lon = coords
        return Response({
            'address': address,
            'latitude': lat,
            'longitude': lon
        })
    else:
        return Response(
            {'error': 'Impossible de géocoder cette adresse'},
            status=status.HTTP_404_NOT_FOUND
        )
