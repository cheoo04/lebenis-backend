# 🚀 Déploiement Render (Compte Payant) - Redis Cloud + Celery

## ✅ Avantages du compte payant

- **Pas de limite de 750h/mois** - Services 24/7
- **Pas de sleep après 15 min** - Toujours actif
- **Plus de RAM** - Peut gérer plus de workers
- **Déploiement automatique** - Via render.yaml

---

## 📋 Prérequis

- [x] Compte Render payant activé
- [x] Redis Cloud acheté
- [x] Repository GitHub prêt
- [x] `django-redis` ajouté dans requirements.txt

---

## 🎯 Architecture finale

```
┌─────────────────────────────────────────────────────┐
│            REDIS CLOUD (Payant - Déjà acheté)       │
│     rediss://...@redis-cloud.com:12345              │
│                                                      │
│  • Cache Django                                      │
│  • Celery Broker (queue)                            │
│  • Celery Results                                   │
└──────────────────┬──────────────────────────────────┘
                   │ SSL/TLS
                   │
┌──────────────────▼──────────────────────────────────┐
│         RENDER (1 Compte Payant)                    │
│                                                      │
│  ┌────────────────────────────────────────────┐    │
│  │  Web Service (Django + Gunicorn)           │    │
│  │  • 2 workers                                │    │
│  │  • Auto-deploy depuis main                 │    │
│  └────────────┬───────────────────────────────┘    │
│               │                                     │
│  ┌────────────▼───────────────────────────────┐    │
│  │  PostgreSQL Database                       │    │
│  │  • Starter Plan (ou supérieur)             │    │
│  └────────────────────────────────────────────┘    │
│                                                      │
│  ┌──────────────────────────────────────────┐      │
│  │  Background Worker (Celery Worker)        │      │
│  │  • Concurrency: 2                         │      │
│  │  • Max tasks per child: 100               │      │
│  └──────────────────────────────────────────┘      │
│                                                      │
│  ┌──────────────────────────────────────────┐      │
│  │  Cron Job (Celery Beat)                   │      │
│  │  • Schedule: */15 * * * *                │      │
│  │  • Max interval: 15 min                   │      │
│  └──────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────┘
```

---

## 🚀 Déploiement en 3 étapes

### Étape 1: Préparer Redis Cloud (5 min)

#### 1.1 Obtenir l'URL Redis

1. Aller sur https://app.redislabs.com/
2. Sélectionner votre database
3. Copier l'URL de connexion
4. **IMPORTANT**: Changer `redis://` en `rediss://` (SSL)

**Format attendu:**

```
rediss://default:VOTRE_PASSWORD@redis-12345.c123.us-east-1-2.ec2.redns.redis-cloud.com:12345
```

#### 1.2 Tester localement (optionnel)

```bash
cd backend
export REDIS_URL="rediss://default:PASSWORD@..."
export REQUIRE_REDIS_SSL=true
python test_redis_celery.py
```

**Résultat attendu:**

```
✅ Redis: Connecté
✅ Celery Broker: OK
✅ Celery Results: OK
🎉 Tous les tests passés!
```

---

### Étape 2: Déployer via Blueprint (10 min)

#### Option A: Via render.yaml (Recommandé - Automatique)

1. **Vérifier que render.yaml existe:**

```bash
ls backend/render.yaml
```

2. **Commiter et pusher:**

```bash
git add backend/render.yaml backend/requirements.txt
git commit -m "Add Render Blueprint with Redis + Celery"
git push origin main
```

3. **Sur Render Dashboard:**

   - Aller sur https://dashboard.render.com/
   - Cliquer "New" → "Blueprint"
   - Sélectionner votre repository
   - Branch: `main`
   - Render détectera `render.yaml` automatiquement
   - Cliquer **"Apply"**

4. **Render va créer automatiquement:**
   - ✅ Web Service (lebenis-backend)
   - ✅ Background Worker (lebenis-celery-worker)
   - ✅ Cron Job (lebenis-celery-beat)
   - ✅ PostgreSQL Database (lebenis-db)

#### Option B: Manuel (si render.yaml ne marche pas)

Voir section "Configuration manuelle" ci-dessous.

---

### Étape 3: Configurer les variables d'environnement (5 min)

#### 3.1 Variables communes (pour les 3 services)

Sur Render Dashboard, pour **chaque service** (Web, Worker, Cron), ajouter:

```env
# Django
DJANGO_SETTINGS_MODULE=config.settings.production
SECRET_KEY=<générer avec Render ou pwgen>
DEBUG=False
ALLOWED_HOSTS=lebenis-backend.onrender.com

# Redis Cloud (SSL requis)
REDIS_URL=rediss://default:PASSWORD@redis-xxxxx.c123.region.ec2.redns.redis-cloud.com:12345
REQUIRE_REDIS_SSL=true

# Email (SendGrid)
SENDGRID_API_KEY=SG.xxxxxxxxxxxxxxxxxxxxxxxx
DEFAULT_FROM_EMAIL=noreply@votre-domaine.com

# Firebase (Push Notifications)
FCM_SERVER_KEY=AAAA...xxxxx

# Google Maps
GOOGLE_MAPS_API_KEY=AIzaSy...xxxxx

# Cloudinary (Images)
CLOUDINARY_CLOUD_NAME=votre-cloud-name
CLOUDINARY_API_KEY=123456789012345
CLOUDINARY_API_SECRET=votre-secret-cloudinary

# Mobile Money (Optionnel - si configuré)
MTN_MOMO_API_USER=xxxxx
MTN_MOMO_API_KEY=xxxxx
MTN_MOMO_SUBSCRIPTION_KEY=xxxxx
ORANGE_MONEY_CLIENT_ID=xxxxx
ORANGE_MONEY_CLIENT_SECRET=xxxxx
```

#### 3.2 Variable spécifique au Web Service

**Uniquement pour le Web Service:**

```env
DATABASE_URL=<auto-généré par Render>
```

⚠️ **Note**: Le Worker et le Cron Job utiliseront automatiquement la même database via l'URL interne.

---

## ✅ Vérification du déploiement

### 1. Vérifier les logs

#### Web Service

```
✅ Django version 4.2.7
✅ Resolved Celery broker: rediss://***:***@...
✅ Starting gunicorn 21.2.0
✅ Listening at: http://0.0.0.0:10000
```

#### Background Worker

```
✅ Connected to rediss://***:***@...
✅ celery@worker v5.3.4 (emerald-rush)
✅ ready.
```

#### Cron Job (Beat)

```
✅ celery beat v5.3.4 (emerald-rush) is starting.
✅ Scheduler: Sending due task daily-driver-payouts
```

### 2. Tester via Django Admin

1. Aller sur `https://lebenis-backend.onrender.com/admin/`
2. Se connecter (créer superuser si nécessaire)
3. Aller dans **"Django Celery Results"** → **"Task results"**
4. Vous devriez voir les tâches exécutées

### 3. Tester une tâche manuellement

Via Shell Render (sur le Web Service):

```bash
python manage.py shell
```

```python
# Tester une tâche simple
from config.celery import debug_task
result = debug_task.delay()
print(f"Task ID: {result.id}")
print(f"Status: {result.status}")

# Vérifier les tâches planifiées
from django_celery_beat.models import PeriodicTask
print(PeriodicTask.objects.all())

# Vérifier les résultats
from django_celery_results.models import TaskResult
print(f"Total tasks: {TaskResult.objects.count()}")
```

---

## 🛠️ Configuration manuelle (si Blueprint échoue)

### Service 1: Web Service

```yaml
Name: lebenis-backend
Environment: Python 3.12
Region: Frankfurt (ou votre région)
Branch: main
Root Directory: backend

Build Command:
pip install -r requirements.txt && python manage.py collectstatic --noinput && python manage.py migrate

Start Command:
gunicorn config.wsgi:application --bind 0.0.0.0:$PORT --workers 2 --timeout 120

Health Check Path: /admin/login/
```

**Instance Type:** Starter ($7/mois) ou supérieur

### Service 2: Background Worker

```yaml
Name: lebenis-celery-worker
Environment: Python 3.12
Region: Même que Web Service
Branch: main
Root Directory: backend

Build Command:
pip install -r requirements.txt

Start Command:
celery -A config worker --loglevel=info --concurrency=2 --max-tasks-per-child=100
```

**Instance Type:** Starter ($7/mois) ou supérieur

### Service 3: Cron Job

```yaml
Name: lebenis-celery-beat
Environment: Python 3.12
Region: Même que Web Service
Branch: main
Root Directory: backend

Schedule: */15 * * * * (toutes les 15 minutes)

Build Command:
pip install -r requirements.txt

Start Command:
celery -A config beat --loglevel=info --max-interval=15
```

**Instance Type:** Starter ($7/mois)

### Service 4: PostgreSQL Database

```yaml
Name: lebenis-db
Plan: Starter ($7/mois) ou supérieur
Region: Même que Web Service
```

**Connexion:** Automatique au Web Service via `DATABASE_URL`

---

## 📊 Monitoring et maintenance

### Créer un superuser

```bash
# Via Shell Render (Web Service)
python manage.py createsuperuser
```

### Vérifier les workers actifs

```bash
celery -A config inspect active
```

### Voir les tâches planifiées

```bash
celery -A config inspect scheduled
```

### Logs en temps réel

Sur Render Dashboard → Service → **Logs**

---

## 🔧 Troubleshooting

### ❌ "Could not find backend 'django_redis.cache.RedisCache'"

**Cause:** `django-redis` pas dans requirements.txt  
**Solution:** ✅ Déjà corrigé dans le dernier commit

### ❌ "Connection refused" (Redis)

**Cause:** URL Redis incorrecte  
**Solution:** Vérifier que l'URL commence par `rediss://` (avec SSL)

### ❌ "SSL: CERTIFICATE_VERIFY_FAILED"

**Cause:** Certificat SSL non accepté  
**Solution:** ✅ Déjà configuré dans `base.py` avec `ssl_cert_reqs=None`

### ❌ Worker ne démarre pas

**Vérifications:**

1. Variables d'environnement identiques au Web Service?
2. `REDIS_URL` accessible?
3. Logs du Worker pour voir l'erreur exacte

### ❌ Beat n'envoie pas de tâches

**Vérifications:**

1. Cron Job schedule correct? (`*/15 * * * *`)
2. Beat connecté à Redis? (voir logs)
3. Tâches définies dans `base.py`? (vérifier `CELERY_BEAT_SCHEDULE`)

---

## 💰 Coûts mensuels

| Service           | Plan    | Prix/mois     |
| ----------------- | ------- | ------------- |
| Web Service       | Starter | $7            |
| Background Worker | Starter | $7            |
| Cron Job          | Starter | $7            |
| PostgreSQL        | Starter | $7            |
| Redis Cloud       | Basic   | ~$5           |
| **TOTAL**         |         | **~$33/mois** |

**Optimisation:** Si budget serré, utiliser Starter ($7) au lieu de Standard ($25) pour chaque service.

---

## 🎯 Checklist finale

- [ ] Redis Cloud URL récupérée et convertie en `rediss://`
- [ ] `render.yaml` committé et pushé
- [ ] Blueprint appliqué sur Render
- [ ] Variables d'environnement configurées (3 services)
- [ ] Web Service healthy (logs OK)
- [ ] Worker connecté (logs OK)
- [ ] Beat actif (logs OK)
- [ ] Superuser créé
- [ ] Test d'une tâche réussi
- [ ] Django Admin accessible
- [ ] Task Results visibles dans l'admin

---

## 📚 Fichiers de référence

- `render.yaml` - Configuration Blueprint
- `test_redis_celery.py` - Tests de connectivité
- `REDIS_CELERY_RENDER_SETUP.md` - Guide détaillé technique
- `DEPLOYMENT_QUICKSTART.md` - Guide rapide

---

## 🆘 Support

**En cas de problème:**

1. Vérifier les logs de chaque service
2. Tester Redis localement avec `test_redis_celery.py`
3. Vérifier que toutes les variables d'environnement sont identiques
4. Consulter https://render.com/docs/troubleshooting-deploys

**Contact Render Support:** support@render.com (réponse rapide avec compte payant)
