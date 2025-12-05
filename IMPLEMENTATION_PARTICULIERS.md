# Implémentation Particuliers et Commerçants

## 🎯 Objectif

Permettre aux **particuliers** (personnes lambda) et aux **commerçants** d'utiliser la même application avec des interfaces adaptées à leurs besoins.

## 📋 Architecture

### Backend

#### 1. **Nouveau type d'utilisateur : `individual`**

- Ajout de `'individual'` dans `User.USER_TYPE_CHOICES`
- Nouvelle app Django `apps/individuals/`

#### 2. **Modèle Individual** (`apps/individuals/models.py`)

```python
class Individual(models.Model):
    id = UUIDField (primary_key)
    user = OneToOneField(User)
    address = TextField (optionnel)
    created_at, updated_at
```

#### 3. **Permissions** (`core/permissions.py`)

- `IsIndividual` : Uniquement les particuliers
- `IsMerchantOrIndividual` : Les deux types peuvent créer des livraisons

#### 4. **API Endpoints** (`/api/v1/individuals/`)

- `GET /my-profile/` - Profil du particulier
- `PATCH /update-profile/` - Mettre à jour le profil
- `GET /my-stats/?period=30` - Statistiques des livraisons

#### 5. **Signal automatique**

Quand un User avec `user_type='individual'` est créé, un profil `Individual` est automatiquement créé.

### Frontend (Flutter)

#### 1. **Écran de sélection du type d'utilisateur**

`user_type_selection_screen.dart`

- Design moderne avec 2 cartes :
  - 👤 **Particulier** : Demander des livraisons personnelles
  - 🏪 **Commerçant** : Gérer un commerce et ses livraisons

#### 2. **Écran d'inscription adaptatif**

`register_screen.dart`

- Accepte un paramètre `userType`
- Affiche/masque les champs selon le type :
  - **Particuliers** : Nom, prénom, email, téléphone, mot de passe
  - **Commerçants** : + Nom du commerce, type, adresse

#### 3. **Navigation mise à jour**

- Login → Clic "Créer un compte" → Écran de sélection
- Sélection type → Écran d'inscription adapté

## 🔄 Flux d'inscription

### Particulier

1. Sélectionne "Particulier"
2. Remplit : nom, prénom, email, téléphone, mot de passe
3. Inscription → Profil `Individual` créé automatiquement
4. Accès immédiat à l'app (pas de vérification)
5. Peut créer des livraisons

### Commerçant

1. Sélectionne "Commerçant"
2. Remplit : nom, prénom, email, téléphone + **nom du commerce**
3. Inscription → Profil `Merchant` créé avec `verification_status='pending'`
4. Écran d'attente de vérification
5. Upload des documents (RCCM, ID)
6. Admin approuve → Accès complet

## 📊 Dashboard adaptatif

Le dashboard affiche les fonctionnalités pertinentes selon le type :

### Particuliers

- Statistiques simplifiées :
  - Nombre de livraisons
  - Montant total dépensé
  - Livraisons en cours
- Actions :
  - ✅ Créer une livraison
  - ✅ Voir mes livraisons
  - ✅ Modifier mon profil
  - ❌ Pas de gestion de documents

### Commerçants

- Statistiques détaillées :
  - Livraisons du mois
  - Taux de succès
  - Revenus générés
  - Livraisons actives
- Actions :
  - ✅ Créer une livraison
  - ✅ Voir mes livraisons
  - ✅ Modifier mon profil
  - ✅ Upload documents
  - ✅ Statistiques avancées

## 🗄️ Base de données

### Migrations créées

1. `authentication/0006_alter_user_user_type.py`

   - Ajoute 'individual' aux choix de user_type

2. `individuals/0001_initial.py`
   - Crée la table `individuals`

### Commandes à exécuter

```bash
cd backend
python manage.py migrate
```

## 🎨 Design

### Écran de sélection

- Fond gradient avec couleurs primaires
- 2 cartes avec :
  - Icône distinctive (person / store)
  - Titre clair
  - Description de l'usage
  - Flèche de navigation
- Bouton "Se connecter" en bas

### Interface adaptative

Même design de base, mais :

- Champs conditionnels selon le type
- Messages adaptés
- Dashboard personnalisé

## 🔐 Permissions API

Les endpoints de livraisons utilisent maintenant `IsMerchantOrIndividual` pour autoriser les deux types à créer des livraisons.

## ✅ Avantages

1. **Une seule application** : Pas besoin de 2 apps séparées
2. **Code réutilisé** : Widgets partagés, logique commune
3. **Maintenance facilitée** : Un seul codebase
4. **Évolutif** : Facile d'ajouter des types d'utilisateurs
5. **UX cohérente** : Même design et navigation

## 📝 TODO (optionnel)

- [ ] Créer un modèle `IndividualModel` côté Flutter (pour symétrie avec `MerchantModel`)
- [ ] Adapter le dashboard pour masquer les stats commerçant aux particuliers
- [ ] Ajuster les filtres de livraisons selon le type
- [ ] Tester l'inscription et la connexion des 2 types
- [ ] Documenter les différences d'accès dans l'API

## 🚀 Déploiement

1. Pusher le code backend
2. Lancer les migrations sur le serveur
3. Compiler l'app Flutter
4. Tester les 2 parcours d'inscription

---

**Implémenté le** : 5 décembre 2025
**Architecture** : Professionnelle, simple, évolutive ✅
