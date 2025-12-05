from django.apps import AppConfig


class IndividualsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.individuals'
    verbose_name = 'Particuliers'
    
    def ready(self):
        import apps.individuals.signals
