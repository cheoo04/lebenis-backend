# apps/payments/urls.py

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import InvoiceViewSet, DriverEarningViewSet, DriverPaymentViewSet, PaymentViewSet
from .webhooks import orange_money_webhook, mtn_momo_webhook
from .wave_views import (
    WaveCheckoutView, 
    WaveCheckoutStatusView, 
    WaveWebhookView, 
    WaveBalanceView
)

app_name = 'payments'

router = DefaultRouter()
router.register('invoices', InvoiceViewSet, basename='invoice')
router.register('earnings', DriverEarningViewSet, basename='earning')
router.register('driver-payments', DriverPaymentViewSet, basename='driver-payment')
router.register('', PaymentViewSet, basename='payment')

urlpatterns = [
    path('', include(router.urls)),
    
    # Wave Money
    path('wave/checkout/', WaveCheckoutView.as_view(), name='wave-checkout'),
    path('wave/checkout/<str:session_id>/', WaveCheckoutStatusView.as_view(), name='wave-checkout-status'),
    path('wave/webhook/', WaveWebhookView.as_view(), name='wave-webhook'),
    path('wave/balance/', WaveBalanceView.as_view(), name='wave-balance'),
    
    # Webhooks Mobile Money (legacy)
    path('webhooks/orange-money/', orange_money_webhook, name='orange-money-webhook'),
    path('webhooks/mtn-momo/', mtn_momo_webhook, name='mtn-momo-webhook'),
]
