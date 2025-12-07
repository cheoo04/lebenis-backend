import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:lebeni_driver/features/deliveries/presentation/screens/delivery_navigation_screen.dart';
import 'package:lebeni_driver/data/models/delivery_model.dart';
import 'package:lebeni_driver/core/providers/routing_provider.dart';
import 'package:lebeni_driver/core/services/routing_service.dart';

class _FakeRoutingService implements RoutingService {
  final DeliveryRouteResult _res;
  _FakeRoutingService(this._res);

  @override
  Future<RouteResult> getRoute({required LatLng origin, required LatLng destination, List<LatLng>? waypoints}) async {
    return RouteResult.empty();
  }

  @override
  Future<DeliveryRouteResult> getDeliveryRoute({required LatLng pickup, required LatLng delivery, LatLng? driverPosition}) async {
    return _res;
  }
}

void main() {
  group('DeliveryNavigationScreen', () {
    testWidgets('affiche un seul bouton Ouvrir la navigation et les infos ville/quartier/précision', (tester) async {
      final delivery = DeliveryModel(
        id: '1',
        trackingNumber: 'T123',
        status: 'pending',
        pickupAddress: 'Marché Central, Quartier: Yopougon, Abidjan',
        pickupLatitude: 5.316667,
        pickupLongitude: -4.033333,
        deliveryAddress: 'Rue Principale, Commune: Treichville, Abidjan',
        deliveryLatitude: 5.333333,
        deliveryLongitude: -4.016667,
        recipientName: 'Client',
        recipientPhone: '0000000000',
        packageDescription: 'Colis',
        weight: 1.0,
        price: 1000.0,
        distanceKm: 2.0,
        notes: 'Sonner deux fois',
        merchant: null,
        driver: null,
        createdAt: DateTime.now(),
      );

      // Create a simple DeliveryRouteResult with some points so the widget can render
      final routeResult = DeliveryRouteResult(
        success: true,
        totalDistanceKm: 2.0,
        totalDurationMin: 5.0,
        legs: [],
        allPolylinePoints: [
          RoutePoint(lat: delivery.pickupLatitude, lng: delivery.pickupLongitude),
          RoutePoint(lat: delivery.deliveryLatitude, lng: delivery.deliveryLongitude),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routingServiceProvider.overrideWithValue(_FakeRoutingService(routeResult)),
          ],
          child: MaterialApp(
            home: DeliveryNavigationScreen(delivery: delivery, mapOverride: const SizedBox.shrink()),
          ),
        ),
      );

      // Allow futures to resolve
      await tester.pumpAndSettle();

      // Vérifie qu'il y a un seul bouton avec l'étiquette
      expect(find.widgetWithText(ElevatedButton, 'Ouvrir la navigation'), findsOneWidget);

      // Vérifie présence des parties d'adresse extraites
      expect(find.text('Abidjan'), findsNWidgets(2)); // both pickup and delivery city
      expect(find.textContaining('Yopougon'), findsOneWidget);
      expect(find.textContaining('Treichville'), findsOneWidget);

      // Vérifie la précision (notes)
      expect(find.textContaining('Sonner deux fois'), findsOneWidget);
    });

    testWidgets('n affiche pas la précision si notes vide', (tester) async {
      final delivery = DeliveryModel(
        id: '2',
        trackingNumber: 'T124',
        status: 'pending',
        pickupAddress: 'Zone A, Quartier: Cocody, Abidjan',
        pickupLatitude: 5.35,
        pickupLongitude: -4.0,
        deliveryAddress: 'Zone B, Commune: Koumassi, Abidjan',
        deliveryLatitude: 5.33,
        deliveryLongitude: -4.03,
        recipientName: 'Client2',
        recipientPhone: '1111111111',
        packageDescription: 'Colis2',
        weight: 2.0,
        price: 2000.0,
        distanceKm: 3.0,
        notes: null,
        merchant: null,
        driver: null,
        createdAt: DateTime.now(),
      );

      final routeResult = DeliveryRouteResult(
        success: true,
        totalDistanceKm: 3.0,
        totalDurationMin: 7.0,
        legs: [],
        allPolylinePoints: [
          RoutePoint(lat: delivery.pickupLatitude, lng: delivery.pickupLongitude),
          RoutePoint(lat: delivery.deliveryLatitude, lng: delivery.deliveryLongitude),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routingServiceProvider.overrideWithValue(_FakeRoutingService(routeResult)),
          ],
          child: MaterialApp(
            home: DeliveryNavigationScreen(delivery: delivery, mapOverride: const SizedBox.shrink()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifie qu'il y a un seul bouton
      expect(find.widgetWithText(ElevatedButton, 'Ouvrir la navigation'), findsOneWidget);

      // Il ne doit pas y avoir de texte correspondant à une précision
      expect(find.textContaining('Sonner'), findsNothing);
    });
  });
}
