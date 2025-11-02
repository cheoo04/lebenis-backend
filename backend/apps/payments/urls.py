# apps/payments/urls.py

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import InvoiceViewSet, DriverEarningViewSet, DriverPaymentViewSet

app_name = 'payments'

router = DefaultRouter()
router.register('invoices', InvoiceViewSet, basename='invoice')
router.register('earnings', DriverEarningViewSet, basename='earning')
router.register('driver-payments', DriverPaymentViewSet, basename='driver-payment')

urlpatterns = [
    path('', include(router.urls)),
]
