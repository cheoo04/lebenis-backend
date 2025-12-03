# 📋 TODO - Lebenis Project

**Date**: 6 Novembre 2025  
**Status**: Phase 3 complète - Production Ready ✅

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
- [x] GPS Adaptatif (12 fichiers)
- [x] Géolocalisation Automatique (9 fichiers backend + 7 fichiers Flutter)

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

- [ ] Créer task cleanup GPS

  ```python
  # backend/apps/drivers/tasks.py
  @shared_task
  def cleanup_old_gps_data():
      from .gps_tracking_service import GPSTrackingService
      deleted_count = GPSTrackingService.cleanup_old_locations(days_to_keep=30)
      return f"Deleted {deleted_count} old location records"
  ```

- [ ] Planifier dans Celery Beat
  ```python
  # backend/config/celery.py
  app.conf.beat_schedule = {
      'cleanup-gps-daily': {
          'task': 'drivers.tasks.cleanup_old_gps_data',
          'schedule': crontab(hour=2, minute=0),  # 2h du matin
      },
  }
  ```

#### Sécurité

- [ ] Rate limiting
  ```bash
  pip install django-ratelimit
  ```
- [ ] Vérifier ALLOWED_HOSTS production

  ```python
  # config/settings/production.py
  ALLOWED_HOSTS = ['lebenis-backend.onrender.com', 'api.lebenis.com']
  ```

- [ ] Activer HTTPS strict
  ```python
  SECURE_SSL_REDIRECT = True
  SESSION_COOKIE_SECURE = True
  CSRF_COOKIE_SECURE = True
  ```

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

- [x] Permissions GPS vérifiées (voir `driver_app/GEOLOCATION_COMPLETE_SUMMARY.md`)

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

### 1. Intégration Widgets Géolocalisation dans Formulaires

**Priorité**: Haute (Déjà créés, à intégrer)
**Impact**: Calcul automatique distance et prix

- [ ] Intégrer `CommuneSelectorWidget` dans formulaire création livraison
- [ ] Intégrer `AddressGeocoderWidget` pour saisie adresse
- [ ] Intégrer `LocationPickerWidget` pour GPS actuel
- [ ] Tester le flux complet : sélection → création → vérification distance

**Voir** : `driver_app/GEOLOCATION_INTEGRATION_GUIDE.md`  
**Estimation**: 1 jour

---

### 2. Background GPS Service

**Priorité**: Moyenne  
**Impact**: Tracking continu même app fermée

- [ ] Package: `flutter_background_service`
- [ ] Service Android avec notification persistante

**Estimation**: 2-3 jours

---

### 3. Détection Batterie

**Priorité**: Basse  
**Impact**: Économie batterie intelligente

- [ ] Package: `battery_plus`
- [ ] Mode économie auto si < 20%

**Estimation**: 1 jour

---

### 4. Notifications Riches

**Priorité**: Basse  
**Impact**: UX améliorée

- [ ] Images dans notifications FCM
- [ ] Actions rapides (boutons "Accepter" / "Refuser")

**Estimation**: 2 jours

---

### 5. Offline Mode

**Priorité**: Moyenne  
**Impact**: Fonctionnement sans connexion

- [ ] Local database: `Hive` ou `Isar`
- [ ] Sync automatique et queue des requêtes
- [ ] Cache données critiques

**Estimation**: 5-7 jours

---

### 6. Geofencing

**Priorité**: Basse  
**Impact**: Notifications géolocalisées

- [ ] Package: `geofence_service`
- [ ] Zones de livraison avec alertes

**Estimation**: 3-4 jours

---

### 7. Analytics Temps Réel

**Priorité**: Basse  
**Impact**: Dashboard live

- [ ] WebSocket backend (Django Channels)
- [ ] Flutter WebSocket client

**Estimation**: 5-7 jours

---

## 📊 RÉSUMÉ DES PRIORITÉS

### IMMÉDIAT (Cette semaine)

1. ⭐ **URGENT** : Intégrer les widgets de géolocalisation dans les formulaires
   - Voir `driver_app/GEOLOCATION_INTEGRATION_GUIDE.md`
   - Temps estimé : 1 jour

### Avant Production (1-2 semaines)

1. ✅ Tests backend critiques
2. ✅ Permissions GPS vérifiées
3. ✅ Build release Android/iOS
4. ✅ Task Celery cleanup GPS

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
