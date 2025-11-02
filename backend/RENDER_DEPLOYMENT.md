# 🚀 Guide de Déploiement Render.com - LeBeni's Backend

## ✅ Fichiers préparés

- ✅ `.env.production` - Configuration production
- ✅ `build.sh` - Script de build automatique
- ✅ `requirements.txt` - Dépendances mises à jour
- ✅ `config/settings/production.py` - Settings production

---

## 📋 Étapes de Déploiement

### 1️⃣ Créer un compte Render.com

1. Va sur **https://render.com**
2. Clique sur **"Get Started"**
3. Connecte-toi avec **GitHub** (recommandé)

### 2️⃣ Pousser le code sur GitHub

Si ce n'est pas déjà fait :

```bash
cd /home/cheoo/lebenis_project
git init
git add .
git commit -m "Backend LeBeni's - Production ready"

# Créer un repo sur GitHub puis :
git remote add origin https://github.com/TON_USERNAME/lebenis-backend.git
git branch -M main
git push -u origin main
```

**IMPORTANT :** Ajoute `.env` au `.gitignore` (ne jamais commit les secrets !)

```bash
echo ".env" >> backend/.gitignore
echo ".env.production" >> backend/.gitignore
```

### 3️⃣ Créer le Web Service sur Render

1. **Dashboard Render** → Clique sur **"New +"** → **"Web Service"**

2. **Connect Repository** :
   - Connecte ton compte GitHub
   - Sélectionne le repo `lebenis-backend`
   - Clique **"Connect"**

3. **Configuration du service** :

| Paramètre | Valeur |
|-----------|--------|
| **Name** | `lebenis-backend` |
| **Region** | `Frankfurt (EU Central)` (ou Oregon si pas dispo) |
| **Branch** | `main` |
| **Root Directory** | `backend` |
| **Runtime** | `Python 3` |
| **Build Command** | `./build.sh` |
| **Start Command** | `gunicorn config.wsgi:application --bind 0.0.0.0:$PORT` |
| **Plan** | **Free** (0€/mois) |

4. **Variables d'environnement** :

Clique sur **"Advanced"** → **"Add Environment Variable"**

Copie-colle TOUTES ces variables depuis `.env.production` :

```
SECRET_KEY=zfs3n@rp34h(th7j(6l71!0gron^ukm5q1y26aq0=n6$p57)&y
DEBUG=False
ENVIRONMENT=production
DATABASE_URL=postgresql://neondb_owner:npg_dQZoSOym7Mk9@ep-old-unit-ahmi4lzb-pooler.c-3.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require
OPENROUTESERVICE_API_KEY=eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjUyODQzNWQzODRmOTRiNWViN2EyZTM2MTA2NDdhYzQ5IiwiaCI6Im11cm11cjY0In0=
SENTRY_DSN=https://b149ba662541dc3c616720cd33ba510d@o4510230370516992.ingest.de.sentry.io/4510292488618064
FIREBASE_CREDENTIALS_PATH=config/firebase/service-account.json
PYTHON_VERSION=3.12.0
```

**IMPORTANT :** Pour `ALLOWED_HOSTS` et `CORS_ALLOWED_ORIGINS`, attends d'avoir l'URL Render (étape suivante).

5. **Créer le service** :
   - Clique sur **"Create Web Service"**
   - Render va commencer le déploiement (5-10 min)

### 4️⃣ Récupérer l'URL et finaliser

1. Une fois déployé, tu auras une URL comme :
   ```
   https://lebenis-backend.onrender.com
   ```

2. **Ajoute cette URL** dans les variables d'environnement :

```
ALLOWED_HOSTS=lebenis-backend.onrender.com
CORS_ALLOWED_ORIGINS=https://lebenis-backend.onrender.com
```

3. **Redéploie** : Render va automatiquement redéployer.

### 5️⃣ Uploader le fichier Firebase

**Option A : Utiliser Render Dashboard**
1. Dashboard → Ton service → **"Shell"**
2. Upload `service-account.json` via l'interface

**Option B : Encode en Base64** (recommandé)

```bash
# Sur ton ordinateur
cd /home/cheoo/lebenis_project/backend/config/firebase
cat service-account.json | base64 -w 0 > service-account-base64.txt
```

Puis dans `config/settings/production.py`, décode :

```python
import base64
import json
import os

FIREBASE_CREDENTIALS_BASE64 = config('FIREBASE_CREDENTIALS_BASE64', default='')
if FIREBASE_CREDENTIALS_BASE64:
    credentials_json = base64.b64decode(FIREBASE_CREDENTIALS_BASE64)
    # Utiliser ces credentials
```

---

## ✅ Vérification du déploiement

1. **Healthcheck** :
   ```bash
   curl https://lebenis-backend.onrender.com/health/
   ```
   
   Doit retourner :
   ```json
   {"status": "healthy", "database": "connected"}
   ```

2. **Swagger** :
   ```
   https://lebenis-backend.onrender.com/swagger/
   ```

3. **Test login** :
   ```bash
   curl -X POST https://lebenis-backend.onrender.com/api/v1/auth/register/ \
     -H "Content-Type: application/json" \
     -d '{
       "email": "test@test.com",
       "password": "test123456",
       "user_type": "merchant",
       "full_name": "Test User"
     }'
   ```

---

## 🎯 Après le déploiement

### Mettre à jour les apps Flutter

Dans tes apps Flutter, change l'URL de base :

```dart
// Avant (dev)
const String baseUrl = 'http://localhost:8000';

// Après (production)
const String baseUrl = 'https://lebenis-backend.onrender.com';
```

### Créer un super utilisateur

Via Render Shell :

```bash
python manage.py createsuperuser
```

Puis accède à l'admin :
```
https://lebenis-backend.onrender.com/admin/
```

---

## ⚠️ Limitations Plan Gratuit Render

- ✅ 750 heures/mois (suffisant)
- ⚠️ Service s'endort après 15 min d'inactivité
- ⚠️ Redémarre en ~30 secondes à la prochaine requête
- ✅ PostgreSQL Neon gratuit (512 MB)
- ✅ SSL/HTTPS automatique

**Solution si problème :** Upgrade vers plan payant (7$/mois) pour service toujours actif.

---

## 🆘 Troubleshooting

### Build échoue

**Problème :** `ModuleNotFoundError`

**Solution :**
```bash
# Vérifier requirements.txt contient tous les packages
pip freeze > requirements.txt
git add requirements.txt
git commit -m "Update requirements"
git push
```

### Database connection failed

**Problème :** `could not connect to server`

**Solution :** Vérifie `DATABASE_URL` dans les variables d'environnement Render.

### Static files 404

**Problème :** CSS/JS admin ne charge pas

**Solution :** Vérifie que `build.sh` exécute `collectstatic`.

### CORS errors

**Problème :** `Access-Control-Allow-Origin`

**Solution :** Ajoute l'URL Flutter dans `CORS_ALLOWED_ORIGINS`.

---

## 📊 Monitoring

- **Logs Render** : Dashboard → Logs (temps réel)
- **Sentry** : https://sentry.io/issues/ (erreurs)
- **Uptime monitoring** : Ajoute sur UptimeRobot.com (gratuit)

---

## 🎉 C'est tout !

Ton backend sera accessible 24/7 sur :
```
https://lebenis-backend.onrender.com
```

Temps total : **15-30 minutes** ⏱️

**Prochaine étape :** Développer les apps Flutter avec cette URL ! 🚀
