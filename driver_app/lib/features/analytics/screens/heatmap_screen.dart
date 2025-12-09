import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/models/analytics/heatmap_point_model.dart';

class HeatmapScreen extends StatefulWidget {
  final List<HeatmapPointModel> heatmapPoints;

  const HeatmapScreen({
    super.key,
    required this.heatmapPoints,
  });

  @override
  State<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends State<HeatmapScreen> {
  final MapController _mapController = MapController();
  List<CircleMarker> _circles = [];

  @override
  void initState() {
    super.initState();
    _createHeatmapMarkers();
  }

  void _createHeatmapMarkers() {
    if (widget.heatmapPoints.isEmpty) return;

    // Find max weight for color scaling
    final maxWeight = widget.heatmapPoints
        .map((p) => p.weight)
        .reduce((a, b) => a > b ? a : b);

    // Create circles for heatmap effect
    _circles = widget.heatmapPoints.map((point) {
      final normalizedWeight = point.weight / maxWeight;
      final radius = 50.0 + (normalizedWeight * 150.0); // 50-200m radius
      final opacity = 0.3 + (normalizedWeight * 0.4); // 0.3-0.7 opacity

      return CircleMarker(
        point: LatLng(point.lat, point.lng),
        radius: radius,
        color: Colors.red.withValues(alpha: opacity),
        borderColor: Colors.red.withValues(alpha: opacity * 0.5),
        borderStrokeWidth: 2,
        useRadiusInMeter: true,
      );
    }).toList();

    setState(() {});
  }

  void _fitBounds() {
    if (widget.heatmapPoints.isNotEmpty) {
      final points = widget.heatmapPoints
          .map((p) => LatLng(p.lat, p.lng))
          .toList();
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.heatmapPoints.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Delivery Heatmap'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No delivery data available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate center point
    final centerPoint = widget.heatmapPoints.first;
    final initialCenter = LatLng(centerPoint.lat, centerPoint.lng);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Heatmap'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fit_screen),
            onPressed: _fitBounds,
            tooltip: 'Fit to bounds',
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 12,
              onMapReady: () {
                Future.delayed(const Duration(milliseconds: 500), _fitBounds);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.lebenis.driver_app',
              ),
              CircleLayer(circles: _circles),
            ],
          ),
          // Legend
          Positioned(
            top: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Heat Intensity',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('High', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Low', style: TextStyle(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Stats card
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.place, color: Colors.blue, size: 20),
                        const SizedBox(height: 4),
                        Text(
                          widget.heatmapPoints.length.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'Locations',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_shipping,
                            color: Colors.green, size: 20),
                        const SizedBox(height: 4),
                        Text(
                          widget.heatmapPoints
                              .map((p) => p.weight)
                              .reduce((a, b) => a + b)
                              .toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'Deliveries',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
