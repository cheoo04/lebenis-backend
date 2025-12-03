from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import NotificationViewSet, NotificationHistoryViewSet

router = DefaultRouter()
router.register(r'main', NotificationViewSet, basename='notification')
router.register(r'history', NotificationHistoryViewSet, basename='notification-history')

urlpatterns = [
    path('', include(router.urls)),
]

