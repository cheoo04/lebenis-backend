# 🔧 Guide de Configuration des Services - Lebenis

> Guide complet de configuration des services backend et frontend
> Date: 6 novembre 2025

---

## 📋 Table des Matières

1. [Backend - Services Django](#backend---services-django)
2. [Frontend - Services Flutter](#frontend---services-flutter)
3. [Services Tiers](#services-tiers)
4. [Variables d'Environnement](#variables-denvironnement)
5. [Checklist de Déploiement](#checklist-de-déploiement)

---

## 🐍 Backend - Services Django

### 1. Configuration de Base

#### **`.env` Backend (Production)**

```bash
# ============================================
# CONFIGURATION DJANGO
# ============================================
DEBUG=False
SECRET_KEY=votre-secret-key-super-securisee-production
DJANGO_SETTINGS_MODULE=config.settings.production
ALLOWED_HOSTS=lebenis.com,api.lebenis.com,www.lebenis.com

# ============================================
# BASE DE DONNÉES PostgreSQL
# ============================================
DB_ENGINE=django.db.backends.postgresql
DB_NAME=lebenis_db
DB_USER=lebenis_user
DB_PASSWORD=votre-mot-de-passe-securise
DB_HOST=localhost
DB_PORT=5432

# ============================================
# REDIS (Cache & Celery Broker)
# ============================================
REDIS_URL=redis://localhost:6379/0
CELERY_BROKER_URL=redis://localhost:6379/0
CELERY_RESULT_BACKEND=redis://localhost:6379/1

# ============================================
# EMAIL (SMTP Gmail)
# ============================================
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=noreply@lebenis.com
EMAIL_HOST_PASSWORD=votre-app-password-gmail
DEFAULT_FROM_EMAIL=Lebenis <noreply@lebenis.com>
SERVER_EMAIL=noreply@lebenis.com

# ============================================
# CLOUDINARY (Stockage Media)
# ============================================
CLOUDINARY_CLOUD_NAME=votre-cloud-name
CLOUDINARY_API_KEY=votre-api-key
CLOUDINARY_API_SECRET=votre-api-secret

# ============================================
# FIREBASE (FCM Push + Realtime DB)
# ============================================
FIREBASE_CREDENTIALS_PATH=/chemin/vers/firebase-service-account.json
FIREBASE_DATABASE_URL=https://lebenis-xxxxx.firebaseio.com
FIREBASE_STORAGE_BUCKET=lebenis-xxxxx.appspot.com

# ============================================
# MOBILE MONEY - ORANGE MONEY (Côte d'Ivoire)
# ============================================
ORANGE_MONEY_BASE_URL=https://api.orange.com/orange-money-webpay/dev/v1
ORANGE_MONEY_MERCHANT_KEY=votre-merchant-key
ORANGE_MONEY_API_KEY=votre-api-key
ORANGE_MONEY_SECRET_KEY=votre-secret-key
ORANGE_MONEY_RETURN_URL=https://api.lebenis.com/api/v1/payments/webhooks/orange-money/
ORANGE_MONEY_CANCEL_URL=https://lebenis.com/payment-cancelled
ORANGE_MONEY_NOTIFY_URL=https://api.lebenis.com/api/v1/payments/webhooks/orange-money/

# ============================================
# MOBILE MONEY - MTN MOMO (Côte d'Ivoire)
# ============================================
MTN_MOMO_BASE_URL=https://sandbox.momodeveloper.mtn.com
MTN_MOMO_API_USER=votre-api-user-uuid
MTN_MOMO_API_KEY=votre-api-key
MTN_MOMO_SUBSCRIPTION_KEY=votre-subscription-key
MTN_MOMO_CALLBACK_URL=https://api.lebenis.com/api/v1/payments/webhooks/mtn-momo/
MTN_MOMO_ENVIRONMENT=sandbox  # ou 'production'

# ============================================
# CORS & SÉCURITÉ
# ============================================
CORS_ALLOWED_ORIGINS=https://lebenis.com,https://www.lebenis.com
CSRF_TRUSTED_ORIGINS=https://lebenis.com,https://www.lebenis.com
SECURE_SSL_REDIRECT=True
SESSION_COOKIE_SECURE=True
CSRF_COOKIE_SECURE=True

# ============================================
# JWT TOKENS
# ============================================
JWT_ACCESS_TOKEN_LIFETIME=1  # heures
JWT_REFRESH_TOKEN_LIFETIME=7  # jours

# ============================================
# CELERY BEAT (Tâches Planifiées)
# ============================================
CELERY_BEAT_SCHEDULER=django_celery_beat.schedulers:DatabaseScheduler
CELERY_TIMEZONE=Africa/Abidjan

# ============================================
# LOGS & MONITORING
# ============================================
LOG_LEVEL=INFO
SENTRY_DSN=votre-sentry-dsn  # optionnel
```

---

### 2. Services à Installer

#### **PostgreSQL**

```bash
# Installation Ubuntu/Debian
sudo apt update
sudo apt install postgresql postgresql-contrib

# Créer la base de données
sudo -u postgres psql
CREATE DATABASE lebenis_db;
CREATE USER lebenis_user WITH PASSWORD 'votre-mot-de-passe';
ALTER ROLE lebenis_user SET client_encoding TO 'utf8';
ALTER ROLE lebenis_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE lebenis_user SET timezone TO 'Africa/Abidjan';
GRANT ALL PRIVILEGES ON DATABASE lebenis_db TO lebenis_user;
\q

# Vérifier la connexion
psql -U lebenis_user -d lebenis_db -h localhost
```

#### **Redis**

```bash
# Installation
sudo apt install redis-server

# Configuration (optionnel)
sudo nano /etc/redis/redis.conf
# Modifier: bind 127.0.0.1 ::1
# Modifier: requirepass votre-mot-de-passe-redis

# Démarrer Redis
sudo systemctl start redis-server
sudo systemctl enable redis-server

# Vérifier
redis-cli ping
# Réponse: PONG
```

#### **Celery + Celery Beat**

```bash
# Dans votre virtualenv
pip install celery[redis] django-celery-beat

# Créer les tables Celery Beat
python manage.py migrate django_celery_beat

# Lancer Celery Worker (terminal 1)
celery -A config worker -l info

# Lancer Celery Beat (terminal 2)
celery -A config beat -l info --scheduler django_celery_beat.schedulers:DatabaseScheduler

# Monitoring avec Flower (optionnel)
pip install flower
celery -A config flower
# Accès: http://localhost:5555
```

#### **Supervisor (Production - Gestion des processus)**

```bash
# Installation
sudo apt install supervisor

# Configuration Celery Worker
sudo nano /etc/supervisor/conf.d/lebenis_celery_worker.conf
```

```ini
[program:lebenis_celery_worker]
command=/chemin/vers/venv/bin/celery -A config worker -l info
directory=/chemin/vers/lebenis_project/backend
user=lebenis
numprocs=1
stdout_logfile=/var/log/celery/worker.log
stderr_logfile=/var/log/celery/worker.log
autostart=true
autorestart=true
startsecs=10
stopwaitsecs=600
priority=998
```

```bash
# Configuration Celery Beat
sudo nano /etc/supervisor/conf.d/lebenis_celery_beat.conf
```

```ini
[program:lebenis_celery_beat]
command=/chemin/vers/venv/bin/celery -A config beat -l info --scheduler django_celery_beat.schedulers:DatabaseScheduler
directory=/chemin/vers/lebenis_project/backend
user=lebenis
numprocs=1
stdout_logfile=/var/log/celery/beat.log
stderr_logfile=/var/log/celery/beat.log
autostart=true
autorestart=true
startsecs=10
priority=999
```

```bash
# Créer les dossiers de logs
sudo mkdir -p /var/log/celery
sudo chown lebenis:lebenis /var/log/celery

# Recharger Supervisor
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl status
```

---

### 3. Configuration Firebase

#### **Télécharger le Service Account**

1. Aller sur [Firebase Console](https://console.firebase.google.com/)
2. Sélectionner votre projet `lebenis`
3. Paramètres du projet → Comptes de service
4. Cliquer "Générer une nouvelle clé privée"
5. Télécharger `firebase-service-account.json`

```bash
# Placer le fichier
mkdir -p /home/lebenis/secrets
mv firebase-service-account.json /home/lebenis/secrets/
chmod 600 /home/lebenis/secrets/firebase-service-account.json

# Dans .env
FIREBASE_CREDENTIALS_PATH=/home/lebenis/secrets/firebase-service-account.json
```

#### **Activer Firebase Services**

Dans Firebase Console :
- ✅ **Realtime Database** : Activé (mode Production)
- ✅ **Cloud Messaging (FCM)** : Activé
- ✅ **Storage** : Activé

**Règles Realtime Database** :
```json
{
  "rules": {
    "chat_rooms": {
      "$roomId": {
        ".read": "auth != null && (data.child('participants').child(auth.uid).exists() || root.child('users').child(auth.uid).child('user_type').val() == 'admin')",
        ".write": "auth != null && (data.child('participants').child(auth.uid).exists() || root.child('users').child(auth.uid).child('user_type').val() == 'admin')",
        "messages": {
          ".indexOn": ["createdAt", "isRead"]
        },
        "typing_indicators": {
          ".read": true,
          ".write": "auth != null"
        }
      }
    }
  }
}
```

---

### 4. Configuration Cloudinary

1. Créer un compte sur [Cloudinary](https://cloudinary.com/)
2. Tableau de bord → Copier les credentials

```bash
# Dans .env
CLOUDINARY_CLOUD_NAME=lebenis-ci
CLOUDINARY_API_KEY=123456789012345
CLOUDINARY_API_SECRET=abcdefghijklmnopqrstuvwxyz123456
```

**Dossiers Upload Presets** :
- `chat_images` : Images de chat
- `driver_photos` : Photos profil drivers
- `delivery_photos` : Photos de livraison
- `signatures` : Signatures
- `documents` : Documents (permis, CNI, etc.)

---

### 5. Configuration Mobile Money

#### **Orange Money CI**

1. S'inscrire sur [Orange Developer](https://developer.orange.com/)
2. Créer une application "Orange Money Web Payment"
3. Récupérer les credentials

```bash
ORANGE_MONEY_MERCHANT_KEY=OMxxxxxxxxxxxxx
ORANGE_MONEY_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
ORANGE_MONEY_SECRET_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**Test Sandbox** :
```python
# Numéros de test CI
TEST_PHONE = "+2250757000001"  # Succès
TEST_PHONE_FAIL = "+2250757000002"  # Échec
```

#### **MTN Mobile Money CI**

1. S'inscrire sur [MTN MoMo Developer Portal](https://momodeveloper.mtn.com/)
2. Créer un compte API dans le sandbox
3. Générer API User et API Key

```bash
MTN_MOMO_API_USER=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
MTN_MOMO_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
MTN_MOMO_SUBSCRIPTION_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**Test Sandbox** :
```python
# Numéro de test CI
TEST_PHONE = "+2250746000001"
```

---

### 6. Tâches Celery à Configurer

```python
# backend/config/celery.py - Tâches planifiées

from celery.schedules import crontab

app.conf.beat_schedule = {
    # Versements automatiques quotidiens à 23h59
    'process-daily-payouts': {
        'task': 'apps.payments.tasks.process_daily_payouts',
        'schedule': crontab(hour=23, minute=59),
    },
    
    # Nettoyage codes de réinitialisation expirés (chaque heure)
    'cleanup-expired-reset-codes': {
        'task': 'apps.authentication.tasks.cleanup_expired_codes',
        'schedule': crontab(minute=0),  # Toutes les heures
    },
    
    # Génération factures mensuelles marchands (1er du mois à 00h00)
    'generate-monthly-invoices': {
        'task': 'apps.payments.tasks.generate_monthly_invoices',
        'schedule': crontab(day_of_month=1, hour=0, minute=0),
    },
    
    # Rappels factures impayées (tous les jours à 10h00)
    'send-invoice-reminders': {
        'task': 'apps.payments.tasks.send_invoice_reminders',
        'schedule': crontab(hour=10, minute=0),
    },
    
    # Nettoyage anciennes notifications (chaque dimanche à 02h00)
    'cleanup-old-notifications': {
        'task': 'apps.notifications.tasks.cleanup_old_notifications',
        'schedule': crontab(day_of_week=0, hour=2, minute=0),
    },
}
```

---

## 📱 Frontend - Services Flutter

### 1. Configuration Firebase

#### **Fichiers de Configuration**

```bash
# Android
driver_app/android/app/google-services.json

# iOS
driver_app/ios/Runner/GoogleService-Info.plist

# Web
driver_app/web/firebase-config.js
```

**Télécharger les fichiers** :
1. Firebase Console → Paramètres projet
2. Ajouter une application Android/iOS/Web
3. Télécharger les fichiers de configuration
4. Placer dans les dossiers appropriés

#### **`pubspec.yaml` - Packages Firebase**

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase Core
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3  # FCM Push Notifications
  firebase_database: ^11.1.4   # Realtime Database
  
  # State Management
  flutter_riverpod: ^2.6.1
  
  # Networking
  dio: ^5.7.0
  
  # Storage
  flutter_secure_storage: ^9.2.2
  shared_preferences: ^2.3.2
  
  # Location & GPS
  geolocator: ^13.0.1
  google_maps_flutter: ^2.9.0
  battery_plus: ^7.0.0  # Battery optimization
  
  # Media
  image_picker: ^1.1.2
  cached_network_image: ^3.4.1
  
  # Charts & Analytics
  fl_chart: ^0.69.0
  
  # PDF
  pdf: ^3.11.1
  printing: ^5.13.2
  path_provider: ^2.1.4
  
  # Utils
  intl: ^0.19.0
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  
dev_dependencies:
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
```

#### **Initialisation Firebase** (`main.dart`)

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Handler pour messages en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📬 Message en arrière-plan: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp();
  
  // Configurer FCM background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

---

### 2. Variables d'Environnement Flutter

Créer `driver_app/lib/core/config/app_config.dart` :

```dart
class AppConfig {
  // API Backend
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
  
  static const String apiVersion = 'v1';
  static const String apiBaseUrl = '$baseUrl/api/$apiVersion';
  
  // Cloudinary
  static const String cloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'lebenis-ci',
  );
  
  static const String cloudinaryUploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'driver_app',
  );
  
  // Firebase
  static const String firebaseDatabaseUrl = String.fromEnvironment(
    'FIREBASE_DATABASE_URL',
    defaultValue: 'https://lebenis-xxxxx.firebaseio.com',
  );
  
  // Google Maps
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'YOUR_API_KEY',
  );
  
  // App Info
  static const String appName = 'Lebenis Driver';
  static const String appVersion = '1.0.0';
  
  // Features Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = false;
  static const bool enablePushNotifications = true;
  
  // Cache
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 50 * 1024 * 1024; // 50 MB
  
  // GPS
  static const Duration gpsUpdateIntervalAvailable = Duration(seconds: 300);  // 5 min
  static const Duration gpsUpdateIntervalBusy = Duration(seconds: 30);        // 30 sec
  static const Duration gpsUpdateIntervalOnBreak = Duration(seconds: 600);    // 10 min
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 5);
}
```

---

### 3. Configuration Android

#### **`android/app/build.gradle`**

```gradle
android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        
        // Permissions
        manifestPlaceholders = [
            GOOGLE_MAPS_API_KEY: project.hasProperty('GOOGLE_MAPS_API_KEY') 
                ? project.property('GOOGLE_MAPS_API_KEY') 
                : ''
        ]
    }
}

dependencies {
    // Firebase
    implementation platform('com.google.firebase:firebase-bom:33.5.1')
    implementation 'com.google.firebase:firebase-messaging'
    implementation 'com.google.firebase:firebase-database'
}
```

#### **`android/app/src/main/AndroidManifest.xml`**

```xml
<manifest>
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    
    <application>
        <!-- Google Maps API Key -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="${GOOGLE_MAPS_API_KEY}" />
        
        <!-- FCM Default Channel -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="high_importance_channel" />
    </application>
</manifest>
```

---

### 4. Configuration iOS

#### **`ios/Runner/Info.plist`**

```xml
<dict>
    <!-- Location -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Nous avons besoin de votre localisation pour assigner les livraisons</string>
    
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>Nous suivons votre position pour optimiser les livraisons</string>
    
    <key>NSLocationAlwaysUsageDescription</key>
    <string>Le tracking en arrière-plan permet aux clients de suivre leur livraison</string>
    
    <!-- Camera & Photos -->
    <key>NSCameraUsageDescription</key>
    <string>Prendre des photos de livraison</string>
    
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Sélectionner des photos de livraison</string>
    
    <!-- Firebase -->
    <key>FirebaseAppDelegateProxyEnabled</key>
    <false/>
</dict>
```

---

## 🌐 Services Tiers

### 1. Google Maps API

1. [Google Cloud Console](https://console.cloud.google.com/)
2. Activer APIs :
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API
   - Directions API
   - Distance Matrix API
3. Créer une clé API avec restrictions

### 2. Sentry (Monitoring - Optionnel)

```bash
# Backend
pip install sentry-sdk

# settings/production.py
import sentry_sdk
sentry_sdk.init(
    dsn="votre-sentry-dsn",
    traces_sample_rate=1.0,
)
```

```yaml
# Flutter
dependencies:
  sentry_flutter: ^8.9.0
```

---

## 📝 Variables d'Environnement Complètes

### Backend `.env` (Template)

```bash
# Django
DEBUG=False
SECRET_KEY=
DJANGO_SETTINGS_MODULE=config.settings.production
ALLOWED_HOSTS=

# Database
DB_ENGINE=django.db.backends.postgresql
DB_NAME=
DB_USER=
DB_PASSWORD=
DB_HOST=
DB_PORT=5432

# Redis
REDIS_URL=
CELERY_BROKER_URL=
CELERY_RESULT_BACKEND=

# Email
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=
EMAIL_HOST_PASSWORD=
DEFAULT_FROM_EMAIL=
SERVER_EMAIL=

# Cloudinary
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=

# Firebase
FIREBASE_CREDENTIALS_PATH=
FIREBASE_DATABASE_URL=
FIREBASE_STORAGE_BUCKET=

# Orange Money
ORANGE_MONEY_BASE_URL=
ORANGE_MONEY_MERCHANT_KEY=
ORANGE_MONEY_API_KEY=
ORANGE_MONEY_SECRET_KEY=
ORANGE_MONEY_RETURN_URL=
ORANGE_MONEY_CANCEL_URL=
ORANGE_MONEY_NOTIFY_URL=

# MTN MoMo
MTN_MOMO_BASE_URL=
MTN_MOMO_API_USER=
MTN_MOMO_API_KEY=
MTN_MOMO_SUBSCRIPTION_KEY=
MTN_MOMO_CALLBACK_URL=
MTN_MOMO_ENVIRONMENT=

# CORS
CORS_ALLOWED_ORIGINS=
CSRF_TRUSTED_ORIGINS=

# JWT
JWT_ACCESS_TOKEN_LIFETIME=1
JWT_REFRESH_TOKEN_LIFETIME=7

# Celery
CELERY_TIMEZONE=Africa/Abidjan

# Monitoring
LOG_LEVEL=INFO
SENTRY_DSN=
```

### Frontend `--dart-define` (Build)

```bash
flutter build apk \
  --dart-define=API_BASE_URL=https://api.lebenis.com \
  --dart-define=CLOUDINARY_CLOUD_NAME=lebenis-ci \
  --dart-define=CLOUDINARY_UPLOAD_PRESET=driver_app \
  --dart-define=FIREBASE_DATABASE_URL=https://lebenis-xxxxx.firebaseio.com \
  --dart-define=GOOGLE_MAPS_API_KEY=AIzaSy... \
  --release
```

---

## ✅ Checklist de Déploiement

### Backend

- [ ] PostgreSQL installé et configuré
- [ ] Redis installé et démarré
- [ ] Celery Worker + Beat configurés (Supervisor)
- [ ] Firebase Service Account téléchargé
- [ ] Cloudinary credentials configurés
- [ ] Orange Money credentials (production)
- [ ] MTN MoMo credentials (production)
- [ ] Email SMTP configuré (Gmail App Password)
- [ ] Migrations appliquées
- [ ] Fichiers statiques collectés
- [ ] HTTPS/SSL configuré (Nginx + Certbot)
- [ ] Logs configurés
- [ ] Backup automatique DB configuré

### Frontend

- [ ] Firebase `google-services.json` ajouté (Android)
- [ ] Firebase `GoogleService-Info.plist` ajouté (iOS)
- [ ] Google Maps API key configurée
- [ ] Permissions Android/iOS ajoutées
- [ ] Build release testé
- [ ] Signing keys configurés
- [ ] App uploadée sur Play Store / App Store
- [ ] Deep links configurés
- [ ] Crashlytics configuré (optionnel)

### Tests

- [ ] Tests API endpoints
- [ ] Tests paiements Mobile Money
- [ ] Tests notifications push
- [ ] Tests GPS tracking
- [ ] Tests chat temps réel
- [ ] Tests génération PDF
- [ ] Tests versements automatiques
- [ ] Tests performance (load testing)

---

## 🆘 Support & Ressources

- **Documentation Django**: https://docs.djangoproject.com/
- **Documentation Flutter**: https://flutter.dev/docs
- **Firebase Console**: https://console.firebase.google.com/
- **Cloudinary Docs**: https://cloudinary.com/documentation
- **Orange Money Dev**: https://developer.orange.com/
- **MTN MoMo Dev**: https://momodeveloper.mtn.com/

---

**Date de dernière mise à jour**: 6 novembre 2025
**Version du guide**: 1.0.0
