// lib/core/services/routing_service.dart
// Service pour calculer les itinéraires réels avec OSRM

import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter/foundation.dart';
import '../network/dio_client.dart';
import '../utils/json_utils.dart';

/// Modèle pour un point de route
class RoutePoint {
  final double lat;
  final double lng;

  const RoutePoint({required this.lat, required this.lng});

  factory RoutePoint.fromJson(Map<String, dynamic> json) {
    return RoutePoint(
      lat: safeDouble(json['lat']),
      lng: safeDouble(json['lng']),
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
      distanceKm: safeDouble(json['distance_km']),
      durationMin: safeDouble(json['duration_min']),
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
  final List<RouteStep>? steps;

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
    this.steps,
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
      steps: (json['steps'] as List?)
          ?.map((s) => RouteStep.fromJson(s))
          .toList(),
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

/// Modèle pour une étape de navigation
class RouteStep {
  final String instruction;
  final double distanceM;
  final double durationS;
  final String maneuver;

  const RouteStep({
    required this.instruction,
    required this.distanceM,
    required this.durationS,
    required this.maneuver,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      instruction: json['instruction'] ?? '',
      distanceM: safeDouble(json['distance_m']),
      durationS: safeDouble(json['duration_s']),
      maneuver: json['maneuver'] ?? '',
    );
  }
}

/// Modèle pour une route de livraison complète
class DeliveryRouteResult {
  final bool success;
  final double totalDistanceKm;
  final double totalDurationMin;
  final List<RouteLeg> legs;
  final List<RoutePoint> allPolylinePoints;
  final String? pickupCoordsSource;
  final bool pickupCoordsInferred;
  final String? deliveryCoordsSource;
  final bool deliveryCoordsInferred;

  const DeliveryRouteResult({
    required this.success,
    required this.totalDistanceKm,
    required this.totalDurationMin,
    required this.legs,
    required this.allPolylinePoints,
    this.pickupCoordsSource,
    this.pickupCoordsInferred = false,
    this.deliveryCoordsSource,
    this.deliveryCoordsInferred = false,
  });

  factory DeliveryRouteResult.fromJson(Map<String, dynamic> json) {
    return DeliveryRouteResult(
      success: json['success'] ?? false,
      totalDistanceKm: safeDouble(json['total_distance_km']),
      totalDurationMin: safeDouble(json['total_duration_min']),
      legs: (json['legs'] as List?)?.map((l) => RouteLeg.fromJson(l)).toList() ?? [],
      allPolylinePoints: (json['all_polyline_points'] as List?)
              ?.map((p) => RoutePoint.fromJson(p))
              .toList() ??
          [],
      pickupCoordsSource: json['pickup_coords_source'],
      pickupCoordsInferred: json['pickup_coords_inferred'] == true,
      deliveryCoordsSource: json['delivery_coords_source'],
      deliveryCoordsInferred: json['delivery_coords_inferred'] == true,
    );
  }

  /// Convertit tous les points en liste de LatLng
  List<LatLng> get allPoints => allPolylinePoints.map((p) => p.toLatLng()).toList();

  /// Récupère le leg pour aller au pickup
  RouteLeg? get toPickupLeg => legs.firstWhere(
        (l) => l.name == 'driver_to_pickup',
        orElse: () => RouteLeg(
          name: '',
          label: '',
          distanceKm: 0,
          durationMin: 0,
          polylinePoints: [],
          source: '',
        ),
      );

  /// Récupère le leg pour aller à la destination
  RouteLeg? get toDeliveryLeg => legs.firstWhere(
        (l) => l.name == 'pickup_to_delivery',
        orElse: () => RouteLeg(
          name: '',
          label: '',
          distanceKm: 0,
          durationMin: 0,
          polylinePoints: [],
          source: '',
        ),
      );

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
      // Validate coordinates before sending to backend
      bool _validLatLng(LatLng? p) {
        if (p == null) return false;
        if (!p.latitude.isFinite || !p.longitude.isFinite) return false;
        // Reject placeholder coordinates sometimes emitted by devices (0.0, 0.0)
        if (p.latitude == 0.0 && p.longitude == 0.0) return false;
        return true;
      }

      if (!_validLatLng(origin) || !_validLatLng(destination) || (waypoints != null && waypoints.any((w) => !_validLatLng(w)))) {
        // Log and return a straight-line fallback without calling backend
        if (kDebugMode) debugPrint('RoutingService.getRoute: invalid coordinates detected, using fallback straight line');
        return _fallbackStraightLine(origin, destination);
      }
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
        options: dio_pkg.Options(headers: {'Content-Type': 'application/json'}),
      );

      return RouteResult.fromJson(response.data);
    } catch (e) {
      // If backend failed, try public OSRM as a best-effort before falling back
      try {
        final osrm = await _callOsrmRoute(origin, destination, waypoints: waypoints);
        if (osrm != null) return osrm;
      } catch (_) {}

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
      // Validate coordinates before sending to backend
      bool _validLatLng(LatLng? p) {
        if (p == null) return false;
        if (!p.latitude.isFinite || !p.longitude.isFinite) return false;
        if (p.latitude == 0.0 && p.longitude == 0.0) return false;
        return true;
      }

      if (!_validLatLng(pickup) || !_validLatLng(delivery) || (driverPosition != null && (!_validLatLng(driverPosition)))) {
        if (kDebugMode) debugPrint('RoutingService.getDeliveryRoute: invalid coordinates detected, using fallback delivery route');
        return _fallbackDeliveryRoute(pickup, delivery, driverPosition);
      }
      final Map<String, dynamic> data = {
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
        options: dio_pkg.Options(headers: {'Content-Type': 'application/json'}),
      );

      final result = DeliveryRouteResult.fromJson(response.data);
      // If backend returned no legs / no polyline (approx), try public OSRM
      if ((result.legs.isEmpty || result.allPolylinePoints.isEmpty)) {
        try {
          final osrm = await _callOsrmDeliveryRoute(pickup, delivery, driverPosition);
          if (osrm != null) return osrm;
        } catch (_) {}
      }

      return result;
    } catch (e) {
      // If backend failed, try public OSRM as a best-effort before falling back
      try {
        final osrm = await _callOsrmDeliveryRoute(pickup, delivery, driverPosition);
        if (osrm != null) return osrm;
      } catch (_) {}

      // Fallback: retourne une ligne droite
      return _fallbackDeliveryRoute(pickup, delivery, driverPosition);
    }
  }

  /// Try public OSRM demo server to build a route (returns null on failure)
  Future<RouteResult?> _callOsrmRoute(LatLng origin, LatLng destination, {List<LatLng>? waypoints}) async {
    final coords = <String>[];
    coords.add('${origin.longitude},${origin.latitude}');
    if (waypoints != null && waypoints.isNotEmpty) {
      for (final w in waypoints) {
        coords.add('${w.longitude},${w.latitude}');
      }
    }
    coords.add('${destination.longitude},${destination.latitude}');

    final url = 'https://router.project-osrm.org/route/v1/driving/${coords.join(';')}?overview=full&geometries=geojson&steps=true&annotations=true';

    final d = dio_pkg.Dio();
    final resp = await d.get(url);
    if (resp.statusCode == 200 && resp.data != null && resp.data['routes'] != null && (resp.data['routes'] as List).isNotEmpty) {
      final rt = resp.data['routes'][0];
        final geometry = rt['geometry'];
        final coordsList = (geometry['coordinates'] as List)
          .map((c) => RoutePoint(lat: safeDouble(c[1]), lng: safeDouble(c[0])))
          .toList();
        final distanceKm = safeDouble(rt['distance']);
        final durationMin = (safeDouble(rt['duration']) ) / 60.0;

      return RouteResult(
        success: true,
        source: 'osrm',
        distanceKm: distanceKm / 1000.0,
        durationMin: durationMin,
        polylinePoints: coordsList,
        encodedPolyline: null,
      );
    }
    return null;
  }

  /// Try public OSRM for a delivery route (driver -> pickup -> delivery)
  Future<DeliveryRouteResult?> _callOsrmDeliveryRoute(LatLng pickup, LatLng delivery, LatLng? driverPosition) async {
    final coords = <String>[];
    if (driverPosition != null) coords.add('${driverPosition.longitude},${driverPosition.latitude}');
    coords.add('${pickup.longitude},${pickup.latitude}');
    coords.add('${delivery.longitude},${delivery.latitude}');

    final url = 'https://router.project-osrm.org/route/v1/driving/${coords.join(';')}?overview=full&geometries=geojson&steps=true&annotations=true';
    final d = dio_pkg.Dio();
    final resp = await d.get(url);
    if (resp.statusCode == 200 && resp.data != null && resp.data['routes'] != null && (resp.data['routes'] as List).isNotEmpty) {
      final rt = resp.data['routes'][0];
        final geometry = rt['geometry'];
        final coordsList = (geometry['coordinates'] as List)
          .map((c) => RoutePoint(lat: safeDouble(c[1]), lng: safeDouble(c[0])))
          .toList();

        final distanceKm = safeDouble(rt['distance']);
        final durationMin = (safeDouble(rt['duration'])) / 60.0;

      return DeliveryRouteResult(
        success: true,
        totalDistanceKm: distanceKm / 1000.0,
        totalDurationMin: durationMin,
        legs: [],
        allPolylinePoints: coordsList,
      );
    }
    return null;
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
