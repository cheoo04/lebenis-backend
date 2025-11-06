# Push Notifications - Guide d'Intégration

## 📱 Vue d'ensemble

Le système de notifications push pour le chat utilise **Firebase Cloud Messaging (FCM)** pour envoyer des notifications en temps réel lorsque de nouveaux messages arrivent.

## 🏗️ Architecture

### Backend (Django)
- **Model**: `DeviceToken` - Stocke les tokens FCM des appareils
- **Service**: `ChatPushNotificationService` - Envoie les notifications
- **Endpoints**:
  - `POST /api/v1/notifications/register_token/` - Enregistrer un token
  - `POST /api/v1/notifications/delete_token/` - Supprimer un token
  - `GET /api/v1/notifications/my_tokens/` - Lister mes tokens

### Flutter (Driver App)
- **Service**: `NotificationService` - Gère FCM et notifications locales
- **Service**: `ChatNotificationService` - Spécifique au chat
- **Provider**: `chatNotificationServiceProvider` - Injection de dépendance

## 🚀 Utilisation

### 1. Initialisation au démarrage de l'app

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialiser les notifications au démarrage
    ref.read(notificationServiceProvider).initialize();
    
    return MaterialApp(
      // ...
    );
  }
}
```

### 2. Activation après connexion

Après qu'un utilisateur se connecte, activez les notifications de chat :

```dart
Future<void> onUserLoggedIn(WidgetRef ref) async {
  final chatNotifService = ref.read(chatNotificationServiceProvider);
  await chatNotifService.initialize();
}
```

### 3. Navigation depuis une notification

Configurez le callback de navigation :

```dart
void setupNotificationNavigation(WidgetRef ref, BuildContext context) {
  final notificationService = ref.read(notificationServiceProvider);
  
  notificationService.onNotificationTap = (data) {
    final type = data['type'];
    
    if (type == 'new_chat_message') {
      final chatRoomId = data['chat_room_id'];
      
      // Naviguer vers l'écran de chat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatRoom: /* récupérer la room */,
          ),
        ),
      );
    }
  };
}
```

### 4. Déconnexion

Lors de la déconnexion, nettoyez les abonnements :

```dart
Future<void> onUserLoggedOut(WidgetRef ref) async {
  final chatNotifService = ref.read(chatNotificationServiceProvider);
  await chatNotifService.unsubscribe();
}
```

## 📦 Types de Notifications

### 1. Nouveau Message
Envoyée automatiquement lorsqu'un message est reçu.

**Données**:
```json
{
  "type": "new_chat_message",
  "chat_room_id": "uuid",
  "message_id": "uuid",
  "sender_name": "Jean Dupont"
}
```

**Affichage**:
- Titre: `💬 Jean Dupont`
- Corps: `Texte du message...`
- Son + Vibration
- Badge incrémenté

### 2. Typing Indicator (Silencieux)
Notification data-only pour indiquer qu'un utilisateur écrit.

**Données**:
```json
{
  "type": "typing_indicator",
  "chat_room_id": "uuid",
  "sender_name": "Jean Dupont",
  "is_typing": "true"
}
```

**Affichage**: Aucun (notification silencieuse)

## 🔧 Backend - Envoi Manuel

Si vous voulez envoyer une notification manuellement depuis le backend :

```python
from apps.chat.push_notification_service import ChatPushNotificationService

# Nouveau message
ChatPushNotificationService.send_new_message_notification(
    recipient_user=user,
    sender_name="Jean Dupont",
    message_text="Bonjour, comment ça va ?",
    chat_room_id=str(chat_room.id),
    message_id=str(message.id)
)

# Typing indicator
ChatPushNotificationService.send_typing_notification(
    recipient_user=user,
    sender_name="Jean Dupont",
    chat_room_id=str(chat_room.id)
)
```

## 🔐 Sécurité

### Tokens FCM
- Stockés dans la table `device_tokens`
- Associés à un utilisateur spécifique
- Révoqués automatiquement si invalides
- Supprimés lors de la déconnexion

### Permissions
- Tous les endpoints requièrent l'authentification JWT
- Un utilisateur ne peut enregistrer que ses propres tokens
- Les notifications ne sont envoyées qu'aux participants de la conversation

## 📊 Monitoring

### Logs Backend
```python
logger.info(f"✅ Notification envoyée à {user.email}")
logger.warning(f"⚠️ Aucun token FCM pour {user.email}")
logger.error(f"❌ Erreur envoi notification: {e}")
```

### Logs Flutter
```dart
debugPrint('📤 Token FCM envoyé au backend');
debugPrint('📢 Abonné aux topics de notifications');
debugPrint('🗑️ Token FCM supprimé du backend');
```

## 🧪 Tests

### Test Backend
```bash
# Dans Django shell
python manage.py shell

from apps.authentication.models import User
from apps.chat.push_notification_service import ChatPushNotificationService

user = User.objects.get(email='test@example.com')
ChatPushNotificationService.send_new_message_notification(
    recipient_user=user,
    sender_name="Test",
    message_text="Test notification",
    chat_room_id="test-room-id",
    message_id="test-msg-id"
)
```

### Test Flutter
1. Installer l'app sur un appareil physique
2. Se connecter
3. Vérifier les logs : "✅ Chat notifications initialisées"
4. Fermer l'app
5. Envoyer un message depuis un autre compte
6. Vérifier que la notification arrive

## 🔄 Topics FCM

Les utilisateurs sont automatiquement abonnés aux topics :
- `drivers` - Tous les livreurs
- `chat_messages` - Notifications de chat

## ⚠️ Limitations

### iOS
- Les notifications ne fonctionnent que sur appareil physique (pas simulateur)
- Nécessite un certificat APNs configuré dans Firebase Console
- Badge géré automatiquement par iOS

### Android
- Channel ID: `chat_messages`
- Icône: `ic_notification` (à ajouter dans `/android/app/src/main/res/`)
- Couleur: `#2196F3` (bleu Material)

## 🐛 Troubleshooting

### "Aucun token FCM"
- Vérifier que `NotificationService.initialize()` est appelé
- Vérifier les permissions de notification
- Vérifier Firebase Console (APNs pour iOS)

### "Token invalide/désabonné"
- Le token est automatiquement désactivé dans la DB
- L'utilisateur doit se reconnecter pour obtenir un nouveau token

### Notifications ne s'affichent pas
- **Android**: Vérifier que le channel est créé
- **iOS**: Vérifier certificat APNs
- **Les deux**: Vérifier que l'app est en arrière-plan

## 📚 Ressources

- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Firebase Messaging Flutter](https://pub.dev/packages/firebase_messaging)
