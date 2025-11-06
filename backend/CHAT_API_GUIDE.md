# 💬 Guide API Chat Temps Réel - Phase 3

## Vue d'ensemble

**Architecture Hybride**:
- **Firebase Realtime Database**: Synchronisation instantanée des messages
- **PostgreSQL**: Backup persistant, recherche, analytics
- **Django REST Framework**: API REST pour opérations complexes

**Avantages**:
- ✅ Messages instantanés (pas de polling)
- ✅ Typing indicators en temps réel
- ✅ Historique complet et searchable
- ✅ Fonctionne offline (local DB backup)
- ✅ Coût: $0/mois (plan gratuit Firebase)

---

## 📦 Configuration Backend

### 1. Variables d'environnement

Ajouter à `.env`:

```bash
# Firebase Realtime Database
FIREBASE_CREDENTIALS_PATH=config/firebase/service-account.json
FIREBASE_DATABASE_URL=https://your-project.firebaseio.com
```

### 2. Service Account Firebase

1. Aller sur [Firebase Console](https://console.firebase.google.com)
2. Sélectionner votre projet
3. Settings > Service Accounts
4. Cliquer "Generate new private key"
5. Télécharger le fichier JSON
6. Placer dans `backend/config/firebase/service-account.json`

### 3. Activer Realtime Database

1. Dans Firebase Console > Realtime Database
2. Créer une base de données
3. Mode test (pour développement):

```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

### 4. Lancer les migrations

```bash
cd backend
python manage.py makemigrations chat
python manage.py migrate chat
```

---

## 🔌 API Endpoints

### Base URL
```
http://localhost:8000/api/v1/chat/
```

### Authentication
Tous les endpoints requièrent un JWT token:
```http
Authorization: Bearer <your_jwt_token>
```

---

## 📝 Endpoints Conversations

### 1. **Liste des conversations**

```http
GET /api/v1/chat/rooms/
```

**Query Parameters**:
- `room_type`: `delivery` ou `support` (optionnel)
- `delivery_id`: UUID d'une livraison (optionnel)
- `include_archived`: `true` pour inclure archivées (défaut: `false`)
- `search`: Recherche par nom ou numéro de tracking
- `ordering`: `-last_message_at` (défaut) ou `created_at`

**Response**:
```json
{
  "count": 15,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": "uuid",
      "room_type": "delivery",
      "other_participant": {
        "id": "uuid",
        "full_name": "Jean Dupont",
        "phone_number": "+2250701020304",
        "user_type": "client",
        "profile_photo_url": "https://..."
      },
      "delivery_info": {
        "id": "uuid",
        "tracking_number": "LBN123456",
        "pickup_address": "Cocody...",
        "delivery_address": "Yopougon..."
      },
      "last_message_text": "Dernier message...",
      "last_message_at": "2025-01-15T14:30:00Z",
      "unread_count": 3,
      "is_archived": false,
      "created_at": "2025-01-15T10:00:00Z"
    }
  ]
}
```

---

### 2. **Détails d'une conversation**

```http
GET /api/v1/chat/rooms/{room_id}/
```

**Response**:
```json
{
  "id": "uuid",
  "room_type": "delivery",
  "driver": { /* User object */ },
  "other_participant": { /* User object */ },
  "delivery_info": { /* Delivery object */ },
  "last_message_text": "...",
  "last_message_at": "2025-01-15T14:30:00Z",
  "unread_count": 3,
  "is_active": true,
  "is_archived": false,
  "created_at": "2025-01-15T10:00:00Z",
  "firebase_path": "/chats/uuid"
}
```

---

### 3. **Créer une conversation**

```http
POST /api/v1/chat/rooms/
```

**Body**:
```json
{
  "other_user_id": "uuid_of_client_or_merchant",
  "delivery_id": "uuid_of_delivery",  // optionnel
  "room_type": "delivery",  // ou "support"
  "initial_message": "Bonjour, je suis votre livreur"  // optionnel
}
```

**Response**: Conversation créée (ou existante si déjà présente)

**Note**: Retourne une conversation existante si les mêmes participants + livraison existent déjà.

---

### 4. **Marquer conversation comme lue**

```http
POST /api/v1/chat/rooms/{room_id}/mark_as_read/
```

**Response**:
```json
{
  "success": true,
  "message": "Conversation marquée comme lue"
}
```

---

### 5. **Archiver/Désarchiver**

```http
POST /api/v1/chat/rooms/{room_id}/archive/
```

**Body**:
```json
{
  "archive": true  // ou false
}
```

---

### 6. **Nombre total de non lus**

```http
GET /api/v1/chat/rooms/unread_count/
```

**Response**:
```json
{
  "unread_count": 12
}
```

---

## 💬 Endpoints Messages

### 1. **Historique des messages**

```http
GET /api/v1/chat/messages/?chat_room_id={room_id}
```

**Response**:
```json
{
  "count": 50,
  "results": [
    {
      "id": "uuid",
      "chat_room": "uuid",
      "sender": {
        "id": "uuid",
        "full_name": "Driver Name",
        "profile_photo_url": "..."
      },
      "message_type": "text",
      "text": "Message content",
      "image_url": "",
      "latitude": null,
      "longitude": null,
      "is_read": true,
      "read_at": "2025-01-15T14:35:00Z",
      "created_at": "2025-01-15T14:30:00Z"
    }
  ]
}
```

---

### 2. **Envoyer un message**

```http
POST /api/v1/chat/messages/
```

**Body - Message texte**:
```json
{
  "chat_room_id": "uuid",
  "message_type": "text",
  "text": "Votre message ici"
}
```

**Body - Message image**:
```json
{
  "chat_room_id": "uuid",
  "message_type": "image",
  "text": "Voici la photo",  // optionnel
  "image_url": "https://cloudinary.com/..."
}
```

**Body - Partage de localisation**:
```json
{
  "chat_room_id": "uuid",
  "message_type": "location",
  "text": "Je suis ici",
  "latitude": 5.345317,
  "longitude": -4.024429
}
```

**Response**: Message créé avec sync Firebase

---

### 3. **Marquer messages comme lus**

**Option A - Messages spécifiques**:
```http
POST /api/v1/chat/messages/mark_as_read/
```
```json
{
  "message_ids": ["uuid1", "uuid2", "uuid3"]
}
```

**Option B - Tous les messages d'une room**:
```json
{
  "chat_room_id": "uuid"
}
```

**Response**:
```json
{
  "success": true,
  "count": 5,
  "message": "5 message(s) marqué(s) comme lu(s)"
}
```

---

## 🔥 Structure Firebase Realtime Database

```
/chats/{chat_room_id}/
  ├── metadata/
  │   ├── id: "uuid"
  │   ├── room_type: "delivery"
  │   ├── driver_id: "uuid"
  │   ├── other_user_id: "uuid"
  │   ├── delivery_id: "uuid"
  │   ├── created_at: "2025-01-15T10:00:00Z"
  │   ├── is_active: true
  │   ├── last_message_text: "..."
  │   ├── last_message_at: "2025-01-15T14:30:00Z"
  │   └── last_message_sender_id: "uuid"
  │
  ├── messages/{message_id}/
  │   ├── id: "uuid"
  │   ├── sender_id: "uuid"
  │   ├── message_type: "text"
  │   ├── text: "Message content"
  │   ├── image_url: ""
  │   ├── latitude: null
  │   ├── longitude: null
  │   ├── timestamp: "2025-01-15T14:30:00Z"
  │   ├── is_read: false
  │   └── read_at: null
  │
  └── typing/{user_id}/
      └── timestamp: "2025-01-15T14:30:15Z"
```

---

## 🚀 Workflow Complet

### Scénario: Driver envoie un message à un client

```python
# 1. Frontend envoie le message via REST API
POST /api/v1/chat/messages/
{
  "chat_room_id": "abc-123",
  "message_type": "text",
  "text": "J'arrive dans 5 minutes"
}

# 2. Backend Django:
# - Crée le message en PostgreSQL
# - Sync avec Firebase Realtime DB
# - Met à jour les compteurs non lus
# - Met à jour last_message dans la conversation

# 3. Firebase push le message au client en temps réel

# 4. Client reçoit le message instantanément via stream Firebase

# 5. Client marque comme lu (optionnel)
POST /api/v1/chat/messages/mark_as_read/
{
  "chat_room_id": "abc-123"
}
```

---

## 📱 Intégration Flutter

### 1. Écouter les messages (Realtime)

```dart
// Stream Firebase pour messages temps réel
final messagesRef = FirebaseDatabase.instance
    .ref('chats/$chatRoomId/messages')
    .orderByChild('timestamp');

messagesRef.onChildAdded.listen((event) {
  final message = MessageModel.fromFirebase(event.snapshot.value);
  // Ajouter à l'UI
});
```

### 2. Envoyer un message

```dart
// 1. Envoyer via REST API (crée backup + sync Firebase)
await chatRepository.sendMessage(
  chatRoomId: roomId,
  text: 'Mon message',
  type: MessageType.text,
);

// 2. Firebase sync automatique par le backend
// 3. Stream listener reçoit le message
```

### 3. Typing Indicator

```dart
// Backend Firebase service expose cette méthode
FirebaseChatService.set_typing_indicator(
  chat_room_id='abc-123',
  user_id='driver-uuid',
  is_typing=True
)

// Frontend écoute
FirebaseDatabase.instance
    .ref('chats/$chatRoomId/typing/$userId')
    .onValue
    .listen((event) {
      final isTyping = event.snapshot.exists;
      // Afficher "... est en train d'écrire"
    });
```

---

## 🎯 Cas d'Usage

### 1. **Chat Livraison (delivery)**
- **Participants**: Driver + Client
- **Contexte**: Livraison spécifique
- **Use case**: "Je suis arrivé", partage localisation, photo preuve

### 2. **Chat Support (support)**
- **Participants**: Driver + Admin/Support
- **Contexte**: Général (pas lié à une livraison)
- **Use case**: Questions, problèmes techniques, disputes

---

## 🔒 Sécurité

### 1. **Authentification**
- Tous les endpoints requièrent JWT token
- Seuls les participants d'une conversation peuvent y accéder

### 2. **Validation**
- `room_type` validé: `delivery` ou `support` uniquement
- `message_type` validé: `text`, `image`, `location`, `system`
- Contrainte unique: 1 conversation par driver + other_user + delivery

### 3. **Firebase Rules (Production)**
```json
{
  "rules": {
    "chats": {
      "$chat_id": {
        ".read": "auth != null && (
          data.child('metadata/driver_id').val() == auth.uid ||
          data.child('metadata/other_user_id').val() == auth.uid
        )",
        ".write": "auth != null && (
          data.child('metadata/driver_id').val() == auth.uid ||
          data.child('metadata/other_user_id').val() == auth.uid
        )"
      }
    }
  }
}
```

---

## 📊 Monitoring

### Logs Backend
```python
import logging
logger = logging.getLogger(__name__)

# Voir logs Firebase sync
logger.info("✓ Message synced to Firebase")
logger.error("❌ Firebase sync failed")
```

### Métriques à suivre
- Taux de sync Firebase (succès/échecs)
- Temps de réponse des endpoints
- Nombre de conversations actives
- Messages envoyés par jour

---

## ⚡ Performance

### Optimisations
1. **Indexes DB**:
   - `(chat_room, created_at)` pour historique rapide
   - `(is_read)` pour compteurs non lus
   - `(driver, is_active)` pour liste conversations

2. **Firebase**:
   - Limiter à 50 derniers messages en mémoire
   - Charger historique ancien via REST API

3. **Caching**:
   - Cache Redis pour conversations fréquentes
   - Invalider cache lors de nouveaux messages

---

## 🐛 Troubleshooting

### Problème: Messages ne s'affichent pas
**Solution**: Vérifier que Firebase Database URL est configuré dans `.env`

### Problème: Erreur "Firebase sync failed"
**Solutions**:
1. Vérifier service account JSON est valide
2. Vérifier Firebase Database est activé dans console
3. Vérifier règles Firebase permettent read/write

### Problème: Compteurs non lus incorrects
**Solution**: Endpoint reset:
```http
POST /api/v1/chat/rooms/{room_id}/mark_as_read/
```

---

## 📝 Prochaines étapes (Phase 3)

- [ ] Flutter: Chat Models & Repository
- [ ] Flutter: ChatProvider (Riverpod)
- [ ] Flutter: Conversations List UI
- [ ] Flutter: Chat Screen UI
- [ ] Push Notifications pour nouveaux messages

**Progression Backend**: ✅ 100% terminé
**Progression Frontend**: ⏳ 0% (à démarrer)

---

## 💡 Tips

1. **Offline-first**: Enregistrer messages localement avant sync
2. **Optimistic UI**: Afficher messages immédiatement, sync en background
3. **Retry logic**: Réessayer sync Firebase si échec
4. **Compression images**: Cloudinary avant upload dans chat
5. **Pagination**: Charger 20 messages à la fois, infinite scroll

---

**Dernière mise à jour**: 2025-01-15
**Statut**: Backend complet ✅
