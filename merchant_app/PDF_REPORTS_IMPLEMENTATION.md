# 📄 Rapports PDF - Merchant App

**Date d'implémentation**: 3 décembre 2025  
**Status**: ✅ Fonctionnel

---

## 🎯 Fonctionnalités

L'export PDF permet aux merchants de :

- ✅ Télécharger un rapport PDF complet de chaque livraison
- ✅ Partager le rapport via n'importe quelle app (WhatsApp, Email, etc.)
- ✅ Ouvrir le PDF dans un lecteur externe
- ✅ Stocker les PDFs localement pour consultation offline

---

## 🔧 Architecture

### Backend

#### Endpoint PDF

```
GET /api/v1/deliveries/{delivery_id}/generate-pdf/
```

**Permissions:**

- `IsAuthenticated` + `IsMerchant`
- Le merchant doit être propriétaire de la livraison

**Réponse:**

- `Content-Type: application/pdf`
- `Content-Disposition: attachment; filename="delivery_TRK123_20251203.pdf"`

#### Template HTML

`backend/templates/reports/delivery_report.html`

**Contenu du PDF:**

- 📦 Informations de livraison (tracking number, status, dates)
- 🏪 Informations merchant (business name, contact, adresse)
- 👤 Informations destinataire (nom, téléphone, adresse, commune)
- 📦 Détails du colis (type, poids, description)
- 🚗 Informations driver (nom, téléphone, véhicule, plaque)
- 💰 Détails de tarification (distance, prix, instructions spéciales)
- 📝 Instructions spéciales (si présentes)
- ⭐ Notation (si disponible)

---

## 📱 Côté Merchant App

### Service PDF (`pdf_report_service.dart`)

```dart
class PDFReportService {
  // Télécharger le PDF d'une livraison
  Future<String> downloadDeliveryPDF({
    required int deliveryId,
    Function(double)? onProgress,
  });

  // Partager le PDF
  Future<void> sharePDF(String filePath);

  // Ouvrir le PDF dans une app externe
  Future<void> openPDF(String filePath);

  // Lister les PDFs téléchargés
  Future<List<File>> getDownloadedPDFs();

  // Supprimer un PDF
  Future<void> deletePDF(String filePath);

  // Supprimer tous les PDFs
  Future<void> clearAllPDFs();
}
```

### Provider

```dart
final pdfReportServiceProvider = Provider<PDFReportService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PDFReportService(dioClient);
});
```

### Stockage Local

**Android:** `/data/user/0/com.example.merchant_app/app_flutter/Documents/PDFs/`  
**iOS:** `Documents/PDFs/`

**Format de fichier:** `delivery_{tracking_number}_{timestamp}.pdf`

---

## 📱 Interface Utilisateur

### Bouton de téléchargement

Dans `DeliveryDetailScreen`, un bouton est toujours visible :

```dart
ModernButton(
  text: _isDownloadingPDF
    ? 'Téléchargement... ${(_downloadProgress * 100).toInt()}%'
    : 'Télécharger le PDF',
  icon: Icons.picture_as_pdf,
  onPressed: _isDownloadingPDF ? null : _downloadPDF,
  isLoading: _isDownloadingPDF,
  backgroundColor: Colors.deepPurple,
)
```

### États UI

**Pendant le téléchargement:**

- Bouton désactivé
- Affichage du pourcentage de progression
- Spinner de chargement

**Après téléchargement:**

- Dialog avec 3 options :
  - **Ouvrir** : Ouvre le PDF dans une app externe
  - **Partager** : Partage via le système (WhatsApp, Email, etc.)
  - **Fermer** : Ferme le dialog

---

## 🔄 Flux d'utilisation

### 1. Télécharger un PDF

```dart
final pdfService = ref.read(pdfReportServiceProvider);
final filePath = await pdfService.downloadDeliveryPDF(
  deliveryId: 123,
  onProgress: (progress) {
    print('Download: ${(progress * 100).toInt()}%');
  },
);
```

### 2. Partager le PDF

```dart
await pdfService.sharePDF(filePath);
// Ouvre le sélecteur système pour partager
```

### 3. Ouvrir le PDF

```dart
await pdfService.openPDF(filePath);
// Ouvre dans un lecteur PDF externe
```

---

## 🧪 Test Manuel

1. **Lancer l'app merchant**
2. Aller dans "Mes livraisons"
3. Sélectionner une livraison (n'importe quel statut)
4. Cliquer sur **"Télécharger le PDF"**
5. Observer :
   - Bouton devient "Téléchargement... X%"
   - Progression de 0% à 100%
   - Dialog apparaît : "PDF téléchargé"
6. Tester les 3 options :
   - **Ouvrir** : Ouvre le PDF
   - **Partager** : Ouvre le menu de partage
   - **Fermer** : Ferme le dialog

---

## 📋 Contenu du PDF Généré

### Section 1 : Header

- Logo LeBeni's
- Titre "Delivery Report"
- Subtitle "Delivery Receipt & Details"

### Section 2 : Info Livraison

- Tracking Number (en gros)
- Status (badge coloré)
- Date de création
- Date de livraison (si delivered)

### Section 3 : Merchant

- Business Name
- Contact
- Adresse

### Section 4 : Destinataire

- Nom
- Téléphone
- Adresse complète
- Commune

### Section 5 : Colis

- Type (Document 📄, Package 📦, Fragile ⚠️, Food 🍔)
- Poids (kg)
- Description (si présente)

### Section 6 : Driver (si assigné)

- Nom complet
- Téléphone
- Type de véhicule
- Plaque d'immatriculation

### Section 7 : Tarification

- Distance (km)
- Prix de base
- Frais supplémentaires (si instructions spéciales)
- **Total** (en gras)

### Section 8 : Instructions Spéciales (si présentes)

- Bloc jaune avec les instructions

### Section 9 : Notation (si disponible)

- Note globale (⭐)
- Ponctualité
- Professionnalisme
- Soin du colis
- Commentaire

### Section 10 : Footer

- Branding LeBeni's
- Date de génération
- Contact support

---

## 🎨 Design du PDF

### Couleurs

- **Primary Green**: `#4CAF50`
- **Success Badge**: `#4CAF50`
- **Warning Badge**: `#FF9800`
- **Danger Badge**: `#F44336`
- **Info Badge**: `#2196F3`

### Layout

- **Format**: A4
- **Marges**: 1.5cm tout autour
- **Font**: DejaVu Sans (supporte UTF-8)
- **Font Size**: 11pt (body), 14pt (titles), 24pt (header)

### Sections

- Background gris clair (`#f8f9fa`) pour sections importantes
- Borders arrondies (8px)
- Grid 2 colonnes pour info compacte
- Tables pour pricing avec total en fond vert

---

## 🚀 Performance

### Taille moyenne des PDFs

- **Livraison simple** : ~50-80 KB
- **Livraison avec notation** : ~80-120 KB
- **Livraison avec instructions** : ~60-100 KB

### Temps de génération/téléchargement

- **Backend génération** : ~0.5-1s
- **Téléchargement 50KB** : ~0.5-1s (connexion normale)
- **Total** : ~1-2 secondes

### Optimisations

- ✅ Progress callback pour feedback utilisateur
- ✅ Stockage local pour accès offline
- ✅ Nommage standardisé des fichiers
- ✅ Gestion automatique du dossier PDFs

---

## 🔒 Sécurité

### Backend

- ✅ Authentification JWT requise
- ✅ Permission `IsMerchant` vérifiée
- ✅ Vérification de propriété (merchant_id == delivery.merchant_id)
- ✅ 403 Forbidden si pas propriétaire

### Frontend

- ✅ Token automatiquement ajouté par DioClient
- ✅ Gestion des erreurs réseau
- ✅ Stockage sécurisé local (app-specific directory)
- ✅ Pas de permission externe requise

---

## 🐛 Gestion d'erreurs

### Erreurs possibles

| Erreur          | Cause                            | Solution                           |
| --------------- | -------------------------------- | ---------------------------------- |
| `403 Forbidden` | Pas propriétaire de la livraison | Vérifier que c'est votre livraison |
| `404 Not Found` | Livraison inexistante            | Vérifier l'ID                      |
| `Network error` | Backend down / pas de connexion  | Vérifier connexion internet        |
| `Storage error` | Pas d'espace disque              | Libérer de l'espace                |

### Messages utilisateur

```dart
try {
  final path = await pdfService.downloadDeliveryPDF(...);
  print('✅ PDF téléchargé: $path');
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('❌ Erreur: $e')),
  );
}
```

---

## 📊 Cas d'usage

### 1. Preuve de livraison

Le merchant peut télécharger le PDF comme preuve de service pour :

- Facturation client
- Comptabilité interne
- Litiges éventuels

### 2. Partage avec client

Le merchant peut partager le PDF directement au client final via :

- WhatsApp
- Email
- SMS

### 3. Archive

Le merchant peut garder une copie locale pour :

- Consultation offline
- Backup personnel
- Historique des livraisons

---

## 🔮 Améliorations futures

### Potentiel

- [ ] Batch download (télécharger plusieurs PDFs)
- [ ] Personnalisation du PDF (logo merchant, couleurs)
- [ ] Export multi-format (PDF, Excel, CSV)
- [ ] Statistiques d'usage des PDFs
- [ ] Compression automatique des vieux PDFs
- [ ] Envoi automatique par email
- [ ] QR Code dans le PDF pour tracking

---

## 📝 Checklist d'intégration

- [x] Backend endpoint créé (`generate_delivery_pdf`)
- [x] Template HTML créé (`delivery_report.html`)
- [x] CSS styling ajouté
- [x] PDFReportService créé côté Flutter
- [x] DioClient.download() implémenté
- [x] Provider pdfReportServiceProvider ajouté
- [x] Bouton UI dans DeliveryDetailScreen
- [x] Progress indicator pendant téléchargement
- [x] Dialog post-téléchargement (Ouvrir/Partager/Fermer)
- [x] Dépendance share_plus installée
- [x] Gestion des erreurs
- [x] 0 erreur de compilation
- [x] Documentation complète
