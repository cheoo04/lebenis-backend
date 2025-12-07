from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import DeliveryViewSet
from .analytics_views import AnalyticsViewSet
from .pdf_views import generate_analytics_pdf, test_pdf_generation, generate_delivery_pdf

router = DefaultRouter()
router.register(r'', DeliveryViewSet, basename='delivery')  # Pas de préfixe 'deliveries' ici car déjà dans config/urls.py
router.register(r'analytics', AnalyticsViewSet, basename='analytics')

urlpatterns = [
    path('', include(router.urls)),
    # Explicit actions for drivers: some routers with empty prefix don't
    # reliably expose viewset @action routes in all deployment settings,
    # so we add explicit paths for accept/reject here to avoid 404s.
    path('<uuid:pk>/accept/', DeliveryViewSet.as_view({'post': 'accept'}), name='delivery-accept'),
    path('<uuid:pk>/reject/', DeliveryViewSet.as_view({'post': 'reject'}), name='delivery-reject'),
    path('reports/analytics-pdf/', generate_analytics_pdf, name='analytics-pdf'),
    path('reports/test-pdf/', test_pdf_generation, name='test-pdf'),
    path('<uuid:delivery_id>/generate-pdf/', generate_delivery_pdf, name='delivery-pdf'),
]
