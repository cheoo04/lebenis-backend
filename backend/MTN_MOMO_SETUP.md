# MTN Mobile Money - Guide de Configuration

## 📋 Vue d'ensemble

MTN Mobile Money est intégré dans LeBeni's Platform pour permettre :
- **Collection** : Client paie via MTN MoMo
- **Disbursement** : Transfert automatique vers les drivers
- **Webhooks** : Notifications en temps réel

---

## 🔑 Créer un Compte Sandbox MTN

### 1. Inscription MTN Developer Portal

1. Aller sur : https://momodeveloper.mtn.com/
2. Cliquer sur **Sign Up**
3. Remplir le formulaire :
   - Email
   - Mot de passe
   - Pays : **Ivory Coast** (Côte d'Ivoire)
4. Confirmer par email

### 2. Créer un Produit (Product)

Une fois connecté :

1. Aller dans **Products**
2. Créer 2 produits séparés :
   - **Collections** (pour recevoir paiements clients)
   - **Disbursements** (pour payer les drivers)

### 3. S'abonner aux APIs

Pour chaque produit :

1. Aller dans **Subscriptions**
2. S'abonner à :
   - **Collection API** → Obtenir `Ocp-Apim-Subscription-Key`
   - **Disbursement API** → Obtenir `Ocp-Apim-Subscription-Key`

---

## 🛠️ Configuration Sandbox

### 1. Créer API User

MTN nécessite de créer un **API User** avant d'utiliser l'API.

**Via Postman ou script Python** :

```python
import requests
import uuid

# 1. Créer API User
api_user_id = str(uuid.uuid4())
subscription_key = 'YOUR_SUBSCRIPTION_KEY'

url = 'https://sandbox.momodeveloper.mtn.com/v1_0/apiuser'
headers = {
    'X-Reference-Id': api_user_id,
    'Ocp-Apim-Subscription-Key': subscription_key,
    'Content-Type': 'application/json'
}
body = {
    'providerCallbackHost': 'https://your-domain.com'  # Votre webhook URL
}

response = requests.post(url, headers=headers, json=body)
print(f"API User créé: {api_user_id}")

# 2. Créer API Key
url_key = f'https://sandbox.momodeveloper.mtn.com/v1_0/apiuser/{api_user_id}/apikey'
headers_key = {
    'Ocp-Apim-Subscription-Key': subscription_key
}

response_key = requests.post(url_key, headers=headers_key)
api_key = response_key.json().get('apiKey')
print(f"API Key: {api_key}")
```

**Sauvegarder** :
- `api_user_id` → `MTN_MOMO_API_USER`
- `api_key` → `MTN_MOMO_API_KEY`

---

## 📝 Variables d'Environnement

Ajouter dans `.env` :

```bash
# MTN Mobile Money (Sandbox)
MTN_MOMO_API_USER=uuid-from-previous-step
MTN_MOMO_API_KEY=api-key-from-previous-step
MTN_MOMO_SUBSCRIPTION_KEY=subscription-key-from-portal
MTN_MOMO_ENVIRONMENT=sandbox
```

**Note** : Il faut créer API User/Key séparément pour :
- Collections
- Disbursements

---

## 🚀 Utilisation du Service

### 1. Collection (Client → LeBeni's)

```python
from apps.payments.services.mtn_momo_service import MTNMoMoService

mtn_service = MTNMoMoService()

# Demander paiement au client
result = mtn_service.request_to_pay(
    amount=10000,
    customer_phone='+2250701234567',
    reference='DEL_20250124_123',
    currency='XOF'
)

# Retour:
# {
#     'reference_id': 'uuid-v4',
#     'status': 'PENDING',
#     'customer_phone': '2250701234567',
#     'amount': 10000,
#     'external_id': 'DEL_20250124_123'
# }

# Vérifier le statut
status = mtn_service.check_payment_status(result['reference_id'])
# Retour: 'SUCCESSFUL', 'FAILED', 'PENDING'
```

### 2. Disbursement (LeBeni's → Driver)

```python
# Transférer vers driver
transfer = mtn_service.transfer_to_driver(
    amount=8000,
    receiver_phone='+2250707654321',
    reference='PAYOUT_20250124_456',
    currency='XOF'
)

# Retour:
# {
#     'reference_id': 'uuid-v4',
#     'status': 'PENDING',
#     'receiver_phone': '2250707654321',
#     'amount': 8000,
#     'external_id': 'PAYOUT_20250124_456'
# }

# Vérifier le statut du transfert
status = mtn_service.check_transfer_status(transfer['reference_id'])
```

### 3. Vérifier Solde

```python
# Solde Collection
balance_collection = mtn_service.get_account_balance('collection')
# {'availableBalance': '50000.00', 'currency': 'XOF'}

# Solde Disbursement
balance_disbursement = mtn_service.get_account_balance('disbursement')
```

---

## 🔔 Webhooks

### 1. Endpoint

```
POST /api/v1/payments/webhooks/mtn-momo/
```

### 2. Configuration MTN

Dans MTN Developer Portal :
1. Aller dans **Products** → **Collections** (ou Disbursements)
2. Section **Callback URL**
3. Entrer : `https://your-domain.com/api/v1/payments/webhooks/mtn-momo/`

### 3. Payload Webhook

MTN envoie :

```json
{
  "referenceId": "uuid-v4",
  "externalId": "DEL_20250124_123",
  "status": "SUCCESSFUL",
  "amount": "10000",
  "currency": "XOF",
  "financialTransactionId": "MTN123456",
  "reason": null
}
```

**Statuts** :
- `SUCCESSFUL` → Paiement réussi
- `FAILED` → Paiement échoué
- `PENDING` → En attente

### 4. Sécurité Webhook

MTN n'utilise pas de signature HMAC comme Orange Money.

**Vérifications** :
- IP Whitelisting (production)
- SSL Mutual Authentication (production)
- En sandbox : Tous les webhooks acceptés

---

## 🧪 Tests Sandbox

### Numéros de Test MTN

MTN Sandbox fournit des numéros de test :

| Numéro | Description |
|--------|-------------|
| `46733123450` | Test collection réussie |
| `46733123451` | Test collection échouée |
| `46733123452` | Test timeout |

**Format** : Ajouter le code pays : `+225 46733123450`

### Scénarios de Test

```python
# Test collection réussie
result = mtn_service.request_to_pay(
    amount=1000,
    customer_phone='+22546733123450',  # Numéro de test
    reference='TEST_001'
)

# Attendre quelques secondes
import time
time.sleep(5)

# Vérifier
status = mtn_service.check_payment_status(result['reference_id'])
# Devrait retourner 'SUCCESSFUL'
```

---

## 📊 Différences avec Orange Money

| Aspect | Orange Money | MTN MoMo |
|--------|--------------|----------|
| **Authentication** | OAuth2 Client Credentials | OAuth2 + API User/Key |
| **Webhook Signature** | HMAC SHA256 | IP Whitelisting |
| **API Structure** | REST + OAuth séparé | REST avec headers spéciaux |
| **Sandbox** | URL sandbox spécifique | URL sandbox + Target-Environment |
| **Transaction ID** | `pay_token` / `notif_token` | `referenceId` (UUID v4) |

---

## 🔄 Intégration dans Celery

Le service MTN est compatible avec les tâches Celery :

```python
# apps/payments/tasks.py

from apps.payments.services.mtn_momo_service import MTNMoMoService

@shared_task
def process_daily_payouts():
    # ...
    
    # Choisir le provider selon préférence driver
    if driver.preferred_payment_method == 'mtn_money':
        mtn_service = MTNMoMoService()
        transfer = mtn_service.transfer_to_driver(
            amount=float(total_driver_amount),
            receiver_phone=driver.phone_number,
            reference=order_id
        )
    else:
        # Orange Money par défaut
        orange_service = OrangeMoneyService()
        # ...
```

---

## 🚀 Passage en Production

### 1. Contrat Marchand MTN

1. Contacter MTN Business : https://www.mtn.ci/business
2. Demander ouverture compte marchand MTN MoMo
3. Obtenir credentials production

### 2. Configuration Production

```bash
MTN_MOMO_API_USER=production-uuid
MTN_MOMO_API_KEY=production-key
MTN_MOMO_SUBSCRIPTION_KEY=production-subscription-key
MTN_MOMO_ENVIRONMENT=production
```

### 3. Whitelist IP

Fournir à MTN :
- IP serveur backend
- URL webhook : `https://api.lebenis.com/api/v1/payments/webhooks/mtn-momo/`

### 4. Tests Production

Avant mise en service :
- Test collection avec petit montant (100 CFA)
- Test disbursement
- Test webhook
- Vérifier soldes

---

## 📚 Documentation API Complète

- **Portal** : https://momodeveloper.mtn.com/
- **API Docs** : https://momodeveloper.mtn.com/api-documentation/
- **Support** : support@momodeveloper.mtn.com

---

## 🔧 Troubleshooting

### Erreur : "Invalid subscription key"

**Solution** :
- Vérifier `MTN_MOMO_SUBSCRIPTION_KEY` dans `.env`
- S'assurer d'être abonné à l'API (Collections ou Disbursements)

### Erreur : "API User not found"

**Solution** :
- Recréer API User via script
- Vérifier `MTN_MOMO_API_USER` correspond bien à l'ID créé

### Webhook non reçu

**Solution** :
- Vérifier URL dans MTN Portal
- Exposer localhost avec ngrok : `ngrok http 8000`
- Vérifier logs Django

---

**Version** : 1.0  
**Date** : Phase 2 - MTN Mobile Money Intégration Complète
