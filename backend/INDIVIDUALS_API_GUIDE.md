# API Documentation - Endpoints pour Particuliers

## 🎯 Vue d'ensemble

Cette documentation décrit les endpoints API spécifiques aux **particuliers** (utilisateurs de type `individual`).

---

## 🔐 Authentification

La plupart des endpoints nécessitent une authentification via JWT token.

**Headers requis:**

```
Authorization: Bearer <your_jwt_token>
```

**Exceptions (accès public):**

- `POST /api/v1/pricing/zones/calculate/` - Accessible sans authentification

---

## 📋 Endpoints Particuliers

### 1. Profil Particulier

#### GET /api/v1/individuals/profile/

Récupérer le profil du particulier connecté. Crée automatiquement le profil s'il n'existe pas.

**Authentification:** Requise

**Réponse:**

```json
{
  "id": "uuid",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "first_name": "Jean",
    "last_name": "Dupont",
    "user_type": "individual",
    "phone": "0123456789"
  },
  "address": "123 Rue Test, Abidjan",
  "full_name": "Jean Dupont",
  "phone": "0123456789",
  "email": "user@example.com",
  "created_at": "2025-12-06T10:00:00Z",
  "updated_at": "2025-12-06T10:00:00Z"
}
```

---

#### PATCH /api/v1/individuals/profile/

Mettre à jour le profil du particulier connecté.

**Authentification:** Requise

**Body:**

```json
{
  "first_name": "Jean-Pierre",
  "last_name": "Kouassi",
  "phone": "0987654321",
  "address": "456 Avenue Test, Cocody"
}
```

**Réponse:**

```json
{
  "id": "uuid",
  "user": {...},
  "address": "456 Avenue Test, Cocody",
  "full_name": "Jean-Pierre Kouassi",
  ...
}
```

---

### 2. Calcul de Prix

#### POST /api/v1/pricing/zones/calculate/

Calculer le prix d'une livraison entre deux communes.

**⚠️ Authentification:** NON requise (accès public)

**Body:**

```json
{
  "pickup_commune": "Cocody",
  "delivery_commune": "Treichville",
  "package_weight_kg": 2.5,
  "is_fragile": false,
  "scheduling_type": "immediate"
}
```

**Paramètres optionnels:**

- `pickup_latitude` (float): Latitude du point d'enlèvement
- `pickup_longitude` (float): Longitude du point d'enlèvement
- `delivery_latitude` (float): Latitude du point de livraison
- `delivery_longitude` (float): Longitude du point de livraison

**Réponse:**

```json
{
  "base_price": 1500.0,
  "distance_fee": 500.0,
  "weight_fee": 300.0,
  "fragile_fee": 0.0,
  "urgent_fee": 0.0,
  "total_price": 2300.0,
  "distance_km": 8.5,
  "estimated_duration_minutes": 25
}
```

**Codes de statut:**

- `200 OK`: Calcul réussi
- `400 Bad Request`: Données invalides
- `500 Internal Server Error`: Erreur serveur

---

### 3. Création de Livraison

#### POST /api/v1/deliveries/

Créer une nouvelle livraison en tant que particulier.

**Authentification:** Requise

**Body:**

```json
{
  "pickup_commune": "Cocody",
  "pickup_latitude": 5.3599,
  "pickup_longitude": -3.9569,
  "delivery_address": "456 Avenue Test",
  "delivery_commune": "Treichville",
  "delivery_quartier": "Zone 4",
  "delivery_latitude": 5.295,
  "delivery_longitude": -4.0265,
  "package_description": "Vêtements",
  "package_weight_kg": 2.5,
  "is_fragile": false,
  "recipient_name": "Marie Kouassi",
  "recipient_phone": "0789456123",
  "payment_method": "prepaid",
  "scheduling_type": "immediate"
}
```

**Champs requis:**

- `pickup_commune` (string): Commune d'enlèvement
- `delivery_address` (string): Adresse de livraison
- `delivery_commune` (string): Commune de livraison
- `package_weight_kg` (float): Poids du colis en kg
- `recipient_name` (string): Nom du destinataire
- `recipient_phone` (string): Téléphone du destinataire
- `payment_method` (string): `prepaid` ou `cod`

**Champs optionnels:**

- `pickup_latitude`, `pickup_longitude`: Coordonnées GPS d'enlèvement
- `delivery_latitude`, `delivery_longitude`: Coordonnées GPS de livraison
- `delivery_quartier` (string): Quartier de livraison
- `package_description` (string): Description du colis
- `is_fragile` (boolean): Colis fragile (défaut: false)
- `scheduling_type` (string): `immediate` ou `scheduled`
- `scheduled_pickup_time` (datetime): Heure d'enlèvement planifiée
- `cod_amount` (float): Montant à collecter (si payment_method=cod)

**Réponse:**

```json
{
  "id": "uuid",
  "tracking_number": "LB650155106849",
  "status": "pending_assignment",
  "calculated_price": 2300.00,
  "delivery_confirmation_code": "1234",
  "created_at": "2025-12-06T10:05:10Z",
  ...
}
```

**Codes de statut:**

- `201 Created`: Livraison créée avec succès
- `400 Bad Request`: Données invalides
- `401 Unauthorized`: Non authentifié

**Notes importantes pour les particuliers:**

- Le champ `merchant` sera automatiquement `null`
- Un code PIN à 4 chiffres est généré pour confirmer la livraison
- Le prix est calculé automatiquement selon les zones

---

### 4. Liste des Livraisons

#### GET /api/v1/deliveries/

Liste des livraisons du particulier connecté.

**Authentification:** Requise

**Paramètres de requête:**

- `status` (string): Filtrer par statut (pending, in_progress, delivered, cancelled)
- `page` (int): Numéro de page (pagination)

**Réponse:**

```json
{
  "count": 10,
  "next": "url_next_page",
  "previous": null,
  "results": [
    {
      "id": "uuid",
      "tracking_number": "LB650155106849",
      "status": "delivered",
      "calculated_price": 2300.00,
      ...
    }
  ]
}
```

---

### 5. Notifications

#### GET /api/v1/notifications/main/

Liste des notifications du particulier.

**Authentification:** Requise

**Réponse:**

```json
{
  "count": 5,
  "results": [
    {
      "id": "uuid",
      "title": "Livraison assignée",
      "message": "Votre livraison a été assignée à un livreur",
      "is_read": false,
      "created_at": "2025-12-06T10:00:00Z"
    }
  ]
}
```

---

#### POST /api/v1/notifications/main/mark-all-as-read/

Marquer toutes les notifications comme lues.

**Authentification:** Requise

**Body:** Aucun

**Réponse:**

```json
{
  "success": true,
  "message": "5 notification(s) marquée(s) comme lue(s)",
  "count": 5
}
```

---

## 🔄 Flux Typique pour un Particulier

### 1. Inscription/Connexion

```
POST /api/v1/auth/register/
POST /api/v1/auth/login/
```

### 2. Vérifier/Créer le Profil

```
GET /api/v1/individuals/profile/
```

### 3. Calculer le Prix (optionnel, sans auth)

```
POST /api/v1/pricing/zones/calculate/
```

### 4. Créer une Livraison

```
POST /api/v1/deliveries/
```

### 5. Suivre la Livraison

```
GET /api/v1/deliveries/{id}/
```

### 6. Consulter les Notifications

```
GET /api/v1/notifications/main/
```

---

## ❌ Gestion des Erreurs

### Erreurs Communes

#### 400 Bad Request

```json
{
  "error": "Message d'erreur descriptif",
  "details": {
    "field_name": ["Liste des erreurs"]
  }
}
```

#### 401 Unauthorized

```json
{
  "detail": "Authentication credentials were not provided."
}
```

#### 404 Not Found

```json
{
  "error": "Profil particulier introuvable"
}
```

#### 500 Internal Server Error

```json
{
  "error": "Erreur serveur",
  "details": "Description technique"
}
```

---

## 🔒 Différences Merchant vs Individual

| Endpoint                           | Merchant            | Individual          |
| ---------------------------------- | ------------------- | ------------------- |
| `/api/v1/merchants/`               | ✅ Accès            | ❌ Limité           |
| `/api/v1/individuals/profile/`     | ❌ Non              | ✅ Accès            |
| `/api/v1/deliveries/` (POST)       | ✅ avec merchant_id | ✅ merchant_id=null |
| `/api/v1/pricing/zones/calculate/` | ✅ Public           | ✅ Public           |

---

## 📝 Notes Techniques

### Base de Données

- Les livraisons des particuliers ont `merchant_id = NULL`
- Un profil `Individual` est créé automatiquement lors du premier accès
- Les coordonnées GPS sont optionnelles mais recommandées pour un calcul précis

### Sécurité

- Les particuliers ne peuvent voir que leurs propres livraisons
- Le calcul de prix est public pour faciliter l'UX
- Les tokens JWT expirent après 24h (refresh nécessaire)

### Performance

- Pagination par défaut: 20 résultats par page
- Cache activé sur le calcul de prix (5 minutes)

---

## 🧪 Exemples avec cURL

### Calculer un prix (sans auth)

```bash
curl -X POST http://localhost:8000/api/v1/pricing/zones/calculate/ \
  -H "Content-Type: application/json" \
  -d '{
    "pickup_commune": "Cocody",
    "delivery_commune": "Treichville",
    "package_weight_kg": 2.5,
    "is_fragile": false
  }'
```

### Créer une livraison (avec auth)

```bash
curl -X POST http://localhost:8000/api/v1/deliveries/ \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "pickup_commune": "Cocody",
    "delivery_address": "456 Avenue Test",
    "delivery_commune": "Treichville",
    "package_weight_kg": 2.5,
    "recipient_name": "Marie Kouassi",
    "recipient_phone": "0789456123",
    "payment_method": "prepaid"
  }'
```

---

## 📞 Support

Pour toute question ou problème :

- Email: support@lebenis.com
- Documentation complète: [À définir]
