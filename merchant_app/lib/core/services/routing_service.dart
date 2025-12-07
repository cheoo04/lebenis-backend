// lib/core/services/routing_service.dart
// Service pour calculer les itinéraires réels avec OSRM

import 'package:latlong2/latlong.dart';
import '../network/dio_client.dart';

/// Modèle pour un point de route
class RoutePoint {
  final double lat;
  final double lng;

  const RoutePoint({required this.lat, required this.lng});

  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  LatLng toLatLng() => LatLng(lat, lng);
}

/// Modèle pour un leg (segment) de route
class RouteLeg {
  final String name;
  final String label;
  final double distanceKm;
  final double durationMin;
  final List<RoutePoint> polylinePoints;
  final String source;

  const RouteLeg({
    required this.name,
    required this.label,
    required this.distanceKm,
    required this.durationMin,
    required this.polylinePoints,
    required this.source,
  });

  factory RouteLeg.fromJson(Map<String, dynamic> json) {
    return RouteLeg(
      name: json['name'] ?? '',
      label: json['label'] ?? '',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      durationMin: (json['duration_min'] as num?)?.toDouble() ?? 0.0,
      polylinePoints: (json['polyline_points'] as List?)
              ?.map((p) => RoutePoint.fromJson(p))
              .toList() ??
          [],
      source: json['source'] ?? 'unknown',
    );
  }

  List<LatLng> get points => polylinePoints.map((p) => p.toLatLng()).toList();
}

/// Modèle pour une route complète
class RouteResult {
  final bool success;
  final String source;
  final double distanceKm;
  final double durationMin;
  final List<RoutePoint> polylinePoints;
  final String? encodedPolyline;
  final String? warning;
  final RoutePoint? origin;
  final RoutePoint? destination;

  const RouteResult({
    required this.success,
    required this.source,
    required this.distanceKm,
    required this.durationMin,
    required this.polylinePoints,
    this.encodedPolyline,
    this.warning,
    this.origin,
    this.destination,
  });

  factory RouteResult.fromJson(Map<String, dynamic> json) {
    return RouteResult(
      success: json['success'] ?? false,
      source: json['source'] ?? 'unknown',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      durationMin: (json['duration_min'] as num?)?.toDouble() ?? 0.0,
      polylinePoints: (json['polyline_points'] as List?)
              ?.map((p) => RoutePoint.fromJson(p))
              .toList() ??
          [],
      encodedPolyline: json['encoded_polyline'],
      warning: json['warning'],
      origin: json['origin'] != null ? RoutePoint.fromJson(json['origin']) : null,
      destination:
          json['destination'] != null ? RoutePoint.fromJson(json['destination']) : null,
    );
  }

  /// Convertit les points en liste de LatLng pour flutter_map
  List<LatLng> get points => polylinePoints.map((p) => p.toLatLng()).toList();

  /// Retourne une route vide (fallback)
  static RouteResult empty() => const RouteResult(
        success: false,
        source: 'none',
        distanceKm: 0,
        durationMin: 0,
        polylinePoints: [],
      );
}

/// Modèle pour une route de livraison complète
class DeliveryRouteResult {
  final bool success;
  final double totalDistanceKm;
  final double totalDurationMin;
  final List<RouteLeg> legs;
  final List<RoutePoint> allPolylinePoints;

  const DeliveryRouteResult({
    required this.success,
    required this.totalDistanceKm,
    required this.totalDurationMin,
    required this.legs,
    required this.allPolylinePoints,
  });

  factory DeliveryRouteResult.fromJson(Map<String, dynamic> json) {
    return DeliveryRouteResult(
      success: json['success'] ?? false,
      totalDistanceKm: (json['total_distance_km'] as num?)?.toDouble() ?? 0.0,
      totalDurationMin: (json['total_duration_min'] as num?)?.toDouble() ?? 0.0,
      legs: (json['legs'] as List?)?.map((l) => RouteLeg.fromJson(l)).toList() ?? [],
      allPolylinePoints: (json['all_polyline_points'] as List?)
              ?.map((p) => RoutePoint.fromJson(p))
              .toList() ??
          [],
    );
  }

  /// Convertit tous les points en liste de LatLng
  List<LatLng> get allPoints => allPolylinePoints.map((p) => p.toLatLng()).toList();

  /// Route vide (fallback)
  static DeliveryRouteResult empty() => const DeliveryRouteResult(
        success: false,
        totalDistanceKm: 0,
        totalDurationMin: 0,
        legs: [],
        allPolylinePoints: [],
      );
}

/// Service de calcul d'itinéraires
/// 
/// Utilise l'API backend qui fait appel à OSRM (gratuit) ou OpenRouteService
class RoutingService {
  final DioClient _dioClient;

  RoutingService({required DioClient dioClient}) : _dioClient = dioClient;

  /// Calcule la route entre 2 points
  /// 
  /// [origin] - Point de départ
  /// [destination] - Point d'arrivée
  /// [waypoints] - Points intermédiaires optionnels
  Future<RouteResult> getRoute({
    required LatLng origin,
    required LatLng destination,
    List<LatLng>? waypoints,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'origin': {'lat': origin.latitude, 'lng': origin.longitude},
        'destination': {'lat': destination.latitude, 'lng': destination.longitude},
      };

      if (waypoints != null && waypoints.isNotEmpty) {
        data['waypoints'] = waypoints
            .map((w) => {'lat': w.latitude, 'lng': w.longitude})
            .toList();
      }

      final response = await _dioClient.post(
        '/api/v1/locations/route/',
        data: data,
      );

      return RouteResult.fromJson(response.data);
    } catch (e) {
      // Fallback: retourne une ligne droite
      return _fallbackStraightLine(origin, destination);
    }
  }

  /// Calcule l'itinéraire complet pour une livraison
  /// 
  /// Retourne:
  /// - Si [driverPosition] fourni: driver → pickup → delivery
  /// - Sinon: pickup → delivery
  Future<DeliveryRouteResult> getDeliveryRoute({
    required LatLng pickup,
    required LatLng delivery,
    LatLng? driverPosition,
  }) async {
    try {
      final data = {
        'pickup': {'lat': pickup.latitude, 'lng': pickup.longitude},
        'delivery': {'lat': delivery.latitude, 'lng': delivery.longitude},
      };

      if (driverPosition != null) {
        data['driver'] = {
          'lat': driverPosition.latitude,
          'lng': driverPosition.longitude,
        };
      }

      final response = await _dioClient.post(
        '/api/v1/locations/delivery-route/',
        data: data,
      );

      return DeliveryRouteResult.fromJson(response.data);
    } catch (e) {
      // Fallback: retourne une ligne droite
      return _fallbackDeliveryRoute(pickup, delivery, driverPosition);
    }
  }

  /// Fallback: retourne une ligne droite entre 2 points
  RouteResult _fallbackStraightLine(LatLng origin, LatLng destination) {
    final distance = const Distance();
    final distanceKm = distance.as(LengthUnit.Kilometer, origin, destination);
    final durationMin = distanceKm / 40 * 60; // ~40 km/h en ville

    return RouteResult(
      success: true,
      source: 'straight_line',
      distanceKm: distanceKm,
      durationMin: durationMin,
      polylinePoints: [
        RoutePoint(lat: origin.latitude, lng: origin.longitude),
        RoutePoint(lat: destination.latitude, lng: destination.longitude),
      ],
      warning: 'Itinéraire approximatif (ligne droite)',
    );
  }

  /// Fallback: retourne un itinéraire en ligne droite pour une livraison
  DeliveryRouteResult _fallbackDeliveryRoute(
    LatLng pickup,
    LatLng delivery,
    LatLng? driverPosition,
  ) {
    final distance = const Distance();
    final points = <RoutePoint>[];
    double totalDistance = 0;

    if (driverPosition != null) {
      points.add(RoutePoint(lat: driverPosition.latitude, lng: driverPosition.longitude));
      totalDistance +=
          distance.as(LengthUnit.Kilometer, driverPosition, pickup);
    }

    points.add(RoutePoint(lat: pickup.latitude, lng: pickup.longitude));
    points.add(RoutePoint(lat: delivery.latitude, lng: delivery.longitude));
    totalDistance += distance.as(LengthUnit.Kilometer, pickup, delivery);

    final totalDuration = totalDistance / 40 * 60;

    return DeliveryRouteResult(
      success: true,
      totalDistanceKm: totalDistance,
      totalDurationMin: totalDuration,
      legs: [],
      allPolylinePoints: points,
    );
  }
}
