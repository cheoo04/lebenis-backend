from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import DriverViewSet

# Routeur avec prefix vide pour éviter /drivers/drivers/
router = DefaultRouter()
router.register(r'', DriverViewSet, basename='driver')

urlpatterns = [
    path('', include(router.urls)),
]
