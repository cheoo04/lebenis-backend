# 🗺️ CONFIGURATION GOOGLE MAPS - Guide Rapide

## 1. Obtenir une API Key Google Maps

1. Aller sur [Google Cloud Console](https://console.cloud.google.com/)
2. Créer un nouveau projet (ou sélectionner existant)
3. Activer les APIs suivantes:
   - **Maps SDK for Android**
   - **Maps SDK for iOS**
   - **Geocoding API** (optionnel, pour géocodage)
4. Aller dans **APIs & Services** → **Credentials**
5. Créer une **API Key**
6. Restreindre la clé (optionnel mais recommandé):
   - Android: Ajouter SHA-1 fingerprint + package name
   - iOS: Ajouter bundle identifier

---

## 2. Configuration Android

### Étape 1: Ajouter la clé dans AndroidManifest.xml

Fichier: `merchant_app/android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.lebenis.merchant_app">

    <!-- Permissions déjà présentes -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

    <application
        android:label="LeBenis Merchant"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <!-- ✅ AJOUTER ICI -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="VOTRE_API_KEY_GOOGLE_MAPS_ICI"/>

        <activity
            android:name=".MainActivity"
            ...>
            ...
        </activity>
    </application>
</manifest>
```

### Étape 2: Obtenir le SHA-1 fingerprint (optionnel)

Pour restreindre l'API Key à votre app:

```bash
cd android

# Debug
./gradlew signingReport

# Ou avec keytool
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Copier le **SHA-1** et l'ajouter dans Google Cloud Console.

---

## 3. Configuration iOS

### Étape 1: Ajouter la clé dans AppDelegate

Fichier: `merchant_app/ios/Runner/AppDelegate.swift`

```swift
import UIKit
import Flutter
import GoogleMaps  // ✅ AJOUTER

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // ✅ AJOUTER ICI
    GMSServices.provideAPIKey("VOTRE_API_KEY_GOOGLE_MAPS_ICI")

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Étape 2: Info.plist

Fichier: `merchant_app/ios/Runner/Info.plist`

Vérifier que ces permissions sont présentes:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Nous avons besoin de votre localisation pour afficher la carte</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Nous avons besoin de votre localisation pour le tracking</string>
```

### Étape 3: Podfile

Fichier: `merchant_app/ios/Podfile`

Vérifier la version iOS:

```ruby
platform :ios, '12.0'  # Minimum iOS 12
```

Puis installer les pods:

```bash
cd ios
pod install
```

---

## 4. Tester l'intégration

### Test rapide:

```dart
// Dans tracking_screen.dart, vérifier que la carte s'affiche
// Si erreur "Map API key not found", vérifier la config
```

### Debug Android:

```bash
# Vérifier les logs
adb logcat | grep -i "google\|maps\|api"
```

### Debug iOS:

Ouvrir Xcode et vérifier les logs de la console.

---

## 5. Erreurs courantes

### ❌ "Google Maps API key not found"

**Solution:** Vérifier que la clé est bien dans `AndroidManifest.xml` ou `AppDelegate.swift`

### ❌ "This API key is not authorized to use this service"

**Solution:**

1. Activer **Maps SDK for Android/iOS** dans Google Cloud Console
2. Attendre 5-10 minutes pour propagation
3. Vérifier restrictions de la clé

### ❌ "Map is grey/blank"

**Solutions:**

1. Vérifier connexion internet
2. Vérifier que l'API est activée
3. Vérifier que le billing est activé sur Google Cloud (requis même pour version gratuite)

### ❌ "SHA-1 fingerprint doesn't match"

**Solution:**

1. Regénérer le SHA-1 avec `./gradlew signingReport`
2. Ajouter tous les SHA-1 (debug + release) dans Google Cloud Console

---

## 6. Variables d'environnement (Recommandé)

Au lieu de hardcoder la clé, utiliser `.env`:

### Étape 1: Créer `.env`

Fichier: `merchant_app/.env`

```env
GOOGLE_MAPS_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### Étape 2: Charger dans Dart

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

// Utiliser
final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
```

### Étape 3: Ne pas commit .env

`.gitignore`:

```
.env
```

---

## 7. Limites gratuites Google Maps

- **Maps SDK:** 28,000 chargements de carte/mois gratuits
- **Geocoding API:** 40,000 requêtes/mois gratuits

Au-delà, facturation activée.

**Recommandation:** Activer le billing avec limite de dépense ($0-$50).

---

## 8. Vérification finale

```bash
# Clean & rebuild
cd merchant_app
flutter clean
flutter pub get
flutter run
```

Ouvrir l'écran de tracking et vérifier que la carte s'affiche correctement avec les markers.

---

## ✅ Checklist configuration

- [ ] API Key obtenue sur Google Cloud Console
- [ ] Maps SDK for Android activé
- [ ] Maps SDK for iOS activé
- [ ] Billing activé (même pour version gratuite)
- [ ] Clé ajoutée dans `AndroidManifest.xml`
- [ ] Clé ajoutée dans `AppDelegate.swift`
- [ ] Permissions location dans `Info.plist`
- [ ] `pod install` exécuté (iOS)
- [ ] App testée sur device réel
- [ ] Carte s'affiche correctement
- [ ] Markers visibles

---

**Temps estimé:** 15-30 minutes

**Important:** Toujours tester sur **device réel**, pas seulement émulateur !
