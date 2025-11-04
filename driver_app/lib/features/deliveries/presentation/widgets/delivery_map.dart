import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';

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
  GoogleMapController? _mapController;
  final Completer<GoogleMapController> _controllerCompleter = Completer();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _animateToShowAllMarkers());
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!_controllerCompleter.isCompleted) {
      _controllerCompleter.complete(controller);
    }
    _mapController = controller;
    widget.onMapCreated?.call();
    _animateToShowAllMarkers();
  }

  Future<void> _animateToShowAllMarkers() async {
    if (_mapController == null) {
      final controller = await _controllerCompleter.future;
      _mapController = controller;
    }

    final bounds = _calculateBounds();
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 50),
    );
  }

  LatLngBounds _calculateBounds() {
    final points = [
      widget.pickupLocation,
      widget.deliveryLocation,
      if (widget.currentLocation != null) widget.currentLocation!,
    ];

    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    // Pickup marker
    markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: widget.pickupLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(
          title: 'Point de récupération',
        ),
      ),
    );

    // Delivery marker
    markers.add(
      Marker(
        markerId: const MarkerId('delivery'),
        position: widget.deliveryLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(
          title: 'Point de livraison',
        ),
      ),
    );

    // Current location marker
    if (widget.currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: widget.currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Ma position',
          ),
        ),
      );
    }

    return markers;
  }

  Set<Polyline> _buildPolylines() {
    if (widget.routePoints == null || widget.routePoints!.isEmpty) {
      return {};
    }

    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: widget.routePoints!,
        color: AppColors.primary,
        width: 4,
        patterns: [
          PatternItem.dash(20),
          PatternItem.gap(10),
        ],
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radiusM),
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: widget.pickupLocation,
            zoom: 14,
          ),
          markers: _buildMarkers(),
          polylines: _buildPolylines(),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,
          mapType: MapType.normal,
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
        borderRadius: BorderRadius.circular(Dimensions.radiusM),
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
            top: Dimensions.spacingM,
            left: Dimensions.spacingM,
            right: Dimensions.spacingM,
            child: _AddressChip(
              icon: Icons.circle_outlined,
              iconColor: AppColors.success,
              label: pickupAddress,
            ),
          ),
          
          Positioned(
            bottom: Dimensions.spacingM,
            left: Dimensions.spacingM,
            right: Dimensions.spacingM,
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
        horizontal: Dimensions.spacingM,
        vertical: Dimensions.spacingS,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusS),
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
          Icon(icon, color: iconColor, size: Dimensions.iconS),
          const SizedBox(width: Dimensions.spacingS),
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
