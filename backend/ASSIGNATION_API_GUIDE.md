# 📦 Guide d'utilisation du système d'assignation LeBeni's Group

## 🎯 Vue d'ensemble

Le système d'assignation des livreurs est maintenant pleinement fonctionnel avec les fonctionnalités suivantes :

- ✅ **Assignation manuelle** par les administrateurs
- ✅ **Assignation automatique** intelligente basée sur plusieurs critères
- ✅ **Acceptation/Refus** par les livreurs
- ✅ **Réassignation** en cas de besoin
- ✅ **Permissions adaptées** par rôle (Merchant/Driver/Admin)

---

## 🔐 Permissions par rôle

| Action | Merchant | Driver | Admin |
|--------|----------|--------|-------|
| Créer une livraison | ✅ | ❌ | ✅ |
| Assigner un livreur | ❌ | ❌ | ✅ |
| Auto-assigner | ❌ | ❌ | ✅ |
| Accepter une livraison | ❌ | ✅ | ❌ |
| Refuser une livraison | ❌ | ✅ | ❌ |
| Voir ses livraisons | ✅ | ✅ | ✅ |
| Voir toutes les livraisons | ❌ | ❌ | ✅ |

---

## 📡 Endpoints disponibles

### 1️⃣ **Pour les MARCHANDS (Merchants)**

#### Créer une nouvelle livraison
```http
POST /api/v1/deliveries/
Authorization: Bearer <merchant_token>
Content-Type: application/json

{
  "delivery_address": "123 Rue de la Paix",
  "delivery_commune": "Cocody",
  "delivery_quartier": "Riviera",
  "package_description": "Électronique fragile",
  "package_weight_kg": 3.5,
  "is_fragile": true,
  "recipient_name": "Jean Kouassi",
  "recipient_phone": "+225 0123456789",
  "recipient_alternative_phone": "+225 0987654321",
  "payment_method": "cod",
  "cod_amount": 50000,
  "scheduling_type": "immediate"
}
```

**Réponse (201 Created) :**
```json
{
  "id": "uuid-de-la-livraison",
  "tracking_number": "LB1730462412345",
  "status": "pending_assignment",
  "calculated_price": 2500,
  "merchant": { ... },
  "driver": null,
  "created_at": "2025-11-01T10:30:00Z"
}
```

#### Voir mes livraisons
```http
GET /api/v1/deliveries/
Authorization: Bearer <merchant_token>
```

---

### 2️⃣ **Pour les ADMINISTRATEURS (Admins)**

#### Assigner manuellement un livreur
```http
POST /api/v1/deliveries/{delivery_id}/assign/
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "driver_id": "uuid-du-livreur"
}
```

**Réponse (200 OK) :**
```json
{
  "success": true,
  "delivery_id": "...",
  "tracking_number": "LB1730462412345",
  "driver_name": "Kouadio Yao",
  "driver_phone": "+225 0711223344",
  "previous_driver": null,
  "assigned_at": "2025-11-01T10:35:00Z"
}
```

#### Auto-assigner le meilleur livreur disponible
```http
POST /api/v1/deliveries/{delivery_id}/auto-assign/
Authorization: Bearer <admin_token>
```

**Réponse (200 OK) :**
```json
{
  "success": true,
  "delivery_id": "...",
  "tracking_number": "LB1730462412345",
  "driver_name": "Kouadio Yao",
  "driver_phone": "+225 0711223344",
  "driver_rating": 4.85,
  "assigned_at": "2025-11-01T10:35:00Z"
}
```

#### Réassigner à un autre livreur
```http
POST /api/v1/deliveries/{delivery_id}/reassign/
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "driver_id": "uuid-du-nouveau-livreur",
  "reason": "Le premier livreur a un problème mécanique"
}
```

#### Voir les livreurs disponibles par zone
```http
GET /api/v1/drivers/available/?commune=Cocody&min_rating=4.0
Authorization: Bearer <admin_token>
```

**Réponse :**
```json
{
  "count": 5,
  "drivers": [
    {
      "id": "...",
      "user": {
        "full_name": "Kouadio Yao",
        "phone": "+225 0711223344"
      },
      "vehicle_type": "moto",
      "rating": 4.85,
      "is_available": true,
      "total_deliveries": 234,
      "successful_deliveries": 228
    },
    ...
  ],
  "filters": {
    "commune": "Cocody",
    "min_rating": "4.0"
  }
}
```

---

### 3️⃣ **Pour les LIVREURS (Drivers)**

#### Voir mes livraisons assignées
```http
GET /api/v1/drivers/my-deliveries/
Authorization: Bearer <driver_token>

# Filtres optionnels :
GET /api/v1/drivers/my-deliveries/?status=assigned,pickup_in_progress
GET /api/v1/drivers/my-deliveries/?date_from=2025-11-01&date_to=2025-11-30
```

**Réponse :**
```json
{
  "count": 12,
  "results": [
    {
      "id": "...",
      "tracking_number": "LB1730462412345",
      "status": "assigned",
      "delivery_address": "123 Rue de la Paix",
      "delivery_commune": "Cocody",
      "recipient_name": "Jean Kouassi",
      "recipient_phone": "+225 0123456789",
      "calculated_price": 2500,
      "package_weight_kg": 3.5,
      "is_fragile": true,
      "assigned_at": "2025-11-01T10:35:00Z"
    },
    ...
  ]
}
```

#### Voir les livraisons disponibles dans mes zones
```http
GET /api/v1/drivers/available-deliveries/
Authorization: Bearer <driver_token>
```

**Réponse :**
```json
{
  "count": 8,
  "deliveries": [ ... ],
  "driver_zones": ["Cocody", "Plateau", "Marcory"]
}
```

#### Accepter une livraison assignée
```http
POST /api/v1/deliveries/{delivery_id}/accept/
Authorization: Bearer <driver_token>
```

**Réponse (200 OK) :**
```json
{
  "success": true,
  "message": "Livraison acceptée avec succès",
  "new_status": "pickup_in_progress"
}
```

#### Refuser une livraison
```http
POST /api/v1/deliveries/{delivery_id}/reject/
Authorization: Bearer <driver_token>
Content-Type: application/json

{
  "reason": "Je ne peux pas récupérer le colis à temps"
}
```

**Réponse (200 OK) :**
```json
{
  "success": true,
  "message": "Livraison refusée",
  "new_status": "pending_assignment"
}
```

#### Mettre à jour ma position GPS
```http
POST /api/v1/drivers/update-location/
Authorization: Bearer <driver_token>
Content-Type: application/json

{
  "latitude": 5.3467,
  "longitude": -4.0305
}
```

#### Changer ma disponibilité
```http
POST /api/v1/drivers/toggle-availability/
Authorization: Bearer <driver_token>
Content-Type: application/json

{
  "is_available": true
}
```

**Réponse :**
```json
{
  "success": true,
  "is_available": true,
  "message": "Vous êtes maintenant disponible"
}
```

---

## 🤖 Algorithme d'assignation automatique

L'algorithme `auto_assign` sélectionne le meilleur livreur selon les critères suivants (par ordre de priorité) :

1. ✅ **Vérifié** (`verification_status = 'verified'`)
2. ✅ **Disponible** (`is_available = True`)
3. ✅ **Capacité suffisante** (`vehicle_capacity_kg >= package_weight_kg`)
4. ✅ **Travaille dans la zone** (communes définies dans `DriverZone`)
5. ✅ **Moins de livraisons en cours** (priorité aux moins chargés)
6. ✅ **Meilleur rating** (note de 0 à 5)
7. ✅ **Plus d'expérience** (`successful_deliveries`)

**Exemple de sélection :**

Livraison pour **Cocody** :
- ✅ Driver A : Zone Cocody, Rating 4.8, 2 livraisons actives → **CHOISI**
- ❌ Driver B : Zone Plateau, Rating 5.0, 1 livraison active (hors zone)
- ❌ Driver C : Zone Cocody, Rating 4.5, 5 livraisons actives (trop chargé)

---

## 🔄 Workflow complet d'une livraison

```
1. Merchant crée une livraison
   ↓ (status: pending_assignment)

2. Admin assigne un livreur (manuel ou auto)
   ↓ (status: assigned)
   ↓ Notification envoyée au driver

3. Driver accepte la livraison
   ↓ (status: pickup_in_progress)
   ↓ Notification au merchant

4. Driver récupère le colis
   ↓ (status: picked_up)

5. Driver en route vers le client
   ↓ (status: in_transit)

6. Driver livre le colis
   ↓ (status: delivered)
   ↓ Preuve de livraison (signature/photo)
```

**Cas alternatif :**
- Si le driver **refuse** → retour à `pending_assignment`
- Si problème → **réassignation** à un autre driver

---

## 📊 Statistiques et monitoring

### Livraisons non assignées
```http
GET /api/v1/deliveries/?status=pending_assignment
Authorization: Bearer <admin_token>
```

### Performance d'un livreur
```http
GET /api/v1/drivers/{driver_id}/
Authorization: Bearer <admin_token>
```

Retourne :
- `total_deliveries` : Nombre total de livraisons
- `successful_deliveries` : Livraisons réussies
- `rating` : Note moyenne (0-5)

---

## 🧪 Tests avec cURL

### Test d'assignation automatique
```bash
# 1. Créer une livraison (en tant que merchant)
curl -X POST http://localhost:8000/api/v1/deliveries/ \
  -H "Authorization: Bearer <merchant_token>" \
  -H "Content-Type: application/json" \
  -d '{
    "delivery_commune": "Cocody",
    "delivery_address": "Riviera Palmeraie",
    "package_weight_kg": 2.5,
    "recipient_name": "Test User",
    "recipient_phone": "+225 0123456789",
    "payment_method": "prepaid",
    "scheduling_type": "immediate"
  }'

# 2. Auto-assigner (en tant qu'admin)
curl -X POST http://localhost:8000/api/v1/deliveries/<delivery_id>/auto-assign/ \
  -H "Authorization: Bearer <admin_token>"

# 3. Accepter (en tant que driver)
curl -X POST http://localhost:8000/api/v1/deliveries/<delivery_id>/accept/ \
  -H "Authorization: Bearer <driver_token>"
```

---

## ⚠️ Gestion des erreurs

### Erreur : Aucun livreur disponible
```json
{
  "error": "Aucun livreur disponible pour la zone 'Cocody'"
}
```
**Solution :** Créer des livreurs dans cette zone ou utiliser l'assignation manuelle.

### Erreur : Le livreur n'est pas vérifié
```json
{
  "error": "Le livreur Kouadio Yao n'est pas vérifié"
}
```
**Solution :** Changer le `verification_status` du driver à `'verified'`.

### Erreur : Capacité insuffisante
```json
{
  "error": "Le colis (50 kg) dépasse la capacité du véhicule (30 kg)"
}
```
**Solution :** Assigner un livreur avec un véhicule plus grand.

---

## 🔧 Configuration requise

### 1. Créer des zones pour les livreurs
```python
# Via Django Admin ou API
DriverZone.objects.create(
    driver=driver,
    commune="Cocody",
    priority=1
)
```

### 2. Activer la disponibilité
```python
driver.is_available = True
driver.save()
```

### 3. Vérifier le livreur
```python
driver.verification_status = 'verified'
driver.save()
```

---

## 📝 Notes importantes

- **Notifications** : Toutes les actions d'assignation créent des notifications automatiques
- **Logs** : Chaque assignation est loguée avec contexte complet (tracking_number, driver, commune)
- **Transactions** : Toutes les opérations sont atomiques (tout ou rien)
- **Sécurité** : Permissions strictes par rôle (IsMerchant, IsDriver, IsAdmin)

---

## 🚀 Prochaines améliorations possibles

- [ ] Assignation basée sur la distance GPS réelle
- [ ] Regroupement intelligent de plusieurs livraisons (tournée)
- [ ] Score de proximité pour l'assignation automatique
- [ ] Historique des assignations refusées
- [ ] Dashboard temps réel des assignations

---

**Développé pour LeBeni's Group** 📦
*Système d'assignation intelligent pour la logistique B2B2C*
