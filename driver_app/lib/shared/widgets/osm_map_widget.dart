// lib/shared/widgets/osm_map_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';

/// Widget de carte OpenStreetMap (100% gratuit, pas de carte bancaire requise)
/// 
/// Alternative à Google Maps sans coûts ni limites
class OsmMapWidget extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final MapController? mapController;
  final Function(LatLng)? onTap;
  final Function(LatLng)? onLongPress;

  const OsmMapWidget({
    super.key,
    required this.center,
    this.zoom = 13.0,
    this.markers = const [],
    this.polylines = const [],
    this.mapController,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        onTap: onTap != null ? (_, latlng) => onTap!(latlng) : null,
        onLongPress: onLongPress != null ? (_, latlng) => onLongPress!(latlng) : null,
      ),
      children: [
        // Tuiles de carte OpenStreetMap (gratuit)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.lebenis.driver_app',
          maxZoom: 19,
        ),
        
        // Polylines (routes)
        if (polylines.isNotEmpty)
          PolylineLayer(
            polylines: polylines,
          ),
        
        // Markers (épingles)
        if (markers.isNotEmpty)
          MarkerLayer(
            markers: markers,
          ),
      ],
    );
  }
}

/// Helper pour créer des markers personnalisés
class OsmMarkerHelper {
  /// Marker de pickup (point de récupération)
  static Marker pickup({
    required LatLng position,
    String? label,
  }) {
    return Marker(
      point: position,
      width: 24,
      height: 24,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Icon(
          Icons.circle_outlined,
          color: Colors.white,
          size: 12,
        ),
      ),
    );
  }

  /// Marker de livraison (destination)
  static Marker delivery({
    required LatLng position,
    String? label,
  }) {
    return Marker(
      point: position,
      width: 24,
      height: 24,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Icon(
          Icons.location_on,
          color: Colors.white,
          size: 12,
        ),
      ),
    );
  }

  /// Marker du driver (position actuelle)
  static Marker driver({
    required LatLng position,
    double? heading,
    String? label,
  }) {
    return Marker(
      point: position,
      width: 32,
      height: 32,
      child: Transform.rotate(
        angle: heading ?? 0,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha((0.5 * 255).round()),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: const Icon(
            Icons.navigation,
            color: Colors.white,
            size: 14,
          ),
        ),
      ),
    );
  }

  /// Créer une polyline pour la route
  static Polyline route({
    required List<LatLng> points,
    Color? color,
    double width = 4.0,
  }) {
    return Polyline(
      points: points,
      strokeWidth: width,
      color: color ?? AppColors.primary,
      borderColor: Colors.white,
      borderStrokeWidth: 2,
    );
  }
}
