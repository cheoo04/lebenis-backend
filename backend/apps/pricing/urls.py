# pricing/urls.py

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    PricingZoneViewSet,
    ZonePricingMatrixViewSet,
)

# Créer un router pour les ViewSets
router = DefaultRouter()
router.register(r'zones', PricingZoneViewSet, basename='pricingzone')
router.register(r'matrix', ZonePricingMatrixViewSet, basename='zonepricing')

urlpatterns = [
    path('', include(router.urls)),
]
