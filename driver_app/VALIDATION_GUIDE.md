# Système de Validation - Driver App

## 📋 Vue d'ensemble

Ce document décrit le système de validation côté client qui assure que toutes les données envoyées au backend sont conformes aux attentes de l'API Django.

## 🎯 Objectifs

1. **Valider les données AVANT l'envoi** - Éviter les requêtes inutiles au backend
2. **Messages d'erreur clairs** - Guider l'utilisateur avec des messages précis
3. **Synchronisation avec le backend** - Refléter exactement les contraintes Django
4. **Expérience utilisateur optimale** - Feedback visuel en temps réel

## 📂 Fichiers de validation

### `lib/core/utils/validators.dart`
Validateurs génériques pour les formulaires :
- Email
- Mot de passe (conforme aux validateurs Django)
- Téléphone (format Côte d'Ivoire)
- Noms et champs texte

### `lib/core/utils/backend_validators.dart`
Validateurs spécifiques aux modèles Django :
- **Delivery** : adresse, commune, poids, dimensions, etc.
- **Driver** : permis, immatriculation, capacité véhicule
- **Payment** : méthode, montant COD
- **Status** : statuts de livraison, codes de confirmation

### `lib/core/constants/backend_constants.dart`
Constantes synchronisées avec le backend :
- Choix de statuts (delivery, payment, verification)
- Types de véhicules
- Communes d'Abidjan
- Limites de champs (longueurs, valeurs min/max)

### `lib/shared/widgets/commune_selector.dart`
Widgets réutilisables pour les sélections :
- `CommuneSelector` - Sélecteur de commune
- `PaymentMethodSelector` - Sélecteur de méthode de paiement
- `SchedulingTypeSelector` - Sélecteur de type de planification

## 🔍 Contraintes du Backend

### Delivery (Livraison)

| Champ | Type | Contraintes | Validation |
|-------|------|-------------|------------|
| `delivery_address` | string | max 255 chars, min 10 chars | `validateDeliveryAddress()` |
| `delivery_commune` | string | max 100 chars, choix limité | `validateCommune()` |
| `delivery_quartier` | string | max 100 chars, optionnel | `validateQuartier()` |
| `package_weight_kg` | decimal | max 999.99, 2 décimales | `validatePackageWeight()` |
| `package_dimensions` | decimal | max 999.99, optionnel | `validatePackageDimension()` |
| `package_value` | decimal | max 99999999.99, optionnel | `validatePackageValue()` |
| `recipient_name` | string | max 200 chars, min 2 chars | `validateRecipientName()` |
| `recipient_phone` | string | max 20 chars, format CI | `validateRecipientPhone()` |
| `payment_method` | choice | 'prepaid' ou 'cod' | `validatePaymentMethod()` |
| `cod_amount` | decimal | requis si COD | `validateCodAmount()` |

### Driver (Chauffeur)

| Champ | Type | Contraintes | Validation |
|-------|------|-------------|------------|
| `driver_license` | string | max 50 chars, min 5 chars | `validateDriverLicense()` |
| `vehicle_type` | choice | 'moto', 'voiture', 'camionnette' | `validateVehicleType()` |
| `vehicle_registration` | string | max 20 chars, min 4 chars | `validateVehicleRegistration()` |
| `vehicle_capacity_kg` | decimal | max 9999.99 | `validateVehicleCapacity()` |

### User (Utilisateur)

| Champ | Type | Contraintes | Validation |
|-------|------|-------------|------------|
| `email` | string | max 254 chars, format email | `validateEmail()` |
| `password` | string | min 8 chars, mixte, non courant | `validatePassword()` |
| `phone` | string | 8 ou 10 chiffres, préfixes CI | `validatePhone()` |
| `first_name` | string | min 2 chars, lettres seules | `validateName()` |
| `last_name` | string | min 2 chars, lettres seules | `validateName()` |

## 🌍 Communes d'Abidjan (Choix valides)

```dart
[
  'abobo', 'adjamé', 'attécoubé', 'cocody', 'koumassi',
  'marcory', 'plateau', 'port-bouët', 'treichville', 'yopougon',
  'anyama', 'bingerville', 'songon'
]
```

## 🚗 Types de véhicules

```dart
{
  'moto': 'Moto',
  'voiture': 'Voiture',
  'camionnette': 'Camionnette'
}
```

## 💳 Méthodes de paiement

```dart
{
  'prepaid': 'Prépayé',
  'cod': 'Paiement à la livraison'
}
```

## 📱 Format téléphone Côte d'Ivoire

- **8 chiffres** : `07 12 34 56 78` (préfixes: 01, 05, 07)
- **10 chiffres** : `225 07 12 34 56 78` (avec code pays)

## 🔒 Règles mot de passe

Conformes aux validateurs Django :
- ✅ Minimum 8 caractères
- ✅ Mélange de lettres ET chiffres
- ✅ Ne doit pas être entièrement numérique
- ✅ Ne doit pas être trop courant (password123, 12345678, etc.)

## 📊 Statuts de livraison

```dart
{
  'pending_assignment': 'En attente d\'assignation',
  'assigned': 'Assigné',
  'pickup_in_progress': 'Enlèvement en cours',
  'picked_up': 'Colis récupéré',
  'in_transit': 'En livraison',
  'delivered': 'Livré',
  'cancelled': 'Annulé'
}
```

## 🛠️ Utilisation

### Exemple 1 : Valider une adresse de livraison

```dart
import 'package:driver_app/core/utils/backend_validators.dart';

final addressError = BackendValidators.validateDeliveryAddress(
  addressController.text
);

if (addressError != null) {
  // Afficher l'erreur à l'utilisateur
  Helpers.showErrorSnackBar(context, addressError);
}
```

### Exemple 2 : Valider un formulaire complet

```dart
final errors = BackendValidators.validateDeliveryData(
  deliveryAddress: addressController.text,
  deliveryCommune: selectedCommune,
  deliveryQuartier: quartierController.text,
  packageWeight: weightController.text,
  recipientName: nameController.text,
  recipientPhone: phoneController.text,
  paymentMethod: selectedPaymentMethod,
  codAmount: codAmountController.text,
);

if (errors.isNotEmpty) {
  // Afficher toutes les erreurs
  errors.forEach((field, error) {
    print('$field: $error');
  });
}
```

### Exemple 3 : Utiliser les widgets de sélection

```dart
import 'package:driver_app/shared/widgets/commune_selector.dart';

CommuneSelector(
  selectedCommune: _selectedCommune,
  onCommuneSelected: (commune) {
    setState(() {
      _selectedCommune = commune;
    });
  },
)
```

## ⚠️ Important

### TOUJOURS vérifier avant d'envoyer au backend

```dart
Future<void> _submitDelivery() async {
  // 1. Valider les données
  final errors = BackendValidators.validateDeliveryData(...);
  
  if (errors.isNotEmpty) {
    // Afficher les erreurs, NE PAS envoyer
    return;
  }
  
  // 2. Envoyer uniquement si validation OK
  await deliveryRepository.createDelivery(...);
}
```

### Synchronisation avec le backend

Quand le backend change :
1. Mettre à jour `BackendConstants`
2. Mettre à jour les validateurs correspondants
3. Tester tous les formulaires

## 🎨 Feedback visuel

L'écran d'inscription montre un exemple de validation en temps réel :
- ✔️ Coches vertes quand les critères sont remplis
- ⭕ Cercles gris quand non remplis
- Messages d'erreur sous les champs
- Bouton désactivé si formulaire invalide

## 📝 Checklist pour nouvelle fonctionnalité

- [ ] Identifier les champs requis dans le backend
- [ ] Créer les validateurs dans `BackendValidators`
- [ ] Ajouter les constantes dans `BackendConstants`
- [ ] Créer les widgets de sélection si nécessaire
- [ ] Implémenter la validation dans le formulaire
- [ ] Ajouter le feedback visuel
- [ ] Tester tous les cas limites
- [ ] Documenter les contraintes

## 🔗 Ressources

- Modèles Django : `/backend/apps/*/models.py`
- Serializers Django : `/backend/apps/*/serializers.py`
- Guide API : `/API_INTEGRATION_GUIDE.md`
