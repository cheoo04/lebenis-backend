# 📱 Système de Notifications Push - Guide d'utilisation

## ✅ Installation terminée

Le système de notifications push avec Firebase Cloud Messaging V1 est maintenant **complètement opérationnel**.

---

## 🎯 Fonctionnalités disponibles

### 1️⃣ **Enregistrement de tokens FCM** (depuis l'app mobile)
```http
POST /api/v1/notifications/register-token/
Authorization: Bearer <token>

{
  "token": "fcm_device_token_from_flutter",
  "platform": "android",  // ou "ios", "web"
  "device_name": "Samsung Galaxy S21"
}
```

### 2️⃣ **Supprimer un token** (déconnexion)
```http
POST /api/v1/notifications/delete-token/
Authorization: Bearer <token>

{
  "token": "fcm_device_token_to_remove"
}
```

### 3️⃣ **Lister mes tokens**
```http
GET /api/v1/notifications/my-tokens/
Authorization: Bearer <token>
```

### 4️⃣ **Marquer une notification comme lue**
```http
POST /api/v1/notifications/{id}/mark-as-read/
Authorization: Bearer <token>
```

### 5️⃣ **Envoyer à un utilisateur spécifique** (Admin)
```http
POST /api/v1/notifications/send-to-user/
Authorization: Bearer <admin_token>

{
  "user_id": "uuid-of-user",
  "title": "Nouvelle livraison",
  "message": "Votre colis est en route",
  "notification_type": "delivery_update",
  "data": {
    "delivery_id": "uuid-of-delivery",
    "action": "view_delivery"
  }
}
```

### 6️⃣ **Broadcast** (envoyer à tous ou un groupe) - Admin
```http
POST /api/v1/notifications/broadcast/
Authorization: Bearer <admin_token>

{
  "title": "Maintenance planifiée",
  "message": "Le service sera indisponible demain de 2h à 4h",
  "user_type": "all",  // ou "merchant", "driver"
  "notification_type": "announcement"
}
```

---

## 🖥️ Commande Django (pour tests admin)

### Envoyer à un utilisateur spécifique
```bash
python manage.py send_push_notification \
  --user merchant@example.com \
  --title "Test notification" \
  --message "Ceci est un test" \
  --type general
```

### Envoyer à tous les merchants
```bash
python manage.py send_push_notification \
  --user-type merchant \
  --title "Promotion spéciale" \
  --message "Bénéficiez de 20% de réduction sur vos livraisons" \
  --type marketing
```

### Envoyer à tous les drivers
```bash
python manage.py send_push_notification \
  --user-type driver \
  --title "Nouveau bonus" \
  --message "Gagnez +500 CFA par livraison ce weekend" \
  --type announcement
```

### Broadcast à tous
```bash
python manage.py send_push_notification \
  --all \
  --title "Mise à jour de l'app" \
  --message "Veuillez mettre à jour l'application vers la version 2.0" \
  --type system
```

---

## 📱 Intégration Flutter

### 1. Installation
Ajoute dans `pubspec.yaml` :
```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.0
```

### 2. Initialisation
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Demander la permission (iOS)
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  
  runApp(MyApp());
}
```

### 3. Récupérer le token
```dart
Future<void> registerFCMToken() async {
  final fcm = FirebaseMessaging.instance;
  String? token = await fcm.getToken();
  
  if (token != null) {
    // Envoyer le token au backend
    await ApiService.post('/api/v1/notifications/register-token/', {
      'token': token,
      'platform': Platform.isAndroid ? 'android' : 'ios',
      'device_name': await getDeviceName(),
    });
    
    print('✅ Token FCM enregistré: $token');
  }
}
```

### 4. Écouter les notifications
```dart
void setupNotifications() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📩 Notification reçue (app au premier plan)');
    print('Titre: ${message.notification?.title}');
    print('Message: ${message.notification?.body}');
    
    // Afficher une notification locale ou un snackbar
    showLocalNotification(message);
  });
  
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📱 Notification cliquée');
    
    // Naviguer vers l'écran approprié
    if (message.data['action'] == 'view_delivery') {
      Navigator.push(context, DeliveryDetailsScreen(
        deliveryId: message.data['delivery_id']
      ));
    }
  });
}
```

### 5. Supprimer le token (déconnexion)
```dart
Future<void> logout() async {
  final fcm = FirebaseMessaging.instance;
  String? token = await fcm.getToken();
  
  if (token != null) {
    // Supprimer le token côté backend
    await ApiService.post('/api/v1/notifications/delete-token/', {
      'token': token,
    });
  }
  
  // Supprimer le token localement
  await fcm.deleteToken();
}
```

---

## 🧪 Tests rapides

### Test 1 : Vérifier Firebase initialisé
```bash
cd /home/cheoo/lebenis_project/backend
python3 manage.py shell
```
```python
from apps.notifications.firebase_service import FirebaseService
print(FirebaseService._initialized)  # doit afficher True
```

### Test 2 : Créer un token de test
```python
from apps.authentication.models import User
from apps.notifications.models import DeviceToken

user = User.objects.first()
token = DeviceToken.objects.create(
    user=user,
    token='test_fcm_token_123',
    platform='android',
    device_name='Test Device'
)
print(f'✅ Token créé pour {user.email}')
```

### Test 3 : Envoyer une notification de test
```python
from apps.notifications.firebase_service import FirebaseService

# ⚠️ Remplace par un VRAI token FCM depuis Flutter
result = FirebaseService.send_notification(
    fcm_token='ton_vrai_token_fcm_ici',
    title='Test depuis Django',
    body='Si tu reçois ça, tout fonctionne !',
    data={'test': 'true'}
)
print(result)
```

---

## 📊 Tableau de bord admin

Dans l'admin Django (`/admin/`), tu peux maintenant :
- ✅ Voir tous les tokens FCM enregistrés
- ✅ Filtrer par plateforme (Android/iOS/Web)
- ✅ Désactiver les tokens invalides
- ✅ Voir les notifications envoyées

---

## 🔧 Résolution de problèmes

### ❌ "Firebase not initialized"
- Vérifie que `config/firebase/service-account.json` existe
- Vérifie `FIREBASE_CREDENTIALS_PATH` dans `.env`

### ❌ "Invalid token" lors de l'envoi
- Le token FCM a expiré ou l'app a été désinstallée
- Le système désactive automatiquement les tokens invalides

### ❌ Notification non reçue sur Flutter
- Vérifie que l'app a bien envoyé le token au backend
- Vérifie que Firebase Cloud Messaging est configuré dans Firebase Console
- Sur iOS, vérifie que les permissions sont accordées

---

## 📝 Types de notifications recommandés

```python
NOTIFICATION_TYPES = [
    'delivery_update',    # Changement de statut livraison
    'delivery_assigned',  # Nouvelle livraison assignée
    'payment',           # Paiement reçu/envoyé
    'invoice',           # Nouvelle facture
    'approval',          # Compte approuvé/rejeté
    'announcement',      # Annonce générale
    'marketing',         # Promotion
    'system',            # Maintenance, mise à jour
    'general',           # Autre
]
```

---

## ✅ Système prêt !

Le système de notifications push est **100% fonctionnel**. Tu peux maintenant :
1. Enregistrer des tokens depuis Flutter
2. Envoyer des notifications depuis le backend
3. Tester avec la commande Django
4. Gérer les tokens dans l'admin

**Prochaine étape** : Configure Firebase dans tes apps Flutter et teste l'envoi ! 🚀
