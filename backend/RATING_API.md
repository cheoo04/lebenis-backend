# 📊 API de Notation des Livreurs - Guide Complet

## 🎯 Vue d'ensemble

Ce système permet aux **marchands** de noter les livreurs après une livraison terminée.
La notation calcule automatiquement la **moyenne du livreur** pour son profil.

---

## 🔐 Authentification

Toutes les requêtes nécessitent un **JWT token** dans le header :

```http
Authorization: Bearer <votre_token_jwt>
```

---

## 📋 Endpoints

### 1️⃣ **Noter un livreur** (Merchants uniquement)

```http
POST /api/deliveries/{delivery_id}/rate-driver/
```

**Permissions** : Merchant (doit être propriétaire de la livraison)

**Conditions** :
- ✅ La livraison doit être à `status = delivered`
- ✅ L'utilisateur doit être le merchant de cette livraison
- ❌ Une livraison ne peut être notée qu'**une seule fois**

**Body (JSON)** :

```json
{
  "rating": 4.5,
  "comment": "Très professionnel, à l'heure",
  "punctuality_rating": 5,
  "professionalism_rating": 5,
  "care_rating": 4
}
```

**Champs** :

| Champ | Type | Obligatoire | Description |
|-------|------|-------------|-------------|
| `rating` | `float` | ✅ Oui | Note globale (1.0 - 5.0, paliers de 0.5) |
| `comment` | `string` | ❌ Non | Commentaire du marchand |
| `punctuality_rating` | `int` | ❌ Non | Ponctualité (1 - 5) |
| `professionalism_rating` | `int` | ❌ Non | Professionnalisme (1 - 5) |
| `care_rating` | `int` | ❌ Non | Soin du colis (1 - 5) |

**Réponse (201 Created)** :

```json
{
  "id": "uuid-123",
  "delivery": {
    "id": "uuid-456",
    "tracking_number": "LB-20250119-ABCDEF"
  },
  "merchant": {
    "id": "uuid-789",
    "business_name": "Supermarché Yopougon"
  },
  "driver": {
    "id": "uuid-012",
    "name": "Jean Kouassi",
    "rating": 4.7  // Nouvelle moyenne après cette notation
  },
  "rating": 4.5,
  "comment": "Très professionnel, à l'heure",
  "punctuality_rating": 5,
  "professionalism_rating": 5,
  "care_rating": 4,
  "created_at": "2025-01-19T14:30:00Z"
}
```

**Erreurs possibles** :

```json
// 400 Bad Request - Livraison non terminée
{
  "detail": "Vous ne pouvez noter que les livraisons terminées"
}

// 400 Bad Request - Déjà noté
{
  "detail": "Cette livraison a déjà été notée"
}

// 403 Forbidden - Pas le bon merchant
{
  "detail": "Vous ne pouvez noter que vos propres livraisons"
}

// 400 Bad Request - Note invalide
{
  "rating": ["La note doit être comprise entre 1.0 et 5.0 avec des paliers de 0.5"]
}
```

---

## 🧪 Tests avec cURL

### Créer une notation

```bash
curl -X POST http://localhost:8000/api/deliveries/uuid-delivery/rate-driver/ \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "rating": 4.5,
    "comment": "Livraison impeccable, très professionnel",
    "punctuality_rating": 5,
    "professionalism_rating": 5,
    "care_rating": 4
  }'
```

---

## 🔄 Logique métier

### Calcul automatique de la moyenne du livreur

Chaque fois qu'une nouvelle notation est créée :

1. Le signal `post_save` se déclenche sur `DeliveryRating`
2. Le système calcule la **moyenne de toutes les notes du livreur** :
   ```python
   driver.rating = avg(toutes les notes du livreur)
   ```
3. Le profil `Driver` est automatiquement mis à jour

### Exemple :

Si un livreur a les notes suivantes :
- Livraison 1 : 4.5 ⭐
- Livraison 2 : 5.0 ⭐
- Livraison 3 : 4.0 ⭐

→ `driver.rating = (4.5 + 5.0 + 4.0) / 3 = 4.5` ⭐

---

## 📊 Modèle de données

```python
class DeliveryRating(models.Model):
    delivery = models.OneToOneField(Delivery)  # Une seule notation par livraison
    merchant = models.ForeignKey(Merchant)      # Qui note
    driver = models.ForeignKey(Driver)          # Qui est noté
    rating = models.DecimalField(1.0 - 5.0)     # Note globale
    comment = models.TextField(blank=True)      # Commentaire
    
    # Critères détaillés
    punctuality_rating = models.IntegerField(1 - 5, null=True)
    professionalism_rating = models.IntegerField(1 - 5, null=True)
    care_rating = models.IntegerField(1 - 5, null=True)
```

---

## 🎨 Utilisation dans Flutter

### Écran de notation

```dart
// Afficher après livraison terminée
if (delivery.status == DeliveryStatus.delivered && 
    delivery.rating == null) {
  showRatingDialog(delivery);
}
```

### Envoyer la notation

```dart
Future<void> rateDriver(String deliveryId, double rating, String comment) async {
  final response = await _dio.post(
    '/deliveries/$deliveryId/rate-driver/',
    data: {
      'rating': rating,
      'comment': comment,
      'punctuality_rating': 5,
      'professionalism_rating': 5,
      'care_rating': 4,
    },
  );
  
  if (response.statusCode == 201) {
    // ✅ Notation envoyée
  }
}
```

---

## ✅ Points de contrôle

- [x] Modèle `DeliveryRating` créé
- [x] Migration appliquée
- [x] Serializer avec validation
- [x] Endpoint `POST /deliveries/{id}/rate-driver/`
- [x] Calcul automatique de la moyenne du livreur
- [x] Permissions (Merchant uniquement)
- [x] Admin Django enregistré

---

## 🚀 Prochaines étapes

1. **Flutter** : Créer l'écran de notation (RatingScreen)
2. **Flutter** : Intégrer avec `flutter_rating_bar`
3. **Tests** : Tester le calcul automatique de la moyenne
4. **UX** : Afficher la moyenne du livreur dans le profil

---

**Auteur** : LeBeni's Platform  
**Version** : 1.0 - Phase 1
