# 💳 API Mobile Money - Documentation

## 📋 Résumé

Endpoints pour gérer les informations de paiement Mobile Money des drivers.

**Base URL** : `/api/v1/drivers/me/mobile-money/`  
**Authentification** : JWT Bearer Token (Driver uniquement)

---

## 🔌 Endpoints

### 1. GET - Récupérer informations Mobile Money

```http
GET /api/v1/drivers/me/mobile-money/
Authorization: Bearer <access_token>
```

**Réponse 200 OK** :
```json
{
  "mobile_money_number": "+225 07 12 34 56 78",
  "mobile_money_number_masked": "+225 07 XX XX XX 78",
  "mobile_money_provider": "orange",
  "mobile_money_provider_display": "Orange Money"
}
```

**Cas particulier** (si aucune info enregistrée) :
```json
{
  "mobile_money_number": null,
  "mobile_money_number_masked": null,
  "mobile_money_provider": "",
  "mobile_money_provider_display": ""
}
```

---

### 2. PATCH - Mettre à jour Mobile Money

```http
PATCH /api/v1/drivers/me/mobile-money/
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "mobile_money_number": "+225 07 12 34 56 78",
  "mobile_money_provider": "orange"
}
```

#### Providers acceptés

| Code | Nom complet |
|------|-------------|
| `orange` | Orange Money |
| `mtn` | MTN Money |
| `moov` | Moov Money |
| `wave` | Wave |

#### Formats numéro acceptés

✅ Valides :
- `+225 07 12 34 56 78`
- `+22507123456` 
- `07 12 34 56 78`
- `0712345678`
- `225 07 12 34 56 78`

❌ Invalides :
- `7123456` (trop court)
- `+221 77 123 45 67` (code pays Sénégal)
- `123456789012345` (trop long)

#### Validation

- **Obligatoire** : Les 2 champs (`mobile_money_number` ET `mobile_money_provider`) sont requis ensemble
- Si vous fournissez le numéro, le provider est obligatoire (et inversement)

**Réponse 200 OK** :
```json
{
  "success": true,
  "message": "Informations Mobile Money mises à jour",
  "data": {
    "mobile_money_number": "+225 07 12 34 56 78",
    "mobile_money_number_masked": "+225 07 XX XX XX 78",
    "mobile_money_provider": "orange",
    "mobile_money_provider_display": "Orange Money"
  }
}
```

**Réponse 400 Bad Request** (erreur validation) :
```json
{
  "error": {
    "mobile_money_number": [
      "Format de numéro invalide. Formats acceptés: +225 07 12 34 56 78, 0712345678, 07 12 34 56 78"
    ]
  }
}
```

**Réponse 400 Bad Request** (provider manquant) :
```json
{
  "error": {
    "non_field_errors": [
      "Vous devez fournir à la fois le numéro ET le provider Mobile Money"
    ]
  }
}
```

**Réponse 400 Bad Request** (provider invalide) :
```json
{
  "error": {
    "mobile_money_provider": [
      "Provider invalide. Choix: orange, mtn, moov, wave"
    ]
  }
}
```

---

## 🧪 Test avec cURL

### Récupérer les infos

```bash
curl -X GET \
  https://api.lebenis.com/api/v1/drivers/me/mobile-money/ \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..."
```

### Mettre à jour

```bash
curl -X PATCH \
  https://api.lebenis.com/api/v1/drivers/me/mobile-money/ \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..." \
  -H "Content-Type: application/json" \
  -d '{
    "mobile_money_number": "+225 07 12 34 56 78",
    "mobile_money_provider": "orange"
  }'
```

---

## 🔒 Sécurité

### Masquage du numéro

Le numéro Mobile Money est **masqué** lors de l'affichage via `mobile_money_number_masked` :
- Format original : `+225 07 12 34 56 78`
- Format masqué : `+225 07 XX XX XX 78`

**Règle** : Garde les **6 premiers** caractères et les **2 derniers**, masque le reste.

### Authentification

- Seul le **driver propriétaire** peut voir/modifier ses propres infos Mobile Money
- Requiert un **JWT token valide**
- Type d'utilisateur vérifié : `user_type = 'driver'`

---

## 📱 Intégration Flutter

### Modèle

```dart
class MobileMoneyInfo {
  final String? number;
  final String? numberMasked;
  final String? provider;
  final String? providerDisplay;

  MobileMoneyInfo({
    this.number,
    this.numberMasked,
    this.provider,
    this.providerDisplay,
  });

  factory MobileMoneyInfo.fromJson(Map<String, dynamic> json) {
    return MobileMoneyInfo(
      number: json['mobile_money_number'] as String?,
      numberMasked: json['mobile_money_number_masked'] as String?,
      provider: json['mobile_money_provider'] as String?,
      providerDisplay: json['mobile_money_provider_display'] as String?,
    );
  }
}
```

### Repository

```dart
class DriverRepository {
  Future<MobileMoneyInfo> getMobileMoneyInfo() async {
    final response = await _dioClient.get(
      '/api/v1/drivers/me/mobile-money/',
    );
    return MobileMoneyInfo.fromJson(response.data);
  }

  Future<void> updateMobileMoneyInfo({
    required String number,
    required String provider,
  }) async {
    await _dioClient.patch(
      '/api/v1/drivers/me/mobile-money/',
      data: {
        'mobile_money_number': number,
        'mobile_money_provider': provider,
      },
    );
  }
}
```

### Validation Flutter

```dart
String? validateMobileMoneyNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Entrez votre numéro Mobile Money';
  }

  // Nettoyer (garder seulement chiffres et +)
  final clean = value.replaceAll(RegExp(r'[^\d+]'), '');

  // Vérifier format CI
  final validPatterns = [
    RegExp(r'^\+225\d{10}$'),    // +225xxxxxxxxxx
    RegExp(r'^225\d{10}$'),      // 225xxxxxxxxxx
    RegExp(r'^0[0-9]\d{8}$'),    // 0xxxxxxxxx
    RegExp(r'^\d{10}$'),         // xxxxxxxxxx
  ];

  final isValid = validPatterns.any((pattern) => pattern.hasMatch(clean));

  if (!isValid) {
    return 'Format invalide. Ex: +225 07 12 34 56 78';
  }

  return null;
}
```

---

## 💡 Workflow complet

### 1. Driver renseigne ses infos

```
App Driver → ProfileScreen → MobileMoneyScreen
└─ Saisie numéro: +225 07 12 34 56 78
└─ Sélection provider: Orange Money
└─ Bouton "Enregistrer"
   └─ PATCH /api/v1/drivers/me/mobile-money/
      └─ Validation backend
         ✅ Succès: Infos enregistrées
         ❌ Échec: Message d'erreur
```

### 2. Admin voit les infos pour paiement

```sql
-- Requête admin pour voir les drivers avec Mobile Money
SELECT 
    u.first_name,
    u.last_name,
    d.mobile_money_number,
    d.mobile_money_provider,
    SUM(de.total_earning) as total_pending
FROM drivers d
JOIN users u ON d.user_id = u.id
LEFT JOIN driver_earnings de ON de.driver_id = d.id AND de.status = 'approved'
WHERE d.mobile_money_number IS NOT NULL
GROUP BY d.id, u.first_name, u.last_name, d.mobile_money_number, d.mobile_money_provider;
```

### 3. Admin effectue le paiement (manuel ou auto)

- **Manuel** : Admin copie le numéro, paie via app Orange Money
- **Auto** (Phase 2) : Backend appelle API Orange Money

---

## ✅ Checklist d'intégration

### Backend
- [x] Champs Mobile Money dans modèle Driver
- [x] Serializer MobileMoneySerializer avec validation
- [x] Endpoint GET/PATCH mobile_money
- [x] Validation format numéro CI
- [x] Masquage numéro pour affichage
- [x] Validation croisée numéro + provider

### Flutter
- [ ] Screen MobileMoneyScreen
- [ ] Dropdown providers avec icônes
- [ ] Input numéro avec validation
- [ ] Affichage info actuelle dans ProfileScreen
- [ ] Navigation depuis ProfileScreen
- [ ] Gestion erreurs et messages succès

---

## 🐛 Troubleshooting

### Erreur 404 Not Found

**Cause** : Driver non trouvé pour l'utilisateur connecté.

**Solution** : Vérifier que l'utilisateur a un profil Driver lié :
```python
# Django shell
from apps.authentication.models import User
user = User.objects.get(email='driver@test.com')
print(hasattr(user, 'driver_profile'))  # Doit être True
```

### Erreur 403 Forbidden

**Cause** : Utilisateur pas de type `driver`.

**Solution** : Vérifier le `user_type` :
```python
print(user.user_type)  # Doit être 'driver'
```

### Validation échoue malgré bon format

**Cause** : Espaces ou caractères invisibles.

**Solution** : Nettoyer la chaîne avant envoi :
```dart
final cleanNumber = phoneController.text.trim();
```

---

## 📊 Exemples de données

### Côte d'Ivoire

| Provider | Préfixe | Exemple |
|----------|---------|---------|
| Orange Money | 07, 67, 87, 97 | +225 07 12 34 56 78 |
| MTN Money | 05, 45, 55, 65, 75, 85, 95 | +225 05 12 34 56 78 |
| Moov Money | 01, 02, 40, 50, 60, 70 | +225 01 12 34 56 78 |

### Autres pays (futur)

| Pays | Code | Exemple |
|------|------|---------|
| Sénégal | +221 | +221 77 123 45 67 |
| Burkina Faso | +226 | +226 70 12 34 56 |
| Mali | +223 | +223 70 12 34 56 |

---

**✅ L'API Mobile Money est opérationnelle ! Il ne reste plus qu'à créer l'UI Flutter.**
