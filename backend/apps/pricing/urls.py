# pricing/urls.py

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    PricingZoneViewSet,
    ZonePricingMatrixViewSet,
)
from .geocoding_views import (
    get_commune_coordinates,
    list_communes_with_gps,
    geocode_address,
)

# Créer un router pour les ViewSets
router = DefaultRouter()
router.register(r'zones', PricingZoneViewSet, basename='pricingzone')
router.register(r'matrix', ZonePricingMatrixViewSet, basename='zonepricing')

urlpatterns = [
    path('', include(router.urls)),
    # Endpoints de géolocalisation
    path('communes/', list_communes_with_gps, name='list-communes'),
    path('communes/coordinates/', get_commune_coordinates, name='commune-coordinates'),
    path('geocode/', geocode_address, name='geocode-address'),
]
