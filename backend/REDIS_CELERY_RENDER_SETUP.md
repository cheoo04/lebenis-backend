# 🚀 Configuration Redis Cloud + Celery sur Render (Plan Gratuit)

## 📋 Vue d'ensemble

Configuration complète pour utiliser **Redis Cloud** (payant) avec **Celery Worker + Beat** sur Render (gratuit).

### Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    RENDER (Plan Gratuit)                        │
│                                                                 │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐ │
│  │   Web Service    │  │  Background Work │  │  Cron Job    │ │
│  │   (Gunicorn)     │  │  (Celery Worker) │  │ (Celery Beat)│ │
│  │   Django App     │  │                  │  │              │ │
│  └────────┬─────────┘  └────────┬─────────┘  └──────┬───────┘ │
│           │                     │                    │         │
│           └─────────────────────┼────────────────────┘         │
│                                 │                              │
└─────────────────────────────────┼──────────────────────────────┘
                                  │
                                  │ SSL/TLS (rediss://)
                                  ▼
                    ┌──────────────────────────┐
                    │   REDIS CLOUD (Payant)   │
                    │   - Broker: Celery       │
                    │   - Results: Celery      │
                    │   - Cache: Django        │
                    └──────────────────────────┘
```

## 🔐 Étape 1: Configuration Redis Cloud

### 1.1 Récupérer les informations de connexion

Depuis votre dashboard Redis Cloud, vous devriez avoir une URL au format :
```
redis://default:PASSWORD@redis-12345.c123.us-east-1-2.ec2.redns.redis-cloud.com:12345
```

**Important** : Redis Cloud nécessite **SSL/TLS**, donc l'URL doit être convertie en :
```
rediss://default:PASSWORD@redis-12345.c123.us-east-1-2.ec2.redns.redis-cloud.com:12345
```

### 1.2 Variables d'environnement Render

Dans chaque service Render, ajouter ces variables :

| Variable | Valeur | Description |
|----------|--------|-------------|
| `REDIS_URL` | `rediss://default:PASSWORD@...` | URL Redis Cloud avec SSL |
| `REQUIRE_REDIS_SSL` | `true` | Force l'utilisation de SSL |
| `CELERY_BROKER_URL` | (laisser vide) | Auto-dérivé de REDIS_URL |
| `CELERY_RESULT_BACKEND` | (laisser vide) | Auto-dérivé de REDIS_URL |

## 📦 Étape 2: Structure des Services Render

Vous aurez besoin de **3 services** sur Render :

### 2.1 Web Service (Django + Gunicorn)

**Type:** Web Service  
**Plan:** Gratuit (Starter)  
**Build Command:**
```bash
pip install -r requirements.txt && python manage.py collectstatic --noinput && python manage.py migrate
```

**Start Command:**
```bash
gunicorn config.wsgi:application --bind 0.0.0.0:$PORT --workers 2 --timeout 120
```

**Variables d'environnement:**
- Toutes les variables Django standard
- `REDIS_URL` (Redis Cloud)
- `REQUIRE_REDIS_SSL=true`

### 2.2 Background Worker (Celery Worker)

**Type:** Background Worker  
**Plan:** Gratuit (Starter)  
**Build Command:**
```bash
pip install -r requirements.txt
```

**Start Command:**
```bash
celery -A config worker --loglevel=info --concurrency=2 --max-tasks-per-child=100
```

**Variables d'environnement:**
- Mêmes variables que Web Service
- **Important:** Copier TOUTES les variables d'environnement du Web Service

**Options recommandées:**
- `--concurrency=2` : 2 workers max (limite du plan gratuit)
- `--max-tasks-per-child=100` : Redémarre worker tous les 100 tasks (évite memory leaks)

### 2.3 Cron Job (Celery Beat)

**Type:** Cron Job  
**Plan:** Gratuit  
**Schedule:** `*/15 * * * *` (toutes les 15 minutes)

**Build Command:**
```bash
pip install -r requirements.txt
```

**Run Command:**
```bash
celery -A config beat --loglevel=info --max-interval=15
```

**Variables d'environnement:**
- Mêmes variables que Web Service

**⚠️ Important pour le plan gratuit:**
- Le Cron Job s'exécute toutes les 15 minutes
- `--max-interval=15` limite l'intervalle entre les checks
- Beat vérifie le schedule et déclenche les tâches qui doivent s'exécuter

## 🔧 Étape 3: Configuration Django

### 3.1 Vérifier requirements.txt

Assurez-vous que ces dépendances sont présentes :

```txt
celery[redis]==5.3.4
django-celery-beat==2.5.0
django-celery-results==2.5.1
redis==5.0.1
```

### 3.2 Configuration settings/base.py (Déjà fait ✅)

Le fichier `config/settings/base.py` est déjà correctement configuré avec :
- Détection automatique SSL via `REQUIRE_REDIS_SSL`
- Conversion `redis://` → `rediss://` automatique
- Configuration SSL avec `ssl.CERT_NONE` pour Redis Cloud
- Logs de diagnostic

### 3.3 Activer le cache Redis (Optionnel)

Dans `config/settings/production.py`, décommenter :

```python
REDIS_URL = config('REDIS_URL', default='')
if REDIS_URL:
    CACHES = {
        'default': {
            'BACKEND': 'django_redis.cache.RedisCache',
            'LOCATION': REDIS_URL,
            'OPTIONS': {
                'CLIENT_CLASS': 'django_redis.client.DefaultClient',
                'CONNECTION_POOL_KWARGS': {
                    'ssl_cert_reqs': None  # Pour Redis Cloud
                }
            }
        }
    }
```

## 🧪 Étape 4: Tests et Vérification

### 4.1 Test local (avec votre Redis Cloud)

```bash
# Export des variables
export REDIS_URL="rediss://default:PASSWORD@..."
export REQUIRE_REDIS_SSL=true
export DJANGO_SETTINGS_MODULE=config.settings.development

# Test connexion Redis
python -c "import redis; r=redis.from_url('$REDIS_URL', ssl_cert_reqs=None); print(r.ping())"

# Test Celery worker
celery -A config worker --loglevel=debug -c 1

# Dans un autre terminal, test Celery beat
celery -A config beat --loglevel=debug

# Test d'une tâche
python manage.py shell
>>> from apps.payments.tasks import process_daily_payouts
>>> result = process_daily_payouts.delay()
>>> result.status
```

### 4.2 Test sur Render

#### Vérifier les logs du Worker :
```
[2025-12-11 01:00:00] INFO/MainProcess] Connected to rediss://***:***@...
[2025-12-11 01:00:00] INFO/MainProcess] celery@worker ready.
```

#### Vérifier les logs de Beat :
```
[2025-12-11 01:00:00] INFO/Beat] Scheduler: Sending due task daily-driver-payouts
```

#### Vérifier l'exécution des tâches :
```bash
# Via Django shell sur Render
python manage.py shell
>>> from django_celery_results.models import TaskResult
>>> TaskResult.objects.all().order_by('-date_done')[:5]
```

## 📊 Étape 5: Monitoring

### 5.1 Dashboard Django Admin

Ajouter à `config/urls.py` (si pas déjà fait) :
```python
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    # ... autres URLs
]

# Ajouter les résultats Celery dans l'admin
from django.contrib import admin
from django_celery_results.models import TaskResult

admin.site.register(TaskResult)
```

### 5.2 Commandes utiles

```bash
# Lister les workers actifs
celery -A config inspect active

# Lister les tâches en cours
celery -A config inspect active_queues

# Stats des workers
celery -A config inspect stats

# Purger la queue (⚠️ Danger !)
celery -A config purge
```

## 💰 Optimisation Plan Gratuit Render

### Limites du plan gratuit :
- **750 heures/mois** par service
- Services **s'endorment** après 15 min d'inactivité
- **1 instance** par service
- **512 MB RAM** par service

### Astuces d'optimisation :

#### 1. Réduire la concurrence Celery
```bash
# Au lieu de --concurrency=4
celery -A config worker --concurrency=2
```

#### 2. Limiter la mémoire des tâches
```python
# Dans config/settings/base.py
CELERY_TASK_TIME_LIMIT = 5 * 60  # 5 minutes max
CELERY_TASK_SOFT_TIME_LIMIT = 4 * 60  # Warning à 4 min
```

#### 3. Utiliser le Cron Job pour Beat (gratuit !)
Au lieu d'un Background Worker dédié pour Beat, utilisez un Cron Job qui s'exécute toutes les 15 minutes.

#### 4. Combiner Worker + Web (si possible)
Pour économiser les heures, vous pouvez lancer Celery worker en mode embedded :
```python
# Dans config/wsgi.py (⚠️ Pas recommandé en prod)
if os.environ.get('ENABLE_CELERY_WORKER'):
    from celery import current_app
    current_app.worker_main(['worker', '--loglevel=info'])
```

## 🔍 Troubleshooting

### Problème : "Connection refused"
**Solution :** Vérifier que `REDIS_URL` commence bien par `rediss://` (avec double 's')

### Problème : "SSL: CERTIFICATE_VERIFY_FAILED"
**Solution :** Ajouter `ssl_cert_reqs=None` dans les options de connexion

### Problème : Worker crash fréquents
**Solution :**
```bash
# Ajouter --max-tasks-per-child
celery -A config worker --max-tasks-per-child=50

# Ou limiter la mémoire
celery -A config worker --max-memory-per-child=200000  # 200MB
```

### Problème : Tasks pas exécutées
**Solution :**
1. Vérifier que Beat tourne (`celery -A config inspect scheduled`)
2. Vérifier que Worker est actif (`celery -A config inspect active`)
3. Vérifier les logs Render pour errors

### Problème : "Too many connections"
**Solution :** Redis Cloud gratuit limite à 30 connexions. Réduire :
```python
# Dans settings/base.py
CELERY_BROKER_POOL_LIMIT = 10  # Max 10 connexions
```

## ✅ Checklist de Déploiement

- [ ] Redis Cloud configuré et accessible
- [ ] URL Redis Cloud récupérée (avec mot de passe)
- [ ] URL convertie en `rediss://` (SSL)
- [ ] Variable `REDIS_URL` ajoutée sur tous les services Render
- [ ] Variable `REQUIRE_REDIS_SSL=true` ajoutée
- [ ] Web Service déployé et fonctionnel
- [ ] Background Worker déployé (Celery worker)
- [ ] Cron Job configuré (Celery beat, toutes les 15 min)
- [ ] Logs vérifiés (pas d'erreurs de connexion)
- [ ] Test d'une tâche simple réussi
- [ ] Monitoring activé (Django Admin + TaskResult)

## 📚 Ressources

- [Redis Cloud Documentation](https://redis.io/docs/cloud/)
- [Celery Documentation](https://docs.celeryq.dev/)
- [Render Background Workers](https://render.com/docs/background-workers)
- [Render Cron Jobs](https://render.com/docs/cronjobs)
