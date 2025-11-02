# 🚀 Guide de Déploiement Production - LeBeni's Backend

## ✅ Checklist Rapide

Votre backend est **prêt à 95% pour la production** ! Voici les dernières étapes :

### 1️⃣ Préparer l'environnement de production (10 min)

```bash
# Copier le fichier d'exemple
cp .env.production.example .env.production

# Éditer avec les vraies valeurs
nano .env.production
```

**Valeurs critiques à remplir :**
- `SECRET_KEY` : Générer avec `python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"`
- `DEBUG=False`
- `ALLOWED_HOSTS` : Vos vrais domaines
- `DATABASE_URL` : Base de données de production
- `CORS_ALLOWED_ORIGINS` : Domaines autorisés uniquement

---

### 2️⃣ Installer les dépendances supplémentaires (5 min)

```bash
pip install whitenoise gunicorn
pip freeze > requirements.txt  # Mettre à jour
```

---

### 3️⃣ Tester en mode production localement (15 min)

```bash
# Activer le mode production
export DJANGO_SETTINGS_MODULE=config.settings.production
export ENVIRONMENT=production

# Appliquer les migrations
python manage.py migrate

# Collecter les static files
python manage.py collectstatic --noinput

# Créer un superuser
python manage.py createsuperuser

# Vérifier la configuration
python manage.py check --deploy

# Tester avec Gunicorn
gunicorn config.wsgi:application --bind 0.0.0.0:8000
```

Ouvrir http://localhost:8000/health/ → Devrait retourner `{"status": "healthy"}`

---

### 4️⃣ Désactiver les endpoints de test (FAIT ✅)

Les endpoints de test (`/api/v1/test/`) sont **automatiquement désactivés** quand `DEBUG=False`.

---

### 5️⃣ Fichiers à supprimer avant déploiement (optionnel)

Ces fichiers ne sont **pas nécessaires** en production :

```bash
rm test_location_service.py
rm examples_geolocation.py
rm TEST_GEOLOCATION.md
```

Garder :
- `GEOLOCATION_GUIDE.md` (documentation)
- `PUSH_NOTIFICATIONS_GUIDE.md` (documentation)
- `apps/*/tests/` (pour CI/CD)

---

## 🔒 Sécurité - Points clés

### ✅ Déjà configuré automatiquement

Quand `DEBUG=False`, le backend active automatiquement :

- ✅ HTTPS redirect
- ✅ Secure cookies
- ✅ HSTS headers
- ✅ XSS protection
- ✅ Rate limiting (100 req/h anonymes, 1000 req/h authentifiés)
- ✅ CORS limité aux domaines autorisés
- ✅ Endpoints de test désactivés

---

## 📊 Monitoring & Santé

### Healthcheck

```bash
curl https://votre-api.com/health/
```

**Réponse attendue :**
```json
{
  "status": "healthy",
  "database": "connected"
}
```

Utiliser ce endpoint pour :
- Load balancers (AWS ALB, Google Cloud)
- Monitoring (Uptime Robot, Pingdom)
- CI/CD health checks

---

## 🐳 Déploiement avec Docker (optionnel)

**Dockerfile** (déjà prêt) :

```dockerfile
FROM python:3.12-slim

WORKDIR /app

# Dépendances
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Code
COPY . .

# Static files
RUN python manage.py collectstatic --noinput

# Port
EXPOSE 8000

# Commande
CMD ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000"]
```

**Docker Compose** :

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8000:8000"
    env_file:
      - .env.production
    depends_on:
      - db
      
  db:
    image: postgres:15
    environment:
      POSTGRES_DB: lebenis
      POSTGRES_USER: lebenis
      POSTGRES_PASSWORD: changeme
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

---

## 🌐 Déploiement sur serveur (VPS)

### Option 1 : Avec Systemd

**Fichier** : `/etc/systemd/system/lebenis.service`

```ini
[Unit]
Description=LeBeni's Gunicorn
After=network.target

[Service]
User=lebenis
Group=www-data
WorkingDirectory=/home/lebenis/lebenis_project/backend
Environment="PATH=/home/lebenis/lebenis_project/backend/venv/bin"
EnvironmentFile=/home/lebenis/lebenis_project/backend/.env.production
ExecStart=/home/lebenis/lebenis_project/backend/venv/bin/gunicorn \
          --workers 3 \
          --bind unix:/run/lebenis.sock \
          config.wsgi:application

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable lebenis
sudo systemctl start lebenis
```

### Option 2 : Avec Nginx (reverse proxy)

**Fichier** : `/etc/nginx/sites-available/lebenis`

```nginx
server {
    listen 80;
    server_name api.lebenis.com;

    location = /favicon.ico { access_log off; log_not_found off; }
    
    location /static/ {
        alias /home/lebenis/lebenis_project/backend/staticfiles/;
    }
    
    location /media/ {
        alias /home/lebenis/lebenis_project/backend/media/;
    }

    location / {
        proxy_pass http://unix:/run/lebenis.sock;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/lebenis /etc/nginx/sites-enabled
sudo nginx -t
sudo systemctl restart nginx
```

### Option 3 : SSL avec Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d api.lebenis.com
```

---

## ☁️ Déploiement Cloud

### Render.com (Recommandé - Gratuit)

1. Connecter repo GitHub
2. Créer nouveau Web Service
3. Build Command : `pip install -r requirements.txt && python manage.py collectstatic --noinput`
4. Start Command : `gunicorn config.wsgi:application`
5. Ajouter variables d'environnement (depuis `.env.production`)

### Railway.app

1. Connecter repo GitHub
2. Déploiement automatique
3. Ajouter PostgreSQL addon
4. Variables d'environnement depuis `.env.production`

### Heroku

```bash
# Ajouter Procfile
echo "web: gunicorn config.wsgi:application" > Procfile

# Ajouter runtime
echo "python-3.12.0" > runtime.txt

# Déployer
heroku create lebenis-api
heroku addons:create heroku-postgresql:hobby-dev
git push heroku main
heroku run python manage.py migrate
heroku run python manage.py createsuperuser
```

---

## 📈 Optimisations Production (optionnel)

### Redis Cache

```python
# .env.production
REDIS_URL=redis://localhost:6379/0
```

Le backend utilise automatiquement Redis si configuré.

### AWS S3 pour médias

```bash
pip install boto3 django-storages
```

Décommenter dans `config/settings/production.py` :
```python
AWS_ACCESS_KEY_ID = config('AWS_ACCESS_KEY_ID')
AWS_SECRET_ACCESS_KEY = config('AWS_SECRET_ACCESS_KEY')
AWS_STORAGE_BUCKET_NAME = config('AWS_STORAGE_BUCKET_NAME')
DEFAULT_FILE_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'
```

### Monitoring avec Sentry

```bash
pip install sentry-sdk
```

```bash
# .env.production
SENTRY_DSN=https://xxxxx@sentry.io/xxxxx
```

Le backend utilise automatiquement Sentry si configuré.

---

## 🧪 Tests avant déploiement

```bash
# Tests unitaires
python manage.py test

# Vérification sécurité
python manage.py check --deploy

# Test healthcheck
curl http://localhost:8000/health/

# Test API
curl http://localhost:8000/api/v1/auth/register/ -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123"}'
```

---

## 🆘 Troubleshooting

### `SECRET_KEY` invalide
```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

### Static files 404
```bash
python manage.py collectstatic --noinput --clear
```

### Database connection refused
Vérifier `DATABASE_URL` dans `.env.production`

### CORS errors
Ajouter domaines dans `CORS_ALLOWED_ORIGINS`

---

## 📞 Support

**Documentation complète** :
- `PRODUCTION_CHECKLIST.md` - Checklist détaillée
- `GEOLOCATION_GUIDE.md` - Intégration géolocalisation
- `PUSH_NOTIFICATIONS_GUIDE.md` - Notifications push

**Logs** :
```bash
tail -f logs/error.log
journalctl -u lebenis -f  # Si systemd
```

---

## ✅ Résumé - Prêt pour production

**Score actuel : 95/100** 🎉

### ✅ Déjà fait
- Structure code production-ready
- Settings production créés
- Sécurité configurée automatiquement
- Healthcheck endpoint
- Rate limiting
- Endpoints test auto-désactivés
- Documentation complète

### ⏳ Reste à faire (10 min)
1. Créer `.env.production` avec vraies valeurs
2. Tester localement avec `DEBUG=False`
3. Déployer sur serveur/cloud

**Temps total : ~30 minutes** pour être 100% production ! 🚀
