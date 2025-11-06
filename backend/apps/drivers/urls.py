from django.urls import path
from .views import DriverViewSet
from .gps_views import GPSTrackingViewSet

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

# GPS Tracking ViewSet
gps_update_location = GPSTrackingViewSet.as_view({'post': 'update_location'})
gps_get_interval = GPSTrackingViewSet.as_view({'get': 'get_interval'})
gps_history = GPSTrackingViewSet.as_view({'get': 'history'})
gps_sessions = GPSTrackingViewSet.as_view({'get': 'sessions'})
gps_statistics = GPSTrackingViewSet.as_view({'get': 'statistics'})
gps_end_session = GPSTrackingViewSet.as_view({'post': 'end_session'})

urlpatterns = [
    # GPS Tracking endpoints
    path('gps/update-location/', gps_update_location, name='gps-update-location'),
    path('gps/interval/', gps_get_interval, name='gps-get-interval'),
    path('gps/history/', gps_history, name='gps-history'),
    path('gps/sessions/', gps_sessions, name='gps-sessions'),
    path('gps/statistics/', gps_statistics, name='gps-statistics'),
    path('gps/end-session/', gps_end_session, name='gps-end-session'),
    
    # Actions pour drivers (nécessitent IsDriver permission)
    path('my-deliveries/', DriverViewSet.as_view({'get': 'my_deliveries'}), name='driver-my-deliveries'),
    path('available-deliveries/', DriverViewSet.as_view({'get': 'available_deliveries'}), name='driver-available-deliveries'),
    path('me/', DriverViewSet.as_view({'get': 'me', 'patch': 'me'}), name='driver-me'),
    path('me/mobile-money/', DriverViewSet.as_view({'get': 'mobile_money', 'patch': 'mobile_money'}), name='driver-mobile-money'),
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
