#!/bin/bash
# Script de démarrage simple sans Celery (pour Render Free Tier)

echo "🚀 Démarrage de Django (sans Celery)"

# Démarrer Gunicorn avec configuration optimisée pour 512MB RAM
exec gunicorn config.wsgi:application \
    --bind 0.0.0.0:$PORT \
    --workers 1 \
    --threads 4 \
    --worker-class gthread \
    --max-requests 1000 \
    --max-requests-jitter 50 \
    --timeout 120 \
    --log-level info \
    --access-logfile - \
    --error-logfile -
