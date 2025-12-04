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
    path('reports/analytics-pdf/', generate_analytics_pdf, name='analytics-pdf'),
    path('reports/test-pdf/', test_pdf_generation, name='test-pdf'),
    path('<int:delivery_id>/generate-pdf/', generate_delivery_pdf, name='delivery-pdf'),
]
