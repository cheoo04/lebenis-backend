# Guide de Structure des Applications Flutter LeBeni's

> **Date**: 3 novembre 2025  
> **Version**: 1.0.0

## 📱 Structure Optimale Recommandée

### **driver_app/** (App Livreur)

```
driver_app/
├── android/
│   ├── app/
│   │   ├── google-services.json          # ✅ AJOUTER - Firebase Android
│   │   └── src/main/AndroidManifest.xml  # ✅ MODIFIER - Permissions GPS + Notifications
│   └── ...
│
├── ios/
│   ├── Runner/
│   │   ├── GoogleService-Info.plist      # ✅ AJOUTER - Firebase iOS
│   │   └── Info.plist                    # ✅ MODIFIER - Permissions
│   └── ...
│
├── lib/
│   ├── config/                           # ✅ AJOUTER - Configuration
│   │   ├── env_config.dart               # Dev/Prod environments
│   │   └── app_config.dart               # Configuration globale
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart        # ✅ REMPLIR - URLs backend
│   │   │   ├── app_colors.dart           # ✅ REMPLIR - Palette couleurs
│   │   │   ├── app_strings.dart          # ✅ REMPLIR - Textes français
│   │   │   └── storage_keys.dart         # ✅ AJOUTER - Clés SecureStorage
│   │   │
│   │   ├── network/
│   │   │   ├── api_exception.dart        # ✅ REMPLIR - Gestion erreurs
│   │   │   └── dio_client.dart           # ✅ REMPLIR - Client HTTP
│   │   │
│   │   ├── routes/
│   │   │   └── app_router.dart           # ✅ REMPLIR - Navigation
│   │   │
│   │   ├── services/
│   │   │   ├── api_service.dart          # ❌ SUPPRIMER - Redondant avec repositories
│   │   │   ├── auth_service.dart         # ✅ REMPLIR - JWT storage
│   │   │   ├── location_service.dart     # ✅ REMPLIR - GPS tracking
│   │   │   └── notification_service.dart # ✅ REMPLIR - FCM
│   │   │
│   │   └── utils/
│   │       ├── formatters.dart           # ✅ REMPLIR - Date, prix, distance
│   │       ├── helpers.dart              # ✅ REMPLIR - Fonctions utiles
│   │       └── validators.dart           # ✅ REMPLIR - Validation forms
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── delivery_model.dart       # ✅ REMPLIR - Depuis API guide
│   │   │   ├── driver_model.dart         # ✅ REMPLIR - Depuis API guide
│   │   │   └── user_model.dart           # ✅ AJOUTER - User auth
│   │   │
│   │   ├── providers/                    # State Management
│   │   │   ├── auth_provider.dart        # ✅ REMPLIR - AuthNotifier
│   │   │   ├── delivery_provider.dart    # ✅ REMPLIR - DeliveryProvider
│   │   │   └── location_provider.dart    # ✅ AJOUTER - GPS state
│   │   │
│   │   └── repositories/
│   │       ├── auth_repository.dart      # ✅ REMPLIR - Login/Register
│   │       ├── delivery_repository.dart  # ✅ REMPLIR - CRUD livraisons
│   │       └── driver_repository.dart    # ✅ REMPLIR - Profil + disponibilité
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/                     # ❌ SUPPRIMER - Déjà dans /data
│   │   │   └── presentation/
│   │   │       ├── screens/              # ✅ AJOUTER
│   │   │       │   ├── login_screen.dart
│   │   │       │   ├── register_screen.dart
│   │   │       │   └── splash_screen.dart
│   │   │       └── widgets/              # ✅ AJOUTER
│   │   │           ├── login_form.dart
│   │   │           └── register_form.dart
│   │   │
│   │   ├── deliveries/
│   │   │   ├── data/                     # ❌ SUPPRIMER - Déjà dans /data
│   │   │   └── presentation/
│   │   │       ├── screens/              # ✅ AJOUTER
│   │   │       │   ├── delivery_list_screen.dart
│   │   │       │   ├── delivery_details_screen.dart
│   │   │       │   ├── active_delivery_screen.dart  # Avec map GPS
│   │   │       │   └── confirm_delivery_screen.dart # Signature + photo
│   │   │       └── widgets/              # ✅ AJOUTER
│   │   │           ├── delivery_card.dart
│   │   │           ├── status_badge.dart
│   │   │           └── delivery_map.dart
│   │   │
│   │   ├── earnings/
│   │   │   └── presentation/
│   │   │       ├── screens/              # ✅ AJOUTER
│   │   │       │   └── earnings_screen.dart
│   │   │       └── widgets/              # ✅ AJOUTER
│   │   │           ├── earnings_chart.dart
│   │   │           └── stats_card.dart
│   │   │
│   │   ├── profile/
│   │   │   └── presentation/             # ✅ AJOUTER
│   │   │       ├── screens/
│   │   │       │   ├── profile_screen.dart
│   │   │       │   └── edit_profile_screen.dart
│   │   │       └── widgets/
│   │   │           └── availability_toggle.dart
│   │   │
│   │   └── scanner/                      # Pour QR codes livraison
│   │       └── presentation/
│   │           └── screens/              # ✅ AJOUTER
│   │               └── qr_scanner_screen.dart
│   │
│   ├── l10n/                             # ✅ AJOUTER - Internationalisation
│   │   ├── app_fr.arb                    # Français (langue principale)
│   │   └── app_en.arb                    # Anglais (optionnel)
│   │
│   ├── theme/                            # ✅ AJOUTER - Thème personnalisé
│   │   ├── app_theme.dart                # ThemeData complet
│   │   ├── text_styles.dart              # Styles de texte
│   │   └── dimensions.dart               # Espacements, tailles
│   │
│   ├── shared/
│   │   └── widgets/
│   │       ├── custom_button.dart        # ✅ AJOUTER - Bouton réutilisable
│   │       ├── custom_textfield.dart     # ✅ AJOUTER - Input personnalisé
│   │       ├── error_widget.dart         # ✅ AJOUTER - Affichage erreurs
│   │       ├── loading_widget.dart       # ✅ AJOUTER - Indicateur chargement
│   │       ├── empty_state.dart          # ✅ AJOUTER - État vide
│   │       └── network_image_cached.dart # ✅ AJOUTER - Images optimisées
│   │
│   ├── firebase_options.dart             # ✅ AJOUTER - Généré par FlutterFire
│   └── main.dart                         # ✅ REMPLIR - Point d'entrée
│
├── assets/                               # ✅ AJOUTER - À la racine !
│   ├── fonts/                            # Polices personnalisées
│   │   └── Poppins-Regular.ttf
│   ├── icons/                            # Icônes SVG
│   │   ├── delivery.svg
│   │   ├── earnings.svg
│   │   └── profile.svg
│   └── images/                           # Images
│       ├── logo.png
│       ├── logo_white.png
│       └── placeholder_delivery.png
│
├── test/                                 # ✅ AJOUTER Tests
│   ├── unit/
│   │   ├── models/
│   │   │   └── delivery_model_test.dart
│   │   ├── repositories/
│   │   │   └── delivery_repository_test.dart
│   │   └── services/
│   │       └── auth_service_test.dart
│   ├── widget/
│   │   └── delivery_card_test.dart
│   └── integration/
│       └── login_flow_test.dart
│
├── .env.development                      # ✅ AJOUTER - Variables dev
├── .env.production                       # ✅ AJOUTER - Variables prod
├── analysis_options.yaml                 # ✅ MODIFIER - Linter strict
├── pubspec.yaml                          # ✅ REMPLIR - Dépendances
└── README.md                             # ✅ COMPLÉTER - Documentation
```

---

### **merchant_app/** (App Marchand)

```
merchant_app/
├── android/
│   └── app/
│       ├── google-services.json          # ✅ AJOUTER - Firebase Android
│       └── src/main/AndroidManifest.xml  # ✅ MODIFIER - Permissions
│
├── ios/
│   └── Runner/
│       ├── GoogleService-Info.plist      # ✅ AJOUTER - Firebase iOS
│       └── Info.plist                    # ✅ MODIFIER - Permissions
│
├── lib/
│   ├── config/                           # ✅ AJOUTER
│   │   ├── env_config.dart
│   │   └── app_config.dart
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart        # ✅ REMPLIR
│   │   │   ├── app_colors.dart           # ✅ REMPLIR
│   │   │   ├── app_strings.dart          # ✅ REMPLIR
│   │   │   └── storage_keys.dart         # ✅ AJOUTER
│   │   │
│   │   ├── network/
│   │   │   ├── api_exception.dart        # ✅ REMPLIR
│   │   │   ├── dio_client.dart           # ✅ REMPLIR
│   │   │   └── network_info.dart         # ✅ REMPLIR - Check connexion
│   │   │
│   │   ├── routes/
│   │   │   └── app_router.dart           # ✅ REMPLIR
│   │   │
│   │   ├── services/
│   │   │   ├── api_service.dart          # ❌ SUPPRIMER - Redondant
│   │   │   ├── auth_service.dart         # ✅ REMPLIR
│   │   │   ├── location_service.dart     # ✅ REMPLIR - Geocoding
│   │   │   ├── notification_service.dart # ✅ REMPLIR
│   │   │   └── upload_service.dart       # ✅ AJOUTER - Upload docs
│   │   │
│   │   └── utils/
│   │       ├── formatters.dart           # ✅ REMPLIR
│   │       ├── helpers.dart              # ✅ REMPLIR
│   │       └── validators.dart           # ✅ REMPLIR
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── delivery_model.dart       # ✅ REMPLIR
│   │   │   ├── merchant_model.dart       # ✅ REMPLIR
│   │   │   ├── pricing_estimate.dart     # ✅ REMPLIR (DÉJÀ CRÉÉ !)
│   │   │   └── user_model.dart           # ✅ AJOUTER
│   │   │
│   │   ├── providers/
│   │   │   ├── auth_provider.dart        # ✅ REMPLIR
│   │   │   ├── delivery_provider.dart    # ✅ REMPLIR
│   │   │   └── merchant_provider.dart    # ✅ REMPLIR
│   │   │
│   │   └── repositories/
│   │       ├── auth_repository.dart      # ✅ REMPLIR
│   │       ├── delivery_repository.dart  # ✅ REMPLIR
│   │       └── merchant_repository.dart  # ✅ REMPLIR
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/                     # ❌ SUPPRIMER
│   │   │   └── presentation/
│   │   │       ├── screens/              # ✅ AJOUTER
│   │   │       │   ├── login_screen.dart
│   │   │       │   ├── register_screen.dart
│   │   │       │   └── splash_screen.dart
│   │   │       └── widgets/              # ✅ AJOUTER
│   │   │           ├── login_form.dart
│   │   │           └── register_form.dart
│   │   │
│   │   ├── dashboard/
│   │   │   └── presentation/
│   │   │       ├── screens/              # ✅ AJOUTER
│   │   │       │   └── dashboard_screen.dart  # Navigation principale
│   │   │       └── widgets/              # ✅ AJOUTER
│   │   │           ├── stats_overview.dart
│   │   │           └── quick_actions.dart
│   │   │
│   │   ├── deliveries/
│   │   │   ├── data/                     # ❌ SUPPRIMER
│   │   │   └── presentation/
│   │   │       ├── screens/              # ✅ AJOUTER
│   │   │       │   ├── create_delivery_screen.dart  # PRIORITÉ !
│   │   │       │   ├── delivery_list_screen.dart
│   │   │       │   ├── delivery_details_screen.dart
│   │   │       │   └── track_delivery_screen.dart   # Map tracking
│   │   │       └── widgets/              # ✅ AJOUTER
│   │   │           ├── delivery_card.dart
│   │   │           ├── price_estimator.dart
│   │   │           ├── address_picker.dart
│   │   │           └── status_timeline.dart
│   │   │
│   │   └── profile/
│   │       └── presentation/
│   │           ├── screens/              # ✅ AJOUTER
│   │           │   ├── profile_screen.dart
│   │           │   └── edit_profile_screen.dart
│   │           └── widgets/              # ✅ AJOUTER
│   │               └── verification_status.dart
│   │
│   ├── l10n/                             # ✅ AJOUTER
│   │   ├── app_fr.arb
│   │   └── app_en.arb
│   │
│   ├── theme/                            # ✅ AJOUTER
│   │   ├── app_theme.dart
│   │   ├── text_styles.dart
│   │   └── dimensions.dart
│   │
│   ├── shared/
│   │   └── widgets/
│   │       ├── custom_button.dart        # ✅ REMPLIR
│   │       ├── custom_textfield.dart     # ✅ REMPLIR
│   │       ├── error_widget.dart         # ✅ REMPLIR
│   │       ├── loading_widget.dart       # ✅ REMPLIR
│   │       ├── empty_state.dart          # ✅ AJOUTER
│   │       └── commune_dropdown.dart     # ✅ AJOUTER - Sélection commune
│   │
│   ├── firebase_options.dart             # ✅ AJOUTER
│   └── main.dart                         # ✅ REMPLIR
│
├── assets/                               # ⚠️ DÉPLACER de lib/ vers racine !
│   ├── fonts/
│   │   └── Poppins-Regular.ttf
│   ├── icons/
│   │   ├── delivery.svg
│   │   ├── tracking.svg
│   │   └── profile.svg
│   └── images/
│       ├── logo.png
│       ├── logo_white.png
│       ├── onboarding_1.png
│       └── placeholder_map.png
│
├── test/                                 # ✅ AJOUTER Tests
│   ├── unit/
│   │   └── repositories/
│   │       └── delivery_repository_test.dart
│   ├── widget/
│   │   └── delivery_card_test.dart
│   └── integration/
│       └── create_delivery_flow_test.dart
│
├── .env.development                      # ✅ AJOUTER
├── .env.production                       # ✅ AJOUTER
├── analysis_options.yaml                 # ✅ MODIFIER
├── pubspec.yaml                          # ✅ REMPLIR
└── README.md                             # ✅ COMPLÉTER
```

---

## 📋 Checklist d'Actions

### **1️⃣ Suppressions** (Fichiers/Dossiers redondants)

```bash
# ❌ SUPPRIMER ces dossiers vides redondants

# driver_app
rm -rf driver_app/lib/features/auth/data
rm -rf driver_app/lib/features/deliveries/data
rm driver_app/lib/core/services/api_service.dart

# merchant_app
rm -rf merchant_app/lib/features/auth/data
rm -rf merchant_app/lib/features/deliveries/data
rm merchant_app/lib/core/services/api_service.dart
```

**Raison** : Les `data/` sont déjà centralisés dans `lib/data/`. `api_service.dart` fait doublon avec les repositories.

---

### **2️⃣ Déplacements** (Corrections de structure)

```bash
# ⚠️ DÉPLACER assets hors de lib/ dans merchant_app
mv merchant_app/lib/assets merchant_app/assets
```

---

### **3️⃣ Ajouts** (Fichiers critiques manquants)

#### **A. Configuration**

```bash
# Créer dossiers config
mkdir -p driver_app/lib/config
mkdir -p merchant_app/lib/config

# Créer fichiers environnement
touch driver_app/.env.development
touch driver_app/.env.production
touch merchant_app/.env.development
touch merchant_app/.env.production
```

#### **B. Thème & Internationalisation**

```bash
# Thème
mkdir -p driver_app/lib/theme
mkdir -p merchant_app/lib/theme

# i18n
mkdir -p driver_app/lib/l10n
mkdir -p merchant_app/lib/l10n
```

#### **C. Assets à la racine**

```bash
# Créer structure assets
mkdir -p driver_app/assets/{fonts,icons,images}
mkdir -p merchant_app/assets/{fonts,icons,images}
```

#### **D. Écrans (presentation/screens)**

```bash
# driver_app
mkdir -p driver_app/lib/features/auth/presentation/{screens,widgets}
mkdir -p driver_app/lib/features/deliveries/presentation/{screens,widgets}
mkdir -p driver_app/lib/features/earnings/presentation/{screens,widgets}
mkdir -p driver_app/lib/features/profile/presentation/{screens,widgets}
mkdir -p driver_app/lib/features/scanner/presentation/screens

# merchant_app
mkdir -p merchant_app/lib/features/auth/presentation/{screens,widgets}
mkdir -p merchant_app/lib/features/dashboard/presentation/{screens,widgets}
mkdir -p merchant_app/lib/features/deliveries/presentation/{screens,widgets}
mkdir -p merchant_app/lib/features/profile/presentation/{screens,widgets}
```

#### **E. Widgets partagés**

```bash
# Ajouter fichiers manquants dans shared/widgets
touch driver_app/lib/shared/widgets/{custom_button,custom_textfield,error_widget,loading_widget,empty_state,network_image_cached}.dart

touch merchant_app/lib/shared/widgets/{empty_state,commune_dropdown,network_image_cached}.dart
```

#### **F. Fichiers constants manquants**

```bash
# Storage keys
touch driver_app/lib/core/constants/storage_keys.dart
touch merchant_app/lib/core/constants/storage_keys.dart

# Upload service (merchant only)
touch merchant_app/lib/core/services/upload_service.dart
```

#### **G. Tests**

```bash
# Structure tests
mkdir -p driver_app/test/{unit/{models,repositories,services},widget,integration}
mkdir -p merchant_app/test/{unit/{models,repositories,services},widget,integration}
```

---

### **4️⃣ Firebase Setup** (CRITIQUE)

```bash
# ⚠️ À FAIRE MANUELLEMENT via FlutterFire CLI

# 1. Installer FlutterFire CLI
dart pub global activate flutterfire_cli

# 2. Configurer Firebase pour driver_app
cd driver_app
flutterfire configure

# 3. Configurer Firebase pour merchant_app
cd ../merchant_app
flutterfire configure
```

**Résultat** : Génère automatiquement :
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

---

## 🎯 **Priorités de Remplissage**

### **Phase 1 : Infrastructure (Semaine 1)**

1. **core/constants/**
   - `api_constants.dart` ← Copier du guide API
   - `app_colors.dart` ← Palette LeBeni's
   - `app_strings.dart` ← Textes français
   - `storage_keys.dart` ← Clés SecureStorage

2. **core/network/**
   - `dio_client.dart` ← Intercepteurs JWT (guide ligne 286)
   - `api_exception.dart` ← Gestion erreurs (guide ligne 80)

3. **core/services/**
   - `auth_service.dart` ← Storage tokens (guide ligne 528)
   - `notification_service.dart` ← FCM (guide ligne 1440)
   - `location_service.dart` ← GPS (guide ligne 1702)

4. **data/models/**
   - `delivery_model.dart` ← Guide ligne 1045
   - `driver_model.dart` ← Guide ligne 1281
   - `merchant_model.dart` ← Guide ligne 1254
   - `pricing_estimate.dart` ← Guide ligne 1011

5. **data/repositories/**
   - `auth_repository.dart` ← Guide ligne 631
   - `delivery_repository.dart` ← Guide ligne 817
   - `driver_repository.dart` ← Guide ligne 1329

---

### **Phase 2 : UI & Features (Semaine 2-3)**

1. **theme/** ← Créer ThemeData complet
2. **shared/widgets/** ← Widgets réutilisables
3. **features/auth/presentation/screens/** ← Login/Register
4. **features/deliveries/presentation/screens/** ← CRUD livraisons

---

## 📦 **pubspec.yaml à Compléter**

Ajoutez ces dépendances dans **les deux apps** :

```yaml
dependencies:
  flutter:
    sdk: flutter

  # HTTP & Networking
  dio: ^5.3.3
  
  # State Management
  provider: ^6.1.1
  
  # Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.1.0
  
  # Géolocalisation
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  permission_handler: ^11.1.0
  
  # Cartes
  flutter_map: ^6.1.0  # Gratuit
  latlong2: ^0.9.0
  
  # Images
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
  
  # Signature (driver_app only)
  signature: ^5.4.1
  
  # UI
  shimmer: ^3.0.0
  intl: ^0.18.1
  device_info_plus: ^9.1.0
  url_launcher: ^6.2.1
  path_provider: ^2.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  mockito: ^5.4.3
  build_runner: ^2.4.7

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
  
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
```

---

## ✅ **Résumé des Actions**

| Action | driver_app | merchant_app |
|--------|-----------|--------------|
| **❌ Supprimer** | 3 dossiers `data/` redondants | 3 dossiers `data/` redondants |
| **⚠️ Déplacer** | - | `lib/assets/` → `assets/` |
| **✅ Ajouter** | 15 dossiers + 30 fichiers | 16 dossiers + 32 fichiers |
| **📝 Remplir** | 25 fichiers vides | 27 fichiers vides |
| **🔥 Firebase** | Configuration FlutterFire CLI | Configuration FlutterFire CLI |

---

**Total estimé** :
- **Suppressions** : ~10 minutes
- **Déplacements** : ~5 minutes
- **Créations** : ~30 minutes
- **Firebase setup** : ~20 minutes
- **Remplissage code** : **2-3 semaines** selon guide API

