# 📋 Réponses aux Questions - Driver App

Date: 5 novembre 2025

---

## 🔐 Question 1: Mot de passe oublié

### ✅ Solution Implémentée

Le système de réinitialisation de mot de passe a été **entièrement créé** avec :

#### **Backend (Django)**

1. **Modèle de code de réinitialisation** (`PasswordResetCode`)
   - Code à 6 chiffres aléatoire
   - Expiration après 15 minutes
   - Un seul code valide par email à la fois

2. **3 nouveaux endpoints API** :
   ```
   POST /api/v1/auth/password-reset/request/
   → Envoie un code par email
   
   POST /api/v1/auth/password-reset/confirm/
   → Vérifie le code et change le mot de passe
   
   POST /api/v1/auth/change-password/
   → Change le mot de passe (utilisateur connecté)
   ```

3. **Fichiers créés** :
   - `backend/apps/authentication/models_password.py`
   - `backend/apps/authentication/serializers_password.py`
   - `backend/apps/authentication/views_password.py`
   - Migration créée : `0003_passwordresetcode.py`

#### **Flutter**

1. **Écran complet** : `forgot_password_screen.dart`
   - Formulaire d'envoi du code par email
   - Formulaire de vérification du code
   - Formulaire de nouveau mot de passe
   - Validation complète

2. **Méthodes ajoutées au provider** :
   - `requestPasswordReset(email)` 
   - `confirmPasswordReset(email, code, newPassword)`
   - `changePassword(oldPassword, newPassword)`

### 📝 Prochaines étapes

1. ✅ Lancer la migration backend :
   ```bash
   cd backend
   python manage.py migrate authentication
   ```

2. ⚠️ Configurer l'envoi d'emails :
   ```python
   # backend/config/settings/base.py
   
   # Email Configuration (pour production)
   EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
   EMAIL_HOST = 'smtp.gmail.com'  # ou autre
   EMAIL_PORT = 587
   EMAIL_USE_TLS = True
   EMAIL_HOST_USER = 'votre-email@gmail.com'
   EMAIL_HOST_PASSWORD = 'votre-mot-de-passe-app'
   DEFAULT_FROM_EMAIL = 'LeBenis <noreply@lebenis.com>'
   
   # Pour développement (console)
   EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
   ```

3. 🔗 Ajouter le lien dans l'écran de login :
   ```dart
   // Dans login_screen.dart, ajouter :
   TextButton(
     onPressed: () {
       Navigator.of(context).pushNamed('/forgot-password');
     },
     child: Text('Mot de passe oublié?'),
   )
   ```

4. 📱 Ajouter la route dans `app_router.dart`

---

## 👤 Question 2: Informations du driver insuffisantes

### 📊 Analyse des champs actuels

**Champs User (table `users`)** :
- ✅ email
- ✅ phone
- ✅ first_name, last_name
- ✅ profile_photo
- ✅ user_type (driver/merchant/admin)
- ✅ is_verified, is_active
- ✅ created_at, updated_at

**Champs Driver (table `drivers`)** :
- ✅ driver_license (permis de conduire)
- ✅ license_expiry (date d'expiration)
- ✅ vehicle_type (moto/tricycle/voiture/camionnette)
- ✅ vehicle_registration (plaque d'immatriculation)
- ✅ vehicle_capacity_kg (capacité de charge)
- ✅ verification_status (pending/verified/rejected)
- ✅ availability_status (available/busy/offline)
- ✅ current_latitude, current_longitude (position GPS)
- ✅ rating (note moyenne)
- ✅ total_deliveries, successful_deliveries
- ✅ zones (communes desservies)

### 🔍 Champs manquants recommandés

Pour une **vérification complète** du conducteur, voici ce qui manque :

#### **1. Documents d'identité** (CRITIQUE pour la sécurité)
```python
# Ajouter au modèle Driver:
identity_card_number = models.CharField(max_length=50, blank=True)
identity_card_front = models.URLField(max_length=500, blank=True, null=True)
identity_card_back = models.URLField(max_length=500, blank=True, null=True)
date_of_birth = models.DateField(null=True, blank=True)
```

#### **2. Documents véhicule** (IMPORTANT pour conformité)
```python
# Ajouter au modèle Driver:
vehicle_insurance = models.URLField(max_length=500, blank=True, null=True)
vehicle_insurance_expiry = models.DateField(null=True, blank=True)
vehicle_technical_inspection = models.URLField(max_length=500, blank=True, null=True)
vehicle_inspection_expiry = models.DateField(null=True, blank=True)
vehicle_gray_card = models.URLField(max_length=500, blank=True, null=True) # Carte grise
```

#### **3. Informations bancaires** (pour paiements)
```python
# Ajouter au modèle Driver:
bank_account_name = models.CharField(max_length=200, blank=True)
bank_account_number = models.CharField(max_length=50, blank=True)
bank_name = models.CharField(max_length=100, blank=True)
mobile_money_number = models.CharField(max_length=20, blank=True)
mobile_money_provider = models.CharField(
    max_length=50, 
    choices=[('orange', 'Orange Money'), ('mtn', 'MTN Money'), ('moov', 'Moov Money')],
    blank=True
)
```

#### **4. Informations d'urgence**
```python
# Ajouter au modèle Driver:
emergency_contact_name = models.CharField(max_length=200, blank=True)
emergency_contact_phone = models.CharField(max_length=20, blank=True)
emergency_contact_relationship = models.CharField(max_length=100, blank=True)
```

#### **5. Professionnel**
```python
# Ajouter au modèle Driver:
years_of_experience = models.IntegerField(default=0)
previous_employer = models.CharField(max_length=200, blank=True)
languages_spoken = models.JSONField(default=list, blank=True)  # ['français', 'anglais']
```

### ✅ Recommandation prioritaire

**Documents ESSENTIELS à ajouter** :
1. ✅ Photo d'identité (CNI/Passeport) - **recto/verso**
2. ✅ Assurance du véhicule + date d'expiration
3. ✅ Visite technique + date d'expiration
4. ✅ Informations bancaires/Mobile Money
5. ✅ Contact d'urgence

**Workflow de vérification** :
```
Driver s'inscrit
→ Upload documents (CNI, permis, carte grise, assurance)
→ Admin vérifie les documents
→ Si OK : verification_status = 'verified'
→ Si KO : verification_status = 'rejected' + raison
→ Driver ne peut travailler que si vérifié
```

---

## 🚗 Question 3: Validation de plaque d'immatriculation

### 📍 Contexte Sénégal/Côte d'Ivoire

#### **Format Sénégal** :
- Ancien : `DK 1234 A` (2 lettres + 4 chiffres + 1 lettre)
- Nouveau (CEDEAO) : `SN 1234 AB` (SN + 4 chiffres + 2 lettres)

#### **Format Côte d'Ivoire** :
- Ancien : `01 AA 1234` (2 chiffres + 2 lettres + 4 chiffres)
- Nouveau (CEDEAO) : `CI 1234 AB` (CI + 4 chiffres + 2 lettres)

### ✅ Validation actuelle (FAIBLE)

```dart
// backend_validators.dart (ligne 295)
static String? validateVehicleRegistration(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Immatriculation requise';
  }

  if (value.trim().length < 4) {
    return 'Immatriculation trop courte';
  }

  if (value.trim().length > 20) {
    return 'Immatriculation trop longue (maximum 20 caractères)';
  }

  return null; // ⚠️ Pas de validation du format !
}
```

### 🔒 Solution : Validation FORTE avec regex

#### **Option 1 : Validation CEDEAO uniquement**
```dart
static String? validateVehicleRegistration(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Immatriculation requise';
  }

  final plate = value.trim().toUpperCase();
  
  // Format CEDEAO : XX 1234 YY
  // Exemples: SN 1234 AB, CI 5678 CD
  final cedeaoPattern = RegExp(r'^[A-Z]{2}\s?\d{4}\s?[A-Z]{2}$');
  
  if (!cedeaoPattern.hasMatch(plate)) {
    return 'Format invalide. Exemple: SN 1234 AB ou CI 5678 CD';
  }

  return null;
}
```

#### **Option 2 : Validation FLEXIBLE (ancien + nouveau)**
```dart
static String? validateVehicleRegistration(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Immatriculation requise';
  }

  final plate = value.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
  
  // Format CEDEAO : SN 1234 AB, CI 5678 CD
  final cedeaoPattern = RegExp(r'^[A-Z]{2}\s\d{4}\s[A-Z]{2}$');
  
  // Format Sénégal ancien : DK 1234 A
  final senegalPattern = RegExp(r'^[A-Z]{2}\s\d{4}\s[A-Z]$');
  
  // Format Côte d'Ivoire ancien : 01 AA 1234
  final ivoirePattern = RegExp(r'^\d{2}\s[A-Z]{2}\s\d{4}$');
  
  final isValid = cedeaoPattern.hasMatch(plate) || 
                  senegalPattern.hasMatch(plate) || 
                  ivoirePattern.hasMatch(plate);
  
  if (!isValid) {
    return 'Format invalide.\nExemples valides:\n• SN 1234 AB (CEDEAO)\n• DK 1234 A (Sénégal)\n• 01 AA 1234 (Côte d\'Ivoire)';
  }

  return null;
}
```

#### **Option 3 : Validation avec NORMALISATION**
```dart
static String? validateVehicleRegistration(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Immatriculation requise';
  }

  // Normaliser : supprimer espaces multiples et mettre en majuscules
  final plate = value.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
  
  // Vérifier longueur
  if (plate.length < 6 || plate.length > 15) {
    return 'Longueur invalide (6-15 caractères)';
  }
  
  // Patterns acceptés
  final patterns = [
    RegExp(r'^[A-Z]{2}\s\d{4}\s[A-Z]{2}$'),  // CEDEAO
    RegExp(r'^[A-Z]{2}\s\d{4}\s[A-Z]$'),     // Sénégal ancien
    RegExp(r'^\d{2}\s[A-Z]{2}\s\d{4}$'),     // Côte d'Ivoire
  ];
  
  final isValid = patterns.any((pattern) => pattern.hasMatch(plate));
  
  if (!isValid) {
    return 'Format invalide. Ex: SN 1234 AB';
  }

  return null;
}

/// Normaliser une plaque pour stockage (majuscules, espaces normalisés)
static String normalizePlate(String plate) {
  return plate.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
}
```

### 🎯 Recommandation finale

**Implémenter la validation FLEXIBLE (Option 2)** car :
- ✅ Accepte les anciens ET nouveaux formats
- ✅ Compatible Sénégal + Côte d'Ivoire
- ✅ Message d'erreur clair avec exemples
- ✅ Évite de bloquer les drivers avec anciennes plaques

### 📝 Vérification côté Backend aussi

```python
# backend/apps/drivers/models.py
from django.core.validators import RegexValidator

class Driver(models.Model):
    vehicle_registration = models.CharField(
        max_length=50, 
        blank=True,
        validators=[
            RegexValidator(
                regex=r'^([A-Z]{2}\s\d{4}\s[A-Z]{1,2}|\d{2}\s[A-Z]{2}\s\d{4})$',
                message='Format invalide. Ex: SN 1234 AB, DK 1234 A, 01 AA 1234',
                code='invalid_plate'
            )
        ]
    )
```

---

## 🎯 Actions Prioritaires

### Immédiatement
1. ✅ Migrer la base de données (mot de passe oublié)
2. ✅ Améliorer validation plaque d'immatriculation
3. ⚠️ Configurer l'envoi d'emails

### Court terme (1-2 semaines)
4. 📄 Ajouter upload documents (CNI, assurance, visite technique)
5. 🔐 Créer workflow de vérification admin
6. 💰 Ajouter informations bancaires/Mobile Money

### Moyen terme (1 mois)
7. 📱 Notification expiration documents
8. 📊 Dashboard admin de vérification
9. 🔄 Renouvellement automatique des documents

---

## 📚 Résumé

| Question | État | Action |
|----------|------|--------|
| **Mot de passe oublié** | ✅ Implémenté | Migrer + configurer email |
| **Infos driver insuffisantes** | ⚠️ Partiel | Ajouter documents d'identité + véhicule |
| **Validation plaque** | ❌ Faible | Implémenter regex stricte |

**Priorité 1** : Validation plaque (rapide à faire)
**Priorité 2** : Documents driver (impact sécurité)
**Priorité 3** : Emails mot de passe (besoin configuration SMTP)
