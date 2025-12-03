# 🗺️ Guide d'utilisation de la géolocalisation automatique

## 📋 Vue d'ensemble du système

Le système de géolocalisation automatique est maintenant complet :

### ✅ Backend

1. **Signal automatique** : Géocode les adresses lors de la création de livraison
2. **Coordonnées par commune** : Chaque commune a des coordonnées GPS par défaut
3. **API de géocodage** : Endpoints pour obtenir les coordonnées d'adresses

### 🎯 Comment ça fonctionne

#### 1. À la création d'une livraison dans l'admin Django

**Automatique** :

- Le signal `pre_save` intercepte la livraison avant sauvegarde
- Essaie de géocoder l'adresse complète avec OpenRouteService
- Si échec, utilise les coordonnées par défaut de la commune
- Calcule automatiquement la distance

**Résultat** : Les champs `pickup_latitude`, `pickup_longitude`, `delivery_latitude`, `delivery_longitude` sont remplis automatiquement !

---

## 🚀 Utilisation

### Sur le serveur (une seule fois)

#### Étape 1 : Appliquer la migration

```bash
python manage.py migrate
```

#### Étape 2 : Remplir les coordonnées des communes

```bash
python manage.py populate_commune_gps
```

Cela va créer/mettre à jour les coordonnées GPS pour :

- Cocody, Plateau, Marcory, Yopougon, Abobo, Adjamé, Treichville, Port-Bouët, Attécoubé, Koumassi, Bingerville, Anyama, Songon

#### Étape 3 : Géocoder les livraisons existantes (optionnel)

```bash
python manage.py geocode_deliveries
```

---

## 📡 Nouveaux endpoints API

### 1. Liste des communes avec coordonnées

```http
GET /api/v1/pricing/communes/
```

**Réponse** :

```json
{
  "count": 13,
  "communes": [
    {
      "commune": "Cocody",
      "latitude": 5.3599517,
      "longitude": -4.0082563,
      "zone_name": "Zone Cocody"
    },
    {
      "commune": "Yopougon",
      "latitude": 5.2893189,
      "longitude": -4.0744303,
      "zone_name": "Zone Yopougon"
    },
    ...
  ]
}
```

**Utilisation Flutter** :

```dart
// Lors du chargement de la liste des communes
Future<List<Commune>> fetchCommunes() async {
  final response = await _dioClient.get('/api/v1/pricing/communes/');
  final communes = (response.data['communes'] as List)
      .map((json) => Commune.fromJson(json))
      .toList();
  return communes;
}
```

---

### 2. Coordonnées d'une commune spécifique

```http
GET /api/v1/pricing/communes/coordinates/?commune=Cocody
```

**Réponse** :

```json
{
  "commune": "Cocody",
  "latitude": 5.3599517,
  "longitude": -4.0082563,
  "zone_name": "Zone Cocody"
}
```

**Utilisation Flutter** :

```dart
// Quand l'utilisateur sélectionne une commune
Future<LatLng?> getCommuneCoordinates(String commune) async {
  try {
    final response = await _dioClient.get(
      '/api/v1/pricing/communes/coordinates/',
      queryParameters: {'commune': commune},
    );
    return LatLng(
      response.data['latitude'],
      response.data['longitude'],
    );
  } catch (e) {
    return null;
  }
}
```

---

### 3. Géocoder une adresse complète

```http
POST /api/v1/pricing/geocode/
Content-Type: application/json

{
  "address": "Rue des Jardins, Cocody",
  "city": "Abidjan"
}
```

**Réponse** :

```json
{
  "address": "Rue des Jardins, Cocody",
  "latitude": 5.3612345,
  "longitude": -4.0098765
}
```

**Utilisation Flutter** :

```dart
// Géocoder une adresse entrée par l'utilisateur
Future<LatLng?> geocodeAddress(String address) async {
  try {
    final response = await _dioClient.post(
      '/api/v1/pricing/geocode/',
      data: {
        'address': address,
        'city': 'Abidjan',
      },
    );
    return LatLng(
      response.data['latitude'],
      response.data['longitude'],
    );
  } catch (e) {
    print('Géocodage échoué: $e');
    return null;
  }
}
```

---

## 🎨 Intégration Flutter recommandée

### Scénario 1 : Sélection de commune dans un dropdown

```dart
class CommuneSelector extends StatefulWidget {
  @override
  _CommuneSelectorState createState() => _CommuneSelectorState();
}

class _CommuneSelectorState extends State<CommuneSelector> {
  List<Commune> _communes = [];
  Commune? _selectedCommune;

  @override
  void initState() {
    super.initState();
    _loadCommunes();
  }

  Future<void> _loadCommunes() async {
    final communes = await _apiService.fetchCommunes();
    setState(() {
      _communes = communes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Commune>(
      value: _selectedCommune,
      hint: Text('Sélectionnez une commune'),
      items: _communes.map((commune) {
        return DropdownMenuItem(
          value: commune,
          child: Text(commune.name),
        );
      }).toList(),
      onChanged: (commune) {
        setState(() {
          _selectedCommune = commune;
        });
        // Les coordonnées sont déjà disponibles
        print('Commune: ${commune!.name}');
        print('Coordonnées: (${commune.latitude}, ${commune.longitude})');
      },
    );
  }
}
```

---

### Scénario 2 : Saisie d'adresse avec auto-complétion + géocodage

```dart
class AddressInput extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  AddressInput({required this.onLocationSelected});

  @override
  _AddressInputState createState() => _AddressInputState();
}

class _AddressInputState extends State<AddressInput> {
  final TextEditingController _addressController = TextEditingController();
  LatLng? _coordinates;

  Future<void> _geocodeAddress() async {
    final address = _addressController.text;
    if (address.isEmpty) return;

    final coords = await _apiService.geocodeAddress(address);
    if (coords != null) {
      setState(() {
        _coordinates = coords;
      });
      widget.onLocationSelected(coords);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Adresse géocodée avec succès')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Impossible de localiser cette adresse')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _addressController,
          decoration: InputDecoration(
            labelText: 'Adresse complète',
            hintText: 'Ex: Rue des Jardins, Cocody',
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: _geocodeAddress,
            ),
          ),
        ),
        if (_coordinates != null)
          Text(
            'Coordonnées: ${_coordinates!.latitude}, ${_coordinates!.longitude}',
            style: TextStyle(color: Colors.green),
          ),
      ],
    );
  }
}
```

---

### Scénario 3 : Utiliser le GPS de l'appareil

```dart
import 'package:geolocator/geolocator.dart';

class LocationPicker extends StatefulWidget {
  final Function(LatLng) onLocationPicked;

  LocationPicker({required this.onLocationPicked});

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LatLng? _currentLocation;
  bool _loading = false;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _loading = true;
    });

    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissions GPS refusées');
      }

      // Obtenir la position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final location = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = location;
        _loading = false;
      });

      widget.onLocationPicked(location);

    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _loading ? null : _getCurrentLocation,
          icon: _loading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.my_location),
          label: Text('Utiliser ma position'),
        ),
        if (_currentLocation != null)
          Text(
            'Position actuelle: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}',
            style: TextStyle(color: Colors.green),
          ),
      ],
    );
  }
}
```

---

## ✅ Checklist d'intégration

### Backend

- [x] Ajouter champs GPS dans `PricingZone`
- [x] Créer migration
- [x] Créer command `populate_commune_gps`
- [x] Créer signal de géocodage automatique
- [x] Créer endpoints API de géolocalisation
- [ ] Exécuter `python manage.py migrate`
- [ ] Exécuter `python manage.py populate_commune_gps`
- [ ] Redéployer sur Render

### Frontend Flutter

- [ ] Créer modèle `Commune` avec coordonnées
- [ ] Créer service API pour géolocalisation
- [ ] Intégrer sélection de commune avec coordonnées
- [ ] Ajouter géocodage d'adresse (optionnel)
- [ ] Ajouter bouton "Ma position" (optionnel)
- [ ] Envoyer les coordonnées lors de la création de livraison

---

## 🎯 Résultat final

**Avant** :

- Distance = 0m
- Navigation ne fonctionne pas
- Calculs de prix incorrects

**Après** :

- ✅ Distance calculée automatiquement
- ✅ Navigation Google Maps fonctionne
- ✅ Prix correct basé sur la distance réelle
- ✅ Géolocalisation automatique à la création
- ✅ Coordonnées par défaut pour chaque commune
