# backend/config/settings/__init__.py
from decouple import config

environment = config('ENVIRONMENT', default='development')

if environment == 'production':
    from .production import *
else:
    from .development import *
