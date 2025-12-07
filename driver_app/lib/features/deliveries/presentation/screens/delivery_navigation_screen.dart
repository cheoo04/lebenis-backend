import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../../data/models/delivery_model.dart';
import '../../../../core/providers/routing_provider.dart';
import '../../widgets/delivery_map.dart';
import '../../../../shared/utils/helpers.dart';
import '../../../../core/utils/navigation_utils.dart';

class DeliveryNavigationScreen extends ConsumerStatefulWidget {
  final DeliveryModel delivery;

  const DeliveryNavigationScreen({super.key, required this.delivery});

  @override
  ConsumerState<DeliveryNavigationScreen> createState() => _DeliveryNavigationScreenState();
}

class _DeliveryNavigationScreenState extends ConsumerState<DeliveryNavigationScreen> {
  @override
  Widget build(BuildContext context) {
    final delivery = widget.delivery;

    // Convert delivery model coords to LatLng
    final pickup = LatLng(delivery.pickupLatitude ?? 0.0, delivery.pickupLongitude ?? 0.0);
    final dest = LatLng(delivery.deliveryLatitude ?? 0.0, delivery.deliveryLongitude ?? 0.0);

    final routeAsync = ref.watch(deliveryRouteProvider(DeliveryRouteRequest(pickup: pickup, delivery: dest, driverPosition: null)));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
      ),
      body: routeAsync.when(
        data: (routeResult) {
          final points = routeResult.allPoints;
          return Column(
            children: [
              Expanded(
                child: DeliveryMap(
                  pickupLocation: pickup,
                  deliveryLocation: dest,
                  routePoints: points,
                  height: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.navigation),
                        label: const Text('Ouvrir dans une application'),
                        onPressed: () async {
                          try {
                            await openNavigationApp(latitude: dest.latitude, longitude: dest.longitude, label: delivery.deliveryAddress);
                          } catch (e) {
                            Helpers.showErrorSnackBar(context, 'Aucune application externe disponible');
                          }
                        },
                      ),
                    ),
                  ],
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
