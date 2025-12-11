# 🚀 Guide de Déploiement Rapide - Redis Cloud + Celery

## Prérequis ✅

- [ ] Compte Redis Cloud (forfait payant acheté)
- [ ] Compte Render (plan gratuit OK)
- [ ] Git repository configuré

## Étape 1: Configuration Redis Cloud (5 min)

### 1.1 Récupérer l'URL de connexion

1. Aller sur https://app.redislabs.com/
2. Sélectionner votre database
3. Copier l'URL de connexion (format: `redis://default:PASSWORD@...`)
4. **Important**: Changer `redis://` en `rediss://` pour activer SSL

**Exemple:**
```
Avant:  redis://default:abc123@redis-12345.c123.us-east-1-2.ec2.redns.redis-cloud.com:12345
Après:  rediss://default:abc123@redis-12345.c123.us-east-1-2.ec2.redns.redis-cloud.com:12345
```

### 1.2 Tester la connexion localement

```bash
cd backend
export REDIS_URL="rediss://default:PASSWORD@..."
export REQUIRE_REDIS_SSL=true
python test_redis_celery.py
```

**Résultat attendu:**
```
✅ PING réussi: True
✅ SET/GET réussi: LeBeni Redis Test
🎉 Tous les tests sont passés !
```

## Étape 2: Déployer sur Render (10 min)

### Option A: Via render.yaml (Recommandé)

1. **Pusher le fichier render.yaml:**
```bash
git add render.yaml
git commit -m "Add Render configuration"
git push origin main
```

2. **Sur Render Dashboard:**
   - Aller sur https://dashboard.render.com/
   - Cliquer sur "New" → "Blueprint"
   - Connecter votre repository
   - Sélectionner la branche `main`
   - Render détectera automatiquement `render.yaml`
   - Cliquer sur "Apply"

3. **Ajouter les variables d'environnement manuelles:**

Pour chaque service (Web, Worker, Cron), ajouter:

| Variable | Valeur |
|----------|--------|
| `REDIS_URL` | `rediss://default:PASSWORD@...` (votre URL Redis Cloud) |
| `SENDGRID_API_KEY` | Votre clé SendGrid |
| `FCM_SERVER_KEY` | Votre clé Firebase |
| `GOOGLE_MAPS_API_KEY` | Votre clé Google Maps |
| `CLOUDINARY_CLOUD_NAME` | Votre nom Cloudinary |
| `CLOUDINARY_API_KEY` | Votre clé API Cloudinary |
| `CLOUDINARY_API_SECRET` | Votre secret Cloudinary |

### Option B: Configuration manuelle

#### Service 1: Web Service

```yaml
Name: lebenis-backend
Environment: Python 3.12
Build Command: pip install -r requirements.txt && python manage.py collectstatic --noinput && python manage.py migrate
Start Command: gunicorn config.wsgi:application --bind 0.0.0.0:$PORT --workers 2 --timeout 120
```

**Variables d'environnement:**
```
DJANGO_SETTINGS_MODULE=config.settings.production
REDIS_URL=rediss://...
REQUIRE_REDIS_SSL=true
DATABASE_URL=postgresql://... (auto-généré)
SECRET_KEY=... (générer avec Render)
ALLOWED_HOSTS=lebenis-backend.onrender.com
```

#### Service 2: Background Worker

```yaml
Name: lebenis-celery-worker
Environment: Python 3.12
Build Command: pip install -r requirements.txt
Start Command: celery -A config worker --loglevel=info --concurrency=2 --max-tasks-per-child=100
```

**Variables d'environnement:** (copier toutes celles du Web Service)

#### Service 3: Cron Job

```yaml
Name: lebenis-celery-beat
Environment: Python 3.12
Schedule: */15 * * * * (toutes les 15 min)
Build Command: pip install -r requirements.txt
Start Command: celery -A config beat --loglevel=info --max-interval=15
```

**Variables d'environnement:** (copier toutes celles du Web Service)

## Étape 3: Vérification (5 min)

### 3.1 Vérifier les logs

**Web Service:**
```
✅ Django system check identified no issues
✅ Resolved Celery broker: rediss://***:***@...
✅ Starting gunicorn
```

**Worker:**
```
✅ Connected to rediss://***:***@...
✅ celery@worker ready.
```

**Cron Job (Beat):**
```
✅ Scheduler: Sending due task daily-driver-payouts
```

### 3.2 Tester une tâche

Via Shell Render:

```bash
# Ouvrir shell sur le Web Service
python manage.py shell

# Tester une tâche
>>> from config.celery import debug_task
>>> result = debug_task.delay()
>>> print(result.status)
'PENDING' ou 'SUCCESS'

# Vérifier les résultats
>>> from django_celery_results.models import TaskResult
>>> TaskResult.objects.count()
```

### 3.3 Vérifier le Dashboard Admin

1. Aller sur `https://lebenis-backend.onrender.com/admin/`
2. Se connecter avec le superuser
3. Aller dans "Django Celery Results" → "Task results"
4. Vous devriez voir les tâches exécutées

## Étape 4: Monitoring (Setup une fois)

### 4.1 Créer un Superuser

```bash
# Via Shell Render
python manage.py createsuperuser
```

### 4.2 Activer Sentry (Optionnel)

```bash
# Ajouter dans les variables d'environnement
SENTRY_DSN=https://...@sentry.io/...
```

## Commandes Utiles 🛠️

### Vérifier les workers actifs
```bash
celery -A config inspect active
```

### Lister les tâches planifiées
```bash
celery -A config inspect scheduled
```

### Purger la queue (⚠️ Danger)
```bash
celery -A config purge
```

### Forcer l'exécution d'une tâche
```python
from apps.payments.tasks import process_daily_payouts
process_daily_payouts.apply_async()
```

## Troubleshooting 🔧

### Erreur: "Connection refused"

**Cause:** URL Redis incorrecte  
**Solution:** Vérifier que l'URL commence par `rediss://` (double 's')

### Erreur: "SSL: CERTIFICATE_VERIFY_FAILED"

**Cause:** Certificat SSL non accepté  
**Solution:** Déjà configuré dans `base.py` avec `ssl_cert_reqs=None`

### Worker crash après quelques heures

**Cause:** Memory leak ou trop de tâches  
**Solution:** Déjà configuré avec `--max-tasks-per-child=100`

### Tasks ne s'exécutent pas

**Vérifications:**
1. Worker est-il actif? → Logs du Background Worker
2. Beat est-il actif? → Logs du Cron Job
3. Queue Redis accessible? → Tester avec `test_redis_celery.py`

### "Too many connections" sur Redis

**Cause:** Redis Cloud limite le nombre de connexions  
**Solution:** Ajouter dans `base.py`:
```python
CELERY_BROKER_POOL_LIMIT = 10
```

## Optimisations 💡

### Réduire les coûts Render

1. **Désactiver auto-deploy** si pas nécessaire
2. **Utiliser un seul worker** au lieu de 2 en concurrency
3. **Augmenter l'intervalle du Cron Beat** à 30 min au lieu de 15

### Améliorer les performances

1. **Utiliser le cache Redis:**
```python
from django.core.cache import cache
cache.set('key', 'value', 300)  # 5 minutes
```

2. **Prioriser les tâches:**
```python
task.apply_async(priority=10)  # Plus haute priorité
```

3. **Limiter la durée des tâches:**
```python
@app.task(time_limit=300)  # 5 minutes max
def long_task():
    pass
```

## Checklist Finale ✅

- [ ] Redis Cloud accessible (test local réussi)
- [ ] Web Service déployé et healthy
- [ ] Background Worker déployé et connecté
- [ ] Cron Job configuré (toutes les 15 min)
- [ ] Variables d'environnement copiées sur tous les services
- [ ] Test d'une tâche simple réussi
- [ ] Logs sans erreurs
- [ ] Django Admin accessible
- [ ] Task Results visibles dans l'admin

## Support 📞

- Redis Cloud: https://redis.io/docs/cloud/
- Render: https://render.com/docs
- Celery: https://docs.celeryq.dev/
- Issues: Créer un ticket sur le repo GitHub
