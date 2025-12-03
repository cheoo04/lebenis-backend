# 🔧 Guide de correction des problèmes de livraison

## Problèmes identifiés et corrections

### ✅ 1. Endpoints 404 (confirm-pickup / confirm-delivery)

**Problème** : Double préfixe "deliveries" dans les URLs  
**Solution** : Corrigé dans `backend/apps/deliveries/urls.py`  
**Status** : ✅ RÉSOLU - Redéployer le backend

---

### 🗺️ 2. Distance = 0m / Navigation ne fonctionne pas

**Problème** : Les coordonnées GPS (latitude/longitude) ne sont pas renseignées dans la base de données.

**Solutions** :

#### Option A : Remplir manuellement dans l'admin Django

1. Ouvre l'admin Django
2. Édite la livraison
3. Remplis les champs :
   - `pickup_latitude` / `pickup_longitude` (ex: 5.3599517, -4.0082563 pour Cocody)
   - `delivery_latitude` / `delivery_longitude` (ex: 5.2893189, -4.0744303 pour Yopougon)

#### Option B : Géocoder automatiquement (Recommandé)

Exécute cette commande sur le serveur :

```bash
python manage.py geocode_deliveries
```

Cela utilisera OpenRouteService pour convertir les adresses en coordonnées GPS.

#### Option C : Modifier le frontend pour envoyer les coordonnées

Dans l'app merchant, lors de la création d'une livraison, envoyer :

```json
{
  "pickup_latitude": 5.3599517,
  "pickup_longitude": -4.0082563,
  "delivery_latitude": 5.2893189,
  "delivery_longitude": -4.0744303
}
```

---

### 📞 3. Boutons d'appel ne fonctionnent pas

**Problème** : "Impossible de lancer l'appel"

**Causes possibles** :

1. Le numéro de téléphone n'est pas dans le bon format
2. Permission téléphone non accordée dans l'app
3. Bug dans le code Flutter (url_launcher)

**À vérifier dans le code Flutter** :

```dart
// lib/features/deliveries/presentation/screens/delivery_details_screen.dart

// Le numéro doit être formaté correctement
final phoneUrl = 'tel:${delivery.recipientPhone}';
await launchUrl(Uri.parse(phoneUrl));
```

**Permissions à ajouter** :

- Android : `AndroidManifest.xml` → `<uses-permission android:name="android.permission.CALL_PHONE"/>`
- iOS : `Info.plist` → `LSApplicationQueriesSchemes` avec `tel`

---

### 🔑 4. Code de vérification accepte n'importe quoi

**Problème** : Un faux code passe la validation.

**Vérifications** :

1. Dans l'admin Django, vérifie que le champ `delivery_confirmation_code` est bien rempli (devrait être un code à 4-6 chiffres)
2. Si vide, le backend génère automatiquement un code lors de la création

**Le backend valide déjà le code** (ligne 440-444 de `views.py`):

```python
pin = request.data.get('confirmation_code')
if not pin or pin != delivery.delivery_confirmation_code:
    return Response({'error': 'Code de confirmation invalide'}, status=400)
```

**Si un faux code passe, c'est que** :

- Le champ `delivery_confirmation_code` est vide dans la DB
- OU le code envoyé par l'app correspond au code dans la DB par hasard

**Solution** : Vérifie dans l'admin Django que le code est bien généré et non vide.

---

### 💰 5. Paiement (Prépayé vs COD)

**Comment ça fonctionne** :

#### Prépayé (`prepaid`)

- Le merchant a déjà payé avant la livraison
- Le driver livre le colis sans collecter d'argent
- `cod_amount` = 0

#### Paiement à la livraison (`cod` - Cash On Delivery)

- Le driver collecte l'argent auprès du destinataire
- `cod_amount` = montant à collecter
- Le driver doit ensuite reverser l'argent au merchant (ou à la plateforme)

**Dans l'app driver** :

- Si `payment_method` == "cod", afficher le montant à collecter
- Après livraison, marquer l'argent comme collecté

**Endpoints paiement** :

- `/api/v1/payments/` pour gérer les transactions
- Voir `backend/MOBILE_MONEY_API.md`

---

### ✍️ 6. Problème affichage signature

**À vérifier** :

- Le champ `signature_url` doit contenir une URL Cloudinary valide
- Dans l'app Flutter, utiliser `CachedNetworkImage` ou `Image.network`

```dart
if (delivery.signatureUrl != null)
  Image.network(delivery.signatureUrl!)
```

---

### 🛰️ 7. GPS non configuré

**Permissions nécessaires** :

**Android** (`android/app/src/main/AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**iOS** (`ios/Runner/Info.plist`):

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Nous avons besoin de votre position pour suivre les livraisons</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Nous avons besoin de votre position en arrière-plan</string>
```

**Demander la permission dans le code** :

```dart
await Geolocator.requestPermission();
```

---

## 🚀 Actions immédiates

### Sur le backend (Render) :

1. ✅ Redéployer (les corrections d'URLs sont déjà pushées)
2. Exécuter `python manage.py geocode_deliveries` pour remplir les GPS

### Dans l'admin Django :

1. Ouvrir la livraison LB647292786965
2. Assigner un driver
3. Vérifier que `delivery_confirmation_code` n'est pas vide
4. Remplir les coordonnées GPS si le geocoding échoue

### Dans l'app Flutter :

1. Vérifier les permissions GPS et téléphone
2. Rebuilder l'app
3. Tester à nouveau

---

## 📝 Checklist complète

- [ ] Backend redéployé sur Render
- [ ] Livraison assignée à un driver
- [ ] Coordonnées GPS renseignées
- [ ] Code de confirmation vérifié
- [ ] Permissions GPS/téléphone ajoutées
- [ ] App Flutter rebuildée
- [ ] Tests sur un vrai appareil
