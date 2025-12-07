// lib/features/deliveries/presentation/widgets/delivery_route_map.dart
// Widget de carte avec chargement automatique des routes réelles

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_radius.dart';
import '../../../../shared/widgets/osm_map_widget.dart';
import '../../../../core/providers/routing_provider.dart';
import '../../../../core/services/routing_service.dart';

/// Widget de carte qui charge automatiquement la route réelle depuis l'API
class DeliveryRouteMap extends ConsumerStatefulWidget {
  final LatLng pickupLocation;
  final LatLng deliveryLocation;
  final LatLng? currentLocation;
  final VoidCallback? onMapCreated;
  final double height;
  final bool showRouteInfo;

  const DeliveryRouteMap({
    super.key,
    required this.pickupLocation,
    required this.deliveryLocation,
    this.currentLocation,
    this.onMapCreated,
    this.height = 300,
    this.showRouteInfo = true,
  });

  @override
  ConsumerState<DeliveryRouteMap> createState() => _DeliveryRouteMapState();
}

class _DeliveryRouteMapState extends ConsumerState<DeliveryRouteMap> {
  final MapController _mapController = MapController();
  List<LatLng>? _routePoints;
  bool _routeLoaded = false;
  DeliveryRouteResult? _routeResult;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitBounds();
      _loadRealRoute();
      widget.onMapCreated?.call();
    });
  }

  @override
  void didUpdateWidget(DeliveryRouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recharger la route si la position du driver a changé
    if (oldWidget.currentLocation != widget.currentLocation) {
      _routeLoaded = false;
      _loadRealRoute();
    }
  }

  Future<void> _loadRealRoute() async {
    if (_routeLoaded || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final routingService = ref.read(routingServiceProvider);
      final route = await routingService.getDeliveryRoute(
        pickup: widget.pickupLocation,
        delivery: widget.deliveryLocation,
        driverPosition: widget.currentLocation,
      );

      if (route.success && route.allPoints.isNotEmpty) {
        setState(() {
          _routePoints = route.allPoints;
          _routeResult = route;
          _routeLoaded = true;
        });
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _fitBounds() {
    final points = [
      widget.pickupLocation,
      widget.deliveryLocation,
      if (widget.currentLocation != null) widget.currentLocation!,
    ];

    if (points.length == 1) {
      _mapController.move(points[0], 15);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(CameraFit.bounds(
      bounds: bounds,
      padding: const EdgeInsets.all(50),
    ));
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Pickup marker
    markers.add(OsmMarkerHelper.pickup(
      position: widget.pickupLocation,
      label: 'Récup',
    ));

    // Delivery marker
    markers.add(OsmMarkerHelper.delivery(
      position: widget.deliveryLocation,
      label: 'Livr',
    ));

    // Current location marker
    if (widget.currentLocation != null) {
      markers.add(OsmMarkerHelper.driver(
        position: widget.currentLocation!,
        label: 'Moi',
      ));
    }

    return markers;
  }

  List<Polyline> _buildPolylines() {
    // Utiliser la route réelle si disponible
    if (_routePoints != null && _routePoints!.length >= 2) {
      return [
        OsmMarkerHelper.route(
          points: _routePoints!,
          color: AppColors.primary,
          width: 4,
        ),
      ];
    }

    // Fallback: ligne droite
    final fallbackPoints = <LatLng>[];
    if (widget.currentLocation != null) {
      fallbackPoints.add(widget.currentLocation!);
    }
    fallbackPoints.add(widget.pickupLocation);
    fallbackPoints.add(widget.deliveryLocation);

    return [
      OsmMarkerHelper.route(
        points: fallbackPoints,
        color: AppColors.primary.withOpacity(0.5),
        width: 2,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carte
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Stack(
              children: [
                OsmMapWidget(
                  center: widget.pickupLocation,
                  zoom: 14,
                  markers: _buildMarkers(),
                  polylines: _buildPolylines(),
                  mapController: _mapController,
                ),
                
                // Indicateur de chargement
                if (_isLoading)
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Calcul...',
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                // Badge source de la route
                if (_routeLoaded && _routeResult != null)
                  Positioned(
                    bottom: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Route réelle',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Infos de route
        if (widget.showRouteInfo && _routeResult != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: RouteInfoCard(route: _routeResult!),
          ),
      ],
    );
  }
}

/// Carte d'informations sur la route
class RouteInfoCard extends StatelessWidget {
  final DeliveryRouteResult route;

  const RouteInfoCard({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _InfoItem(
            icon: Icons.route,
            label: 'Distance',
            value: '${route.totalDistanceKm.toStringAsFixed(1)} km',
            color: AppColors.primary,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          _InfoItem(
            icon: Icons.timer,
            label: 'Durée estimée',
            value: '~${route.totalDurationMin.toStringAsFixed(0)} min',
            color: AppColors.warning,
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
