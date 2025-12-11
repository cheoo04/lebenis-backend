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
    default='https://lebenis.com',
    cast=lambda v: [s.strip() for s in v.split(',')] if v else []
)
CORS_ALLOW_CREDENTIALS = True
CORS_ALLOW_ALL_ORIGINS = False  # ✅ Forcer à False en production

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
try:
    from pythonjsonlogger.jsonlogger import JsonFormatter  # type: ignore
    _HAS_JSON_LOGGER = True
except Exception:
    _HAS_JSON_LOGGER = False

if _HAS_JSON_LOGGER:
    json_formatter = {'()': 'pythonjsonlogger.jsonlogger.JsonFormatter', 'fmt': '%(levelname)s %(asctime)s %(name)s %(message)s'}
else:
    json_formatter = {'format': '{levelname} {asctime} {module} {message}', 'style': '{'}

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
        'json': json_formatter,
        'detailed': {
            'format': '[{asctime}] {levelname} {name} {module}.{funcName}:{lineno} - {message}',
            'style': '{',
            'datefmt': '%Y-%m-%d %H:%M:%S',
        },
    },
    'filters': {
        'require_debug_false': {
            '()': 'django.utils.log.RequireDebugFalse',
        },
    },
    'handlers': {
        'console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
        'console_json': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'json',
        },
        # Fichier optionnel - décommenter si stockage persistant disponible
        # 'file': {
        #     'level': 'INFO',
        #     'class': 'logging.handlers.RotatingFileHandler',
        #     'filename': '/var/log/lebenis/app.log',
        #     'maxBytes': 10485760,  # 10MB
        #     'backupCount': 5,
        #     'formatter': 'json',
        #     'filters': ['require_debug_false'],
        # },
        # 'error_file': {
        #     'level': 'ERROR',
        #     'class': 'logging.handlers.RotatingFileHandler',
        #     'filename': '/var/log/lebenis/error.log',
        #     'maxBytes': 10485760,  # 10MB
        #     'backupCount': 10,
        #     'formatter': 'detailed',
        #     'filters': ['require_debug_false'],
        # },
    },
    'root': {
        # Prefer structured JSON output in production for ingestion by logging systems
        'handlers': ['console_json'],
        'level': 'INFO',
    },
    'loggers': {
        'django': {
            'handlers': ['console_json'],
            'level': 'INFO',
            'propagate': False,
        },
        'django.request': {
            'handlers': ['console_json'],
            'level': 'WARNING',
            'propagate': False,
        },
        'django.security': {
            'handlers': ['console_json'],
            'level': 'WARNING',
            'propagate': False,
        },
        # Loggers spécifiques par application
        'apps.deliveries': {
            'handlers': ['console_json'],
            'level': 'INFO',
            'propagate': False,
        },
        'apps.payments': {
            'handlers': ['console_json'],
            'level': 'INFO',
            'propagate': False,
        },
        'apps.drivers': {
            'handlers': ['console_json'],
            'level': 'INFO',
            'propagate': False,
        },
        'apps.notifications': {
            'handlers': ['console_json'],
            'level': 'INFO',
            'propagate': False,
        },
        'apps.chat': {
            'handlers': ['console_json'],
            'level': 'INFO',
            'propagate': False,
        },
    },
}

# Cache - Redis Cloud (activé)
def _clean_redis_url(url: str) -> str:
    """Remove whitespace/newlines from URL that may come from env vars."""
    if url:
        return url.strip().replace('\n', '').replace('\r', '').replace(' ', '')
    return url

REDIS_URL = _clean_redis_url(config('REDIS_URL', default=''))
if REDIS_URL:
    import ssl
    from urllib.parse import urlparse
    
    # Déterminer si SSL/TLS est nécessaire
    parsed_redis = urlparse(REDIS_URL)
    redis_ssl_options = {}
    
    if parsed_redis.scheme == 'rediss':
        # Redis Cloud nécessite SSL mais sans vérification stricte du certificat
        redis_ssl_options = {
            'ssl_cert_reqs': None,  # Accepter les certificats auto-signés
            'ssl_check_hostname': False,
        }
    
    CACHES = {
        'default': {
            'BACKEND': 'django_redis.cache.RedisCache',
            'LOCATION': REDIS_URL,
            'OPTIONS': {
                'CLIENT_CLASS': 'django_redis.client.DefaultClient',
                'CONNECTION_POOL_KWARGS': redis_ssl_options,
                'SOCKET_CONNECT_TIMEOUT': 5,
                'SOCKET_TIMEOUT': 5,
            }
        }
    }
else:
    # Fallback: utiliser le cache en mémoire si Redis n'est pas configuré
    CACHES = {
        'default': {
            'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
            'LOCATION': 'unique-snowflake',
        }
    }


# Rate limiting (protection DDoS)
REST_FRAMEWORK['DEFAULT_THROTTLE_CLASSES'] = [
    'rest_framework.throttling.AnonRateThrottle',
    'rest_framework.throttling.UserRateThrottle'
]
REST_FRAMEWORK['DEFAULT_THROTTLE_RATES'] = {
    'anon': '1000/hour',      # 1000 requêtes/heure pour anonymes (limite raisonnable)
    'user': '5000/hour',      # 5000 requêtes/heure pour authentifiés (limite généreuse)
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
