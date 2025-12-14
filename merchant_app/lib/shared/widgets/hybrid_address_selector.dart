// lib/shared/widgets/hybrid_address_selector.dart
// Widget hybride de sélection d'adresse (Option C)
// Combine: Dropdown, Carte, et GPS

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/providers/quartier_provider.dart';

/// Vérifier si le GPS est supporté sur cette plateforme
bool get isGpsSupported {
  return !kIsWeb && 
      (defaultTargetPlatform == TargetPlatform.android || 
       defaultTargetPlatform == TargetPlatform.iOS);
}

/// Mode de sélection d'adresse
enum AddressSelectionMode {
  dropdown,  // Sélection par dropdown (commune + quartier)
  map,       // Sélection sur carte
  gps,       // Utiliser ma position GPS actuelle
}

/// Résultat de la sélection d'adresse
class AddressResult {
  final String? commune;
  final String? quartier;
  final double? latitude;
  final double? longitude;
  final AddressSelectionMode mode;
  final String? streetAddress; // Adresse/repère optionnel

  AddressResult({
    this.commune,
    this.quartier,
    this.latitude,
    this.longitude,
    required this.mode,
    this.streetAddress,
  });

  bool get hasCoordinates => latitude != null && longitude != null;
  bool get isValid => commune != null || hasCoordinates;

  String get displayAddress {
    final parts = <String>[];
    if (quartier != null) parts.add(quartier!);
    if (commune != null) parts.add(commune!);
    if (streetAddress != null && streetAddress!.isNotEmpty) {
      parts.insert(0, streetAddress!);
    }
    return parts.join(', ');
  }
}

/// Widget hybride pour sélection d'adresse
/// 3 modes: Dropdown, Carte, GPS
class HybridAddressSelector extends ConsumerStatefulWidget {
  final Function(AddressResult result)? onAddressSelected;
  final String? initialCommune;
  final String? initialQuartier;
  final double? initialLatitude;
  final double? initialLongitude;
  final String label;
  final bool required;
  final bool showStreetField;

  const HybridAddressSelector({
    super.key,
    this.onAddressSelected,
    this.initialCommune,
    this.initialQuartier,
    this.initialLatitude,
    this.initialLongitude,
    this.label = 'Adresse',
    this.required = false,
    this.showStreetField = true,
  });

  @override
  ConsumerState<HybridAddressSelector> createState() => _HybridAddressSelectorState();
}

class _HybridAddressSelectorState extends ConsumerState<HybridAddressSelector> {
  AddressSelectionMode _currentMode = AddressSelectionMode.dropdown;
  
  // Données communes
  String? _selectedCommune;
  String? _selectedQuartier;
  double? _latitude;
  double? _longitude;
  final TextEditingController _streetController = TextEditingController();
  
  // État
  bool _isLoading = false;
  bool _isMapExpanded = false;
  
  // Map controller
  MapController? _mapController;
  
  // Centre par défaut sur Abidjan
  static const LatLng _defaultCenter = LatLng(5.3600, -4.0083);

  @override
  void initState() {
    super.initState();
    _selectedCommune = widget.initialCommune;
    _selectedQuartier = widget.initialQuartier;
    _latitude = widget.initialLatitude;
    _longitude = widget.initialLongitude;
  }

  @override
  void dispose() {
    _streetController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _notifyChange() {
    widget.onAddressSelected?.call(AddressResult(
      commune: _selectedCommune,
      quartier: _selectedQuartier,
      latitude: _latitude,
      longitude: _longitude,
      mode: _currentMode,
      streetAddress: _streetController.text.isNotEmpty ? _streetController.text : null,
    ));
  }

  /// Obtenir la position GPS actuelle
  Future<void> _getCurrentLocation() async {
    // Vérifier si GPS est supporté sur cette plateforme
    if (!isGpsSupported) {
      _showError('GPS non disponible sur cette plateforme (Desktop/Web). Utilisez la carte ou la liste.');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Permission de localisation refusée');
          setState(() => _isLoading = false);
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _showError('Permission refusée. Activez dans les paramètres.');
        setState(() => _isLoading = false);
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _currentMode = AddressSelectionMode.gps;
          _isLoading = false;
        });
        
        // Essayer de trouver la commune correspondante
        await _reverseGeocode(position.latitude, position.longitude);
        
        _notifyChange();
        _showSuccess('Position GPS obtenue !');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Erreur GPS: ${e.toString().split(':').first}');
      }
    }
  }

  /// Reverse geocode pour trouver la commune
  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final repository = ref.read(quartierRepositoryProvider);
      final nearestQuartier = await repository.findNearestQuartier(lat, lng);
      
      if (nearestQuartier != null && mounted) {
        setState(() {
          _selectedCommune = nearestQuartier.commune.toUpperCase();
          _selectedQuartier = nearestQuartier.nom;
        });
      }
    } catch (e) {
      // Ignorer les erreurs de reverse geocode
      debugPrint('Reverse geocode error: $e');
    }
  }

  /// Géocoder un quartier sélectionné
  Future<void> _geocodeQuartier() async {
    if (_selectedQuartier == null || _selectedCommune == null) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(quartierRepositoryProvider);
      final result = await repository.geocodeQuartier(
        _selectedQuartier!,
        _selectedCommune!,
      );

      if (result != null && mounted) {
        setState(() {
          _latitude = result.latitude;
          _longitude = result.longitude;
          _isLoading = false;
        });
        _notifyChange();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _currentMode = AddressSelectionMode.map;
    });
    
    // Reverse geocode en background
    _reverseGeocode(position.latitude, position.longitude);
    _notifyChange();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red[600]),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green[600], duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre avec badge de mode
            _buildHeader(),
            const SizedBox(height: 16),
            
            // Sélecteur de mode (tabs)
            _buildModeSelector(),
            const SizedBox(height: 16),
            
            // Contenu selon le mode
            _buildModeContent(),
            
            // Champ adresse/repère optionnel
            if (widget.showStreetField) ...[
              const SizedBox(height: 16),
              _buildStreetField(),
            ],
            
            // Résumé de l'adresse
            if (_hasSelection) ...[
              const SizedBox(height: 16),
              _buildAddressSummary(),
            ],
          ],
        ),
      ),
    );
  }

  bool get _hasSelection => _selectedCommune != null || (_latitude != null && _longitude != null);

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          color: Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (widget.required)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Requis',
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildModeTab(
            icon: Icons.list,
            label: 'Liste',
            mode: AddressSelectionMode.dropdown,
          ),
          _buildModeTab(
            icon: Icons.map,
            label: 'Carte',
            mode: AddressSelectionMode.map,
          ),
          _buildModeTab(
            icon: Icons.my_location,
            label: isGpsSupported ? 'GPS' : 'GPS ❌',
            mode: AddressSelectionMode.gps,
            showLoading: _isLoading && _currentMode == AddressSelectionMode.gps,
            disabled: !isGpsSupported,
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab({
    required IconData icon,
    required String label,
    required AddressSelectionMode mode,
    bool showLoading = false,
    bool disabled = false,
  }) {
    final isSelected = _currentMode == mode;
    
    return Expanded(
      child: GestureDetector(
        onTap: disabled ? null : () {
          if (mode == AddressSelectionMode.gps) {
            _getCurrentLocation();
          } else {
            setState(() => _currentMode = mode);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: disabled 
                ? Colors.grey[300] 
                : (isSelected ? Theme.of(context).primaryColor : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                )
              else
                Icon(
                  icon,
                  size: 18,
                  color: disabled 
                      ? Colors.grey[500] 
                      : (isSelected ? Colors.white : Colors.grey[600]),
                ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: disabled 
                      ? Colors.grey[500] 
                      : (isSelected ? Colors.white : Colors.grey[600]),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeContent() {
    switch (_currentMode) {
      case AddressSelectionMode.dropdown:
        return _buildDropdownMode();
      case AddressSelectionMode.map:
        return _buildMapMode();
      case AddressSelectionMode.gps:
        return _buildGPSMode();
    }
  }

  Widget _buildDropdownMode() {
    final communesAsync = ref.watch(quartiersAvailableCommunesProvider);

    return Column(
      children: [
        // Dropdown Commune
        communesAsync.when(
          data: (communes) => DropdownButtonFormField<String>(
            value: _selectedCommune,
            decoration: InputDecoration(
              labelText: 'Commune',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.location_city),
            ),
            items: communes.map((commune) {
              return DropdownMenuItem(value: commune, child: Text(commune));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCommune = value;
                _selectedQuartier = null;
                _latitude = null;
                _longitude = null;
              });
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Erreur: $e', style: const TextStyle(color: Colors.red)),
        ),
        const SizedBox(height: 12),

        // Dropdown Quartier
        if (_selectedCommune != null)
          ref.watch(quartiersByCommuneProvider(_selectedCommune!)).when(
            data: (quartiers) => DropdownButtonFormField<String>(
              value: _selectedQuartier,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Quartier',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: const Icon(Icons.home),
              ),
              items: quartiers.map((q) {
                return DropdownMenuItem(
                  value: q.nom,
                  child: Row(
                    children: [
                      Flexible(child: Text(q.nom, overflow: TextOverflow.ellipsis)),
                      if (q.hasCoordinates) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.gps_fixed, size: 14, color: Colors.green),
                      ],
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedQuartier = value;
                  _latitude = null;
                  _longitude = null;
                });
                if (value != null) {
                  Future.delayed(const Duration(milliseconds: 100), _geocodeQuartier);
                }
              },
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Erreur: $e'),
          ),
      ],
    );
  }

  Widget _buildMapMode() {
    final center = (_latitude != null && _longitude != null)
        ? LatLng(_latitude!, _longitude!)
        : _defaultCenter;

    return Column(
      children: [
        // Bouton pour afficher/masquer la carte
        OutlinedButton.icon(
          onPressed: () => setState(() => _isMapExpanded = !_isMapExpanded),
          icon: Icon(_isMapExpanded ? Icons.expand_less : Icons.map),
          label: Text(_isMapExpanded ? 'Masquer la carte' : 'Afficher la carte'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
          ),
        ),
        
        // Carte (si étendue)
        if (_isMapExpanded) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 250,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController ??= MapController(),
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 13.0,
                      minZoom: 10.0,
                      maxZoom: 18.0,
                      onTap: _onMapTap,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.lebeni.business',
                      ),
                      if (_latitude != null && _longitude != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(_latitude!, _longitude!),
                              width: 50,
                              height: 50,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 50,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  
                  // Bouton GPS sur la carte
                  Positioned(
                    top: 10,
                    right: 10,
                    child: FloatingActionButton.small(
                      onPressed: _getCurrentLocation,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.my_location),
                    ),
                  ),
                  
                  // Instructions
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '📍 Touchez la carte pour placer le marqueur',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGPSMode() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Récupération de votre position...'),
          ],
        ),
      );
    }

    if (_latitude != null && _longitude != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green[700], size: 40),
            const SizedBox(height: 8),
            const Text(
              'Position GPS obtenue',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser ma position'),
            ),
          ],
        ),
      );
    }

    // Bouton pour obtenir la position
    return OutlinedButton.icon(
      onPressed: _getCurrentLocation,
      icon: const Icon(Icons.my_location),
      label: const Text('Utiliser ma position actuelle'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(color: Theme.of(context).primaryColor),
      ),
    );
  }

  Widget _buildStreetField() {
    return TextField(
      controller: _streetController,
      decoration: InputDecoration(
        labelText: 'Adresse / Repère (optionnel)',
        hintText: 'Ex: Près du marché, immeuble blanc...',
        prefixIcon: const Icon(Icons.signpost),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: (_) => _notifyChange(),
    );
  }

  Widget _buildAddressSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedQuartier != null || _selectedCommune != null)
                  Text(
                    [_selectedQuartier, _selectedCommune].whereType<String>().join(', '),
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (_streetController.text.isNotEmpty)
                  Text(
                    _streetController.text,
                    style: TextStyle(color: Colors.blue[600], fontSize: 12),
                  ),
              ],
            ),
          ),
          if (_latitude != null && _longitude != null)
            Icon(Icons.gps_fixed, color: Colors.green[700], size: 18),
        ],
      ),
    );
  }
}
