// lib/data/providers/location_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/location_service.dart';
import '../repositories/driver_repository.dart';
import 'driver_provider.dart'; // Import pour utiliser driverRepositoryProvider

// ========== SERVICE PROVIDER ==========

/// Location Service Provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// ========== LOCATION STATE ==========

class LocationState {
  final Position? currentPosition;
  final bool isTracking;
  final bool hasPermission;
  final bool isServiceEnabled;
  final String? error;

  LocationState({
    this.currentPosition,
    this.isTracking = false,
    this.hasPermission = false,
    this.isServiceEnabled = false,
    this.error,
  });

  LocationState copyWith({
    Position? currentPosition,
    bool? isTracking,
    bool? hasPermission,
    bool? isServiceEnabled,
    String? error,
    bool clearError = false,
  }) {
    return LocationState(
      currentPosition: currentPosition ?? this.currentPosition,
      isTracking: isTracking ?? this.isTracking,
      hasPermission: hasPermission ?? this.hasPermission,
      isServiceEnabled: isServiceEnabled ?? this.isServiceEnabled,
      error: clearError ? null : error,
    );
  }

  /// Vérifie si le GPS est prêt
  bool get isReady => hasPermission && isServiceEnabled;
}

// ========== LOCATION NOTIFIER ==========


class LocationNotifier extends Notifier<LocationState> {
  late final LocationService _locationService;
  late final DriverRepository _driverRepository;
  Timer? _updateTimer;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  LocationState build() {
    _locationService = ref.read(locationServiceProvider);
    _driverRepository = ref.read(driverRepositoryProvider);
    _checkPermissionsAndService();
    return LocationState();
  }

  /// Vérifier les permissions et le service GPS
  Future<void> _checkPermissionsAndService() async {
    final hasPermission = await _locationService.hasLocationPermission();
    final isServiceEnabled = await _locationService.isLocationServiceEnabled();
    
    state = state.copyWith(
      hasPermission: hasPermission,
      isServiceEnabled: isServiceEnabled,
    );
  }

  /// Demander les permissions
  Future<bool> requestPermission() async {
    final granted = await _locationService.requestLocationPermission();
    state = state.copyWith(hasPermission: granted);
    
    if (!granted) {
      state = state.copyWith(
        error: 'Permission de localisation refusée',
      );
    }
    
    return granted;
  }

  /// Demander l'activation du service GPS
  Future<void> requestLocationService() async {
    await _locationService.requestLocationService();
    // Re-vérifier après que l'utilisateur revienne
    await Future.delayed(const Duration(seconds: 1));
    final isEnabled = await _locationService.isLocationServiceEnabled();
    state = state.copyWith(isServiceEnabled: isEnabled);
  }

  /// Récupérer la position actuelle (une seule fois)
  Future<Position?> getCurrentPosition() async {
    state = state.copyWith(clearError: true);
    
    try {
      final position = await _locationService.getCurrentPosition();
      
      if (position != null) {
        state = state.copyWith(currentPosition: position);
        
        // Envoyer au backend
        await _updateLocationToBackend(position.latitude, position.longitude);
      }
      
      return position;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Démarrer le tracking GPS en temps réel (toutes les 30 secondes)
  Future<void> startTracking() async {
    if (state.isTracking) return;

    // Vérifier les prérequis
    if (!state.hasPermission) {
      final granted = await requestPermission();
      if (!granted) return;
    }

    if (!state.isServiceEnabled) {
      state = state.copyWith(
        error: 'Service de localisation désactivé',
      );
      return;
    }

    state = state.copyWith(isTracking: true, clearError: true);

    // Stream de positions
    final positionStream = _locationService.startPositionTracking(
      intervalSeconds: 30,
    );

    _positionStreamSubscription = positionStream.listen(
      (position) {
        state = state.copyWith(currentPosition: position);
        
        // Envoyer au backend
        _updateLocationToBackend(position.latitude, position.longitude);
      },
      onError: (error) {
        state = state.copyWith(
          error: error.toString(),
          isTracking: false,
        );
      },
    );
  }

  /// Arrêter le tracking GPS
  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _locationService.stopPositionTracking();
    
    state = state.copyWith(isTracking: false);
  }

  /// Envoyer la position au backend
  Future<void> _updateLocationToBackend(double lat, double lng) async {
    try {
      await _driverRepository.updateLocation(lat, lng);
      // Position sent successfully - silent success
    } catch (e) {
      // Silently handle error - location updates are best effort
      // Ne pas afficher l'erreur à l'utilisateur pour éviter le spam
    }
  }

  /// Rafraîchir l'état des permissions/service
  Future<void> refresh() async {
    await _checkPermissionsAndService();
  }

  @override
  void dispose() {
    stopTracking();
    _updateTimer?.cancel();
  }
}

// ========== PROVIDER ==========

final locationProvider = NotifierProvider<LocationNotifier, LocationState>(LocationNotifier.new);

// ========== COMPUTED PROVIDERS ==========

/// Position actuelle (simple)
final currentPositionProvider = Provider<Position?>((ref) {
  return ref.watch(locationProvider).currentPosition;
});

/// Latitude actuelle
final currentLatitudeProvider = Provider<double?>((ref) {
  return ref.watch(currentPositionProvider)?.latitude;
});

/// Longitude actuelle
final currentLongitudeProvider = Provider<double?>((ref) {
  return ref.watch(currentPositionProvider)?.longitude;
});

/// Vérifie si le GPS est prêt
final isGpsReadyProvider = Provider<bool>((ref) {
  return ref.watch(locationProvider).isReady;
});

/// Distance entre deux points (helper)
final distanceCalculatorProvider = Provider<double? Function(double, double, double, double)>((ref) {
  final locationService = ref.read(locationServiceProvider);
  return (startLat, startLng, endLat, endLng) {
    return locationService.calculateDistanceInKm(
      startLat,
      startLng,
      endLat,
      endLng,
    );
  };
});
