#!/usr/bin/env bash
# Script de build et démarrage pour Render.com

set -o errexit   # Arrêter le script en cas d'erreur

# Installer les dépendances Python
pip install -r requirements.txt

# Collecter les fichiers statiques (CSS, JS, images)
python manage.py collectstatic --no-input

# Créer les migrations de la base de données (si nécessaire)
python manage.py makemigrations --no-input

# Appliquer les migrations à la base de données
python manage.py migrate --no-input

