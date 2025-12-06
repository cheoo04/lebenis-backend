"""
URLs pour le service de localisation des quartiers
Endpoints pour géocoder les adresses d'Abidjan
"""
from django.urls import path
from .location_views import (
    list_quartiers,
    search_quartiers_view,
    geocode_quartier,
    geocode_address_nominatim,
    reverse_geocode_nominatim,
    list_communes_available,
    search_suggestions,
    validate_quartier_exists,
    get_route,
    get_delivery_route,
)

app_name = 'locations'

urlpatterns = [
    # Liste des quartiers
    # GET /api/v1/locations/quartiers/
    # GET /api/v1/locations/quartiers/?commune=Cocody
    path('quartiers/', list_quartiers, name='list-quartiers'),
    
    # Recherche de quartiers (autocomplete)
    # GET /api/v1/locations/quartiers/search/?q=Riviera
    path('quartiers/search/', search_quartiers_view, name='search-quartiers'),
    
    # Géocoder un quartier (obtenir coordonnées GPS)
    # POST /api/v1/locations/geocode-quartier/
    # Body: {"quartier": "Riviera 2", "commune": "Cocody"}
    path('geocode-quartier/', geocode_quartier, name='geocode-quartier'),
    
    # Géocoder une adresse libre (avec Nominatim)
    # POST /api/v1/locations/geocode-address/
    # Body: {"address": "Rue des Jardins, Cocody"}
    path('geocode-address/', geocode_address_nominatim, name='geocode-address'),
    
    # Reverse geocoding (coordonnées → adresse)
    # POST /api/v1/locations/reverse-geocode/
    # Body: {"latitude": 5.36, "longitude": -3.98}
    path('reverse-geocode/', reverse_geocode_nominatim, name='reverse-geocode'),
    
    # Liste des communes disponibles
    # GET /api/v1/locations/communes/
    path('communes/', list_communes_available, name='list-communes'),
    
    # Recherche de suggestions (autocomplete avec Nominatim)
    # GET /api/v1/locations/suggestions/?q=Riviera
    path('suggestions/', search_suggestions, name='search-suggestions'),
    
    # Valider si un quartier existe (dans base locale OU OpenStreetMap)
    # POST /api/v1/locations/validate-quartier/
    # Body: {"quartier": "Riviera 2", "commune": "Cocody"}
    path('validate-quartier/', validate_quartier_exists, name='validate-quartier'),
    
    # ============= ROUTING (ITINÉRAIRES) =============
    
    # Calculer un itinéraire entre 2 points
    # POST /api/v1/locations/route/
    # Body: {"origin": {"lat": 5.36, "lng": -4.01}, "destination": {"lat": 5.29, "lng": -3.98}}
    path('route/', get_route, name='get-route'),
    
    # Calculer l'itinéraire complet d'une livraison
    # POST /api/v1/locations/delivery-route/
    # Body: {"pickup": {...}, "delivery": {...}, "driver": {...}}
    path('delivery-route/', get_delivery_route, name='get-delivery-route'),
]
