# 🧡 Orange Money API - Guide d'Intégration Sandbox

## 🎯 Vue d'ensemble

Ce guide explique comment intégrer l'API Orange Money Côte d'Ivoire en mode **Sandbox** (gratuit pour tests).

**Documentation officielle** : https://developer.orange.com/apis/orange-money-webpay/

---

## 📋 Prérequis

### 1. Créer un compte développeur Orange

1. Aller sur https://developer.orange.com
2. S'inscrire (gratuit)
3. Confirmer l'email

### 2. Créer une application

1. **Dashboard** → **My Apps** → **Add New App**
2. Nom : `LeBeni's Delivery Platform`
3. Description : `Plateforme de livraison avec paiements Mobile Money`
4. **APIs** → Sélectionner :
   - ✅ Orange Money Web Pay API
   - ✅ Orange Money Payout API (pour versements livreurs)

5. **Submit** → Récupérer les credentials :

```
CLIENT_ID: XXXXXXXXXXXXXXXXXXXXXXXX
CLIENT_SECRET: YYYYYYYYYYYYYYYYYYYY
```

---

## 🔧 Configuration Backend Django

### 1. Ajouter les credentials dans `.env`

```bash
# Orange Money Sandbox
ORANGE_MONEY_CLIENT_ID=your_client_id_here
ORANGE_MONEY_CLIENT_SECRET=your_client_secret_here
ORANGE_MONEY_BASE_URL=https://api.orange.com/orange-money-webpay/ci/v1
ORANGE_MONEY_MERCHANT_KEY=your_merchant_key  # Fourni par Orange après validation
ORANGE_MONEY_ENVIRONMENT=sandbox  # ou 'production'
```

### 2. Installer les dépendances

```bash
pip install requests
```

---

## 🏗️ Architecture Orange Money

### Flux de Paiement (Collection)

```
1. Client démarre paiement → LeBeni's Backend
2. Backend appelle Orange Money API → Initiate Payment
3. Client reçoit USSD prompt sur son téléphone
4. Client entre son PIN Orange Money
5. Orange Money envoie webhook → LeBeni's Backend
6. Backend met à jour statut payment → 'completed'
```

### Flux de Versement (Disbursement)

```
1. Cron job 23h59 → Calcule earnings livreur
2. Backend appelle Orange Money API → Transfer Money
3. Argent transféré vers compte Orange Money livreur
4. Livreur reçoit SMS de confirmation
5. Backend met à jour DailyPayout → 'completed'
```

---

## 🔑 Endpoints Orange Money API

### 1. **Obtenir un Access Token**

```http
POST https://api.orange.com/oauth/v3/token
Content-Type: application/x-www-form-urlencoded
Authorization: Basic base64(client_id:client_secret)

grant_type=client_credentials
```

**Réponse** :
```json
{
  "access_token": "i6m2iIcY0SodWSe...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

### 2. **Initier un Paiement (Collection)**

```http
POST https://api.orange.com/orange-money-webpay/ci/v1/webpayment
Authorization: Bearer {access_token}
Content-Type: application/json

{
  "merchant_key": "your_merchant_key",
  "currency": "OUV",  // XOF pour FCFA
  "order_id": "LB-20250119-ABCD",
  "amount": 2000,
  "return_url": "https://lebenis.com/payment/success",
  "cancel_url": "https://lebenis.com/payment/cancel",
  "notif_url": "https://api.lebenis.com/webhooks/orange-money",
  "lang": "fr",
  "reference": "Livraison #LB-20250119-ABCD"
}
```

**Réponse** :
```json
{
  "payment_url": "https://webpayment.orange-money.com/...",
  "pay_token": "abc123def456",
  "notif_token": "xyz789"
}
```

### 3. **Vérifier le statut d'un paiement**

```http
GET https://api.orange.com/orange-money-webpay/ci/v1/transactionstatus/{order_id}
Authorization: Bearer {access_token}
```

**Réponse** :
```json
{
  "status": "SUCCESS",  // ou PENDING, FAILED
  "txnid": "MP200119.1234.A12345"
}
```

### 4. **Effectuer un Transfert (Disbursement)**

```http
POST https://api.orange.com/orange-money-webpay/ci/v1/cashout
Authorization: Bearer {access_token}

{
  "merchant_key": "your_merchant_key",
  "currency": "OUV",
  "order_id": "PAYOUT-20250119-001",
  "amount": 1600,
  "receiver_phone": "+2250701234567",  // Numéro Orange Money livreur
  "reference": "Paiement livreur Jean Kouassi"
}
```

---

## 🧪 Numéros de Test Sandbox

Orange Money fournit des numéros de test pour le sandbox :

| Numéro | PIN | Résultat |
|--------|-----|----------|
| +225 07 00 00 01 | 0000 | ✅ Succès |
| +225 07 00 00 02 | 0000 | ❌ Échec (fonds insuffisants) |
| +225 07 00 00 03 | 0000 | ⏳ Timeout |

---

## 📊 Codes de Statut

| Code | Signification |
|------|---------------|
| `200` | Transaction réussie |
| `201` | Paiement initié (en attente confirmation) |
| `400` | Requête invalide |
| `401` | Non autorisé (token invalide) |
| `403` | Interdit (merchant_key invalide) |
| `404` | Transaction non trouvée |
| `500` | Erreur serveur Orange Money |

---

## 🔔 Webhooks

Orange Money envoie des webhooks pour notifier l'état des paiements :

```http
POST https://api.lebenis.com/webhooks/orange-money
Content-Type: application/json

{
  "order_id": "LB-20250119-ABCD",
  "amount": 2000,
  "txnid": "MP200119.1234.A12345",
  "status": "SUCCESS",
  "currency": "OUV",
  "notif_token": "xyz789"
}
```

**Répondre avec** :
```json
{
  "status": "OK"
}
```

---

## 💰 Frais de Transaction

| Service | Frais Sandbox | Frais Production |
|---------|---------------|------------------|
| Collection (client paie) | Gratuit | 1-2% |
| Disbursement (versement livreur) | Gratuit | 1-2% |
| Transfert P2P | Gratuit | 1-2% |

---

## 🚀 Mise en Production

### Checklist avant production :

- [ ] Compte Orange Money Business validé
- [ ] `merchant_key` production obtenu
- [ ] Webhooks configurés avec HTTPS
- [ ] Tests avec vrais numéros Orange Money
- [ ] Gestion des erreurs et retry logic
- [ ] Logs et monitoring configurés

### Changer en production :

```python
# settings/production.py
ORANGE_MONEY_BASE_URL = "https://api.orange.com/orange-money-webpay/ci/v1"
ORANGE_MONEY_ENVIRONMENT = "production"
```

---

## ✅ Prochaines Étapes

1. ✅ Créer compte développeur Orange
2. ✅ Obtenir CLIENT_ID et CLIENT_SECRET
3. ✅ Configurer `.env`
4. ⏳ Créer `orange_money_service.py`
5. ⏳ Implémenter webhooks
6. ⏳ Tester en sandbox

---

**Auteur** : LeBeni's Platform  
**Version** : 1.0 - Phase 2  
**Documentation Orange** : https://developer.orange.com
