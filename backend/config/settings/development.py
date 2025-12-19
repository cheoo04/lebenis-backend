# backend/config/settings/development.py
from .base import *

DEBUG = True

ALLOWED_HOSTS = ['*']

# ============= CORS =============
# En développement, autoriser toutes les origines pour faciliter les tests
CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOW_CREDENTIALS = True

# ============= DATABASE =============
# Pas de SSL requis en dev
if 'OPTIONS' in DATABASES['default']:
    DATABASES['default']['OPTIONS'].pop('sslmode', None)


# Afficher les emails dans la console
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
