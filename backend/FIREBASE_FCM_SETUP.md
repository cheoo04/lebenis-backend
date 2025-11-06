# 🔔 Configuration Firebase Cloud Messaging (FCM)

## 📋 Table des matières
1. [Prérequis](#prérequis)
2. [Setup Backend Django](#setup-backend-django)
3. [Setup Flutter](#setup-flutter)
4. [Test des notifications](#test-des-notifications)
5. [Troubleshooting](#troubleshooting)

---

## 🔧 Prérequis

### 1. Créer un projet Firebase

1. Aller sur [Firebase Console](https://console.firebase.google.com/)
2. Créer un nouveau projet : **"LeBenis-Logistics"**
3. Désactiver Google Analytics (optionnel pour notifications)

### 2. Télécharger les credentials

#### Backend (Django)
1. Dans Firebase Console : **Paramètres du projet** > **Comptes de service**
2. Cliquer sur **"Générer une nouvelle clé privée"**
3. Télécharger le fichier JSON (environ 2 KB)
4. Renommer en `serviceAccountKey.json`

#### Frontend (Flutter)
1. Dans Firebase Console : **Paramètres du projet** > **Vos applications**
2. Ajouter une app **Android** :
   - Package name : `com.lebenis.driver_app`
   - Télécharger `google-services.json`
3. Ajouter une app **iOS** :
   - Bundle ID : `com.lebenis.driverApp`
   - Télécharger `GoogleService-Info.plist`

---

## 🐍 Setup Backend Django

### 1. Placer le fichier credentials

```bash
cd /home/cheoo/lebenis_project/backend
mkdir -p config/firebase
mv ~/Downloads/serviceAccountKey.json config/firebase/
chmod 600 config/firebase/serviceAccountKey.json  # Sécurité
```

**Structure attendue** :
```
backend/
├── config/
│   └── firebase/
│       └── serviceAccountKey.json  ← ICI
├── apps/
├── manage.py
```

### 2. Vérifier l'installation

Les packages sont déjà installés :
- ✅ `firebase-admin==6.9.0`
- ✅ Code de service FCM créé : `apps/notifications/services.py`

### 3. Tester l'initialisation

```bash
cd backend
python manage.py shell
```

```python
from apps.notifications.services import FCMNotificationService

# Initialiser Firebase
FCMNotificationService.initialize_firebase()
# Devrait afficher : ✅ Firebase Admin SDK initialisé avec succès
```

### 4. Endpoints disponibles

#### Enregistrer un token FCM
```http
POST /api/v1/auth/register-fcm-token/
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "fcm_token": "eBdKf7JxQ9..."
}
```

**Réponse** :
```json
{
  "success": true,
  "message": "Token FCM enregistré avec succès"
}
```

---

## 📱 Setup Flutter

### 1. Ajouter les packages

```yaml
# driver_app/pubspec.yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.0
  flutter_local_notifications: ^16.0.0  # Notifications locales
```

```bash
cd driver_app
flutter pub get
```

### 2. Configuration Android

#### Placer le fichier google-services.json

```bash
# Copier depuis téléchargements
cp ~/Downloads/google-services.json driver_app/android/app/
```

#### Modifier build.gradle (projet)

```groovy
// driver_app/android/build.gradle.kts
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")  // ← AJOUTER
    }
}
```

#### Modifier build.gradle (app)

```groovy
// driver_app/android/app/build.gradle.kts
plugins {
    // ...
    id("com.google.gms.google-services")  // ← AJOUTER en bas
}
```

### 3. Configuration iOS

#### Placer GoogleService-Info.plist

```bash
cp ~/Downloads/GoogleService-Info.plist driver_app/ios/Runner/
```

#### Ajouter dans Xcode (si nécessaire)
1. Ouvrir `driver_app/ios/Runner.xcworkspace`
2. Glisser-déposer `GoogleService-Info.plist` dans `Runner/`
3. Cocher "Copy items if needed"

### 4. Créer le service de notifications Flutter

```dart
// lib/core/services/fcm_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/dio_client.dart';
import '../constants/api_constants.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialiser FCM
  static Future<void> initialize() async {
    // 1. Demander permission
    await _requestPermission();

    // 2. Configurer notifications locales
    await _initializeLocalNotifications();

    // 3. Obtenir le token FCM
    final token = await _messaging.getToken();
    print('📱 FCM Token: $token');

    // 4. Écouter les messages
    _setupMessageHandlers();

    return token;
  }

  /// Demander permission notifications
  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Permission notifications accordée');
    } else {
      print('❌ Permission notifications refusée');
    }
  }

  /// Initialiser notifications locales (foreground)
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Gérer le clic sur notification
        print('Notification cliquée: ${details.payload}');
      },
    );
  }

  /// Gérer les messages FCM
  static void _setupMessageHandlers() {
    // Foreground (app ouverte)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📬 Message reçu (foreground): ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Background (app minimisée)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 Message ouvert (background): ${message.notification?.title}');
      _handleNotificationClick(message);
    });
  }

  /// Afficher notification locale
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'lebenis_channel',
      'LeBenis Notifications',
      channelDescription: 'Notifications de livraison',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFFFF6B35),
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Nouvelle notification',
      message.notification?.body ?? '',
      details,
      payload: message.data['delivery_id'],
    );
  }

  /// Gérer le clic sur notification
  static void _handleNotificationClick(RemoteMessage message) {
    final deliveryId = message.data['delivery_id'];
    if (deliveryId != null) {
      // Navigator vers DeliveryDetailsScreen
      print('Navigation vers delivery: $deliveryId');
    }
  }

  /// Enregistrer le token sur le backend
  static Future<void> registerToken(String token, DioClient dioClient) async {
    try {
      await dioClient.post(
        ApiConstants.registerFCMToken,
        data: {'fcm_token': token},
      );
      print('✅ Token FCM enregistré sur backend');
    } catch (e) {
      print('❌ Erreur enregistrement token: $e');
    }
  }
}

/// Handler pour messages en arrière-plan total (terminated)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📬 Message reçu (terminated): ${message.notification?.title}');
}
```

### 5. Initialiser dans main.dart

```dart
// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Handler background messages
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialiser FCM
  await FCMService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}
```

### 6. Enregistrer le token après login

```dart
// lib/features/auth/presentation/screens/login_screen.dart

Future<void> _handleLogin() async {
  // ... login existant

  if (loginSuccess) {
    // Obtenir et enregistrer le token FCM
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await FCMService.registerToken(
        fcmToken,
        ref.read(dioClientProvider),
      );
    }

    // Naviguer vers HomeScreen
  }
}
```

---

## 🧪 Test des notifications

### 1. Test manuel depuis Django shell

```bash
cd backend
python manage.py shell
```

```python
from apps.authentication.models import User
from apps.notifications.services import FCMNotificationService

# Trouver un utilisateur avec FCM token
user = User.objects.filter(fcm_token__isnull=False).first()
print(f"User: {user.email}, Token: {user.fcm_token[:20]}...")

# Envoyer une notification test
result = FCMNotificationService.send_notification(
    fcm_token=user.fcm_token,
    title="🧪 Test Notification",
    body="Ceci est un test depuis Django shell",
    data={
        'type': 'test',
        'timestamp': str(timezone.now())
    }
)

print(f"Résultat: {result}")
```

### 2. Test via assignation livraison

1. Créer une livraison via API merchant
2. Assigner un driver (auto ou manuel)
3. Le driver doit recevoir la notification : **"🚚 Nouvelle livraison !"**

### 3. Test via acceptation

1. Driver accepte la livraison
2. Merchant doit recevoir : **"✅ Livreur trouvé !"**

---

## 🐛 Troubleshooting

### Backend : Firebase SDK non initialisé

**Erreur** :
```
ValueError: The default Firebase app does not exist.
```

**Solution** :
1. Vérifier que `config/firebase/serviceAccountKey.json` existe
2. Relancer le serveur Django

### Flutter : google-services.json introuvable

**Erreur** :
```
File google-services.json is missing
```

**Solution** :
```bash
# Vérifier présence du fichier
ls driver_app/android/app/google-services.json

# Si absent, le télécharger depuis Firebase Console
```

### Notifications non reçues

**Checklist** :
- [ ] Token FCM enregistré dans la DB (`User.fcm_token`)
- [ ] App Flutter en foreground/background (pas terminated au début)
- [ ] Permissions accordées sur le téléphone
- [ ] Connexion internet active

### Tester le token FCM manuellement

Utiliser [FCM API Tester](https://console.firebase.google.com/project/_/notification) :
1. Aller dans Firebase Console > Cloud Messaging
2. Cliquer "Send your first message"
3. Coller le FCM token
4. Envoyer

---

## 📊 Monitoring

### Vérifier les tokens enregistrés

```sql
-- Dans PostgreSQL
SELECT 
    email, 
    user_type,
    SUBSTRING(fcm_token, 1, 20) as token_preview,
    updated_at
FROM users
WHERE fcm_token IS NOT NULL;
```

### Logs backend

```python
# Dans settings/base.py, ajouter logger

LOGGING = {
    'loggers': {
        'apps.notifications.services': {
            'handlers': ['console'],
            'level': 'INFO',
        }
    }
}
```

---

## ✅ Checklist finale

### Backend
- [ ] `serviceAccountKey.json` placé dans `config/firebase/`
- [ ] Migration `add_fcm_token` appliquée
- [ ] Endpoint `/auth/register-fcm-token/` fonctionne
- [ ] Notifications envoyées lors assignation/acceptation/livraison

### Flutter
- [ ] `google-services.json` (Android) et `GoogleService-Info.plist` (iOS) placés
- [ ] Package `firebase_messaging` installé
- [ ] FCMService créé et initialisé dans `main.dart`
- [ ] Token enregistré après login
- [ ] Notifications affichées en foreground/background

---

**🎉 Si tout fonctionne, les drivers recevront des notifications en temps réel pour chaque nouvelle livraison !**
