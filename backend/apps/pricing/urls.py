# pricing/urls.py

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    PricingZoneViewSet,
    ZonePricingMatrixViewSet,
    CalculatePriceView  # AJOUTÉ
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
]
