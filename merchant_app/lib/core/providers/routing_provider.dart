// lib/core/providers/routing_provider.dart
// Provider Riverpod pour le service de routing

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../data/providers/pricing_provider.dart'; // Pour dioClientProvider
import '../services/routing_service.dart';

/// Provider pour le service de routing
final routingServiceProvider = Provider<RoutingService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return RoutingService(dioClient: dioClient);
});

/// Provider pour calculer une route simple entre 2 points
final routeProvider = FutureProvider.family<RouteResult, RouteRequest>(
  (ref, request) async {
    final routingService = ref.watch(routingServiceProvider);
    return routingService.getRoute(
      origin: request.origin,
      destination: request.destination,
      waypoints: request.waypoints,
    );
  },
);

/// Provider pour calculer l'itinéraire d'une livraison
final deliveryRouteProvider = FutureProvider.family<DeliveryRouteResult, DeliveryRouteRequest>(
  (ref, request) async {
    final routingService = ref.watch(routingServiceProvider);
    return routingService.getDeliveryRoute(
      pickup: request.pickup,
      delivery: request.delivery,
      driverPosition: request.driverPosition,
    );
  },
);

/// Classe de requête pour une route simple
class RouteRequest {
  final LatLng origin;
  final LatLng destination;
  final List<LatLng>? waypoints;

  const RouteRequest({
    required this.origin,
    required this.destination,
    this.waypoints,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteRequest &&
          runtimeType == other.runtimeType &&
          origin == other.origin &&
          destination == other.destination;

  @override
  int get hashCode => origin.hashCode ^ destination.hashCode;
}

/// Classe de requête pour une route de livraison
class DeliveryRouteRequest {
  final LatLng pickup;
  final LatLng delivery;
  final LatLng? driverPosition;

  const DeliveryRouteRequest({
    required this.pickup,
    required this.delivery,
    this.driverPosition,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryRouteRequest &&
          runtimeType == other.runtimeType &&
          pickup == other.pickup &&
          delivery == other.delivery &&
          driverPosition == other.driverPosition;

  @override
  int get hashCode =>
      pickup.hashCode ^ delivery.hashCode ^ (driverPosition?.hashCode ?? 0);
}
