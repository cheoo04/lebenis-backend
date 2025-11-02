"""
URLs de test pour le système de géolocalisation
"""
from django.urls import path
from apps.core import test_views

urlpatterns = [
    # Test de calcul de distance
    path('calculate-distance/', test_views.test_calculate_distance, name='test_calculate_distance'),
    
    # Test de geocoding (adresse → GPS)
    path('geocode/', test_views.test_geocode_address, name='test_geocode'),
    
    # Test d'estimation de prix
    path('estimate-price/', test_views.test_estimate_price, name='test_estimate_price'),
    
    # Configuration du système
    path('location-config/', test_views.test_location_config, name='test_location_config'),
]
