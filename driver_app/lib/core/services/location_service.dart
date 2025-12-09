// lib/core/services/location_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service de géolocalisation GPS
/// Gère les permissions et le tracking de position
class LocationService {
  /// Stream pour écouter les changements de position en temps réel
  Stream<Position>? _positionStream;

  // ========== PERMISSIONS ==========

  /// Vérifier si les permissions de localisation sont accordées
  Future<bool> hasLocationPermission() async {
    try {
      final status = await Permission.locationWhenInUse.status;
      return status.isGranted;
    } on MissingPluginException catch (e) {
      if (kDebugMode) debugPrint('Permission plugin missing: $e');
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('Erreur vérification permission: $e');
      return false;
    }
  }

  /// Demander les permissions de localisation
  Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.locationWhenInUse.request();

      if (status.isDenied || status.isPermanentlyDenied) {
        return false;
      }

      return status.isGranted;
    } on MissingPluginException catch (e) {
      if (kDebugMode) debugPrint('Permission plugin missing (request): $e');
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('Erreur requestLocationPermission: $e');
      return false;
    }
  }

  /// Ouvrir les paramètres de l'app si permission refusée
  /// Ouvrir la page des paramètres d'application (si supportée)
  Future<void> openAppSettingsPage() async {
    try {
      await openAppSettings();
    } on MissingPluginException catch (e) {
      if (kDebugMode) debugPrint('openAppSettings plugin missing: $e');
    } catch (e) {
      if (kDebugMode) debugPrint('Erreur openAppSettingsPage: $e');
    }
  }

  // ========== SERVICE LOCALISATION ==========

  /// Vérifier si le service de localisation est activé
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Demander l'activation du service de localisation
  /// (Ouvre les paramètres système)
  Future<void> requestLocationService() async {
    await Geolocator.openLocationSettings();
  }

  // ========== POSITION ACTUELLE ==========

  /// Récupérer la position actuelle (une seule fois)
  Future<Position?> getCurrentPosition() async {
    try {
      // Vérifier le service
      if (!await isLocationServiceEnabled()) {
        throw Exception('Service de localisation désactivé');
      }

      // Vérifier les permissions
      if (!await hasLocationPermission()) {
        final granted = await requestLocationPermission();
        if (!granted) {
          throw Exception('Permission de localisation refusée');
        }
      }

      // Récupérer la position avec les nouveaux settings
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
        if (kDebugMode) debugPrint('❌ Erreur getCurrentPosition: $e');
      return null;
    }
  }

  /// Récupérer la dernière position connue (plus rapide, peut être ancienne)
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
        if (kDebugMode) debugPrint('❌ Erreur getLastKnownPosition: $e');
      return null;
    }
  }

  // ========== TRACKING TEMPS RÉEL ==========

  /// Démarrer le tracking GPS en temps réel
  /// Retourne un Stream qui émet la position toutes les X secondes
  Stream<Position> startPositionTracking({
    int intervalSeconds = 30,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: 10, // Mise à jour tous les 10 mètres
        timeLimit: Duration(seconds: intervalSeconds),
      ),
    );

    return _positionStream!;
  }

  /// Arrêter le tracking GPS
  void stopPositionTracking() {
    _positionStream = null;
  }

  // ========== CALCUL DISTANCE ==========

  /// Calculer la distance entre deux points (en mètres)
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
  }

  /// Calculer la distance en kilomètres
  double calculateDistanceInKm(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final distanceInMeters = calculateDistance(
      startLat,
      startLng,
      endLat,
      endLng,
    );
    return distanceInMeters / 1000;
  }

  // ========== UTILITAIRES ==========

  /// Formater les coordonnées pour l'affichage
  String formatCoordinates(double lat, double lng) {
    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  }

  /// Vérifier si une position est valide
  bool isValidPosition(Position? position) {
    if (position == null) return false;
    
    // Vérifier que les coordonnées sont dans les limites raisonnables
    return position.latitude >= -90 && 
           position.latitude <= 90 &&
           position.longitude >= -180 && 
           position.longitude <= 180;
  }

  /// Obtenir un résumé de l'état du GPS
  Future<Map<String, bool>> getLocationStatus() async {
    return {
      'serviceEnabled': await isLocationServiceEnabled(),
      'permissionGranted': await hasLocationPermission(),
    };
  }
}
