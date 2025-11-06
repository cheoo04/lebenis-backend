# apps/payments/urls.py

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import InvoiceViewSet, DriverEarningViewSet, DriverPaymentViewSet, PaymentViewSet
from .webhooks import orange_money_webhook, mtn_momo_webhook

app_name = 'payments'

router = DefaultRouter()
router.register('invoices', InvoiceViewSet, basename='invoice')
router.register('earnings', DriverEarningViewSet, basename='earning')
router.register('driver-payments', DriverPaymentViewSet, basename='driver-payment')
router.register('payments', PaymentViewSet, basename='payment')

urlpatterns = [
    path('', include(router.urls)),
    
    # Webhooks Mobile Money
    path('webhooks/orange-money/', orange_money_webhook, name='orange-money-webhook'),
    path('webhooks/mtn-momo/', mtn_momo_webhook, name='mtn-momo-webhook'),
]
