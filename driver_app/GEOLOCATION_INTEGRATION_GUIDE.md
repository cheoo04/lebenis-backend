// GUIDE D'INTÉGRATION FLUTTER - GÉOLOCALISATION

# Guide d'Intégration des Widgets de Géolocalisation

## 📦 Packages Requis

Ajoutez dans `pubspec.yaml` :

```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  dio: ^5.3.3
```

Puis : `flutter pub get`

## 🏗️ Structure des Fichiers Créés

```
driver_app/lib/
├── data/
│   ├── models/commune/commune_model.dart          # Modèle de commune avec GPS
│   ├── repositories/geolocation_repository.dart   # API calls géolocalisation
│   └── providers/geolocation_provider.dart        # Riverpod providers
└── shared/widgets/
    ├── commune_selector_widget.dart               # Dropdown de communes
    ├── address_geocoder_widget.dart               # Champ adresse avec géocodage
    └── location_picker_widget.dart                # Bouton GPS actuel
```

## 🔧 Configuration des Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<manifest ...>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.INTERNET" />

    <application ...>
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
    </application>
</manifest>
```

### iOS (`ios/Runner/Info.plist`)

```xml
<dict>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Cette app a besoin d'accéder à votre position pour les livraisons</string>
    <key>NSLocationAlwaysUsageDescription</key>
    <string>Cette app a besoin d'accéder à votre position en arrière-plan</string>
</dict>
```

## 🎯 Exemple d'Utilisation Complète

### Option 1 : Sélection de Commune

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'shared/widgets/commune_selector_widget.dart';

class DeliveryAddressForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<DeliveryAddressForm> createState() => _DeliveryAddressFormState();
}

class _DeliveryAddressFormState extends ConsumerState<DeliveryAddressForm> {
  LatLng? pickupCoordinates;
  String? pickupCommune;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adresse de Récupération')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CommuneSelectorWidget(
              label: 'Commune de récupération',
              onCommuneSelected: (commune) {
                setState(() {
                  pickupCommune = commune.commune;
                  pickupCoordinates = LatLng(
                    double.parse(commune.latitude),
                    double.parse(commune.longitude),
                  );
                });
                print('📍 Commune: ${commune.commune}');
                print('GPS: ${pickupCoordinates}');
              },
            ),

            const SizedBox(height: 20),

            if (pickupCoordinates != null)
              Text('✅ Position: $pickupCoordinates'),
          ],
        ),
      ),
    );
  }
}
```

### Option 2 : Géocodage d'Adresse

```dart
import 'shared/widgets/address_geocoder_widget.dart';

class DeliveryWithGeocoding extends ConsumerStatefulWidget {
  @override
  ConsumerState<DeliveryWithGeocoding> createState() => _DeliveryWithGeocodingState();
}

class _DeliveryWithGeocodingState extends ConsumerState<DeliveryWithGeocoding> {
  LatLng? deliveryCoordinates;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AddressGeocoderWidget(
          label: 'Adresse de livraison',
          hint: 'Ex: Rue des Jardins, Cocody, Abidjan',
          onLocationSelected: (coordinates) {
            setState(() {
              deliveryCoordinates = coordinates;
            });
            print('📍 Livraison géocodée: $coordinates');
          },
        ),

        const SizedBox(height: 20),

        if (deliveryCoordinates != null)
          ElevatedButton(
            onPressed: () {
              // Envoyer au backend avec les coordonnées
              _createDelivery();
            },
            child: const Text('Créer la livraison'),
          ),
      ],
    );
  }
}
```

### Option 3 : Position GPS Actuelle

```dart
import 'shared/widgets/location_picker_widget.dart';

class CurrentLocationPicker extends StatefulWidget {
  @override
  State<CurrentLocationPicker> createState() => _CurrentLocationPickerState();
}

class _CurrentLocationPickerState extends State<CurrentLocationPicker> {
  LatLng? currentPosition;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LocationPickerWidget(
          buttonText: 'Je suis ici maintenant',
          showCoordinates: true,
          onLocationPicked: (coordinates) {
            setState(() {
              currentPosition = coordinates;
            });
            print('📍 Position actuelle: $coordinates');
          },
        ),
      ],
    );
  }
}
```

## 🔄 Intégration avec Formulaire de Livraison

### Exemple Complet avec les 3 Méthodes

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'shared/widgets/commune_selector_widget.dart';
import 'shared/widgets/address_geocoder_widget.dart';
import 'shared/widgets/location_picker_widget.dart';

class CompleteDeliveryForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<CompleteDeliveryForm> createState() => _CompleteDeliveryFormState();
}

class _CompleteDeliveryFormState extends ConsumerState<CompleteDeliveryForm> {
  final _formKey = GlobalKey<FormState>();

  // Récupération
  String? pickupCommune;
  LatLng? pickupCoordinates;

  // Livraison
  String? deliveryAddress;
  LatLng? deliveryCoordinates;

  // Méthode de saisie
  String locationMethod = 'commune'; // 'commune', 'address', 'gps'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle Livraison')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // SECTION RÉCUPÉRATION
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📦 Point de Récupération',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Choix de la méthode
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'commune', label: Text('Commune'), icon: Icon(Icons.location_city)),
                        ButtonSegment(value: 'address', label: Text('Adresse'), icon: Icon(Icons.edit_location)),
                        ButtonSegment(value: 'gps', label: Text('GPS'), icon: Icon(Icons.my_location)),
                      ],
                      selected: {locationMethod},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          locationMethod = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Widget selon la méthode choisie
                    if (locationMethod == 'commune')
                      CommuneSelectorWidget(
                        label: 'Commune',
                        onCommuneSelected: (commune) {
                          setState(() {
                            pickupCommune = commune.commune;
                            pickupCoordinates = LatLng(
                              double.parse(commune.latitude),
                              double.parse(commune.longitude),
                            );
                          });
                        },
                      )
                    else if (locationMethod == 'address')
                      AddressGeocoderWidget(
                        label: 'Adresse de récupération',
                        hint: 'Ex: Boulevard de Marseille, Marcory',
                        onLocationSelected: (coordinates) {
                          setState(() {
                            pickupCoordinates = coordinates;
                          });
                        },
                      )
                    else
                      LocationPickerWidget(
                        buttonText: 'Utiliser ma position',
                        onLocationPicked: (coordinates) {
                          setState(() {
                            pickupCoordinates = coordinates;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // SECTION LIVRAISON (similaire)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎯 Point de Livraison',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    AddressGeocoderWidget(
                      label: 'Adresse de livraison',
                      onLocationSelected: (coordinates) {
                        setState(() {
                          deliveryCoordinates = coordinates;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // BOUTON DE CRÉATION
            ElevatedButton(
              onPressed: (pickupCoordinates != null && deliveryCoordinates != null)
                  ? _createDelivery
                  : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Créer la Livraison',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createDelivery() async {
    if (!_formKey.currentState!.validate()) return;

    // Préparer les données avec coordonnées GPS
    final deliveryData = {
      'pickup_latitude': pickupCoordinates!.latitude,
      'pickup_longitude': pickupCoordinates!.longitude,
      'delivery_latitude': deliveryCoordinates!.latitude,
      'delivery_longitude': deliveryCoordinates!.longitude,
      // ... autres champs
    };

    print('🚀 Création de livraison avec GPS:');
    print('Récupération: $pickupCoordinates');
    print('Livraison: $deliveryCoordinates');

    // TODO: Appeler votre API
    // await deliveryRepository.createDelivery(deliveryData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Livraison créée avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
```

## 📊 Modification du Repository pour Envoyer les Coordonnées

Mettez à jour `delivery_repository.dart` :

```dart
Future<DeliveryModel> createDelivery({
  required String merchantId,
  required String pickupAddress,
  required String deliveryAddress,
  required double pickupLatitude,
  required double pickupLongitude,
  required double deliveryLatitude,
  required double deliveryLongitude,
  String? description,
}) async {
  try {
    final response = await _dioClient.post(
      '/deliveries/',
      data: {
        'merchant': merchantId,
        'pickup_address': pickupAddress,
        'pickup_latitude': pickupLatitude.toString(),
        'pickup_longitude': pickupLongitude.toString(),
        'delivery_address': deliveryAddress,
        'delivery_latitude': deliveryLatitude.toString(),
        'delivery_longitude': deliveryLongitude.toString(),
        'description': description,
      },
    );
    return DeliveryModel.fromJson(response.data);
  } catch (e) {
    throw Exception('Failed to create delivery: $e');
  }
}
```

## ✅ Vérification Backend

Le backend calculera automatiquement la distance grâce aux coordonnées envoyées :

```python
# backend/apps/deliveries/signals.py
# Le signal pre_save utilise les coordonnées fournies ou géocode l'adresse
```

## 🧪 Test du Flux Complet

1. **Sélectionner une commune** → Coordonnées automatiques des 13 communes d'Abidjan
2. **Géocoder une adresse** → OpenRouteService API retourne lat/lng
3. **GPS actuel** → Geolocator obtient la position de l'appareil
4. **Créer la livraison** → Backend reçoit les coordonnées et calcule automatiquement la distance

## 🔍 Debugging

Si les coordonnées ne sont pas calculées :

```bash
# Backend logs
docker-compose logs -f backend | grep "Geocoding"

# Vérifier une livraison
python manage.py shell
from apps.deliveries.models import Delivery
d = Delivery.objects.last()
print(f"Pickup: ({d.pickup_latitude}, {d.pickup_longitude})")
print(f"Delivery: ({d.delivery_latitude}, {d.delivery_longitude})")
print(f"Distance: {d.distance} km")
```

## 📝 Prochaines Étapes

1. Tester les 3 widgets dans votre formulaire existant
2. Vérifier que les coordonnées sont bien envoyées à l'API
3. Confirmer que la distance est calculée automatiquement côté backend
4. Tester avec des vraies livraisons en production

## 🎨 Personnalisation

- Modifier les couleurs dans chaque widget selon votre design system
- Ajouter une carte Google Maps pour visualiser les positions
- Implémenter un historique des adresses récentes
- Ajouter l'autocomplétion avec Google Places API
