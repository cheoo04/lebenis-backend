# 📸 Configuration Cloudinary pour Upload d'Images
## 🗂️ Presets Cloudinary à créer (console Cloudinary)

Pour garantir une organisation optimale et une sécurité adaptée, créez les presets suivants dans la console Cloudinary :

| Nom du preset     | Dossier cible         | Overwrite | Usage principal                |
|-------------------|----------------------|-----------|-------------------------------|
| driver_photos     | lebenis/profiles     | Oui       | Photos de profil drivers       |
| documents         | lebenis/documents    | Non       | Documents officiels (CNI, etc.)|
| chat_images       | lebenis/chat         | Non       | Images envoyées dans le chat   |
| signatures        | lebenis/signatures   | Non       | Signatures électroniques (opt.)|

**Recommandations** :
- Mode Signed pour tous les presets
- Overwrite activé uniquement pour les photos de profil
- Public ID auto-généré sauf si géré côté backend (ex : user_{id})
- Display name : filename

> ⚠️ Pour la photo de profil, le preset doit exister mais la logique d’upload (dossier, overwrite, nommage) est déjà gérée côté backend Python.

## 🎯 Objectif
Permettre l'upload sécurisé de photos de profil vers Cloudinary avec validation, compression automatique et transformations optimisées.

## ✅ Fonctionnalités Implémentées

### Backend
- ✅ Service Cloudinary professionnel (`core/cloudinary_service.py`)
- ✅ Validation stricte (taille, format, type MIME)
- ✅ Compression automatique et transformations
- ✅ Endpoint sécurisé `/api/v1/auth/upload-profile-photo/`
- ✅ Suppression d'anciennes photos
- ✅ Gestion d'erreurs robuste

### Frontend
- ✅ Intégration avec endpoint Cloudinary
- ✅ Upload depuis galerie/caméra
- ✅ Gestion des erreurs
- ✅ Interface utilisateur fluide

## 🚀 Installation et Configuration

### 1. Créer un compte Cloudinary (GRATUIT)

1. Aller sur https://cloudinary.com/users/register/free
2. S'inscrire (plan gratuit inclut):
   - 25 crédits/mois
   - 25GB de stockage
   - 25GB de bande passante
   - Transformations illimitées

3. Une fois connecté, aller dans **Dashboard**
4. Noter vos credentials:
   - **Cloud Name**: `your-cloud-name`
   - **API Key**: `123456789012345`
   - **API Secret**: `abcdefghijklmnopqrstuvwxyz1234`

### 2. Configuration Backend

#### A. Ajouter les credentials dans `.env` (Production)

```bash
# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=123456789012345
CLOUDINARY_API_SECRET=abcdefghijklmnopqrstuvwxyz1234
```

#### B. Sur Render.com (Déploiement)

1. Aller dans votre service Render
2. **Environment** → **Add Environment Variable**
3. Ajouter ces 3 variables:
   ```
   CLOUDINARY_CLOUD_NAME = your-cloud-name
   CLOUDINARY_API_KEY = 123456789012345
   CLOUDINARY_API_SECRET = abcdefghijklmnopqrstuvwxyz1234
   ```

4. **Save Changes** → Service redémarrera automatiquement

### 3. Installation des dépendances

```bash
cd backend
pip install cloudinary==1.41.0 django-cloudinary-storage==0.3.0
```

Ou avec requirements.txt:
```bash
pip install -r requirements.txt
```

### 4. Vérification

#### Test en local:

```bash
# Démarrer le serveur
python manage.py runserver

# Tester l'endpoint avec curl
curl -X POST http://localhost:8000/api/v1/auth/upload-profile-photo/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -F "photo=@/path/to/image.jpg"
```

Réponse attendue:
```json
{
  "success": true,
  "message": "Photo de profil mise à jour avec succès",
  "profile_photo": "https://res.cloudinary.com/your-cloud/image/upload/v123/lebenis/profiles/user_abc.jpg",
  "user": {
    "id": "user-uuid",
    "email": "user@example.com",
    "full_name": "John Doe",
    "profile_photo": "https://res.cloudinary.com/..."
  }
}
```

## 📋 Validations Implémentées

### Taille des fichiers
- **Photos de profil**: Max 5MB
- **Documents**: Max 10MB

### Formats autorisés
- **Images**: JPG, JPEG, PNG, WebP
- **Documents**: JPG, PNG, PDF

### Transformations automatiques

#### Photos de profil:
- Dimension: 512x512px (carré)
- Crop: Centré sur visage (face detection)
- Compression: Automatique (quality: auto:good)
- Format: WebP si navigateur le supporte

#### Documents:
- Dimension max: 2048x2048px
- Compression: Meilleure qualité (quality: auto:best)
- Formats acceptés: JPG, PNG, PDF

## 🔒 Sécurité

### Authentification
- ✅ JWT obligatoire (IsAuthenticated)
- ✅ Upload uniquement pour compte utilisateur

### Validation
- ✅ Type MIME vérifié
- ✅ Taille de fichier limitée
- ✅ Extensions vérifiées
- ✅ Injection de code prévenue

### Stockage
- ✅ HTTPS uniquement (secure: true)
- ✅ URLs signées Cloudinary
- ✅ Noms de fichiers uniques (user_id)

## 📊 Utilisation dans l'App Flutter

### Upload photo de profil:

```dart
// driver_provider.dart
final photoUrl = await ref.read(driverProvider.notifier)
    .uploadProfilePhoto(photoFile);

// Met automatiquement à jour le profil
```

### Affichage photo:

```dart
// Image depuis Cloudinary (optimisée automatiquement)
NetworkImage(driver.profilePhoto)

// Transformations Cloudinary automatiques:
// - WebP si supporté
// - Compression adaptative
// - Lazy loading
// - CDN global
```

## 🐛 Dépannage

### Erreur: "Cloudinary non configuré"
→ Vérifier que les 3 variables d'environnement sont définies

### Erreur: "Type de fichier non autorisé"
→ Vérifier l'extension du fichier (JPG, PNG, WebP uniquement)

### Erreur: "Fichier trop volumineux"
→ Compresser l'image avant upload (max 5MB pour profil)

### Erreur 500: "Erreur lors de l'upload vers Cloudinary"
→ Vérifier les credentials Cloudinary (API Key/Secret invalides)

### Photo n'apparaît pas
→ Vérifier la console Cloudinary → Media Library
→ Vérifier que HTTPS est bien configuré

## 📚 Ressources

- **Dashboard Cloudinary**: https://cloudinary.com/console
- **Documentation API**: https://cloudinary.com/documentation
- **Limites plan gratuit**: https://cloudinary.com/pricing
- **Transformations d'images**: https://cloudinary.com/documentation/image_transformations

## 🎨 Configuration Avancée (Optionnel)

### Personnaliser les transformations:

Dans `backend/config/settings/base.py`:

```python
CLOUDINARY_PROFILE_PHOTO_OPTIONS = {
    'folder': 'lebenis/profiles',
    'transformation': [
        {'width': 1024, 'height': 1024, 'crop': 'fill'},  # Taille personnalisée
        {'quality': 'auto:best'},  # Meilleure qualité
        {'effect': 'sharpen:100'},  # Affûtage
    ],
}
```

### Activer upload de documents (permis, etc.):

```python
# Dans upload_views.py
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def upload_driver_license(request):
    """Upload permis de conduire"""
    if 'license' not in request.FILES:
        return Response({'error': 'Fichier manquant'}, status=400)
    
    license_url = CloudinaryService.upload_document(
        file=request.FILES['license'],
        user_id=str(request.user.id),
        document_type='driver_license'
    )
    
    # Mettre à jour le modèle Driver
    driver = request.user.driver_profile
    driver.driver_license = license_url
    driver.save()
    
    return Response({
        'success': True,
        'license_url': license_url
    })
```

## ✨ Avantages Cloudinary

1. **CDN Global** → Images chargées depuis le serveur le plus proche
2. **Transformations automatiques** → WebP, compression adaptative
3. **Lazy loading** → Améliore les performances
4. **Backup automatique** → Pas de perte de données
5. **Plan gratuit généreux** → Parfait pour MVP
6. **API simple** → Intégration facile

---

**Implémenté par**: AI Assistant  
**Date**: 5 Novembre 2025  
**Version**: 1.0
