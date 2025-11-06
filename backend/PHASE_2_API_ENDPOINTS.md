# Phase 2 - API Endpoints Documentation

**Backend URL**: `http://localhost:8000/api/v1`  
**Commission**: 20% LeBeni's / 80% Driver  
**Payout Schedule**: Daily at 23:59  

---

## 📱 Mobile Money Payments

### Base URL: `/api/v1/payments/payments/`

All endpoints require authentication with `IsDriver` permission.

---

### 1. My Earnings

**GET** `/api/v1/payments/payments/my-earnings/`

Affiche les gains du driver pour une période donnée.

**Query Parameters**:
- `period` (optional): `today`, `week`, `month` (default: `today`)

**Response**:
```json
{
  "period": "today",
  "period_label": "Aujourd'hui",
  "total_amount": "15000.00",
  "driver_amount": "12000.00",
  "commission_amount": "3000.00",
  "payment_count": 5,
  "payments": [
    {
      "id": "uuid",
      "driver": {...},
      "delivery": {...},
      "amount": "3000.00",
      "driver_amount": "2400.00",
      "commission_amount": "600.00",
      "commission_percentage": "20%",
      "payment_method": "orange_money",
      "phone_number": "+2250701234567",
      "status": "completed",
      "provider_reference": "TRX123456",
      "paid_at": "2025-01-24T10:30:00Z",
      "created_at": "2025-01-24T10:00:00Z"
    }
  ]
}
```

**Use Case**: Dashboard driver - Section "Mes gains du jour"

---

### 2. My Payouts

**GET** `/api/v1/payments/payments/my-payouts/`

Affiche l'historique des versements quotidiens (23h59).

**Query Parameters**:
- `limit` (optional): Number of records (default: 30)

**Response**:
```json
{
  "payouts": [
    {
      "id": "uuid",
      "driver": {...},
      "payout_date": "2025-01-24",
      "total_amount": "25000.00",
      "payment_count": 10,
      "payment_method": "orange_money",
      "phone_number": "+2250701234567",
      "status": "completed",
      "status_display": "Complété",
      "provider_reference": "PAYOUT_20250124",
      "paid_at": "2025-01-24T23:59:00Z",
      "created_at": "2025-01-24T23:59:00Z"
    }
  ],
  "count": 30
}
```

**Use Case**: Page "Historique des paiements"

---

### 3. Stats

**GET** `/api/v1/payments/payments/stats/`

Statistiques globales des revenus du driver.

**Response**:
```json
{
  "lifetime": {
    "total_earnings": "500000.00",
    "total_deliveries": 150
  },
  "this_month": {
    "earnings": "85000.00",
    "deliveries": 28
  },
  "last_month": {
    "earnings": "120000.00",
    "deliveries": 35
  },
  "payment_methods": {
    "orange_money": "250000.00",
    "mtn_money": "150000.00",
    "moov_money": "50000.00",
    "wave": "30000.00",
    "cash": "20000.00"
  }
}
```

**Use Case**: 
- Page "Mes statistiques"
- Graphiques de répartition des revenus

---

### 4. Transactions

**GET** `/api/v1/payments/payments/transactions/`

Historique complet des transactions (audit trail).

**Query Parameters**:
- `limit` (optional): Number of records (default: 50)

**Response**:
```json
{
  "transactions": [
    {
      "id": "uuid",
      "payment": {
        "id": "uuid",
        "delivery": {...},
        "amount": "10000.00"
      },
      "transaction_type": "collection",
      "transaction_type_display": "Collecte client",
      "amount": "10000.00",
      "status": "success",
      "status_display": "Succès",
      "provider_reference": "TRX123456",
      "error_message": null,
      "created_at": "2025-01-24T10:30:00Z"
    }
  ],
  "count": 50
}
```

**Transaction Types**:
- `collection` - Client paie via Mobile Money → LeBeni's
- `disbursement` - LeBeni's transfère au driver → Driver account
- `refund` - Remboursement client

**Use Case**: Page "Détails des transactions" pour réconciliation

---

## 🔔 Notification History

### Base URL: `/api/v1/notifications/history/`

---

### 1. List Notifications

**GET** `/api/v1/notifications/history/`

Liste toutes les notifications du driver.

**Response**:
```json
[
  {
    "id": "uuid",
    "user": {...},
    "notification_type": "payment_received",
    "title": "Paiement reçu",
    "body": "Vous avez reçu 12,000 CFA pour la livraison #TRK123",
    "data": {
      "payment_id": "uuid",
      "amount": "12000.00"
    },
    "action": "view_payment",
    "action_url": "/payments/uuid",
    "is_read": false,
    "read_at": null,
    "sent_via_fcm": true,
    "fcm_message_id": "projects/.../messages/...",
    "created_at": "2025-01-24T10:30:00Z"
  }
]
```

---

### 2. Mark as Read

**POST** `/api/v1/notifications/history/{id}/mark_as_read/`

Marque une notification comme lue.

**Response**:
```json
{
  "success": true,
  "is_read": true,
  "read_at": "2025-01-24T11:00:00Z"
}
```

---

### 3. Mark All as Read

**POST** `/api/v1/notifications/history/mark_all_as_read/`

Marque toutes les notifications comme lues.

**Response**:
```json
{
  "success": true,
  "updated_count": 12
}
```

---

### 4. Unread Count

**GET** `/api/v1/notifications/history/unread_count/`

Compte les notifications non lues (pour badge).

**Response**:
```json
{
  "unread_count": 5
}
```

---

### 5. Delete Notification

**DELETE** `/api/v1/notifications/history/{id}/`

Supprime une notification.

**Response**: `204 No Content`

---

## 🚶 Break Management

### Base URL: `/api/v1/drivers/`

---

### 1. Start Break

**POST** `/api/v1/drivers/start-break/`

Démarre une pause.

**Response**:
```json
{
  "success": true,
  "is_on_break": true,
  "break_started_at": "2025-01-24T12:00:00Z",
  "availability_status": "on_break"
}
```

**Side Effects**:
- `is_on_break` → `true`
- `break_started_at` → current time
- `availability_status` → `on_break`

---

### 2. End Break

**POST** `/api/v1/drivers/end-break/`

Termine la pause.

**Response**:
```json
{
  "success": true,
  "is_on_break": false,
  "break_duration_seconds": 1800,
  "break_duration_minutes": 30,
  "total_break_today_seconds": 3600,
  "total_break_today_minutes": 60,
  "availability_status": "available"
}
```

**Side Effects**:
- `is_on_break` → `false`
- `total_break_duration_today` → incremented
- `availability_status` → `available`

---

### 3. Break Status

**GET** `/api/v1/drivers/break-status/`

Statut actuel de pause.

**Response** (si en pause):
```json
{
  "is_on_break": true,
  "break_started_at": "2025-01-24T12:00:00Z",
  "current_break_duration_seconds": 900,
  "current_break_duration_minutes": 15,
  "total_break_today_seconds": 2700,
  "total_break_today_minutes": 45
}
```

**Response** (si pas en pause):
```json
{
  "is_on_break": false,
  "total_break_today_seconds": 2700,
  "total_break_today_minutes": 45
}
```

**Reset**: `total_break_today` resets to 0 at midnight automatically.

---

## 🔗 Webhooks

### Orange Money Webhook

**POST** `/api/v1/payments/webhooks/orange-money/`

Reçoit les notifications de paiement d'Orange Money API.

**Request Body** (from Orange Money):
```json
{
  "order_id": "DEL_20250124_123",
  "status": "SUCCESS",
  "amount": 10000,
  "reference": "TRX123456",
  "timestamp": "2025-01-24T10:30:00Z",
  "signature": "hmac_signature_here"
}
```

**Status Values**:
- `SUCCESS` → Payment status = `completed`
- `FAILED` → Payment status = `failed`
- `PENDING` → Payment status = `processing`

**Response**:
```json
{
  "success": true,
  "order_id": "DEL_20250124_123",
  "status": "completed"
}
```

**Side Effects**:
1. Updates `Payment.status`
2. Creates `TransactionHistory` entry
3. Sends `NotificationHistory` to driver (FCM + DB)

**Security**:
- **Production**: HMAC signature validation required
- **Sandbox**: Signature validation skipped

---

## 🔐 Authentication

All endpoints require JWT token in header:

```http
Authorization: Bearer <access_token>
```

**Permissions**:
- Payment endpoints: `IsDriver`
- Notification endpoints: `IsAuthenticated`
- Break endpoints: `IsDriver`
- Webhook: No auth (public, validated by signature)

---

## 📊 Payment Flow

```
1. Customer pays via Mobile Money
   ↓
2. Orange Money webhook → /webhooks/orange-money/
   ↓
3. Payment status updated → completed
   ↓
4. TransactionHistory created
   ↓
5. NotificationHistory sent to driver (FCM + DB)
   ↓
6. Driver sees in /my-earnings/
   ↓
7. At 23:59 → Celery task creates DailyPayout
   ↓
8. OrangeMoneyService.transfer_to_driver()
   ↓
9. Driver receives money in Mobile Money account
   ↓
10. Driver sees in /my-payouts/
```

---

## 🧪 Testing in Sandbox

### Orange Money Sandbox

1. **Get credentials**: https://developer.orange.com
2. **Set environment**:
   ```bash
   ORANGE_MONEY_ENVIRONMENT=sandbox
   ```
3. **Test numbers**: Use Orange sandbox test numbers
4. **No real money**: All transactions are simulated

### Test Webhook Locally

Use ngrok to expose local server:

```bash
ngrok http 8000
```

Then register webhook URL with Orange:
```
https://your-ngrok-url.ngrok.io/api/v1/payments/webhooks/orange-money/
```

---

## 📝 Notes

- **Commission**: 20% auto-calculated on `Payment.save()`
- **Payout time**: 23:59 daily (Celery task - TO BE IMPLEMENTED)
- **Phone format**: Auto-normalized to `+225XXXXXXXX` for Côte d'Ivoire
- **FCM**: All notifications sent via FCM AND stored in DB
- **Break reset**: Automatic at midnight

---

**Documentation Version**: 1.0  
**Last Updated**: Phase 2 Backend - 80% complete
