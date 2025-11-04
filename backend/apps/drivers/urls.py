from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import DriverViewSet

# Initialisation du routeur
router = DefaultRouter()
router.register(r'', DriverViewSet, basename='driver')

# ViewSet instance pour les actions
viewset = DriverViewSet.as_view({
    'get': 'list',
    'post': 'create',
})

# URLs explicites pour les actions du driver
urlpatterns = [
    # Actions spécifiques au driver connecté
    path('my-deliveries/', DriverViewSet.as_view({'get': 'my_deliveries'}), name='driver-my-deliveries'),
    path('available-deliveries/', DriverViewSet.as_view({'get': 'available_deliveries'}), name='driver-available-deliveries'),
    path('me/', DriverViewSet.as_view({'get': 'me'}), name='driver-me'),
    path('my-stats/', DriverViewSet.as_view({'get': 'my_stats'}), name='driver-my-stats'),
    path('me/earnings/', DriverViewSet.as_view({'get': 'my_earnings'}), name='driver-my-earnings'),
    path('update-location/', DriverViewSet.as_view({'post': 'update_location'}), name='driver-update-location'),
    path('toggle-availability/', DriverViewSet.as_view({'post': 'toggle_availability'}), name='driver-toggle-availability'),
    
    # Routes du routeur (CRUD standard + autres actions)
    path('', include(router.urls)),
]
