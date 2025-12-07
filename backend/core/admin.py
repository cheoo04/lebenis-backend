from django.contrib import admin
from django.urls import path
from django.template.response import TemplateResponse
from django.utils.translation import gettext as _
from datetime import timedelta
from django.utils.timezone import now

class CustomAdminSite(admin.AdminSite):
    site_header = "LeBeni's Group Administration"
    site_title = "LeBeni Admin"
    index_title = "Tableau de Bord"

    def get_urls(self):
        urls = super().get_urls()
        custom_urls = [
            path('dashboard/', self.admin_view(self.dashboard_view), name="dashboard"),
        ]
        # Dashboard comme page d'accueil
        return custom_urls + urls

    def dashboard_view(self, request):
        # Exemple de KPI
        from apps.merchants.models import Merchant
        from apps.drivers.models import Driver
        from apps.deliveries.models import Delivery

        total_merchants = Merchant.objects.count()
        validated_merchants = Merchant.objects.filter(verification_status='verified').count()
        total_drivers = Driver.objects.count()
        validated_drivers = Driver.objects.filter(verification_status='verified').count()
        today = now()
        last_7_days = today - timedelta(days=7)
        deliveries_last_week = Delivery.objects.filter(created_at__gte=last_7_days).count()
        # Inclure les anciennes valeurs 'pending_assignment' pour compatibilité
        deliveries_pending = Delivery.objects.filter(status__in=['pending', 'pending_assignment']).count()

        context = dict(
            self.each_context(request),
            total_merchants=total_merchants,
            validated_merchants=validated_merchants,
            total_drivers=total_drivers,
            validated_drivers=validated_drivers,
            deliveries_last_week=deliveries_last_week,
            deliveries_pending=deliveries_pending,
        )

        return TemplateResponse(request, "admin/dashboard.html", context)

# Instancier et utiliser
custom_admin_site = CustomAdminSite(name='custom_admin')
