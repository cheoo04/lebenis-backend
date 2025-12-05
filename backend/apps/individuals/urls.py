from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import IndividualViewSet

router = DefaultRouter()
router.register(r'', IndividualViewSet, basename='individual')

urlpatterns = [
    path('', include(router.urls)),
]
