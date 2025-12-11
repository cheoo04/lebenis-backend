import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_colors.dart';

class OsmMapWidget extends StatelessWidget {
  final MapController? controller;
  final LatLng center;
  final double zoom;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final void Function(LatLng)? onTap;

  const OsmMapWidget({
    super.key,
    this.controller,
    required this.center,
    this.zoom = 13.0,
    this.markers = const [],
    this.polylines = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        onTap: (_, latlng) => onTap?.call(latlng),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.merchant_app',
        ),
        PolylineLayer(polylines: polylines),
        MarkerLayer(markers: markers),
      ],
    );
  }
}

class OsmMarkerHelper {
  static Marker pickup(LatLng position, {String? label}) {
    return Marker(
      point: position,
      width: 24,
      height: 24,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Icon(Icons.location_on, color: Colors.white, size: 12),
      ),
    );
  }

  static Marker delivery(LatLng position, {String? label}) {
    return Marker(
      point: position,
      width: 24,
      height: 24,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Icon(Icons.flag, color: Colors.white, size: 12),
      ),
    );
  }

  static Marker driver(LatLng position, {String? label}) {
    return Marker(
      point: position,
      width: 32,
      height: 32,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.local_shipping, color: Colors.white, size: 14),
      ),
    );
  }

  static Polyline route(List<LatLng> points, {Color? color}) {
    return Polyline(
      points: points,
      strokeWidth: 4.0,
      color: color ?? AppColors.primary,
      borderStrokeWidth: 2.0,
      borderColor: Colors.white,
    );
  }
}
