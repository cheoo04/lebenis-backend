# 💰 Module de Paiement et Facturation - LeBeni's Group

## 📋 Vue d'ensemble

Ce module gère :
- **Facturation des commerçants** (invoices)
- **Rémunération des livreurs** (driver earnings)
- **Paiements groupés** (driver payments)

---

## 🏢 FACTURES COMMERÇANTS (Invoices)

### Endpoints disponibles

#### 1. Liste des factures
```http
GET /api/v1/payments/invoices/
Authorization: Bearer <token>
```

**Permissions** : Merchants voient leurs factures, Admins voient toutes

**Filtres** :
- `search`: Recherche par numéro ou nom de merchant
- `ordering`: Tri par `created_at`, `due_date`, `total_amount`

**Réponse** :
```json
{
  "count": 10,
  "results": [
    {
      "id": "uuid",
      "invoice_number": "INV-202501-0001",
      "merchant": {
        "id": "uuid",
        "business_name": "Restaurant Abidjan",
        "verification_status": "approved"
      },
      "period_start": "2025-01-01",
      "period_end": "2025-01-31",
      "total_deliveries": 45,
      "subtotal": "450000.00",
      "commission_rate": "15.00",
      "commission_amount": "67500.00",
      "tax_rate": "18.00",
      "tax_amount": "81000.00",
      "discount_amount": "0.00",
      "total_amount": "531500.00",
      "status": "sent",
      "due_date": "2025-02-15",
      "items": [
        {
          "id": "uuid",
          "delivery": {
            "tracking_number": "LBG-20250101-0001",
            "status": "delivered"
          },
          "description": "Livraison LBG-20250101-0001 - Cocody",
          "amount": "10000.00"
        }
      ],
      "created_at": "2025-01-31T23:59:00Z"
    }
  ]
}
```

---

#### 2. Mes factures (Merchant uniquement)
```http
GET /api/v1/payments/invoices/my-invoices/
Authorization: Bearer <merchant_token>
```

**Filtres** :
- `status`: `draft`, `sent`, `paid`, `overdue`, `cancelled`

---

#### 3. Créer une facture (Admin)
```http
POST /api/v1/payments/invoices/
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "merchant": "merchant_uuid",
  "period_start": "2025-01-01",
  "period_end": "2025-01-31",
  "commission_rate": "15.00",
  "tax_rate": "18.00",
  "discount_amount": "0.00",
  "due_date": "2025-02-15",
  "notes": "Facture mensuelle janvier 2025"
}
```

**Comportement** :
- Génère automatiquement le `invoice_number`
- Récupère toutes les livraisons `delivered` de la période
- Crée les `InvoiceItem` automatiquement
- Calcule les totaux (commission, taxes, montant final)

---

#### 4. Marquer comme payée (Admin)
```http
POST /api/v1/payments/invoices/{id}/mark-as-paid/
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "payment_method": "mobile_money",
  "payment_reference": "TRX123456"
}
```

**Méthodes de paiement** :
- `mobile_money` - Wave, Orange Money, MTN, Moov
- `bank_transfer` - Virement bancaire
- `cash` - Espèces
- `cheque` - Chèque

**Réponse** :
```json
{
  "success": true,
  "invoice_number": "INV-202501-0001",
  "paid_at": "2025-02-10T14:30:00Z",
  "amount": "531500.00"
}
```

---

#### 5. Générer toutes les factures mensuelles (Admin)
```http
POST /api/v1/payments/invoices/generate-monthly/
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "year": 2025,
  "month": 1
}
```

**Comportement** :
- Crée une facture pour chaque merchant ayant des livraisons
- Due date automatique : 15 jours après la fin du mois
- Ignore les merchants déjà facturés pour cette période

**Réponse** :
```json
{
  "success": true,
  "count": 12,
  "invoices": [...]
}
```

---

## 🚚 REVENUS LIVREURS (Driver Earnings)

### Endpoints disponibles

#### 1. Liste des gains
```http
GET /api/v1/payments/earnings/
Authorization: Bearer <token>
```

**Permissions** : Drivers voient leurs gains, Admins voient tous

**Réponse** :
```json
{
  "count": 50,
  "results": [
    {
      "id": "uuid",
      "driver": {
        "id": "uuid",
        "user": {
          "full_name": "Jean Kouassi",
          "phone": "+225 07 00 00 00 01"
        }
      },
      "delivery": {
        "tracking_number": "LBG-20250101-0001",
        "status": "delivered"
      },
      "base_earning": "2000.00",
      "distance_bonus": "500.00",
      "time_bonus": "300.00",
      "quality_bonus": "200.00",
      "other_bonus": "0.00",
      "penalty": "0.00",
      "penalty_reason": "",
      "total_earning": "3000.00",
      "status": "approved",
      "approved_at": "2025-01-02T10:00:00Z",
      "paid_at": null,
      "created_at": "2025-01-01T15:30:00Z"
    }
  ]
}
```

---

#### 2. Mes gains (Driver uniquement)
```http
GET /api/v1/payments/earnings/my-earnings/
Authorization: Bearer <driver_token>
```

**Filtres** :
- `status`: `pending`, `approved`, `paid`

---

#### 3. Résumé des gains (Driver)
```http
GET /api/v1/payments/earnings/summary/
Authorization: Bearer <driver_token>
```

**Réponse** :
```json
{
  "total_earnings": "150000.00",
  "pending_amount": "12000.00",
  "approved_amount": "38000.00",
  "paid_amount": "100000.00",
  "total_deliveries": 50,
  "pending_deliveries": 4
}
```

---

#### 4. Créer un gain (Admin)
```http
POST /api/v1/payments/earnings/
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "driver": "driver_uuid",
  "delivery": "delivery_uuid",
  "base_earning": "2000.00",
  "distance_bonus": "500.00",
  "time_bonus": "300.00",
  "quality_bonus": "200.00",
  "other_bonus": "0.00",
  "penalty": "0.00",
  "penalty_reason": "",
  "notes": "Livraison rapide et soignée"
}
```

---

#### 5. Approuver un gain (Admin)
```http
POST /api/v1/payments/earnings/{id}/approve/
Authorization: Bearer <admin_token>
```

**Réponse** :
```json
{
  "success": true,
  "earning_id": "uuid",
  "status": "approved",
  "approved_at": "2025-01-02T10:00:00Z"
}
```

---

#### 6. Approuver en masse (Admin)
```http
POST /api/v1/payments/earnings/bulk-approve/
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "earning_ids": ["uuid1", "uuid2", "uuid3"]
}
```

**Réponse** :
```json
{
  "success": true,
  "approved_count": 3
}
```

---

## 💳 PAIEMENTS LIVREURS (Driver Payments)

### Endpoints disponibles

#### 1. Liste des paiements
```http
GET /api/v1/payments/driver-payments/
Authorization: Bearer <admin_token>
```

---

#### 2. Créer un paiement groupé (Admin)
```http
POST /api/v1/payments/driver-payments/
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "driver": "driver_uuid",
  "period_start": "2025-01-01",
  "period_end": "2025-01-15",
  "payment_method": "mobile_money",
  "payment_reference": "PAY-123456",
  "notes": "Paiement quinzaine janvier"
}
```

**Comportement** :
- Génère automatiquement le `payment_number`
- Récupère tous les earnings `approved` non payés
- Marque automatiquement les earnings comme `paid`
- Calcule le montant total

---

#### 3. Marquer comme payé (Admin)
```http
POST /api/v1/payments/driver-payments/{id}/mark-as-paid/
Authorization: Bearer <admin_token>
```

---

## 🔐 Permissions

| Action | Merchant | Driver | Admin |
|--------|----------|--------|-------|
| Voir ses factures | ✅ | ❌ | ✅ |
| Créer factures | ❌ | ❌ | ✅ |
| Marquer factures payées | ❌ | ❌ | ✅ |
| Voir ses gains | ❌ | ✅ | ✅ |
| Créer gains | ❌ | ❌ | ✅ |
| Approuver gains | ❌ | ❌ | ✅ |
| Paiements groupés | ❌ | ❌ | ✅ |

---

## 📊 Workflow typique

### Pour les Merchants
1. **Fin du mois** : Admin génère les factures avec `generate-monthly`
2. **Réception** : Merchant voit sa facture dans `my-invoices`
3. **Paiement** : Merchant paie par Mobile Money
4. **Confirmation** : Admin marque la facture comme `paid`

### Pour les Drivers
1. **Livraison** : Driver termine une livraison
2. **Création du gain** : Admin crée un `DriverEarning` avec bonus/pénalités
3. **Approbation** : Admin approuve les gains (individuel ou en masse)
4. **Paiement groupé** : Admin crée un `DriverPayment` pour une période
5. **Réception** : Driver voit le paiement dans son wallet

---

## 🛠️ Modèles

### Invoice
- `invoice_number` : Numéro unique (auto-généré)
- `merchant` : Commerçant facturé
- `period_start`, `period_end` : Période de facturation
- `total_deliveries` : Nombre de livraisons (calculé)
- `subtotal` : Total avant commission et taxes
- `commission_rate`, `commission_amount` : Commission LeBeni's
- `tax_rate`, `tax_amount` : TVA (18%)
- `total_amount` : Montant final
- `status` : `draft`, `sent`, `paid`, `overdue`, `cancelled`

### DriverEarning
- `driver` : Livreur
- `delivery` : Livraison concernée
- `base_earning` : Montant de base
- `distance_bonus`, `time_bonus`, `quality_bonus` : Bonus
- `penalty` : Pénalité éventuelle
- `total_earning` : Total (calculé)
- `status` : `pending`, `approved`, `paid`

### DriverPayment
- `payment_number` : Numéro unique (auto-généré)
- `driver` : Livreur payé
- `period_start`, `period_end` : Période du paiement
- `total_deliveries` : Nombre de livraisons payées
- `total_amount` : Montant total (calculé)
- `status` : `pending`, `paid`

---

## ✅ Règles métier

1. **Factures** :
   - Une livraison ne peut être facturée qu'une seule fois
   - Les factures ne peuvent être créées que pour des livraisons `delivered`
   - Le due_date par défaut est 15 jours après `period_end`

2. **Gains livreurs** :
   - Un gain ne peut être approuvé qu'une fois
   - Un gain approuvé ne peut plus être modifié
   - Le `total_earning` est calculé automatiquement

3. **Paiements** :
   - Seuls les gains `approved` peuvent être payés
   - Un gain payé ne peut plus être modifié
   - Les paiements groupent plusieurs gains sur une période

---

## 📝 Notes d'implémentation

- Tous les montants utilisent `DecimalField(max_digits=12, decimal_places=2)`
- Les transactions de paiement utilisent `@transaction.atomic`
- Les calculs sont faits côté serveur (pas côté client)
- Les logs sont activés pour chaque action financière
- Les timestamps utilisent `timezone.now()`
