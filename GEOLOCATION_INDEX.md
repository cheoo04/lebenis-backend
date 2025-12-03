# 📍 INDEX - Géolocalisation Automatique

## 📚 Fichiers Principaux

### 🎯 À Lire en Premier

**`driver_app/GEOLOCATION_COMPLETE_SUMMARY.md`**

- Vue d'ensemble complète du système
- Architecture backend + Flutter
- 3 scénarios d'utilisation
- Flux complet de A à Z
- **→ Commencer ici !**

### 🛠️ Guides Pratiques

**`driver_app/GEOLOCATION_INTEGRATION_GUIDE.md`**

- Configuration des packages Flutter
- Permissions Android/iOS
- Exemples d'utilisation des 3 widgets
- Code complet de formulaire
- Modification du repository
- **→ Pour intégrer dans votre app**

**`GEOLOCATION_DEPLOYMENT_CHECKLIST.md`**

- Étapes de déploiement sur Render
- Commandes de vérification backend
- Tests des endpoints API
- Tests Flutter end-to-end
- Troubleshooting complet
- **→ Pour le déploiement**

---

## 📦 Fichiers Backend

### Models & Migrations

- `backend/apps/pricing/models.py` - Champs GPS dans PricingZone
- `backend/apps/pricing/migrations/0003_add_gps_coordinates_to_zones.py`

### API & Views

- `backend/apps/pricing/geocoding_views.py` - 3 endpoints
- `backend/apps/pricing/urls.py` - Routes API

### Services & Signals

- `backend/apps/core/location_service.py` - Géocodage + calcul distance
- `backend/apps/deliveries/signals.py` - Auto-géocodage pre_save

### Commandes CLI

- `backend/apps/pricing/management/commands/populate_commune_gps.py`
- `backend/apps/deliveries/management/commands/geocode_deliveries.py`

---

## 📱 Fichiers Flutter

### Modèles

- `driver_app/lib/data/models/commune/commune_model.dart`

### Repositories

- `driver_app/lib/data/repositories/geolocation_repository.dart`

### Providers (Riverpod)

- `driver_app/lib/data/providers/geolocation_provider.dart`

### Widgets

- `driver_app/lib/shared/widgets/commune_selector_widget.dart`
- `driver_app/lib/shared/widgets/address_geocoder_widget.dart`
- `driver_app/lib/shared/widgets/location_picker_widget.dart`

---

## 🗺️ Endpoints API

| Endpoint                                               | Méthode | Description                    |
| ------------------------------------------------------ | ------- | ------------------------------ |
| `/api/v1/pricing/communes/`                            | GET     | Liste des 13 communes avec GPS |
| `/api/v1/pricing/communes/coordinates/?commune=Cocody` | GET     | Coordonnées d'une commune      |
| `/api/v1/pricing/geocode/`                             | POST    | Géocode une adresse complète   |

---

## ✅ État du Projet

### Complété (Backend)

- [x] Migration avec champs GPS
- [x] 13 communes d'Abidjan avec coordonnées
- [x] Signal auto-géocodage
- [x] 3 endpoints API
- [x] Commande populate_commune_gps
- [x] Commande geocode_deliveries
- [x] Calcul automatique distance

### Complété (Flutter)

- [x] Modèle CommuneModel
- [x] Repository avec 3 méthodes
- [x] 3 providers Riverpod
- [x] 3 widgets réutilisables
- [x] Guide d'intégration complet

### À Faire

- [ ] Intégrer les widgets dans formulaire de livraison
- [ ] Tester le flux complet
- [ ] Exécuter populate_commune_gps sur Render (si pas déjà fait)

---

## 🚀 Quick Start

### Backend (Sur Render)

```bash
# 1. Appliquer les migrations (normalement auto)
python manage.py migrate

# 2. Peupler les communes
python manage.py populate_commune_gps

# 3. Vérifier
curl https://votre-backend.onrender.com/api/v1/pricing/communes/
```

### Flutter (Dans votre app)

```dart
// Importer le widget
import 'shared/widgets/commune_selector_widget.dart';

// Utiliser dans un formulaire
CommuneSelectorWidget(
  onCommuneSelected: (commune) {
    // Récupérer lat/lng automatiquement
    final coords = LatLng(
      double.parse(commune.latitude),
      double.parse(commune.longitude),
    );
  },
)
```

---

## 📞 Support

**Questions Backend** → Voir `GEOLOCATION_DEPLOYMENT_CHECKLIST.md`  
**Questions Flutter** → Voir `driver_app/GEOLOCATION_INTEGRATION_GUIDE.md`  
**Vue d'ensemble** → Voir `driver_app/GEOLOCATION_COMPLETE_SUMMARY.md`

---

## 🎓 Ressources

- **OpenRouteService API** : https://openrouteservice.org/
- **Geolocator Package** : https://pub.dev/packages/geolocator
- **Google Maps Flutter** : https://pub.dev/packages/google_maps_flutter
- **Riverpod** : https://riverpod.dev/

---

**Dernière mise à jour** : 3 décembre 2025  
**Statut** : ✅ Système complet et déployé
