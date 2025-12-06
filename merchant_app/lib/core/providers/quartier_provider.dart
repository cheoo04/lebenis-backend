// lib/core/providers/quartier_provider.dart
// Providers Riverpod pour la gestion des quartiers

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../data/providers/pricing_provider.dart'; // Pour dioClientProvider
import '../models/quartier_model.dart';
import '../repositories/quartier_repository.dart';

// ============================================================
// PROVIDER DU REPOSITORY
// ============================================================

/// Provider du repository des quartiers
final quartierRepositoryProvider = Provider<QuartierRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return QuartierRepository(dioClient: dioClient);
});


// ============================================================
// PROVIDERS POUR LES DONNÉES
// ============================================================

/// Provider pour la liste des communes disponibles
final quartiersAvailableCommunesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(quartierRepositoryProvider);
  return repository.fetchCommunes();
});

/// Provider pour les quartiers d'une commune spécifique
/// Usage: ref.watch(quartiersByCommuneProvider('Cocody'))
final quartiersByCommuneProvider = FutureProvider.family<List<QuartierModel>, String>((ref, commune) async {
  final repository = ref.watch(quartierRepositoryProvider);
  return repository.fetchQuartiers(commune: commune);
});

/// Provider pour tous les quartiers (sans filtre)
final allQuartiersProvider = FutureProvider<List<QuartierModel>>((ref) async {
  final repository = ref.watch(quartierRepositoryProvider);
  return repository.fetchQuartiers();
});


// ============================================================
// PROVIDERS POUR LA RECHERCHE
// ============================================================

/// Provider pour la recherche de quartiers (autocomplete)
/// Usage: ref.watch(searchQuartiersProvider('Riviera'))
final searchQuartiersProvider = FutureProvider.family<List<QuartierModel>, String>((ref, query) async {
  if (query.length < 2) return [];
  final repository = ref.watch(quartierRepositoryProvider);
  return repository.searchQuartiers(query);
});

/// Provider pour les suggestions d'adresses (autocomplete avec Nominatim)
/// Usage: ref.watch(addressSuggestionsProvider('Aéroport'))
final addressSuggestionsProvider = FutureProvider.family<List<AddressSuggestion>, String>((ref, query) async {
  if (query.length < 3) return [];
  final repository = ref.watch(quartierRepositoryProvider);
  return repository.getSuggestions(query);
});


// ============================================================
// PROVIDERS POUR LE GÉOCODAGE
// ============================================================

/// Provider pour géocoder un quartier
/// Usage: ref.read(geocodeQuartierProvider({'quartier': 'Riviera 2', 'commune': 'Cocody'}))
final geocodeQuartierProvider = FutureProvider.family<QuartierModel?, Map<String, String>>((ref, params) async {
  final repository = ref.watch(quartierRepositoryProvider);
  final quartier = params['quartier'] ?? '';
  final commune = params['commune'] ?? '';
  
  if (quartier.isEmpty || commune.isEmpty) return null;
  
  return repository.geocodeQuartier(quartier, commune);
});

/// Provider pour géocoder une adresse libre
/// Usage: ref.read(geocodeAddressProvider({'address': 'Rue des Jardins', 'city': 'Abidjan'}))
final geocodeAddressNewProvider = FutureProvider.family<LatLng?, Map<String, String>>((ref, params) async {
  final repository = ref.watch(quartierRepositoryProvider);
  final address = params['address'] ?? '';
  final city = params['city'] ?? 'Abidjan';
  
  if (address.isEmpty) return null;
  
  return repository.geocodeAddress(address, city: city);
});

/// Provider pour le reverse geocoding (coordonnées → adresse)
/// Usage: ref.read(reverseGeocodeProvider({'lat': '5.36', 'lon': '-3.98'}))
final reverseGeocodeProvider = FutureProvider.family<String?, Map<String, String>>((ref, params) async {
  final repository = ref.watch(quartierRepositoryProvider);
  final lat = double.tryParse(params['lat'] ?? '');
  final lon = double.tryParse(params['lon'] ?? '');
  
  if (lat == null || lon == null) return null;
  
  return repository.reverseGeocode(lat, lon);
});


// ============================================================
// STATE NOTIFIER POUR LE FORMULAIRE
// ============================================================

/// État pour la sélection d'un lieu (commune + quartier + GPS)
class LocationSelectionState {
  final String? commune;
  final String? quartier;
  final double? latitude;
  final double? longitude;
  final bool isLoading;
  final String? error;

  LocationSelectionState({
    this.commune,
    this.quartier,
    this.latitude,
    this.longitude,
    this.isLoading = false,
    this.error,
  });

  /// L'adresse est-elle complète (avec GPS) ?
  bool get isComplete => commune != null && latitude != null && longitude != null;

  /// Adresse formatée pour affichage
  String get displayAddress {
    if (quartier != null && commune != null) {
      return '$quartier, $commune';
    } else if (commune != null) {
      return commune!;
    }
    return '';
  }

  LocationSelectionState copyWith({
    String? commune,
    String? quartier,
    double? latitude,
    double? longitude,
    bool? isLoading,
    String? error,
  }) {
    return LocationSelectionState(
      commune: commune ?? this.commune,
      quartier: quartier ?? this.quartier,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  LocationSelectionState reset() {
    return LocationSelectionState();
  }
}


/// Notifier pour gérer la sélection d'un lieu de livraison
class LocationSelectionNotifier extends Notifier<LocationSelectionState> {
  @override
  LocationSelectionState build() {
    return LocationSelectionState();
  }

  QuartierRepository get _repository => ref.read(quartierRepositoryProvider);

  /// Sélectionner une commune (reset le quartier)
  void selectCommune(String commune) {
    state = state.copyWith(
      commune: commune,
      quartier: null,
      latitude: null,
      longitude: null,
    );
  }

  /// Sélectionner un quartier et obtenir les coordonnées GPS
  Future<void> selectQuartier(String quartier) async {
    if (state.commune == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.geocodeQuartier(quartier, state.commune!);

      if (result != null) {
        state = state.copyWith(
          quartier: result.nom,
          latitude: result.latitude,
          longitude: result.longitude,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          quartier: quartier,
          isLoading: false,
          error: 'Coordonnées non trouvées',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: $e',
      );
    }
  }

  /// Définir les coordonnées manuellement (après sélection sur carte)
  void setCoordinates(double latitude, double longitude) {
    state = state.copyWith(
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Réinitialiser la sélection
  void reset() {
    state = LocationSelectionState();
  }
}


/// Provider pour la sélection du lieu de récupération (pickup)
final pickupLocationProvider = NotifierProvider<LocationSelectionNotifier, LocationSelectionState>(
  LocationSelectionNotifier.new,
);

/// Provider pour la sélection du lieu de livraison (delivery)
final deliveryLocationProvider = NotifierProvider<LocationSelectionNotifier, LocationSelectionState>(
  LocationSelectionNotifier.new,
);
