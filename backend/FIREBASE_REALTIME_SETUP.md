# 🔥 Configuration Firebase Realtime Database - Chat Temps Réel

## 📋 Prérequis

- Compte Firebase (gratuit): https://console.firebase.google.com
- Projet Firebase existant (déjà utilisé pour FCM notifications)

---

## 🚀 Setup Complet (10 minutes)

### Étape 1: Activer Realtime Database

1. **Aller sur Firebase Console**
   ```
   https://console.firebase.google.com
   ```

2. **Sélectionner votre projet**
   - Le même projet que celui utilisé pour les notifications push

3. **Naviguer vers Realtime Database**
   ```
   Menu gauche > Build > Realtime Database
   ```

4. **Créer une base de données**
   - Cliquer "Create Database"
   - **Région**: `us-central1` (gratuite, bonne latence pour Côte d'Ivoire)
   - **Security rules**: Choisir "Start in test mode" (temporaire)
   - Cliquer "Enable"

5. **Copier l'URL de la base**
   ```
   Exemple: https://votre-projet-12345.firebaseio.com
   ```

---

### Étape 2: Télécharger Service Account Key

1. **Aller dans Project Settings**
   ```
   Icône engrenage ⚙️ > Project settings
   ```

2. **Naviguer vers Service Accounts**
   ```
   Onglet "Service accounts"
   ```

3. **Générer une clé privée**
   - Cliquer "Generate new private key"
   - Confirmer dans la popup
   - Un fichier JSON sera téléchargé (ex: `votre-projet-firebase-adminsdk-xxxxx.json`)

4. **Placer le fichier dans le backend**
   ```bash
   # Créer le dossier firebase config s'il n'existe pas
   mkdir -p backend/config/firebase/
   
   # Copier le fichier téléchargé
   cp ~/Downloads/votre-projet-firebase-adminsdk-xxxxx.json backend/config/firebase/service-account.json
   ```

5. **Sécuriser le fichier**
   ```bash
   # Ajouter au .gitignore (IMPORTANT)
   echo "backend/config/firebase/service-account.json" >> .gitignore
   
   # Permissions restrictives
   chmod 600 backend/config/firebase/service-account.json
   ```

---

### Étape 3: Configurer les variables d'environnement

**Fichier: `backend/.env`**

```bash
# Firebase Realtime Database (Phase 3 - Chat)
FIREBASE_CREDENTIALS_PATH=config/firebase/service-account.json
FIREBASE_DATABASE_URL=https://votre-projet-12345.firebaseio.com

# Note: Remplacer "votre-projet-12345" par votre URL réelle
```

**Vérifier que ces variables existent déjà**:
```bash
# Ces deux variables doivent déjà être présentes (Phase 1-2)
FCM_SERVER_KEY=AAAA...  # Pour notifications push
FIREBASE_CREDENTIALS_PATH=...  # Déjà configuré
```

---

### Étape 4: Configurer les règles de sécurité

**En développement (Test mode - TEMPORAIRE)**:

```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null"
  }
}
```

**En production (OBLIGATOIRE avant déploiement)**:

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
        )",
        "messages": {
          "$message_id": {
            ".validate": "newData.hasChildren(['id', 'sender_id', 'message_type', 'timestamp'])"
          }
        }
      }
    }
  }
}
```

**Comment appliquer les règles**:
1. Firebase Console > Realtime Database > Rules
2. Copier-coller les règles ci-dessus
3. Cliquer "Publish"

---

### Étape 5: Tester la configuration

**Option A - Via script Python**:

```bash
cd backend

# Tester la connexion Firebase
python -c "
from apps.chat.firebase_service import FirebaseChatService

# Initialiser
service = FirebaseChatService()
print('✅ Firebase initialisé avec succès')

# Test write
service._update_chat_metadata('test-chat-123', {
    'last_message': 'Test message',
    'timestamp': '2025-01-15T10:00:00Z'
})
print('✅ Écriture Firebase réussie')
"
```

**Option B - Via Django shell**:

```bash
cd backend
python manage.py shell

# Dans le shell
from apps.chat.firebase_service import FirebaseChatService

service = FirebaseChatService()
print("Firebase status:", service.db)

# Test simple
service.create_chat_room('test-123', {'test': True})
```

**Résultat attendu**:
```
✅ Firebase initialisé avec succès
✅ Écriture Firebase réussie
```

**Si erreur**:
```
❌ ERROR: Failed to initialize Firebase
-> Vérifier FIREBASE_DATABASE_URL dans .env
-> Vérifier service-account.json existe
```

---

### Étape 6: Vérifier dans Firebase Console

1. **Aller dans Realtime Database > Data**
2. **Vérifier que le nœud `/chats/test-123` existe**
3. **Supprimer les données de test**
   ```
   Cliquer sur "test-123" > Icône poubelle
   ```

---

## 🔧 Configuration Flutter (Driver App)

### Fichier: `driver_app/pubspec.yaml`

```yaml
dependencies:
  firebase_core: ^4.2.1      # ✅ Déjà installé (Phase 1)
  firebase_messaging: ^16.0.4  # ✅ Déjà installé (Phase 2)
  firebase_database: ^11.1.4   # ✅ Nouvellement ajouté (Phase 3)
```

### Installation

```bash
cd driver_app
flutter pub get
```

### Initialisation (déjà faite en Phase 1)

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(MyApp());
}
```

---

## 📊 Quotas Firebase Gratuits (Spark Plan)

### Realtime Database
- ✅ **Stockage**: 1 GB
- ✅ **Transfert descendant**: 10 GB/mois
- ✅ **Connexions simultanées**: 100

### Estimation pour LeBeni's
```
📈 100 drivers actifs/jour
💬 50 messages/driver/jour = 5,000 messages/jour

Stockage:
- 1 message ≈ 500 bytes
- 5,000 messages × 500 bytes = 2.5 MB/jour
- 2.5 MB × 30 jours = 75 MB/mois ✅ Largement dans les limites

Bande passante:
- Lecture: 50 messages × 500 bytes × 100 drivers = 2.5 MB/jour
- 2.5 MB × 30 jours = 75 MB/mois ✅ OK

Connexions:
- Max 50 drivers simultanés ✅ OK
```

**Conclusion**: Le plan gratuit est **largement suffisant** pour 6-12 mois.

---

## 🚨 Sécurité - Checklist

### ✅ Configuration locale (dev)
- [ ] Service account JSON dans `.gitignore`
- [ ] Permissions 600 sur `service-account.json`
- [ ] `.env` dans `.gitignore`
- [ ] Firebase rules en "test mode" (temporaire)

### ✅ Production (avant déploiement)
- [ ] Service account JSON stocké dans variables d'environnement Render
- [ ] Firebase rules strictes (authentification + validation)
- [ ] CORS configuré pour domaines autorisés uniquement
- [ ] Logging des accès suspects activé
- [ ] Backups automatiques activés

---

## 🔍 Monitoring & Debug

### Logs Backend

```bash
# Filtrer logs Firebase
cd backend
python manage.py runserver | grep Firebase

# Exemples de logs
✓ Firebase initialized successfully
✓ Message synced to Firebase: /chats/abc-123/messages/msg-456
❌ Firebase sync failed: [Error details]
```

### Firebase Console - Usage

1. **Voir les données en temps réel**
   ```
   Realtime Database > Data
   ```

2. **Voir l'usage (quotas)**
   ```
   Realtime Database > Usage
   ```

3. **Logs Firebase (erreurs)**
   ```
   Realtime Database > Rules > Simulator
   ```

---

## 🐛 Troubleshooting

### Erreur: "Permission denied"

**Symptôme**:
```
FirebaseError: Permission denied
```

**Solutions**:
1. Vérifier que les règles Firebase permettent l'accès
2. Vérifier que l'utilisateur est authentifié
3. Tester avec règles en mode test temporairement

---

### Erreur: "Invalid URL"

**Symptôme**:
```
ERROR: Invalid Firebase Database URL
```

**Solutions**:
1. Vérifier `FIREBASE_DATABASE_URL` dans `.env`
2. Format attendu: `https://votre-projet.firebaseio.com`
3. Pas de slash `/` à la fin

---

### Erreur: "Service account not found"

**Symptôme**:
```
FileNotFoundError: service-account.json
```

**Solutions**:
1. Vérifier que le fichier existe:
   ```bash
   ls -la backend/config/firebase/service-account.json
   ```
2. Vérifier le chemin dans `.env`:
   ```
   FIREBASE_CREDENTIALS_PATH=config/firebase/service-account.json
   ```
3. Chemin relatif depuis `backend/` (pas de `/` au début)

---

### Performance: Latence élevée

**Symptôme**:
```
Messages prennent >2 secondes à arriver
```

**Solutions**:
1. Vérifier région Firebase (doit être us-central1)
2. Vérifier connexion internet du serveur
3. Utiliser Firebase Performance Monitoring

---

## 📝 Fichiers de configuration

### Structure attendue

```
backend/
├── config/
│   ├── firebase/
│   │   └── service-account.json  # ❌ NE PAS COMMIT
│   └── settings/
│       └── base.py               # FIREBASE_DATABASE_URL ici
├── .env                          # ❌ NE PAS COMMIT
├── .gitignore                    # ✅ Inclure les deux fichiers secrets
└── apps/
    └── chat/
        └── firebase_service.py   # Service Firebase
```

### .gitignore (vérifier)

```gitignore
# Firebase secrets
backend/config/firebase/service-account.json
backend/config/firebase/*.json

# Environment variables
.env
backend/.env
*.env.local
```

---

## 🎯 Checklist Finale

Avant de passer au développement Flutter:

- [ ] ✅ Firebase Realtime Database créé
- [ ] ✅ Service account JSON téléchargé et placé
- [ ] ✅ `.env` configuré avec les deux variables
- [ ] ✅ Règles Firebase appliquées (test mode pour dev)
- [ ] ✅ Test de connexion réussi
- [ ] ✅ `firebase_database` ajouté à pubspec.yaml
- [ ] ✅ Migrations Django exécutées
- [ ] ✅ Chat app ajoutée à INSTALLED_APPS

**Commande finale de test**:

```bash
cd backend
python manage.py makemigrations chat
python manage.py migrate chat
python manage.py shell -c "from apps.chat.firebase_service import FirebaseChatService; print('✅ OK' if FirebaseChatService().db else '❌ ERROR')"
```

**Résultat attendu**: `✅ OK`

---

## 📞 Support

Si vous rencontrez des problèmes:

1. **Vérifier les logs**:
   ```bash
   cd backend
   python manage.py runserver
   # Tester un endpoint chat
   curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:8000/api/v1/chat/rooms/
   ```

2. **Firebase Console Debugger**:
   ```
   Realtime Database > Rules > Simulator
   ```

3. **Documentation officielle**:
   - [Firebase Realtime Database](https://firebase.google.com/docs/database)
   - [Firebase Admin Python SDK](https://firebase.google.com/docs/admin/setup)

---

**Dernière mise à jour**: 2025-01-15
**Statut**: Configuration complète ✅
