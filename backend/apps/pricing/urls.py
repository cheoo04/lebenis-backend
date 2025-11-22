# pricing/urls.py

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    PricingZoneViewSet,
    ZonePricingMatrixViewSet,
    CalculatePriceView,
    AssignZonesView,
)

# Créer un router pour les ViewSets
router = DefaultRouter()
router.register(r'zones', PricingZoneViewSet, basename='pricingzone')
router.register(r'matrix', ZonePricingMatrixViewSet, basename='zonepricing')

urlpatterns = [
    # Routes des ViewSets (CRUD complet)
    path('', include(router.urls)),

    # Endpoint spécial pour calculer le prix
    path('calculate/', CalculatePriceView.as_view(), name='calculate_price'),

    # Endpoint pour assigner les zones de travail du livreur
    path('zones/assign/', AssignZonesView.as_view(), name='assign_zones'),
]
