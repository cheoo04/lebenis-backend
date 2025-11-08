# backend/config/settings/development.py
from .base import *

DEBUG = True

ALLOWED_HOSTS = ['*']

# ============= CORS =============
CORS_ALLOWED_ORIGINS = [
    'http://localhost:3000',
    'http://127.0.0.1:3000',
    'http://localhost:8000',
]

# ============= DATABASE =============
# Pas de SSL requis en dev
if 'OPTIONS' in DATABASES['default']:
    DATABASES['default']['OPTIONS'].pop('sslmode', None)


# Afficher les emails dans la console
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
