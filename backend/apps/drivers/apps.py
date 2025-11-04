from django.apps import AppConfig


class DriversConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.drivers'
    
    def ready(self):
        """Import signals when Django starts"""
        import apps.drivers.signals  # noqa
