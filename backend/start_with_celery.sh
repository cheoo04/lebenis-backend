#!/bin/bash
# Script pour démarrer Django + Celery sur Render Free Tier

echo "🚀 Démarrage de Django + Celery"

# Démarrer Celery Beat en arrière-plan (tâches planifiées)
celery -A config beat --loglevel=info --detach

# Démarrer Celery Worker en arrière-plan (exécution des tâches)
celery -A config worker --loglevel=info --concurrency=2 --detach

# Attendre que Celery démarre
sleep 5

echo "✅ Celery démarré en arrière-plan"

# Démarrer Gunicorn (serveur web Django)
exec gunicorn config.wsgi:application --bind 0.0.0.0:$PORT --workers 2 --timeout 120
