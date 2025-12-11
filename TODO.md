# 📋 TODO - Lebenis Project

**Date**: 11 Décembre 2025  
**Status**: Phase 5 - Optimisations & Améliorations 🔧

---

## 🔴 HAUTE PRIORITÉ - À FAIRE IMMÉDIATEMENT

### 1. Index Base de Données (COMPLÉTÉ ✅)

- [x] Ajouter index sur `Delivery.status + created_at`
- [x] Ajouter index sur `Delivery.driver + status`
- [x] Ajouter index sur `Delivery.merchant + status`
- [x] Ajouter index sur `Delivery.pickup_commune`
- [x] Ajouter index sur `Delivery.delivery_commune`
- [x] Ajouter index sur `Delivery.created_by + status`
- [x] Ajouter index sur `Delivery.tracking_number`
- [x] Créer migration `0015_add_delivery_indexes.py`
- [ ] **Exécuter migration en production** : `python manage.py migrate deliveries`

### 2. Sécurité Mobile Money (COMPLÉTÉ ✅)

- [x] Implémenter validation signature HMAC-SHA256 Orange Money
- [x] Implémenter whitelist IP MTN MoMo
- [x] Ajouter logging sécurité pour webhooks
- [ ] **Tester webhooks en production** avec vraies transactions

### 3. Tests Unitaires Backend (EN COURS 🔄)

- [ ] Tests modèles critiques
  - [ ] `test_delivery_model.py` - Création, transitions statut, PIN
  - [ ] `test_payment_model.py` - Calcul commission, création earning
  - [ ] `test_driver_model.py` - Disponibilité, vérification, zones
- [ ] Tests API endpoints critiques
  - [ ] `test_delivery_flow.py` - Flow complet pending → delivered
  - [ ] `test_payment_endpoints.py` - /my-earnings/, /transaction-history/
  - [ ] `test_webhook_security.py` - Validation signatures Orange/MTN
- [ ] Tests services
  - [ ] `test_assignment_service.py` - Assignation auto/manuelle
  - [ ] `test_mobile_money_services.py` - Orange/MTN/Wave
  - [ ] `test_notification_service.py` - FCM, emails

**Objectif**: Coverage > 70%

```bash
cd backend
pytest --cov=apps --cov-report=html
open htmlcov/index.html
```

### 4. Gestion Exceptions (À FAIRE ⏳)

- [ ] Remplacer `except Exception` génériques dans `deliveries/views.py`
  - [ ] Ligne ~225: ValidationError spécifique
  - [ ] Ligne ~315: ObjectDoesNotExist
  - [ ] Ligne ~462: PermissionDenied
- [ ] Ajouter `exc_info=True` à tous les `logger.error()`
- [ ] Créer exceptions custom pour le domaine
  - [ ] `DeliveryAssignmentError`
  - [ ] `PaymentProcessingError`
  - [ ] `WebhookValidationError`

---

## 🟡 MOYENNE PRIORITÉ - Court Terme (1-2 semaines)

### 5. Structure Flutter - Consolidation (ANALYSÉ ✅)

> **Note**: `features/delivery/` contient GPS providers/widgets, `features/deliveries/` contient les écrans.
> Ces modules sont distincts par fonction → **Pas de fusion nécessaire**, architecture correcte.

- [x] Analyser la structure `features/delivery/` vs `features/deliveries/`
- [x] Confirmer que la séparation est intentionnelle (GPS ≠ écrans de livraison)
- [x] Re-exports dans `core/providers/` sont nécessaires pour l'accès facile

### 6. Optimisation N+1 Queries (COMPLÉTÉ ✅)

- [x] Auditer toutes les vues avec `select_related`/`prefetch_related`
  - [x] `DeliveryViewSet.get_queryset()` - OK (merchant, driver)
  - [x] `DriverViewSet.list()` - OK (merchant, driver)
  - [x] `InvoiceViewSet.queryset` - Ajouté `select_related('merchant__user')`
  - [x] `DriverEarningViewSet.queryset` - Ajouté `select_related('driver__user', 'delivery')`
  - [x] `DriverPaymentViewSet.queryset` - Ajouté `select_related` + `prefetch_related`
  - [x] `ChatRoomViewSet.list()` - OK (driver, other_user, delivery)
- [ ] Utiliser Django Debug Toolbar en dev pour détecter N+1 (optionnel)

```bash
pip install django-debug-toolbar
# Ajouter dans INSTALLED_APPS (dev seulement)
```

### 7. Logs Structurés Production (COMPLÉTÉ ✅)

- [x] Configurer niveaux par app dans `LOGGING` (deliveries, payments, drivers, etc.)
- [x] Ajouter format JSON pour parsing (ELK/Datadog)
- [x] Ajouter filtre `require_debug_false`
- [x] Préparer configuration `RotatingFileHandler` (commentée, prête à activer)

```python
# config/settings/production.py - Loggers par application configurés:
# - apps.deliveries
# - apps.payments
# - apps.drivers
# - apps.notifications
# - apps.chat
```

### 8. Mise à jour dépendances Flutter (COMPLÉTÉ ✅)

- [x] Exécuter `flutter pub outdated` - Analysé
- [x] Mettre à jour packages critiques:
  - [x] `flutter_secure_storage: ^9.2.4` - Mise à jour mineure
  - [x] `device_info_plus: ^12.3.0` - Mise à jour
  - [x] `geolocator: ^14.0.2` - Déjà à jour
  - [x] `mobile_scanner: ^7.1.3` - Version stable gardée
  - [x] `firebase_*` - Versions compatibles confirmées
- [x] `flutter pub get` exécuté avec succès
- [ ] Tester après mise à jour (à faire manuellement)

> **Note**: Packages majeurs (freezed 3.x, flutter_map 8.x, flutter_secure_storage 10.x) 
> ont des breaking changes. Garder les versions actuelles pour éviter les régressions.

---

## 🟢 BASSE PRIORITÉ - Moyen Terme (COMPLÉTÉ ✅)

### 9. Deprecations Flutter 3.32+ (COMPLÉTÉ ✅)

- [x] Remplacer `withOpacity()` par `Color.withValues(alpha: ...)`
  - [x] **Déjà fait** - Le code utilise `.withValues(alpha:)` partout (35+ usages trouvés)
- [x] Mettre à jour Radio widgets
  - [x] **Non nécessaire** - Pas de Radio avec `groupValue` deprecated trouvés
- [x] `flutter analyze` - 71 issues (warnings mineurs, aucun deprecated_member_use critique)

> **Note**: Le code est déjà compatible Flutter 3.32+

### 10. Documentation API Swagger (OK ✅)

- [x] Swagger UI configuré sur `/swagger/`
- [x] ReDoc configuré sur `/redoc/`
- [x] Schema JSON sur `/swagger.json`
- [x] Tous les endpoints sont exposés via `drf-yasg`
- [ ] Ajouter exemples de requêtes/réponses (amélioration future)
- [ ] Documenter codes d'erreur (amélioration future)

### 11. Variables d'environnement (COMPLÉTÉ ✅)

- [x] `.env.example` complet créé avec toutes les variables:
  - [x] Django Settings (SECRET_KEY, DEBUG, ALLOWED_HOSTS)
  - [x] Database (DATABASE_URL)
  - [x] Cloudinary (CLOUD_NAME, API_KEY, API_SECRET)
  - [x] Firebase (CREDENTIALS_PATH, DATABASE_URL, FCM_SERVER_KEY)
  - [x] SendGrid (API_KEY, DEFAULT_FROM_EMAIL)
  - [x] Celery/Redis (REDIS_URL)
  - [x] Orange Money (CLIENT_ID, CLIENT_SECRET, MERCHANT_KEY, ENVIRONMENT)
  - [x] MTN MoMo (API_USER, API_KEY, SUBSCRIPTION_KEY, ENVIRONMENT)
  - [x] Sentry (DSN)
  - [x] CORS (ALLOWED_ORIGINS, FRONTEND_URL, BACKEND_URL)

### 12. Background GPS Service Flutter (COMPLÉTÉ ✅)

- [x] Service créé: `core/services/background_gps_service.dart`
  - [x] Singleton pattern
  - [x] Foreground notification config pour Android
  - [x] Stream de positions
  - [x] Envoi automatique au serveur
  - [x] Documentation des permissions requises
- [ ] Installer `flutter_background_service` (optionnel pour tracking app fermée)
- [ ] Tester sur différents appareils (Samsung, Xiaomi, etc.)

### 13. Offline Mode Flutter (COMPLÉTÉ ✅)

- [x] Service créé: `core/services/offline_service.dart`
  - [x] Queue des requêtes en attente
  - [x] Cache des livraisons actives
  - [x] Cache du profil driver
  - [x] Sync automatique à la reconnexion
  - [x] Helper `offlineAwareCall()` pour les appels API
- [x] Utilise `flutter_secure_storage` pour le stockage
- [ ] Évaluer Hive/Isar pour stockage plus performant (amélioration future)
- [ ] Ajouter `connectivity_plus` pour détection réseau automatique

---

## ✅ COMPLÉTÉ (100%)

### Phase 1 (100%)

- [x] Authentification JWT
- [x] Notifications Push FCM
- [x] Mobile Money - Profil Driver

### Phase 2 (100%)

- [x] Modèles de Paiement (Payment, DailyPayout, TransactionHistory)
- [x] Service Orange Money (Sandbox)
- [x] Celery - Paiements automatiques 23h59
- [x] API Endpoints Paiements (4 endpoints)
- [x] Système de Notation (rate-driver)

### Phase 3 (100%)

- [x] Chat Temps Réel (17 fichiers)
- [x] Cloudinary Upload (4 fichiers)
- [x] Push Notifications (2 fichiers)
- [x] Analytics Backend (8 endpoints)
- [x] Analytics Flutter (17 fichiers)
- [x] Rapports PDF (8 fichiers)
- [x] GPS Adaptatif & Géolocalisation (backend + Flutter 100%)

### Phase 4 - MERCHANT APP (100%) ⭐ NOUVEAU

- [x] Widgets de géolocalisation (commune_selector, models, repositories)
- [x] Formulaire création livraison COMPLET (tous les champs + GPS + estimation prix)
- [x] Liste des livraisons avec API (filtres status, pull-to-refresh, cards modernes)
- [x] Détail de livraison (toutes infos + boutons actions)
- [x] Tracking temps réel Google Maps (markers, polyline, auto-refresh 10s)
- [x] Édition profil merchant (formulaire complet avec sauvegarde)
- [x] Widgets UI modernes (stat_card, status_badge, info_card)
- [x] Dashboard moderne (gradient header, grid stats, quick actions)
- [x] Documentation complète (3 guides MD)

---

## 🔧 RECOMMANDÉ (Avant Production)

### Backend

#### Tests (Haute Priorité)

- [ ] Tests unitaires modèles
  - [ ] Test Payment model (calcul commission)
  - [ ] Test LocationUpdate model
  - [ ] Test DailyPayout model
- [ ] Tests API endpoints critiques
  - [ ] Test /payments/my-earnings/
  - [ ] Test /gps/update-location/
  - [ ] Test /analytics/overview/
  - [ ] Test /chat/send-message/
- [ ] Tests services
  - [ ] Test GPSTrackingService.get_tracking_interval()
  - [ ] Test OrangeMoneyService.initiate_payment()
  - [ ] Test PDFReportService.generate_analytics_report()

**Commande**:

```bash
cd backend
pytest apps/payments/tests/
pytest apps/drivers/tests/
pytest apps/deliveries/tests/
coverage run -m pytest
coverage report
```

#### Tâches Celery

- [x] Task cleanup GPS créée
- [x] Planifié dans Celery Beat (2h quotidien)
- [x] Task tracking statistics (6h quotidien)

#### Sécurité

- [x] Rate limiting configuré (1000/h anon, 5000/h auth)
- [x] ALLOWED_HOSTS production vérifié
- [x] HTTPS strict activé (SECURE_SSL_REDIRECT, cookies secure)
- [x] DEBUG = False en production
- [x] SECRET_KEY unique configuré
- [x] HSTS activé (1 an)
- [x] Sentry monitoring configuré (optionnel)

#### Monitoring (Optionnel)

- [ ] Configurer Sentry
  ```bash
  pip install sentry-sdk
  ```
- [ ] Logs structurés
  ```python
  LOGGING = {
      'version': 1,
      'handlers': {
          'file': {
              'level': 'INFO',
              'class': 'logging.handlers.RotatingFileHandler',
              'filename': 'logs/lebenis.log',
          },
      },
  }
  ```

---

### Flutter Driver App

#### Tests (Moyenne Priorité)

- [ ] Tests widgets principaux

  ```bash
  cd driver_app
  flutter test test/analytics_dashboard_test.dart
  flutter test test/chat_screen_test.dart
  flutter test test/gps_status_widget_test.dart
  ```

- [ ] Tests providers

  ```bash
  flutter test test/gps_provider_test.dart
  flutter test test/chat_provider_test.dart
  flutter test test/analytics_provider_test.dart
  ```

- [ ] Coverage report
  ```bash
  flutter test --coverage
  genhtml coverage/lcov.info -o coverage/html
  ```

#### Configuration & Build

- [x] Permissions GPS configurées (Android + iOS)

- [ ] Build release Android

  ```bash
  flutter build apk --release
  # Test APK: build/app/outputs/flutter-apk/app-release.apk
  ```

- [ ] Build release iOS
  ```bash
  flutter build ios --release
  # Ouvrir dans Xcode pour signature
  ```

#### Performance

- [ ] Analyse performance

  ```bash
  flutter analyze
  flutter build apk --analyze-size
  ```

- [ ] Profiling
  ```bash
  flutter run --profile
  # Ouvrir DevTools pour profiling
  ```

---

## 🚀 PHASE 4 (Fonctionnalités Avancées) - OPTIONNEL

### 1. Background GPS Service

**Priorité**: Moyenne  
**Impact**: Tracking continu même app fermée

- [ ] Package: `flutter_background_service`
- [ ] Service Android avec notification persistante

**Estimation**: 2-3 jours

---

### 2. Détection Batterie

**Priorité**: Basse  
**Impact**: Économie batterie intelligente

- [ ] Package: `battery_plus`
- [ ] Mode économie auto si < 20%

**Estimation**: 1 jour

---

### 3. Notifications Riches

**Priorité**: Basse  
**Impact**: UX améliorée

- [ ] Images dans notifications FCM
- [ ] Actions rapides (boutons "Accepter" / "Refuser")

**Estimation**: 2 jours

---

### 4. Offline Mode

**Priorité**: Moyenne  
**Impact**: Fonctionnement sans connexion

- [ ] Local database: `Hive` ou `Isar`
- [ ] Sync automatique et queue des requêtes
- [ ] Cache données critiques

**Estimation**: 5-7 jours

---

### 5. Geofencing

**Priorité**: Basse  
**Impact**: Notifications géolocalisées

- [ ] Package: `geofence_service`
- [ ] Zones de livraison avec alertes

**Estimation**: 3-4 jours

---

### 6. Analytics Temps Réel

**Priorité**: Basse  
**Impact**: Dashboard live

- [ ] WebSocket backend (Django Channels)
- [ ] Flutter WebSocket client

**Estimation**: 5-7 jours

---

## 📊 RÉSUMÉ DES PRIORITÉS

### Avant Production (1-2 semaines)

1. Tests backend critiques
2. Build release Android/iOS
3. Task Celery cleanup GPS
4. Tests Flutter

### Court Terme (1 mois)

1. Background GPS Service
2. Offline Mode
3. Tests complets

### Long Terme (2-3 mois)

1. Détection Batterie
2. Notifications Riches
3. Geofencing
4. Analytics Temps Réel

---

## ✅ CHECKLIST FINALE AVANT PRODUCTION

### Backend

- [ ] Tests unitaires (Coverage > 70%)
- [ ] Variables d'environnement production vérifiées
- [ ] HTTPS activé (SECURE_SSL_REDIRECT = True)
- [ ] ALLOWED_HOSTS configuré
- [ ] DEBUG = False
- [ ] SECRET_KEY unique en production
- [ ] Migrations appliquées
- [ ] Static files collectés
- [ ] Task Celery cleanup GPS planifiée
- [ ] Monitoring (Sentry) configuré

### Flutter

- [ ] Permissions GPS vérifiées (iOS + Android)
- [ ] Firebase configuré (FCM + Realtime DB)
- [ ] Build release testé
- [ ] Tests widgets (Coverage > 50%)
- [ ] Performance profiling
- [ ] Signatures de code configurées
- [ ] Version number mis à jour

### Déploiement

- [ ] Backend déployé sur Render.com
- [ ] Base de données production (PostgreSQL)
- [ ] Redis pour Celery
- [ ] Cloudinary configuré
- [ ] Firebase project production
- [ ] DNS configuré
- [ ] Certificats SSL actifs

---

**Dernière mise à jour**: 6 Novembre 2025  
**Status**: 🚀 **PRODUCTION READY** (avec recommandations)
