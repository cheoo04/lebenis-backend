#!/usr/bin/env bash
# Script de build et démarrage pour Render.com

set -o errexit   # Arrêter le script en cas d'erreur

# Installer les dépendances Python
pip install -r requirements.txt

# Collecter les fichiers statiques (CSS, JS, images)
python manage.py collectstatic --no-input

# Appliquer les migrations à la base de données
python manage.py migrate --no-input

# Démarrer Gunicorn (le serveur WSGI de production)
gunicorn config.wsgi:application \
    --bind 0.0.0.0:$PORT \
    --workers 2 \         # Nombre de workers (à ajuster selon RAM)
    --threads 2 \         # Nombre de threads par worker
    --timeout 120 \       # Timeout en secondes
    --access-logfile - \  # Logs d'accès sur la console
    --error-logfile - \   # Logs d'erreur sur la console
    --log-level info      # Niveau de log
