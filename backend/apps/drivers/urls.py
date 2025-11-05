from django.urls import path
from .views import DriverViewSet

# URLs manuelles car DefaultRouter avec prefix vide ne génère pas les actions
# Documentation: https://www.django-rest-framework.org/api-guide/routers/#usage

# Instance du ViewSet
driver_list = DriverViewSet.as_view({
    'get': 'list',
    'post': 'create'
})

driver_detail = DriverViewSet.as_view({
    'get': 'retrieve',
    'put': 'update',
    'patch': 'partial_update',
    'delete': 'destroy'
})

urlpatterns = [
    # Actions pour drivers (nécessitent IsDriver permission)
    path('my-deliveries/', DriverViewSet.as_view({'get': 'my_deliveries'}), name='driver-my-deliveries'),
    path('available-deliveries/', DriverViewSet.as_view({'get': 'available_deliveries'}), name='driver-available-deliveries'),
    path('me/', DriverViewSet.as_view({'get': 'me'}), name='driver-me'),
    path('my-stats/', DriverViewSet.as_view({'get': 'my_stats'}), name='driver-my-stats'),
    path('me/earnings/', DriverViewSet.as_view({'get': 'my_earnings'}), name='driver-my-earnings'),
    path('update-location/', DriverViewSet.as_view({'post': 'update_location'}), name='driver-update-location'),
    path('toggle-availability/', DriverViewSet.as_view({'post': 'toggle_availability'}), name='driver-toggle-availability'),
    
    # Actions pour admin
    path('available/', DriverViewSet.as_view({'get': 'available'}), name='driver-available'),
    path('<uuid:pk>/stats/', DriverViewSet.as_view({'get': 'stats'}), name='driver-detail-stats'),
    
    # CRUD standard
    path('', driver_list, name='driver-list'),
    path('<uuid:pk>/', driver_detail, name='driver-detail'),
]
