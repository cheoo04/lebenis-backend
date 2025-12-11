# Système de Gestion des Erreurs - LeBeni Backend

## Vue d'ensemble

Le backend utilise maintenant un système de gestion d'erreurs centralisé qui transforme automatiquement **toutes les exceptions** en réponses JSON claires et **en français**.

## Configuration

### Handler d'exceptions personnalisé

Fichier : `apps/core/exception_handler.py`

Ce handler intercepte toutes les exceptions et les transforme en réponses utilisateur-friendly.

Configuration dans `config/settings/base.py` :

```python
REST_FRAMEWORK = {
    ...
    'EXCEPTION_HANDLER': 'apps.core.exception_handler.custom_exception_handler',
}
```

## Types d'erreurs gérés

### 1. Erreurs de validation (400)

#### Erreur par champ

```python
# Backend
raise ValidationError({'email': 'Email invalide'})

# Réponse client
{
    "errors": {
        "email": ["Email invalide"]
    }
}
```

#### Erreur générale

```python
# Backend
raise ValidationError("Le prix calculé est invalide")

# Réponse client
{
    "error": "Le prix calculé est invalide"
}
```

### 2. Erreurs d'authentification (401)

```python
# Réponse automatique
{
    "error": "Authentification requise. Veuillez vous connecter."
}
```

### 3. Erreurs de permission (403)

```python
# Réponse automatique
{
    "error": "Vous n'avez pas la permission d'effectuer cette action."
}
```

### 4. Ressource introuvable (404)

```python
# Réponse automatique
{
    "error": "Ressource introuvable."
}
```

### 5. Erreurs serveur (500)

```python
# Réponse automatique (erreur loggée)
{
    "error": "Une erreur s'est produite. Veuillez réessayer."
}
```

## Messages traduits automatiquement

Le handler traduit automatiquement les messages Django/DRF courants :

| Message anglais (Django/DRF)   | Message français (client)          |
| ------------------------------ | ---------------------------------- |
| "This field is required."      | "Ce champ est obligatoire."        |
| "This field may not be blank." | "Ce champ ne peut pas être vide."  |
| "Enter a valid email address." | "Entrez une adresse email valide." |
| "This field must be unique."   | "Cette valeur existe déjà."        |
| "Invalid token."               | "Token invalide."                  |
| "No active account found..."   | "Email ou mot de passe incorrect." |

## Sécurité des messages d'erreur

### ⚠️ Ne jamais révéler d'informations sensibles

Les messages d'erreur ne doivent **JAMAIS** révéler :

- Si un email existe ou non dans la base de données
- Si c'est l'email OU le mot de passe qui est incorrect
- Des détails sur la structure de la base de données
- Des informations système (versions, chemins de fichiers)

### ✅ Messages sécurisés pour l'authentification

```python
# ✅ BON - Ne révèle pas quelle partie est incorrecte
"Email ou mot de passe incorrect."

# ❌ MAUVAIS - Révèle trop d'informations
"Email incorrect."
"Mot de passe incorrect."
"Cet email n'existe pas."
"L'utilisateur n'existe pas."
```

### ✅ Messages sécurisés pour la réinitialisation

```python
# ✅ BON - Pour la réinitialisation par email
# (acceptable car l'utilisateur doit savoir si l'email est valide)
"Aucun compte n'est associé à cet email."

# ✅ BON - Message générique
"Si cet email existe, vous recevrez un code de réinitialisation."
```

## Bonnes pratiques pour les développeurs

### ✅ Utiliser des messages en français dans le code

```python
# BON - Message déjà en français
if not driver.is_verified:
    raise ValidationError("Votre compte n'est pas encore vérifié.")

# BON - Erreur par champ
if not data.get('pickup_commune'):
    raise ValidationError({'pickup_commune': 'La commune de départ est obligatoire.'})
```

### ✅ Laisser DRF gérer les validations de serializer

```python
# BON - DRF + handler = messages automatiquement traduits
serializer = MySerializer(data=request.data)
serializer.is_valid(raise_exception=True)
```

### ❌ Ne pas renvoyer des exceptions techniques

```python
# MAUVAIS - Exception technique non traduite
raise Exception("Database connection error")

# BON - Message utilisateur clair
raise ValidationError("Service temporairement indisponible. Veuillez réessayer.")
```

### ✅ Utiliser ValidationError pour les erreurs métier

```python
from django.core.exceptions import ValidationError

# BON
if delivery.status != 'assigned':
    raise ValidationError(f"Impossible d'accepter une livraison en statut '{delivery.status}'")
```

## Gestion côté Flutter

### Exemple de gestion dans DioClient

```dart
class DioClient {
  Future<Response> get(String url) async {
    try {
      return await _dio.get(url);
    } on DioException catch (e) {
      // Le backend renvoie toujours { "error": "..." } ou { "errors": {...} }
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('error')) {
          // Erreur générale
          throw ApiException(data['error']);
        } else if (data.containsKey('errors')) {
          // Erreurs par champ
          throw FieldValidationException(data['errors']);
        }
      }

      throw ApiException('Erreur réseau');
    }
  }
}
```

### Affichage dans l'UI Flutter

```dart
try {
  await deliveryRepository.acceptDelivery(id);
} on ApiException catch (e) {
  // e.message est déjà en français, prêt à afficher
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.message)),
  );
} on FieldValidationException catch (e) {
  // e.errors contient les erreurs par champ
  // {'email': ['Entrez une adresse email valide.']}
  showFieldErrors(e.errors);
}
```

## Exemples de réponses

### Validation simple

**Requête :** POST /api/deliveries/create/
**Erreur :** `pickup_commune` manquant

**Réponse :**

```json
{
  "errors": {
    "pickup_commune": ["Ce champ est obligatoire."]
  }
}
```

### Erreur métier

**Requête :** POST /api/deliveries/{id}/accept/
**Erreur :** Driver non vérifié

**Réponse :**

```json
{
  "error": "Votre compte n'est pas encore vérifié. Veuillez attendre la validation de votre profil."
}
```

### Erreur d'authentification

**Requête :** GET /api/driver/me/ (sans token)

**Réponse :**

```json
{
  "error": "Authentification requise. Veuillez vous connecter."
}
```

## Tests

### Tester le handler

```python
# tests/test_exception_handler.py
from django.test import TestCase
from rest_framework.test import APIClient
from django.core.exceptions import ValidationError

class ExceptionHandlerTest(TestCase):
    def test_validation_error_translated(self):
        # Test que les erreurs sont bien traduites
        response = self.client.post('/api/test/', {})
        self.assertIn('error', response.json())
        # Vérifier que le message est en français
        self.assertIn('obligatoire', response.json()['error'].lower())
```

## Ajout de nouvelles traductions

Pour ajouter de nouvelles traductions, modifier `apps/core/exception_handler.py` :

```python
def translate_field_error(message, field_name):
    translations = {
        'New English message': 'Nouveau message français',
        # ...
    }
```

## Logging

Toutes les erreurs 500 sont automatiquement loggées avec le traceback complet pour le debug :

```python
logger.error(f"Unhandled exception: {exc}", exc_info=True)
```

## Compatibilité

- ✅ Django ValidationError
- ✅ DRF ValidationError
- ✅ DRF AuthenticationFailed
- ✅ DRF PermissionDenied
- ✅ Django PermissionDenied
- ✅ Django ObjectDoesNotExist / Http404
- ✅ Toutes les exceptions génériques

## Migration depuis l'ancien système

Aucune migration nécessaire ! Le handler est compatible avec tout le code existant.

Les messages en français dans le code resteront en français.
Les messages en anglais (Django/DRF) seront automatiquement traduits.
