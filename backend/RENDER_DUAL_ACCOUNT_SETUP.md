# 🆓 Configuration avec 2 Comptes Render Gratuits

## Pourquoi 2 comptes?

| Service             | Heures/mois | Solution             |
| ------------------- | ----------- | -------------------- |
| Web Service         | 750h        | Compte 1             |
| Background Worker   | 750h        | Compte 2             |
| Cron Job (Beat)     | 750h        | Compte 2             |
| Database PostgreSQL | Illimité    | Compte 1             |
| Redis Cloud         | Illimité    | Votre forfait payant |

**Total: 0€/mois** (sauf Redis Cloud déjà payé)

## Étape 1: Compte Principal (Compte 1)

### Service 1.1: Web Service Django

**Repository:** Votre repo principal  
**Branch:** `main`

**Build Command:**

```bash
pip install -r requirements.txt && python manage.py collectstatic --noinput && python manage.py migrate
```

**Start Command:**

```bash
gunicorn config.wsgi:application --bind 0.0.0.0:$PORT --workers 2 --timeout 120
```

**Variables d'environnement:**

```env
DJANGO_SETTINGS_MODULE=config.settings.production
DATABASE_URL=<auto-généré par Render>
SECRET_KEY=<générer avec Render>
ALLOWED_HOSTS=lebenis-backend.onrender.com
DEBUG=False

# Redis Cloud (partagé)
REDIS_URL=rediss://default:PASSWORD@redis-xxxxx.c123.region.ec2.redns.redis-cloud.com:12345
REQUIRE_REDIS_SSL=true

# APIs externes
SENDGRID_API_KEY=...
FCM_SERVER_KEY=...
GOOGLE_MAPS_API_KEY=...
CLOUDINARY_CLOUD_NAME=...
CLOUDINARY_API_KEY=...
CLOUDINARY_API_SECRET=...
```

### Service 1.2: PostgreSQL Database

**Plan:** Starter (gratuit)  
**Nom:** `lebenis-db`

✅ **Connexion automatique** au Web Service via `DATABASE_URL`

---

## Étape 2: Compte Secondaire (Compte 2)

### ⚠️ Important: Fork ou partage du repo

**Option A: Fork public (recommandé)**

```bash
# Sur GitHub, faire un Fork du repo
# Le compte 2 pointera vers le fork
```

**Option B: Collaborateur**

```bash
# Ajouter le compte 2 comme collaborateur sur le repo principal
# Settings → Collaborators → Add people
```

### Service 2.1: Background Worker

**Repository:** Fork ou repo principal (avec accès)  
**Branch:** `main`

**Build Command:**

```bash
pip install -r requirements.txt
```

**Start Command:**

```bash
celery -A config worker --loglevel=info --concurrency=2 --max-tasks-per-child=100
```

**Variables d'environnement:**

```env
DJANGO_SETTINGS_MODULE=config.settings.production

# ⚠️ Pointer vers la DB du Compte 1
DATABASE_URL=postgresql://user:password@dpg-xxxxx.oregon-postgres.render.com/lebenis_db

# Redis Cloud (même que Compte 1)
REDIS_URL=rediss://default:PASSWORD@redis-xxxxx.c123.region.ec2.redns.redis-cloud.com:12345
REQUIRE_REDIS_SSL=true

# ⚠️ SECRET_KEY (même que Compte 1)
SECRET_KEY=<copier depuis Compte 1>

# APIs (copier depuis Compte 1)
SENDGRID_API_KEY=...
FCM_SERVER_KEY=...
```

### Service 2.2: Cron Job (Celery Beat)

**Repository:** Même que Service 2.1  
**Branch:** `main`

**Schedule:** `*/15 * * * *` (toutes les 15 minutes)

**Build Command:**

```bash
pip install -r requirements.txt
```

**Start Command:**

```bash
celery -A config beat --loglevel=info --max-interval=15
```

**Variables d'environnement:** (copier toutes celles du Worker)

---

## Étape 3: Configuration DATABASE_URL externe

### 3.1 Récupérer l'URL de la DB (Compte 1)

1. Aller sur le Dashboard du Compte 1
2. Cliquer sur la Database `lebenis-db`
3. Section "Connections"
4. Copier **External Database URL**

**Format:**

```
postgresql://user:password@dpg-xxxxx-a.oregon-postgres.render.com:5432/lebenis_db
```

### 3.2 Utiliser l'URL dans le Compte 2

⚠️ **Important**: Remplacer le hostname interne par l'externe

```bash
# ❌ URL interne (ne marche pas depuis Compte 2)
postgresql://user:password@dpg-xxxxx/lebenis_db

# ✅ URL externe (marche depuis n'importe où)
postgresql://user:password@dpg-xxxxx-a.oregon-postgres.render.com:5432/lebenis_db
```

---

## Schéma de l'architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     REDIS CLOUD (Payant)                     │
│          rediss://...redis-cloud.com:12345                   │
│                                                               │
│  • Cache Django                                               │
│  • Celery Broker (queue des tâches)                          │
│  • Celery Results (résultats des tâches)                     │
└─────────────────────────────────────────────────────────────┘
                               ▲
                               │ SSL/TLS
                ┌──────────────┼──────────────┐
                │              │              │
                │              │              │
┌───────────────▼──────┐  ┌───▼──────────────▼───────────────┐
│   COMPTE RENDER 1    │  │      COMPTE RENDER 2             │
│      (Gratuit)       │  │        (Gratuit)                 │
│                      │  │                                  │
│  ┌────────────────┐  │  │  ┌──────────────────────────┐   │
│  │  Web Service   │  │  │  │  Background Worker       │   │
│  │   (Django)     │  │  │  │   (Celery Worker)        │   │
│  │  750h/mois     │  │  │  │   750h/mois              │   │
│  └────────┬───────┘  │  │  └──────────────────────────┘   │
│           │          │  │                                  │
│  ┌────────▼───────┐  │  │  ┌──────────────────────────┐   │
│  │  PostgreSQL    │◄─┼──┼──│  Cron Job (Beat)         │   │
│  │   Database     │  │  │  │  celery beat             │   │
│  │  (Gratuit)     │  │  │  │  750h/mois               │   │
│  └────────────────┘  │  │  └──────────────────────────┘   │
│                      │  │                                  │
│  URL externe:        │  │  Connexion via URL externe       │
│  dpg-xxx.render.com  │  │                                  │
└──────────────────────┘  └──────────────────────────────────┘
```

---

## Avantages de cette approche

✅ **Complètement gratuit** (sauf Redis Cloud déjà payé)  
✅ **3 services indépendants** (stabilité maximale)  
✅ **Celery Beat fonctionne** (tâches planifiées)  
✅ **Monitoring séparé** (logs distincts par service)  
✅ **Scalable** (peut upgrader un compte sans toucher l'autre)

## Inconvénients

⚠️ **2 comptes à gérer** (emails différents)  
⚠️ **Variables d'environnement à synchroniser** (si changement API key)  
⚠️ **Database externe** (légèrement plus lent que connexion interne)

---

## Alternative: Service combiné sur 1 compte

Si vous ne voulez vraiment qu'**1 seul compte Render gratuit**, utilisez:

**Start Command:**

```bash
./start_with_celery.sh
```

**Mais:**

- ❌ Pas de Celery Beat (pas de tâches planifiées)
- ❌ Worker + Web dans le même processus (instable)
- ⚠️ Si le service sleep (15 min inactivité), tout s'arrête

---

## Recommandation finale

| Scénario                     | Solution                          | Coût      |
| ---------------------------- | --------------------------------- | --------- |
| **Production sérieuse**      | 2 comptes Render gratuits         | 0€        |
| **Test/Démo**                | 1 compte + `start_with_celery.sh` | 0€        |
| **Pas de contrainte budget** | render.yaml sur 1 compte payant   | ~15€/mois |

**Mon conseil: Utiliser 2 comptes gratuits** → C'est 100% gratuit et production-ready!

---

## Checklist de déploiement

### Compte 1 (Principal)

- [ ] Web Service créé
- [ ] PostgreSQL Database créée
- [ ] `DATABASE_URL` automatiquement configurée
- [ ] Variables d'environnement ajoutées
- [ ] Service healthy (logs sans erreur)
- [ ] Noter l'**External Database URL**

### Compte 2 (Secondaire)

- [ ] Accès au repo configuré (fork ou collaborateur)
- [ ] Background Worker créé
- [ ] Cron Job créé
- [ ] `DATABASE_URL` externe ajoutée (depuis Compte 1)
- [ ] `REDIS_URL` ajoutée (même que Compte 1)
- [ ] Toutes les API keys copiées
- [ ] Worker connecté à Redis (vérifier logs)
- [ ] Beat schedule actif (vérifier logs)

### Tests

- [ ] Test Redis: `python test_redis_celery.py`
- [ ] Créer une tâche depuis Django Admin
- [ ] Vérifier que le Worker l'exécute
- [ ] Vérifier que Beat envoie les tâches planifiées

---

## Support

En cas de problème:

1. **Worker ne se connecte pas à Redis:**

   - Vérifier `REDIS_URL` commence par `rediss://`
   - Vérifier `REQUIRE_REDIS_SSL=true`

2. **Worker ne se connecte pas à PostgreSQL:**

   - Utiliser l'**External Database URL** (pas l'interne)
   - Format: `postgresql://...@dpg-xxxxx-a.oregon-postgres.render.com:5432/...`

3. **Beat n'envoie pas de tâches:**
   - Vérifier les logs du Cron Job
   - Le schedule est bien configuré? (`*/15 * * * *`)
