# Guide de Configuration Celery - Paiements Automatiques

## 📋 Vue d'ensemble

Celery est configuré pour automatiser les paiements quotidiens des drivers à **23h59** chaque jour, ainsi que d'autres tâches planifiées.

---

## 🛠️ Installation et Configuration

### 1. Dépendances Installées

```bash
pip install celery==5.3.4
pip install redis==5.0.1
pip install django-celery-beat==2.5.0
pip install django-celery-results==2.5.1
```

### 2. Apps Django Ajoutées

Dans `config/settings/base.py` :

```python
INSTALLED_APPS = [
    # ...
    'django_celery_beat',      # Tâches planifiées
    'django_celery_results',   # Résultats des tâches
    # ...
]
```

### 3. Configuration Celery

Dans `config/settings/base.py` :

```python
# Celery Broker (Redis)
CELERY_BROKER_URL = 'redis://localhost:6379/0'
CELERY_RESULT_BACKEND = 'redis://localhost:6379/0'

# Timezone (Côte d'Ivoire)
CELERY_TIMEZONE = 'Africa/Abidjan'  # UTC+0
```

---

## 📅 Tâches Planifiées

### 1. Paiements Quotidiens (23h59)

**Tâche** : `apps.payments.tasks.process_daily_payouts`  
**Planification** : Chaque jour à 23h59  

**Fonctionnement** :
1. Récupère tous les drivers avec paiements `completed` du jour
2. Pour chaque driver :
   - Crée un `DailyPayout` groupé
   - Calcule le montant total (80% du montant après commission 20%)
   - Appelle `OrangeMoneyService.transfer_to_driver()`
   - Met à jour les statuts des `Payment` → liés au payout
   - Envoie notification FCM + DB au driver
3. Génère un rapport dans les logs

**Exemple de log** :
```
🚀 Démarrage du traitement des paiements quotidiens (23h59)
💰 Payout créé pour Jean Kouassi: 24000.00 CFA (8 paiements)
✅ Transfert Orange Money initié pour Jean Kouassi: 24000.00 CFA
📊 RÉSUMÉ DES PAIEMENTS QUOTIDIENS (23h59)
✅ Payouts créés: 15
💰 Montant total transféré: 450000.00 CFA
❌ Payouts échoués: 0
```

---

### 2. Vérification Payouts en Attente (toutes les heures)

**Tâche** : `apps.payments.tasks.check_pending_payouts`  
**Planification** : Toutes les heures à :00  

**Fonctionnement** :
- Vérifie les payouts avec statut `processing` de moins de 24h
- Appelle `OrangeMoneyService.check_payment_status()`
- Met à jour le statut si `SUCCESS` ou `FAILED`
- Envoie notification de confirmation au driver

**Utilité** : S'assurer que les payouts en attente se finalisent correctement.

---

### 3. Reset Durées de Pause (minuit)

**Tâche** : `apps.payments.tasks.reset_daily_break_durations`  
**Planification** : Chaque jour à 00h00  

**Fonctionnement** :
- Réinitialise `total_break_duration_today` à `0` pour tous les drivers
- Met à jour `last_break_reset` à la date du jour

**Utilité** : Compteur de pause quotidien reset automatiquement.

---

## 🚀 Démarrage de Celery

### Prérequis : Redis

Redis doit être installé et démarré sur votre machine.

**Installation Redis** :

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install redis-server

# macOS
brew install redis

# Windows
# Télécharger depuis https://github.com/microsoftarchive/redis/releases
```

**Démarrer Redis** :

```bash
# Linux/macOS
redis-server

# Ou en arrière-plan
sudo systemctl start redis
```

**Vérifier Redis** :

```bash
redis-cli ping
# Réponse attendue : PONG
```

---

### Lancer Celery Worker

Le worker exécute les tâches en arrière-plan.

```bash
cd /home/cheoo/lebenis_project/backend

# Mode développement (verbose)
celery -A config worker -l info

# Mode production (détaché)
celery -A config worker -l info --detach
```

**Logs attendus** :
```
 -------------- celery@hostname v5.3.4 (emerald-rush)
--- ***** ----- 
-- ******* ---- Linux-6.x.x-x86_64 2025-01-24 23:00:00
- *** --- * --- 
- ** ---------- [config]
- ** ---------- .> app:         lebenis:0x...
- ** ---------- .> transport:   redis://localhost:6379/0
- ** ---------- .> results:     redis://localhost:6379/0
- *** --- * --- .> concurrency: 4 (prefork)
-- ******* ---- .> task events: OFF
--- ***** ----- 
 -------------- [queues]
                .> celery           exchange=celery(direct) key=celery

[tasks]
  . apps.payments.tasks.process_daily_payouts
  . apps.payments.tasks.check_pending_payouts
  . apps.payments.tasks.reset_daily_break_durations
```

---

### Lancer Celery Beat (Scheduler)

Celery Beat déclenche les tâches planifiées aux heures spécifiées.

```bash
cd /home/cheoo/lebenis_project/backend

# Mode développement
celery -A config beat -l info

# Mode production (détaché)
celery -A config beat -l info --detach
```

**Logs attendus** :
```
celery beat v5.3.4 is starting.
LocalTime -> 2025-01-24 23:59:00
Configuration:
    . broker -> redis://localhost:6379/0
    . loader -> celery.loaders.app.AppLoader
    . scheduler -> celery.beat.PersistentScheduler

Scheduler: Sending due task daily-driver-payouts (apps.payments.tasks.process_daily_payouts)
Scheduler: Sending due task check-pending-payouts (apps.payments.tasks.check_pending_payouts)
```

---

### Lancer Worker + Beat Simultanément

Pour le développement local :

```bash
celery -A config worker -B -l info
```

> **Note** : En production, lancer séparément worker et beat.

---

## 🧪 Tester les Tâches Manuellement

### 1. Via Django Shell

```bash
python manage.py shell
```

```python
from apps.payments.tasks import process_daily_payouts

# Exécuter immédiatement (synchrone)
result = process_daily_payouts()
print(result)

# Exécuter en arrière-plan (asynchrone avec Celery)
task = process_daily_payouts.delay()
print(f"Task ID: {task.id}")
print(f"Status: {task.status}")
```

### 2. Via Interface Admin Django

Accéder à `/admin/` :

- **Periodic Tasks** : Gérer les tâches planifiées
- **Task Results** : Voir les résultats des tâches exécutées

---

## 📊 Monitoring et Logs

### 1. Logs Celery

Les logs Celery affichent :
- Tâches exécutées
- Résultats des transferts Orange Money
- Erreurs éventuelles

**Exemple** :
```
[2025-01-24 23:59:05: INFO/MainProcess] Task apps.payments.tasks.process_daily_payouts[...] received
🚀 Démarrage du traitement des paiements quotidiens (23h59)
💰 Payout créé pour Jean Kouassi: 24000.00 CFA (8 paiements)
✅ Transfert Orange Money initié pour Jean Kouassi: 24000.00 CFA
[2025-01-24 23:59:12: INFO/MainProcess] Task apps.payments.tasks.process_daily_payouts[...] succeeded in 7.2s
```

### 2. Table Django Celery Results

Les résultats sont stockés dans `django_celery_results_taskresult` :

```python
from django_celery_results.models import TaskResult

# Dernières tâches
recent_tasks = TaskResult.objects.order_by('-date_done')[:10]

for task in recent_tasks:
    print(f"{task.task_name}: {task.status} - {task.result}")
```

### 3. Flower (Interface Web) - Optionnel

```bash
pip install flower
celery -A config flower
```

Accéder à `http://localhost:5555`

---

## 🔧 Configuration Production

### 1. Variables d'Environnement

Dans `.env` :

```bash
# Redis
REDIS_URL=redis://localhost:6379/0

# Celery
CELERY_BROKER_URL=redis://localhost:6379/0
CELERY_RESULT_BACKEND=redis://localhost:6379/0
```

### 2. Systemd Services (Linux Production)

**Celery Worker** (`/etc/systemd/system/celery.service`) :

```ini
[Unit]
Description=Celery Service
After=network.target redis.service

[Service]
Type=forking
User=www-data
Group=www-data
WorkingDirectory=/var/www/lebenis/backend
Environment="PATH=/var/www/lebenis/venv/bin"
ExecStart=/var/www/lebenis/venv/bin/celery -A config worker -l info --detach

[Install]
WantedBy=multi-user.target
```

**Celery Beat** (`/etc/systemd/system/celerybeat.service`) :

```ini
[Unit]
Description=Celery Beat Service
After=network.target redis.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/var/www/lebenis/backend
Environment="PATH=/var/www/lebenis/venv/bin"
ExecStart=/var/www/lebenis/venv/bin/celery -A config beat -l info

[Install]
WantedBy=multi-user.target
```

**Démarrer les services** :

```bash
sudo systemctl daemon-reload
sudo systemctl start celery
sudo systemctl start celerybeat
sudo systemctl enable celery
sudo systemctl enable celerybeat
```

---

## 🚨 Résolution de Problèmes

### Problème : Redis Connection Refused

**Erreur** :
```
ConnectionRefusedError: [Errno 111] Connection refused
```

**Solution** :
```bash
# Vérifier Redis
redis-cli ping

# Si non démarré
sudo systemctl start redis

# Vérifier le port
netstat -tulnp | grep 6379
```

---

### Problème : Tâche ne s'exécute pas

**Vérifications** :
1. Celery Worker est démarré ?
2. Celery Beat est démarré ?
3. Timezone correcte dans settings ?
4. Logs Celery pour erreurs ?

**Debug** :
```bash
# Vérifier tâches planifiées
celery -A config inspect scheduled

# Vérifier workers actifs
celery -A config inspect active
```

---

### Problème : Payouts en double

**Cause** : Tâche exécutée plusieurs fois.

**Solution** :
- Vérifier qu'un seul Celery Beat tourne
- Ajouter idempotence dans la tâche (vérifier si DailyPayout existe déjà)

---

## 📝 Checklist de Déploiement

- [ ] Redis installé et démarré
- [ ] Celery worker en service systemd
- [ ] Celery beat en service systemd
- [ ] Variables d'environnement configurées
- [ ] Logs configurés (rotation avec logrotate)
- [ ] Monitoring configuré (Flower ou Sentry)
- [ ] Tests manuels effectués
- [ ] Tâche de paiement testée en sandbox

---

## 🎯 Prochaines Étapes

1. **Tester en sandbox** :
   - Créer des paiements test
   - Attendre 23h59 ou déclencher manuellement
   - Vérifier transferts Orange Money

2. **Monitoring** :
   - Configurer alertes si tâche échoue
   - Logs centralisés (Sentry, CloudWatch, etc.)

3. **Extensions possibles** :
   - Webhooks pour confirmer transferts
   - Retry automatique en cas d'échec
   - Notifications admin si échecs multiples

---

**Documentation Version** : 1.0  
**Dernière mise à jour** : Phase 2 - Celery Setup Complet
