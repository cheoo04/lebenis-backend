# 🔐 Flux de Vérification des Merchants - LeBeni's

## 📋 Vue d'ensemble

Le système de vérification permet de valider les commerçants avant qu'ils puissent créer des livraisons.

---

## 🔄 Flux Complet

### 1️⃣ **Inscription du Merchant**

```
Merchant remplit le formulaire d'inscription
  ↓
Backend crée le compte avec statut = "pending"
  ↓
Backend crée automatiquement le profil Merchant (signal)
  ↓
Merchant est connecté automatiquement
  ↓
Redirection vers écran d'attente
```

**Statut initial** : `verification_status = "pending"`  
**Compte actif** : `user.is_active = False` (désactivé jusqu'à approbation)

---

### 2️⃣ **Écran d'Attente (WaitingApprovalScreen)**

Le merchant voit :

- ✅ **Étape 1** : Compte créé (complété)
- 📤 **Étape 2** : Uploader documents RCCM + pièce d'identité
- 🔍 **Étape 3** : Vérification par l'équipe
- 🔔 **Étape 4** : Notification d'approbation

**Actions disponibles** :

1. **"Uploader mes documents"** → Va au profil
2. **"Vérifier le statut"** → Recharge le profil et vérifie le statut
3. **"Se déconnecter"** → Retour au login

---

### 3️⃣ **Upload des Documents**

#### A. Depuis le Profil (Edit Profile Screen)

```dart
// Le merchant peut uploader :
1. Document RCCM (Registre de Commerce)
2. Pièce d'identité

// Process :
Merchant sélectionne fichier (ImagePicker)
  ↓
Upload vers Cloudinary (via backend API)
  ↓
Sauvegarde de l'URL dans le profil
  ↓
PATCH /api/v1/merchants/update-documents/
```

#### B. API Backend

```http
PATCH /api/v1/merchants/update-documents/
Authorization: Bearer <merchant_token>

Body:
{
  "rccm_document": "https://cloudinary.com/.../rccm.pdf",
  "id_document": "https://cloudinary.com/.../id.jpg"
}

Response:
{
  "success": true,
  "message": "Documents mis à jour avec succès",
  "merchant": { ... }
}
```

---

### 4️⃣ **Vérification par Admin**

#### A. Lister les merchants en attente

```http
GET /api/v1/merchants/pending-verification/
Authorization: Bearer <admin_token>

Response:
{
  "count": 5,
  "results": [
    {
      "id": "uuid-123",
      "business_name": "Mon Commerce",
      "user": {
        "email": "merchant@example.com",
        "phone": "+225..."
      },
      "verification_status": "pending",
      "rccm_document": "https://...",
      "id_document": "https://...",
      "created_at": "2025-12-05T10:30:00Z"
    }
  ]
}
```

#### B. Approuver un merchant

```http
POST /api/v1/merchants/{id}/approve/
Authorization: Bearer <admin_token>

Response:
{
  "success": true,
  "message": "Commerçant approuvé avec succès",
  "merchant": {
    "verification_status": "approved",
    "user": {
      "is_active": true
    }
  }
}
```

**Ce qui se passe** :

- ✅ `verification_status` → `"approved"`
- ✅ `user.is_active` → `True`
- 🔔 **TODO** : Notification push au merchant

#### C. Rejeter un merchant

```http
POST /api/v1/merchants/{id}/reject/
Authorization: Bearer <admin_token>

Body:
{
  "rejection_reason": "Documents invalides - RCCM non conforme"
}

Response:
{
  "success": true,
  "message": "Commerçant rejeté",
  "merchant": {
    "verification_status": "rejected",
    "rejection_reason": "Documents invalides - RCCM non conforme",
    "user": {
      "is_active": false
    }
  }
}
```

---

### 5️⃣ **Notification au Merchant**

#### A. Système de Notifications Push (À implémenter)

**Quand un merchant est approuvé** :

```python
# backend/apps/merchants/views.py (ligne 82)
from apps.notifications.utils import send_push_notification

send_push_notification(
    user=merchant.user,
    title="Compte approuvé !",
    body=f"Félicitations ! Votre compte {merchant.business_name} a été approuvé.",
    notification_type="merchant_approved",
    data={
        "action": "open_dashboard",
        "merchant_id": str(merchant.id)
    }
)
```

**Configuration Firebase** :

- FCM configuré dans `google-services.json` (Android)
- Token FCM enregistré lors du login
- Service écoute les notifications en arrière-plan

#### B. Vérification Manuelle du Statut

Le merchant peut cliquer sur **"Vérifier le statut"** qui :

1. Appelle `merchantProfileProvider.notifier.loadProfile()`
2. Vérifie le nouveau `verification_status`
3. Redirige vers :
   - `/dashboard` si `approved`
   - `/rejected` si `rejected`
   - Reste sur `/waiting-approval` si toujours `pending`

---

### 6️⃣ **Après Approbation**

```
Merchant clique "Vérifier le statut" OU reçoit notification
  ↓
App recharge le profil
  ↓
verification_status = "approved" détecté
  ↓
Redirection automatique vers Dashboard
  ↓
Merchant peut créer des livraisons ✅
```

---

## 🛠️ Code Clés

### Flutter - Vérification du Statut

```dart
// lib/features/auth/presentation/screens/splash_screen.dart
if (profile.verificationStatus == 'approved' || profile.verificationStatus == 'verified') {
  Navigator.pushReplacementNamed(context, '/dashboard');
} else if (profile.verificationStatus == 'pending') {
  Navigator.pushReplacementNamed(context, '/waiting-approval');
} else if (profile.verificationStatus == 'rejected') {
  Navigator.pushReplacementNamed(context, '/rejected');
}
```

### Backend - Approbation avec Notification

```python
# backend/apps/merchants/views.py
@action(detail=True, methods=['POST'], permission_classes=[IsAdmin])
def approve(self, request, pk=None):
    merchant = self.get_object()
    merchant.verification_status = 'approved'
    merchant.user.is_active = True
    merchant.save()
    merchant.user.save()

    # TODO: Activer cette ligne quand le système de notifications est prêt
    # send_push_notification(merchant.user, ...)

    return Response({'success': True, 'message': 'Approuvé'})
```

---

## 📱 Interface Utilisateur

### WaitingApprovalScreen

```
┌─────────────────────────────────────┐
│        🕐 Icône sablier              │
│                                      │
│  Compte en attente de vérification  │
│                                      │
│  Votre compte a été créé avec       │
│  succès ! Nous examinons votre      │
│  demande.                            │
│                                      │
│  ┌────────────────────────────────┐ │
│  │ Prochaines étapes :             │ │
│  │ ✅ Compte créé                  │ │
│  │ 📤 Uploader documents           │ │
│  │ 🔍 Vérification équipe          │ │
│  │ 🔔 Notification approbation     │ │
│  └────────────────────────────────┘ │
│                                      │
│  [📤 Uploader mes documents]        │
│  [🔄 Vérifier le statut]            │
│  [Se déconnecter]                   │
│                                      │
│  ℹ️ Contactez support@lebenis.com   │
└─────────────────────────────────────┘
```

---

## ⚠️ Points Importants

### 1. **Polling vs Push Notifications**

**Actuellement** : Vérification manuelle (polling)

- Le merchant clique sur "Vérifier le statut"
- L'app recharge le profil
- ✅ Simple, fonctionne immédiatement

**À venir** : Notifications push

- Admin approuve → notification automatique
- Merchant reçoit la notification → ouvre l'app
- ✅ Meilleure UX, pas besoin de vérifier manuellement

### 2. **Documents Requis**

- **RCCM** : Registre de Commerce et du Crédit Mobilier
- **Pièce d'identité** : CNI, Passeport, Permis de conduire

**Formats acceptés** : JPG, PNG, PDF  
**Upload via** : Cloudinary (avec URL retournée)

### 3. **Sécurité**

- Seul un **Admin** peut approuver/rejeter
- Merchant ne peut pas auto-approuver
- Documents stockés sur Cloudinary (sécurisé)
- URLs signées pour accès temporaire

---

## 🔧 TODO - Améliorations

### Court Terme

- [ ] Implémenter l'upload de documents dans Edit Profile Screen
- [ ] Ajouter indicateurs visuels (documents uploadés ✅)
- [ ] Activer les notifications push Firebase

### Moyen Terme

- [ ] Système de polling automatique (toutes les 30s)
- [ ] Email de notification en plus du push
- [ ] Interface admin pour gérer les vérifications

### Long Terme

- [ ] Dashboard admin avec liste des pending
- [ ] Historique des vérifications
- [ ] Système de commentaires admin → merchant

---

## 📞 Support

Pour toute question sur ce flux :

- Documentation backend : `backend/apps/merchants/VALIDATION_README.md`
- Configuration Firebase : `backend/FIREBASE_FCM_SETUP.md`
- API Guide : `API_INTEGRATION_GUIDE.md`
