# 🔔 Système de Notifications - LeBeni's

## ✅ État d'Implémentation

### 📱 **Driver App** : ✅ COMPLET
### 📦 **Merchant App** : ✅ COMPLET  
### 🖥️ **Backend** : ✅ COMPLET

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Firebase Cloud Messaging                  │
│                          (FCM)                               │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
   ┌────▼─────┐            ┌─────▼────┐
   │  Driver  │            │ Merchant │
   │   App    │            │   App    │
   └────┬─────┘            └─────┬────┘
        │                        │
        └────────────┬───────────┘
                     │
              ┌──────▼──────┐
              │   Backend   │
              │   Django    │
              └─────────────┘
```

---

## 📱 Configuration Mobile (Driver & Merchant)

### 1. **Initialisation Firebase**

#### Driver App
```dart
// driver_app/lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Handler background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  runApp(ProviderScope(child: LeBenisDriverApp()));
}
```

#### Merchant App
```dart
// merchant_app/lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ProviderScope(child: MyApp()));
}
```

### 2. **Service de Notifications**

Les deux apps utilisent le même pattern :

```dart
// lib/core/services/notification_service.dart
class NotificationService {
  FirebaseMessaging? _fcm;
  
  Future<void> initialize({bool firebaseEnabled = true}) async {
    _fcm = FirebaseMessaging.instance;
    await _requestPermissions();
    await _initializeLocalNotifications();
    _configureFirebaseHandlers();
  }
  
  // Enregistrer le token après login
  Future<void> registerTokenAfterLogin() async {
    final token = await _fcm!.getToken();
    await _dioClient.post('/api/v1/auth/register-fcm-token/', {
      'token': token,
      'platform': 'android/ios',
    });
  }
}
```

### 3. **Navigation sur Tap de Notification**

#### Driver App
```dart
// main.dart
_notificationService.onNotificationTap = (data) {
  switch (data['type']) {
    case 'new_delivery':
      Navigator.of(context).pushNamed('/deliveries');
      break;
    case 'delivery_update':
      Navigator.of(context).pushNamed('/delivery-details', 
        arguments: data['delivery_id']);
      break;
  }
};
```

#### Merchant App
```dart
// main.dart
_notificationService.onNotificationTap = (data) {
  switch (type) {
    case 'merchant_approved':
      Navigator.pushReplacementNamed(context, '/dashboard');
      break;
    case 'merchant_rejected':
      Navigator.pushReplacementNamed(context, '/rejected');
      break;
    case 'merchant_delivery_assigned':
      Navigator.pushNamed(context, '/delivery-detail',
        arguments: deliveryId);
      break;
  }
};
```

---

## 🖥️ Backend Django

### 1. **Models**

```python
# apps/authentication/models.py
class User(AbstractBaseUser):
    fcm_token = models.CharField(max_length=255, blank=True, null=True)
    # ... autres champs

# apps/notifications/models.py
class Notification(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    notification_type = models.CharField(max_length=50)
    title = models.CharField(max_length=255)
    message = models.TextField()
    is_read = models.BooleanField(default=False)
    sent_at = models.DateTimeField(auto_now_add=True)
```

### 2. **Firebase Service**

```python
# apps/notifications/firebase_service.py
class FirebaseService:
    @classmethod
    def send_notification(cls, fcm_token, title, body, data=None):
        """Envoie une notification push via FCM"""
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body,
            ),
            data=data or {},
            token=fcm_token,
        )
        
        response = messaging.send(message)
        return True
```

### 3. **Enregistrement du Token**

```python
# apps/authentication/views.py
class RegisterFCMTokenView(APIView):
    """POST /api/v1/auth/register-fcm-token/"""
    permission_classes = [IsAuthenticated]
    
    def post(self, request):
        token = request.data.get('token')
        request.user.fcm_token = token
        request.user.save()
        return Response({'success': True})
```

---

## 🚀 Notifications Implémentées

### Pour les **Drivers** 🚗

#### 1. Nouvelle Livraison Assignée
```python
# apps/notifications/services.py
def notify_new_delivery_assignment(driver, delivery):
    return FirebaseService.send_notification(
        fcm_token=driver.user.fcm_token,
        title="🚚 Nouvelle livraison !",
        body=f"Livraison #{delivery.tracking_number}",
        data={
            'type': 'new_delivery',
            'delivery_id': str(delivery.id),
            'action': 'open_delivery_details',
        }
    )
```

#### 2. Changement de Statut
```python
def notify_delivery_status_change(user, delivery, new_status):
    status_messages = {
        'picked_up': "Colis récupéré",
        'delivered': "✅ Livraison terminée",
        'cancelled': "❌ Livraison annulée",
    }
    # ... envoi notification
```

---

### Pour les **Merchants** 🏪

#### 1. Compte Approuvé ✅
```python
# apps/merchants/utils.py
def notify_merchant_approved(merchant):
    return send_merchant_notification(
        user=merchant.user,
        title="✅ Compte approuvé !",
        body=f"Félicitations ! Votre compte {merchant.business_name} a été approuvé.",
        notification_type="merchant_approved",
        data={
            'type': 'merchant_approved',
            'action': 'open_dashboard',
        }
    )
```

**Quand ?** : Admin approuve le merchant via `/api/v1/merchants/{id}/approve/`

#### 2. Compte Rejeté ❌
```python
def notify_merchant_rejected(merchant, rejection_reason):
    return send_merchant_notification(
        user=merchant.user,
        title="❌ Compte rejeté",
        body=f"Votre demande a été rejetée. Raison: {rejection_reason}",
        notification_type="merchant_rejected",
        data={
            'type': 'merchant_rejected',
            'action': 'open_rejected_screen',
        }
    )
```

**Quand ?** : Admin rejette le merchant via `/api/v1/merchants/{id}/reject/`

#### 3. Documents Reçus 📄
```python
def notify_merchant_documents_received(merchant):
    return send_merchant_notification(
        user=merchant.user,
        title="📄 Documents reçus",
        body="Nous avons bien reçu vos documents. Notre équipe les examine actuellement.",
        notification_type="merchant_documents_received",
        data={'type': 'merchant_documents_received'}
    )
```

**Quand ?** : Merchant uploade documents via `/api/v1/merchants/update-documents/`

#### 4. Livraison Assignée 🚚
```python
def notify_merchant_new_delivery_assigned(merchant, delivery):
    driver_name = delivery.driver.user.get_full_name()
    return send_merchant_notification(
        user=merchant.user,
        title="🚚 Livraison assignée",
        body=f"{driver_name} a accepté votre livraison #{delivery.tracking_number}",
        notification_type="merchant_delivery_assigned",
        data={
            'type': 'merchant_delivery_assigned',
            'delivery_id': str(delivery.id),
        }
    )
```

**Quand ?** : Driver accepte une livraison

#### 5. Facture Payée 💰
```python
def notify_merchant_invoice_paid(merchant, invoice):
    return send_merchant_notification(
        user=merchant.user,
        title="💰 Facture payée",
        body=f"Votre facture {invoice.invoice_number} de {invoice.total_amount} FCFA a été payée.",
        notification_type="merchant_invoice_paid",
        data={
            'type': 'merchant_invoice_paid',
            'invoice_id': str(invoice.id),
        }
    )
```

---

## 🔄 Flux Complet

### Exemple: Approbation d'un Merchant

```
1. Admin approuve via Admin Panel ou API
   POST /api/v1/merchants/{id}/approve/
   ↓
2. Backend (views.py)
   - Met à jour merchant.verification_status = 'approved'
   - Active user.is_active = True
   - Appelle notify_merchant_approved(merchant)
   ↓
3. utils.py
   - Crée notification en DB
   - Appelle FirebaseService.send_notification()
   ↓
4. Firebase envoie la notification
   ↓
5. Merchant App (foreground)
   - _handleForegroundMessage() reçoit le message
   - Affiche notification locale
   ↓
6. Merchant tape sur la notification
   - onNotificationTap() est appelé
   - Navigation vers /dashboard
   ↓
7. Merchant voit le dashboard et peut créer des livraisons ✅
```

---

## 📝 Checklist de Configuration

### Backend ✅
- [x] Firebase Admin SDK initialisé
- [x] Fichier `config/firebase/service-account.json` présent
- [x] Modèle User avec champ `fcm_token`
- [x] Endpoint `/api/v1/auth/register-fcm-token/`
- [x] Service `FirebaseService` avec `send_notification()`
- [x] Fonctions `notify_merchant_*()` dans `merchants/utils.py`
- [x] Appels aux fonctions de notification dans les vues

### Driver App ✅
- [x] Firebase initialisé dans `main.dart`
- [x] `NotificationService` configuré
- [x] Permissions demandées
- [x] Token FCM enregistré après login
- [x] Handler `onNotificationTap` configuré
- [x] Navigation selon type de notification

### Merchant App ✅
- [x] Firebase initialisé dans `main.dart`
- [x] `NotificationService` configuré
- [x] Permissions demandées
- [x] Token FCM enregistré après login
- [x] Handler `onNotificationTap` configuré
- [x] Navigation selon type de notification

---

## 🧪 Tests

### Test Manuel Backend

```bash
# Console Django
python manage.py shell

from apps.merchants.models import Merchant
from apps.merchants.utils import notify_merchant_approved

merchant = Merchant.objects.first()
notify_merchant_approved(merchant)
# ✅ Notification envoyée !
```

### Test via API

```bash
curl -X POST https://lebenis-backend.onrender.com/api/v1/merchants/{id}/approve/ \
  -H "Authorization: Bearer <admin_token>"
# Le merchant devrait recevoir la notification
```

### Vérifier le Token

```bash
# Dans l'app mobile
print('FCM Token: ${await notificationService.getFcmToken()}')
```

---

## 🐛 Troubleshooting

### Notification non reçue ?

1. **Vérifier le token FCM est enregistré**
   ```python
   user = User.objects.get(email='merchant@example.com')
   print(user.fcm_token)  # Doit afficher un token
   ```

2. **Vérifier Firebase est initialisé**
   ```python
   from apps.notifications.firebase_service import FirebaseService
   FirebaseService.initialize()
   # Doit afficher: ✅ Firebase Admin SDK initialisé
   ```

3. **Vérifier les permissions mobile**
   - Android: `AndroidManifest.xml` avec permissions
   - iOS: Capabilities > Push Notifications activé

4. **Logs backend**
   ```bash
   tail -f logs/django.log | grep notification
   ```

---

## 🎯 Prochaines Améliorations

- [ ] Notifications groupées (plusieurs livraisons)
- [ ] Notifications programmées (rappels)
- [ ] Rich notifications (images, actions)
- [ ] Analytics (taux d'ouverture)
- [ ] Support des topics Firebase (tous les drivers, tous les merchants)
- [ ] Notifications par email en backup

---

## 📞 Support

- Documentation Firebase: https://firebase.google.com/docs/cloud-messaging
- Backend: `backend/FIREBASE_FCM_SETUP.md`
- Code: `apps/notifications/services.py` et `apps/merchants/utils.py`
