"""
URL configuration for config project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
# backend/config/urls.py
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework import permissions
from drf_yasg.views import get_schema_view
from drf_yasg import openapi
from rest_framework_simplejwt.views import (TokenObtainPairView,TokenRefreshView,)
from rest_framework_simplejwt.authentication import JWTAuthentication
from apps.core.views import health_check


schema_view = get_schema_view(
    openapi.Info(
        title="LeBeni's Group API",
        default_version='v1',
        description="API de gestion de livraisons",
        contact=openapi.Contact(email="yahmardocheek@gmail.com"),
        license=openapi.License(name="BSD License"),
    ),
    public=True,
    permission_classes=[permissions.AllowAny],
    authentication_classes=[],
)

urlpatterns = [
    # Healthcheck (monitoring)
    path('health/', health_check, name='health_check'),
    
    path('admin/', admin.site.urls),
    # Documentation Swagger avec sécurité JWT configurée
    path('swagger/', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
    path('redoc/', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),
    path('swagger.json', schema_view.without_ui(cache_timeout=0), name='schema-json'),

    # Auth JWT
    # path('api/v1/auth/login/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    # path('api/v1/auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # API endpoints
    path('api/v1/auth/', include('apps.authentication.urls')),
    path('api/v1/merchants/', include('apps.merchants.urls')),
    path('api/v1/drivers/', include('apps.drivers.urls')),
    path('api/v1/deliveries/', include('apps.deliveries.urls')),
    path('api/v1/pricing/', include('apps.pricing.urls')),
    path('api/v1/notifications/', include('apps.notifications.urls')),
    path('api/v1/payments/', include('apps.payments.urls')),
]

# Endpoints de test (uniquement en développement)
if settings.DEBUG:
    urlpatterns += [
        path('api/v1/test/', include('apps.core.test_urls')),
    ]
    
    # Sentry debug endpoint
    def trigger_error(request):
        division_by_zero = 1 / 0
    
    urlpatterns += [
        path('sentry-debug/', trigger_error),
    ]
    
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)