import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../shared/widgets/commune_selector_widget.dart';
import '../shared/widgets/address_geocoder_widget.dart';
import '../shared/widgets/location_picker_widget.dart';
import '../data/models/commune/commune_model.dart';

/// Écran de test pour les widgets de géolocalisation
/// Utile pour tester les fonctionnalités sans créer de vraie livraison
class GeolocationTestScreen extends ConsumerStatefulWidget {
  const GeolocationTestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GeolocationTestScreen> createState() => _GeolocationTestScreenState();
}

class _GeolocationTestScreenState extends ConsumerState<GeolocationTestScreen> {
  // État du formulaire
  CommuneModel? _selectedPickupCommune;
  CommuneModel? _selectedDeliveryCommune;
  LatLng? _pickupCoordinates;
  LatLng? _deliveryCoordinates;
  String _locationMethod = 'commune';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Géolocalisation'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // En-tête
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Écran de Test',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Testez les 3 méthodes de géolocalisation :\n'
                    '1. Sélection de commune (coordonnées pré-enregistrées)\n'
                    '2. Géocodage d\'adresse (OpenRouteService API)\n'
                    '3. Position GPS actuelle (Geolocator)',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // SECTION RÉCUPÉRATION
          _buildPickupSection(),

          const SizedBox(height: 24),

          // SECTION LIVRAISON
          _buildDeliverySection(),

          const SizedBox(height: 24),

          // RÉSUMÉ
          _buildSummarySection(),
        ],
      ),
    );
  }

  Widget _buildPickupSection() {
    return Card(
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
            const Text(
              'Choisissez une méthode :',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'commune',
                  label: Text('Commune'),
                  icon: Icon(Icons.location_city, size: 16),
                ),
                ButtonSegment(
                  value: 'address',
                  label: Text('Adresse'),
                  icon: Icon(Icons.edit_location, size: 16),
                ),
                ButtonSegment(
                  value: 'gps',
                  label: Text('GPS'),
                  icon: Icon(Icons.my_location, size: 16),
                ),
              ],
              selected: {_locationMethod},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _locationMethod = newSelection.first;
                  _pickupCoordinates = null;
                  _selectedPickupCommune = null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Widget selon la méthode
            if (_locationMethod == 'commune')
              CommuneSelectorWidget(
                label: 'Commune de récupération',
                onCommuneSelected: (commune) {
                  setState(() {
                    _selectedPickupCommune = commune;
                    _pickupCoordinates = LatLng(
                      double.parse(commune.latitude),
                      double.parse(commune.longitude),
                    );
                  });
                  _showSnackBar('✅ Commune: ${commune.commune} sélectionnée');
                },
              )
            else if (_locationMethod == 'address')
              AddressGeocoderWidget(
                label: 'Adresse de récupération',
                hint: 'Ex: Boulevard de Marseille, Marcory, Abidjan',
                onLocationSelected: (coordinates) {
                  setState(() {
                    _pickupCoordinates = coordinates;
                  });
                  _showSnackBar('✅ Adresse géocodée avec succès');
                },
              )
            else
              LocationPickerWidget(
                buttonText: 'Utiliser ma position actuelle',
                showCoordinates: true,
                onLocationPicked: (coordinates) {
                  setState(() {
                    _pickupCoordinates = coordinates;
                  });
                  _showSnackBar('✅ Position GPS obtenue');
                },
              ),

            // Affichage des coordonnées
            if (_pickupCoordinates != null) ...[
              const SizedBox(height: 12),
              _buildCoordinatesDisplay(
                'Récupération',
                _pickupCoordinates!,
                Colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Card(
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

            const Text(
              'Méthode : Géocodage d\'adresse',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            AddressGeocoderWidget(
              label: 'Adresse de livraison',
              hint: 'Ex: Rue des Jardins, Cocody, Abidjan',
              onLocationSelected: (coordinates) {
                setState(() {
                  _deliveryCoordinates = coordinates;
                });
                _showSnackBar('✅ Adresse de livraison géocodée');
              },
            ),

            if (_deliveryCoordinates != null) ...[
              const SizedBox(height: 12),
              _buildCoordinatesDisplay(
                'Livraison',
                _deliveryCoordinates!,
                Colors.orange,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    final hasPickup = _pickupCoordinates != null;
    final hasDelivery = _deliveryCoordinates != null;
    final bothSet = hasPickup && hasDelivery;

    double? distance;
    if (bothSet) {
      distance = _calculateDistance(
        _pickupCoordinates!,
        _deliveryCoordinates!,
      );
    }

    return Card(
      color: bothSet ? Colors.green.shade50 : Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  bothSet ? Icons.check_circle : Icons.info_outline,
                  color: bothSet ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Résumé',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildSummaryRow('📦 Récupération', hasPickup),
            _buildSummaryRow('🎯 Livraison', hasDelivery),

            if (bothSet) ...[
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.straighten, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Distance estimée: ${distance!.toStringAsFixed(2)} km',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '✅ Prêt ! Ces coordonnées peuvent être envoyées au backend pour créer une livraison.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.green,
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              const Text(
                'Sélectionnez les deux points pour voir la distance.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinatesDisplay(String label, LatLng coords, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Lat: ${coords.latitude.toStringAsFixed(6)}\n'
            'Lng: ${coords.longitude.toStringAsFixed(6)}',
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, bool isSet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isSet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 20,
            color: isSet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSet ? Colors.black87 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    // Formule de Haversine simplifiée
    const double earthRadiusKm = 6371.0;
    
    final dLat = _degreesToRadians(point2.latitude - point1.latitude);
    final dLng = _degreesToRadians(point2.longitude - point1.longitude);
    
    final a = (dLat / 2).sin() * (dLat / 2).sin() +
        _degreesToRadians(point1.latitude).cos() *
        _degreesToRadians(point2.latitude).cos() *
        (dLng / 2).sin() * (dLng / 2).sin();
    
    final c = 2 * (a.sqrt()).asin();
    
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180.0);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
