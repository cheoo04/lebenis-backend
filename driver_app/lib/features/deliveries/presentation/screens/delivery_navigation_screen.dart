import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../data/models/delivery_model.dart';
import '../../../../core/providers/routing_provider.dart';
import '../../../../data/providers/location_provider.dart';
import '../widgets/delivery_map.dart';
import '../../../../core/utils/navigation_utils.dart';

class DeliveryNavigationScreen extends ConsumerStatefulWidget {
  /// Either provide a full DeliveryModel or provide coordinates directly
  final DeliveryModel? delivery;
  final double? pickupLat;
  final double? pickupLng;
  final double? destLat;
  final double? destLng;
  final String? destLabel;
  // Optional test override to replace the map widget (prevents network calls in tests)
  final Widget? mapOverride;
  // Optional test override to inject a precomputed route result (avoids provider logic in tests)
  final dynamic routeOverride;

  const DeliveryNavigationScreen({
    super.key,
    this.delivery,
    this.pickupLat,
    this.pickupLng,
    this.destLat,
    this.destLng,
    this.destLabel,
    this.mapOverride,
    this.routeOverride,
  });

  @override
  ConsumerState<DeliveryNavigationScreen> createState() => _DeliveryNavigationScreenState();
}
class _DeliveryNavigationScreenState extends ConsumerState<DeliveryNavigationScreen> {

  @override
  void initState() {
    super.initState();
    // Start GPS tracking when opening the navigation screen so we can provide
    // a driver position to the routing service. Use a post-frame callback to
    // ensure `ref` is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        ref.read(locationProvider.notifier).startTracking();
      } catch (_) {
        // Not fatal; tracking is best-effort.
      }
    });
  }

  @override
  void dispose() {
    try {
      ref.read(locationProvider.notifier).stopTracking();
    } catch (_) {}
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final delivery = widget.delivery;

    // Determine coordinates: prefer provided delivery model, otherwise use raw coords
    final pickup = (delivery != null)
      ? LatLng(delivery.pickupLatitude, delivery.pickupLongitude)
      : LatLng(widget.pickupLat ?? 0.0, widget.pickupLng ?? 0.0);

    final dest = (delivery != null)
      ? LatLng(delivery.deliveryLatitude, delivery.deliveryLongitude)
      : LatLng(widget.destLat ?? 0.0, widget.destLng ?? 0.0);

    // Include current driver position when available so backend can compute
    // a realistic route starting from the driver's location.
    final currentPos = ref.watch(currentPositionProvider);
    final driverPosition = (currentPos != null) ? LatLng(currentPos.latitude, currentPos.longitude) : null;

    final routeAsync = ref.watch(deliveryRouteProvider(DeliveryRouteRequest(pickup: pickup, delivery: dest, driverPosition: driverPosition)));

    final pickupCity = delivery != null ? _cityFromAddress(delivery.pickupAddress) : '';
    final pickupNeighborhood = delivery != null ? _neighborhoodFromAddress(delivery.pickupAddress) : '';
    final deliveryCity = delivery != null ? _cityFromAddress(delivery.deliveryAddress) : '';
    final deliveryNeighborhood = delivery != null ? _neighborhoodFromAddress(delivery.deliveryAddress) : '';
    final precision = delivery?.notes ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
      ),
      body: (widget.routeOverride != null)
          ? _buildBody(context, pickup, dest, widget.routeOverride, precision)
          : routeAsync.when(
              data: (routeResult) => _buildBody(context, pickup, dest, routeResult, precision),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Impossible de calculer l\'itinéraire, affichage approximatif.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          // Réessayer (rebuild)
                          setState(() {});
                        },
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBody(BuildContext context, LatLng pickup, LatLng dest, dynamic routeResult, String precision) {
    // routeResult is expected to provide: allPoints (List<LatLng>), totalDistanceKm (double), totalDurationMin (double), legs (List)
    final points = (routeResult as dynamic).allPoints as List<LatLng>? ?? <LatLng>[];
    final totalDistance = (routeResult as dynamic).totalDistanceKm as double? ?? 0.0;
    final totalDuration = (routeResult as dynamic).totalDurationMin as double? ?? 0.0;

    final pickupCity = widget.delivery != null ? _cityFromAddress(widget.delivery!.pickupAddress) : '';
    final pickupNeighborhood = widget.delivery != null ? _neighborhoodFromAddress(widget.delivery!.pickupAddress) : '';
    final deliveryCity = widget.delivery != null ? _cityFromAddress(widget.delivery!.deliveryAddress) : '';
    final deliveryNeighborhood = widget.delivery != null ? _neighborhoodFromAddress(widget.delivery!.deliveryAddress) : '';

    return Column(
      children: [
        // Summary bar with distance & duration
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.alt_route, size: 20),
                  const SizedBox(width: 8),
                  Text('${totalDistance.toStringAsFixed(1)} km'),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20),
                  const SizedBox(width: 8),
                  Text('${totalDuration.toStringAsFixed(0)} min'),
                ],
              ),
            ],
          ),
        ),

        // Pickup & Delivery simplified cards (only city, neighborhood, precision if any)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Column(
            children: [
              // Pickup
              Card(
                child: ListTile(
                  leading: const Icon(Icons.place, color: Colors.green),
                  title: const Text('Point de récupération'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (pickupCity.isNotEmpty) Text(pickupCity),
                      if (pickupNeighborhood.isNotEmpty) Text(pickupNeighborhood),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Delivery
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  title: const Text('Point de livraison'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (deliveryCity.isNotEmpty) Text(deliveryCity),
                      if (deliveryNeighborhood.isNotEmpty) Text(deliveryNeighborhood),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Fallback indicator: if backend didn't supply legs, we assume the route is approximate
        if ((routeResult as dynamic).legs == null || (routeResult as dynamic).legs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: const [
                Chip(
                  avatar: Icon(Icons.error_outline, size: 18),
                  label: Text('Itinéraire approximatif'),
                  backgroundColor: Color(0xFFFFF4E5),
                ),
              ],
            ),
          ),

        // Map
        Expanded(
          child: widget.mapOverride ?? DeliveryMap(
            pickupLocation: pickup,
            deliveryLocation: dest,
            routePoints: points,
            height: double.infinity,
          ),
        ),

        // Legs / Steps list
        if ((routeResult as dynamic).legs != null && (routeResult as dynamic).legs.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: (routeResult as dynamic).legs.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, idx) {
                final leg = (routeResult as dynamic).legs[idx];
                return ListTile(
                  dense: true,
                  title: Text((leg.label ?? '').isNotEmpty ? leg.label : (leg.name ?? '')),
                  subtitle: Text('${(leg.distanceKm ?? 0).toStringAsFixed(1)} km • ${(leg.durationMin ?? 0).toStringAsFixed(0)} min'),
                  trailing: Text(leg.source ?? ''),
                );
              },
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Text('Pas d\'étapes détaillées disponibles. Distance ~ ${totalDistance.toStringAsFixed(1)} km'),
          ),

        // Single navigation button (opens external navigation app)
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.navigation),
                    label: const Text('Ouvrir la navigation'),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await openNavigationApp(latitude: dest.latitude, longitude: dest.longitude, label: widget.destLabel);
                      } catch (e) {
                        if (!mounted) return;
                        messenger.showSnackBar(const SnackBar(content: Text("Impossible d'ouvrir l'application de navigation")));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helpers
  String _cityFromAddress(String addr) {
    if (addr.isEmpty) return '';
    final parts = addr.split(RegExp(r'[,-–|/]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    return parts.last;
  }

  String _neighborhoodFromAddress(String addr) {
    if (addr.isEmpty) return '';
    final labelMatch = RegExp(r'(?:quartier|quartier:|commune|commune:|qtr|qt\.)\s*([^,\-–|/]+)', caseSensitive: false).firstMatch(addr);
    if (labelMatch != null && labelMatch.groupCount >= 1) {
      return labelMatch.group(1)!.trim();
    }
    final parts = addr.split(RegExp(r'[,-–|/]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (parts.length < 2) return '';
    return parts[parts.length - 2];
  }
}
