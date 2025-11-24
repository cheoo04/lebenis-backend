"""
Production settings for LeBeni's Backend
"""
from .base import *

# SECURITY
DEBUG = False
SECRET_KEY = config('SECRET_KEY')  # Ne JAMAIS utiliser de valeur par défaut en production

ALLOWED_HOSTS = config(
    'ALLOWED_HOSTS',
    default='lebenis-backend.onrender.com, localhost',
    cast=lambda v: [s.strip() for s in v.split(',')]
)

# HTTPS/SSL
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = 'DENY'
SECURE_HSTS_SECONDS = 31536000  # 1 an
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True

# CORS - Limiter aux domaines autorisés
CORS_ALLOWED_ORIGINS = config(
    'CORS_ALLOWED_ORIGINS',
    default='https://lebenis.com, localhost',
    cast=lambda v: [s.strip() for s in v.split(',')] if v else []
)
CORS_ALLOW_CREDENTIALS = True

# Database - Pooling pour production
DATABASES['default']['CONN_MAX_AGE'] = 600  # 10 minutes
if 'OPTIONS' not in DATABASES['default']:
    DATABASES['default']['OPTIONS'] = {}
DATABASES['default']['OPTIONS'].update({
    'sslmode': 'require',
    'channel_binding': 'require'
})

# Static files
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# Media files - Utiliser AWS S3 en production (optionnel)
# AWS_ACCESS_KEY_ID = config('AWS_ACCESS_KEY_ID', default='')
# AWS_SECRET_ACCESS_KEY = config('AWS_SECRET_ACCESS_KEY', default='')
# AWS_STORAGE_BUCKET_NAME = config('AWS_STORAGE_BUCKET_NAME', default='')
# if AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY:
#     DEFAULT_FILE_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'

# Logging - Simplifié pour Render (logs dans la console uniquement)
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'DEBUG',
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'DEBUG',
            'propagate': False,
        },
    },
}

# Cache - Redis recommandé pour production (optionnel)
# REDIS_URL = config('REDIS_URL', default='')
# if REDIS_URL:
#     CACHES = {
#         'default': {
#             'BACKEND': 'django_redis.cache.RedisCache',
#             'LOCATION': REDIS_URL,
#             'OPTIONS': {
#                 'CLIENT_CLASS': 'django_redis.client.DefaultClient',
#             }
#         }
#     }


# Rate limiting (protection DDoS)
REST_FRAMEWORK['DEFAULT_THROTTLE_CLASSES'] = [
    'rest_framework.throttling.AnonRateThrottle',
    'rest_framework.throttling.UserRateThrottle'
]
REST_FRAMEWORK['DEFAULT_THROTTLE_RATES'] = {
    'anon': '100/hour',      # 100 requêtes/heure pour anonymes
    'user': '1000/hour',     # 1000 requêtes/heure pour authentifiés
}

# Sentry (monitoring erreurs - optionnel)
SENTRY_DSN = config('SENTRY_DSN', default='')
if SENTRY_DSN:
    import sentry_sdk
    from sentry_sdk.integrations.django import DjangoIntegration
    
    sentry_sdk.init(
        dsn=SENTRY_DSN,
        integrations=[DjangoIntegration()],
        traces_sample_rate=0.1,  # 10% des transactions trackées
        send_default_pii=False,  # Ne pas envoyer d'infos personnelles
        environment='production',
    )
