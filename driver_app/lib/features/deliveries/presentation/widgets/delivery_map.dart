import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_radius.dart';
import '../../../../shared/widgets/osm_map_widget.dart';

class DeliveryMap extends StatefulWidget {
  final LatLng pickupLocation;
  final LatLng deliveryLocation;
  final LatLng? currentLocation;
  final List<LatLng>? routePoints;
  final VoidCallback? onMapCreated;
  final double height;

  const DeliveryMap({
    super.key,
    required this.pickupLocation,
    required this.deliveryLocation,
    this.currentLocation,
    this.routePoints,
    this.onMapCreated,
    this.height = 300,
  });

  @override
  State<DeliveryMap> createState() => _DeliveryMapState();
}

class _DeliveryMapState extends State<DeliveryMap> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitBounds();
      widget.onMapCreated?.call();
    });
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
    if (widget.routePoints == null || widget.routePoints!.isEmpty) {
      return [];
    }

    return [
      OsmMarkerHelper.route(
        points: widget.routePoints!,
        color: AppColors.primary,
        width: 4,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: OsmMapWidget(
          center: widget.pickupLocation,
          zoom: 14,
          markers: _buildMarkers(),
          polylines: _buildPolylines(),
          mapController: _mapController,
        ),
      ),
    );
  }
}

/// Simple static map preview (when Google Maps not needed)
class StaticMapPreview extends StatelessWidget {
  final String pickupAddress;
  final String deliveryAddress;
  final double height;

  const StaticMapPreview({
    super.key,
    required this.pickupAddress,
    required this.deliveryAddress,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Stack(
        children: [
          // Background pattern
          Center(
            child: Icon(
              Icons.map_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
          ),
          
          // Address overlays
          Positioned(
            top: AppSpacing.md,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: _AddressChip(
              icon: Icons.circle_outlined,
              iconColor: AppColors.success,
              label: pickupAddress,
            ),
          ),
          
          Positioned(
            bottom: AppSpacing.md,
            left: AppSpacing.md,
            right: AppSpacing.md,
            child: _AddressChip(
              icon: Icons.location_on,
              iconColor: AppColors.error,
              label: deliveryAddress,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _AddressChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20.0),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
