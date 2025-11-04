from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import DriverViewSet

# Solution: Ne pas utiliser le routeur avec prefix vide car ça casse les actions
# On va créer toutes les routes manuellement pour avoir un contrôle total

urlpatterns = [
    # Actions spécifiques au driver connecté (sans authentification dans as_view, elle est dans le ViewSet)
    path('my-deliveries/', DriverViewSet.as_view({'get': 'my_deliveries'}), name='driver-my-deliveries'),
    path('available-deliveries/', DriverViewSet.as_view({'get': 'available_deliveries'}), name='driver-available-deliveries'),
    path('me/', DriverViewSet.as_view({'get': 'me'}), name='driver-me'),
    path('my-stats/', DriverViewSet.as_view({'get': 'my_stats'}), name='driver-my-stats'),
    path('me/earnings/', DriverViewSet.as_view({'get': 'my_earnings'}), name='driver-my-earnings'),
    path('update-location/', DriverViewSet.as_view({'post': 'update_location'}), name='driver-update-location'),
    path('toggle-availability/', DriverViewSet.as_view({'post': 'toggle_availability'}), name='driver-toggle-availability'),
    path('available/', DriverViewSet.as_view({'get': 'available'}), name='driver-available'),
    
    # CRUD standard (pour l'admin)
    path('', DriverViewSet.as_view({'get': 'list', 'post': 'create'}), name='driver-list'),
    path('<uuid:pk>/', DriverViewSet.as_view({'get': 'retrieve', 'put': 'update', 'patch': 'partial_update', 'delete': 'destroy'}), name='driver-detail'),
    path('<uuid:pk>/stats/', DriverViewSet.as_view({'get': 'stats'}), name='driver-stats'),
]
