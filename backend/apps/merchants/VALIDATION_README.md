# ✅ Validation et Approbation des Commerçants - LeBeni's Group

## 📋 Vue d'ensemble

Ce module gère le workflow d'approbation des commerçants qui s'inscrivent sur la plateforme.

**Statuts possibles** :
- `pending` : En attente de vérification (défaut à l'inscription)
- `approved` : Commerçant approuvé et actif
- `rejected` : Commerçant rejeté avec motif

---

## 🔐 Endpoints disponibles

### 1. Lister les commerçants en attente (Admin)
```http
GET /api/v1/merchants/pending-verification/
Authorization: Bearer <admin_token>
```

**Permissions** : Admin uniquement

**Réponse** :
```json
{
  "count": 5,
  "results": [
    {
      "id": "uuid",
      "user": {
        "id": "uuid",
        "email": "restaurant@example.com",
        "first_name": "Jean",
        "last_name": "Kouassi",
        "phone": "+225 07 00 00 00 01",
        "is_active": false
      },
      "business_name": "Restaurant Le Palmier",
      "business_type": "restaurant",
      "verification_status": "pending",
      "rejection_reason": "",
      "documents_url": "https://example.com/docs/merchant123",
      "rccm_document": "/media/documents/rccm_12345.pdf",
      "id_document": "/media/documents/id_12345.pdf",
      "commission_rate": "15.00",
      "created_at": "2025-01-15T10:30:00Z"
    }
  ]
}
```

---

### 2. Approuver un commerçant (Admin)
```http
POST /api/v1/merchants/{merchant_id}/approve/
Authorization: Bearer <admin_token>
```

**Permissions** : Admin uniquement

**Comportement** :
- Change le `verification_status` à `approved`
- Active le compte utilisateur (`user.is_active = True`)
- Efface le `rejection_reason` (s'il y en avait un)
- Permet au commerçant de créer des livraisons

**Réponse** :
```json
{
  "success": true,
  "message": "Commerçant approuvé avec succès",
  "merchant": {
    "id": "uuid",
    "business_name": "Restaurant Le Palmier",
    "verification_status": "approved",
    "user": {
      "is_active": true
    }
  }
}
```

**Erreurs possibles** :
- `400 Bad Request` : Le commerçant est déjà approuvé

---

### 3. Rejeter un commerçant (Admin)
```http
POST /api/v1/merchants/{merchant_id}/reject/
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "rejection_reason": "Documents invalides - RCCM non conforme"
}
```

**Permissions** : Admin uniquement

**Body obligatoire** :
- `rejection_reason` (string, requis) : Motif du rejet

**Comportement** :
- Change le `verification_status` à `rejected`
- Enregistre le motif dans `rejection_reason`
- Désactive le compte utilisateur (`user.is_active = False`)
- Empêche le commerçant de créer des livraisons

**Réponse** :
```json
{
  "success": true,
  "message": "Commerçant rejeté",
  "merchant": {
    "id": "uuid",
    "business_name": "Restaurant Le Palmier",
    "verification_status": "rejected",
    "rejection_reason": "Documents invalides - RCCM non conforme",
    "user": {
      "is_active": false
    }
  }
}
```

**Erreurs possibles** :
- `400 Bad Request` : Champ `rejection_reason` manquant ou vide

---

## 📊 Workflow d'approbation

### Étape 1 : Inscription du commerçant
```
POST /api/v1/auth/register/
{
  "email": "merchant@example.com",
  "password": "...",
  "user_type": "merchant",
  "first_name": "Jean",
  "last_name": "Kouassi",
  "phone": "+225 07 00 00 00 01",
  "merchant_data": {
    "business_name": "Restaurant Le Palmier",
    "business_type": "restaurant",
    "business_address": "Cocody, Abidjan",
    "rccm_document": <file>,
    "id_document": <file>
  }
}
```

**Résultat** :
- Merchant créé avec `verification_status = "pending"`
- User créé avec `is_active = False`
- Le commerçant ne peut PAS encore créer de livraisons

---

### Étape 2 : Admin vérifie les documents
```
GET /api/v1/merchants/pending-verification/
```

L'admin :
- Consulte la liste des commerçants en attente
- Télécharge les documents (`rccm_document`, `id_document`)
- Vérifie l'authenticité et la conformité

---

### Étape 3a : Approbation (si tout est OK)
```
POST /api/v1/merchants/{id}/approve/
```

**Résultat** :
- `verification_status` → `"approved"`
- `user.is_active` → `True`
- Le commerçant peut maintenant créer des livraisons

---

### Étape 3b : Rejet (si problème)
```
POST /api/v1/merchants/{id}/reject/
{
  "rejection_reason": "RCCM expiré depuis 6 mois"
}
```

**Résultat** :
- `verification_status` → `"rejected"`
- `rejection_reason` → `"RCCM expiré depuis 6 mois"`
- `user.is_active` → `False`
- Le commerçant est notifié du rejet et du motif

---

## 🔄 Ré-soumission après rejet

Si un commerçant a été rejeté, il peut :

1. **Corriger les problèmes** (nouveaux documents, etc.)
2. **Contacter le support** pour une nouvelle vérification
3. **L'admin peut ré-approuver** en utilisant l'endpoint `approve`

Lorsque l'admin approuve après un rejet :
- Le `rejection_reason` est effacé
- Le statut passe à `approved`
- Le compte est réactivé

---

## 📝 Champs du modèle Merchant

### Champs de vérification

| Champ | Type | Description |
|-------|------|-------------|
| `verification_status` | CharField | `pending`, `approved`, `rejected` |
| `rejection_reason` | TextField | Motif du rejet (si `rejected`) |
| `documents_url` | URLField | URL vers un dossier de documents (optionnel) |
| `rccm_document` | FileField | Registre de Commerce (RCCM) |
| `id_document` | FileField | Carte d'identité du représentant |

---

## ✅ Règles métier

1. **À l'inscription** :
   - Tous les merchants sont créés avec `verification_status = "pending"`
   - Le compte utilisateur est désactivé (`is_active = False`)
   - Aucune livraison ne peut être créée

2. **Après approbation** :
   - Le merchant peut créer des livraisons
   - Le compte est actif
   - Le `rejection_reason` est effacé

3. **Après rejet** :
   - Le merchant ne peut pas créer de livraisons
   - Le compte est désactivé
   - Le motif de rejet est enregistré et visible

4. **Permissions** :
   - Seuls les admins peuvent approuver/rejeter
   - Les merchants voient leur propre statut et motif de rejet
   - Les admins voient tous les merchants

---

## 🔔 Notifications (à implémenter)

### Après approbation
```
Titre : "Compte approuvé ! 🎉"
Message : "Votre compte commerçant a été approuvé. Vous pouvez maintenant créer des livraisons."
```

### Après rejet
```
Titre : "Compte en attente 📋"
Message : "Votre demande nécessite des corrections : {rejection_reason}. Contactez le support."
```

---

## 🛡️ Sécurité

- **Upload de fichiers** : Validation du type et de la taille
- **Permissions strictes** : Seuls les admins peuvent approuver/rejeter
- **Logs** : Toutes les actions sont loggées
- **Audit trail** : Les changements de statut sont traçables

---

## 📊 Métriques utiles

### Dashboard admin
```python
pending_count = Merchant.objects.filter(verification_status='pending').count()
approved_count = Merchant.objects.filter(verification_status='approved').count()
rejected_count = Merchant.objects.filter(verification_status='rejected').count()
```

### Temps moyen d'approbation
```python
from django.db.models import Avg, F
from django.utils import timezone

avg_approval_time = Merchant.objects.filter(
    verification_status='approved'
).annotate(
    approval_time=F('updated_at') - F('created_at')
).aggregate(avg=Avg('approval_time'))
```

---

## 🧪 Tests

### Tester l'approbation
```bash
# Créer un merchant pending
POST /api/v1/auth/register/ (user_type=merchant)

# Lister les pending
GET /api/v1/merchants/pending-verification/

# Approuver
POST /api/v1/merchants/{id}/approve/

# Vérifier que le merchant peut créer des livraisons
POST /api/v1/deliveries/ (avec token merchant)
```

### Tester le rejet
```bash
# Rejeter avec motif
POST /api/v1/merchants/{id}/reject/
{
  "rejection_reason": "Test de rejet"
}

# Vérifier que le merchant ne peut PAS créer de livraisons
POST /api/v1/deliveries/ (devrait retourner 403 Forbidden)
```

---

## 📱 Intégration Flutter

### Écran d'attente (après inscription)
```dart
if (merchant.verificationStatus == 'pending') {
  return WaitingApprovalScreen(
    message: "Votre compte est en cours de vérification. Vous recevrez une notification dès validation."
  );
}
```

### Écran de rejet
```dart
if (merchant.verificationStatus == 'rejected') {
  return RejectedScreen(
    reason: merchant.rejectionReason,
    onContactSupport: () => openSupportChat()
  );
}
```

### Écran principal (approuvé)
```dart
if (merchant.verificationStatus == 'approved') {
  return MerchantDashboard();
}
```

---

## 📞 Support

Pour toute question sur le workflow de validation :
- **Email** : yahmardocheek@gmail.com
- **Documentation API** : `/swagger/` ou `/redoc/`
