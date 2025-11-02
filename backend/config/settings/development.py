# backend/config/settings/development.py
from .base import *

DEBUG = True

ALLOWED_HOSTS = ['*']

# Pour le développement, utiliser SQLite si PostgreSQL pas dispo
# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.sqlite3',
#         'NAME': BASE_DIR / 'db.sqlite3',
#     }
# }

# Afficher les emails dans la console
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
