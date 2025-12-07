import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../data/models/delivery_model.dart';
import '../../../../core/providers/routing_provider.dart';
import '../../../../data/providers/location_provider.dart';
import '../widgets/delivery_map.dart';
import '../../../../shared/utils/helpers.dart';
import '../../../../core/utils/navigation_utils.dart';

class DeliveryNavigationScreen extends ConsumerStatefulWidget {
  /// Either provide a full DeliveryModel or provide coordinates directly
  final DeliveryModel? delivery;
  final double? pickupLat;
  final double? pickupLng;
  final double? destLat;
  final double? destLng;
  final String? destLabel;

  const DeliveryNavigationScreen({
    super.key,
    this.delivery,
    this.pickupLat,
    this.pickupLng,
    this.destLat,
    this.destLng,
    this.destLabel,
  });

  @override
  ConsumerState<DeliveryNavigationScreen> createState() => _DeliveryNavigationScreenState();
}
class _DeliveryNavigationScreenState extends ConsumerState<DeliveryNavigationScreen> {
  bool _guidanceActive = false;

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
      ? LatLng(delivery.pickupLatitude ?? 0.0, delivery.pickupLongitude ?? 0.0)
      : LatLng(widget.pickupLat ?? 0.0, widget.pickupLng ?? 0.0);

    final dest = (delivery != null)
      ? LatLng(delivery.deliveryLatitude ?? 0.0, delivery.deliveryLongitude ?? 0.0)
      : LatLng(widget.destLat ?? 0.0, widget.destLng ?? 0.0);

    // Include current driver position when available so backend can compute
    // a realistic route starting from the driver's location.
    final currentPos = ref.watch(currentPositionProvider);
    final driverPosition = (currentPos != null) ? LatLng(currentPos.latitude, currentPos.longitude) : null;

    final routeAsync = ref.watch(deliveryRouteProvider(DeliveryRouteRequest(pickup: pickup, delivery: dest, driverPosition: driverPosition)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
      ),
      body: routeAsync.when(
        data: (routeResult) {
          final points = routeResult.allPoints;
          final totalDistance = routeResult.totalDistanceKm;
          final totalDuration = routeResult.totalDurationMin;

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

              // Fallback indicator: if backend didn't supply legs, we assume
              // the route is approximate (straight-line fallback).
              if (routeResult.legs.isEmpty)
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
                child: DeliveryMap(
                  pickupLocation: pickup,
                  deliveryLocation: dest,
                  routePoints: points,
                  height: double.infinity,
                ),
              ),

              // Legs / Steps list
              if (routeResult.legs.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: routeResult.legs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final leg = routeResult.legs[idx];
                      return ListTile(
                        dense: true,
                        title: Text(leg.label.isNotEmpty ? leg.label : leg.name),
                        subtitle: Text('${leg.distanceKm.toStringAsFixed(1)} km • ${leg.durationMin.toStringAsFixed(0)} min'),
                        trailing: Text(leg.source),
                      );
                    },
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Text('Pas d\'étapes détaillées disponibles. Distance ~ ${totalDistance.toStringAsFixed(1)} km'),
                ),

              // Buttons (ensure SafeArea at bottom to avoid overflow on devices
              // with gesture/navigation bars)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.navigation),
                          label: Text(
                            // Change label depending on state
                            _guidanceActive
                                ? 'Guidage actif'
                                : (routeResult.legs.isEmpty ? 'Itinéraire approximatif' : 'Démarrer guidage'),
                          ),
                          onPressed: (routeResult.legs.isEmpty || _guidanceActive)
                              ? null
                              : () {
                                  // Start a simple guidance mode (placeholder): toggle state
                                  setState(() {
                                    _guidanceActive = true;
                                  });

                                  Helpers.showSuccessSnackBar(context, 'Guidage démarré');
                                },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
}
