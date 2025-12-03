import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/app_colors.dart';
import '../../../../data/providers/delivery_provider.dart';
import '../../../../shared/widgets/osm_map_widget.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final int deliveryId;

  const TrackingScreen({super.key, required this.deliveryId});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  late MapController _mapController;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _startLocationPolling();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _startLocationPolling() {
    // Poll driver location every 10 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      ref.invalidate(deliveryDetailProvider(widget.deliveryId));
    });
  }

  List<Marker> _buildMarkers(delivery) {
    final markers = <Marker>[];

    // Pickup marker
    if (delivery.pickupLatitude != null && delivery.pickupLongitude != null) {
      markers.add(OsmMarkerHelper.pickup(
        LatLng(delivery.pickupLatitude!, delivery.pickupLongitude!),
        label: delivery.pickupCommune,
      ));
    }

    // Driver current position marker
    if (delivery.driver?.currentLatitude != null && 
        delivery.driver?.currentLongitude != null) {
      markers.add(OsmMarkerHelper.driver(
        LatLng(delivery.driver!.currentLatitude!, delivery.driver!.currentLongitude!),
        label: delivery.driver!.name,
      ));
    }

    // Delivery marker
    if (delivery.deliveryLatitude != null && delivery.deliveryLongitude != null) {
      markers.add(OsmMarkerHelper.delivery(
        LatLng(delivery.deliveryLatitude!, delivery.deliveryLongitude!),
        label: delivery.deliveryCommune,
      ));
    }

    return markers;
  }

  List<Polyline> _buildPolylines(delivery) {
    final routePoints = <LatLng>[];

    if (delivery.pickupLatitude != null && delivery.pickupLongitude != null) {
      routePoints.add(LatLng(delivery.pickupLatitude!, delivery.pickupLongitude!));
    }

    if (delivery.driver?.currentLatitude != null && 
        delivery.driver?.currentLongitude != null) {
      routePoints.add(LatLng(delivery.driver!.currentLatitude!, delivery.driver!.currentLongitude!));
    }

    if (delivery.deliveryLatitude != null && delivery.deliveryLongitude != null) {
      routePoints.add(LatLng(delivery.deliveryLatitude!, delivery.deliveryLongitude!));
    }

    if (routePoints.length >= 2) {
      return [OsmMarkerHelper.route(routePoints, color: AppTheme.primaryColor)];
    }

    return [];
  }

  void _fitBounds(List<LatLng> points) {
    if (points.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(points),
          padding: const EdgeInsets.all(50),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final deliveryState = ref.watch(deliveryDetailProvider(widget.deliveryId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi en temps réel'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          deliveryState.when(
            data: (delivery) {
              if (delivery == null) {
                return const Center(child: Text('Livraison introuvable'));
              }

              // Default center (Abidjan)
              LatLng center = const LatLng(5.3364, -4.0267);
              
              // Use pickup location if available
              if (delivery.pickupLatitude != null && delivery.pickupLongitude != null) {
                center = LatLng(delivery.pickupLatitude!, delivery.pickupLongitude!);
              }

              final markers = _buildMarkers(delivery);
              final polylines = _buildPolylines(delivery);

              // Fit bounds to show all markers
              if (markers.isNotEmpty) {
                final points = markers.map((m) => m.point).toList();
                _fitBounds(points);
              }

              return OsmMapWidget(
                controller: _mapController,
                center: center,
                zoom: 13,
                markers: markers,
                polylines: polylines,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Erreur: $error'),
                ],
              ),
            ),
          ),

          // Info panel at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: deliveryState.whenOrNull(
              data: (delivery) {
                if (delivery == null) return const SizedBox.shrink();

                final status = delivery.status ?? 'unknown';
                final statusInfo = _getStatusInfo(status);

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: statusInfo['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              statusInfo['icon'],
                              color: statusInfo['color'],
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  statusInfo['label'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${delivery.pickupCommune ?? "N/A"} → ${delivery.deliveryCommune ?? "N/A"}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (delivery.driver != null) ...[
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                              child: const Icon(Icons.person, color: AppTheme.primaryColor),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    delivery.driver!.firstName ?? 'Livreur',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    delivery.driver!.phoneNumber ?? '',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // Refresh location
                                ref.invalidate(deliveryDetailProvider(widget.deliveryId));
                              },
                              icon: const Icon(Icons.refresh),
                              color: AppTheme.primaryColor,
                              tooltip: 'Actualiser',
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              },
            ) ?? const SizedBox.shrink(),
          ),

          // Auto-refresh indicator
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Mise à jour auto',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pending_assignment':
        return {
          'label': 'En attente d\'assignation',
          'color': Colors.orange,
          'icon': Icons.schedule,
        };
      case 'assigned':
        return {
          'label': 'Livreur en route vers pickup',
          'color': Colors.blue,
          'icon': Icons.directions_car,
        };
      case 'pickup_confirmed':
        return {
          'label': 'Colis récupéré',
          'color': Colors.indigo,
          'icon': Icons.check_box,
        };
      case 'in_transit':
        return {
          'label': 'En cours de livraison',
          'color': Colors.purple,
          'icon': Icons.local_shipping,
        };
      case 'delivered':
        return {
          'label': 'Livré avec succès',
          'color': Colors.green,
          'icon': Icons.check_circle,
        };
      default:
        return {
          'label': status,
          'color': Colors.grey,
          'icon': Icons.help_outline,
        };
    }
  }
}
