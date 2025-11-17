from django.apps import AppConfig


class DeliveriesConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.deliveries'
    
    def ready(self):
        """Import models and signals for Django to recognize them"""
        from . import models_rating  # noqa
        from . import signals  # noqa
