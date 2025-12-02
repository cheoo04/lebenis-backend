#!/bin/bash
# Script pour démarrer Django + Celery sur Render Free Tier (optimisé mémoire)

echo "🚀 Démarrage de Django + Celery (mode économie mémoire)"

# Démarrer Celery Worker en arrière-plan (1 seul worker pour économiser la RAM)
celery -A config worker --loglevel=warning --concurrency=1 --max-memory-per-child=100000 --detach

# Attendre que Celery démarre
sleep 3

echo "✅ Celery démarré en arrière-plan"

# Démarrer Gunicorn avec 1 worker seulement pour économiser la RAM
exec gunicorn config.wsgi:application --bind 0.0.0.0:$PORT --workers 1 --threads 2 --worker-class gthread --max-requests 1000 --max-requests-jitter 50 --timeout 120 --log-level warning
