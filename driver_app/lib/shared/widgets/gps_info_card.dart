import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../core/utils/navigation_utils.dart';

/// Widget d'affichage des informations GPS d'une livraison
class GpsInfoCard extends StatelessWidget {
  final String title;
  final String address;
  final double latitude;
  final double longitude;
  final double? distanceKm;
  final VoidCallback? onNavigate;
  final Color? color;

  const GpsInfoCard({
    Key? key,
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
    this.onNavigate,
    this.color,
  }) : super(key: key);

  bool get hasCoordinates => latitude != 0.0 && longitude != 0.0;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: color ?? Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (hasCoordinates)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.gps_fixed,
                          size: 14,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'GPS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.gps_off,
                          size: 14,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pas de GPS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Adresse
            Text(
              address,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            
            // Optional distance display (no raw coordinates or navigation button)
            if (distanceKm != null && distanceKm! > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.straighten, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Distance: ${distanceKm!.toStringAsFixed(2)} km',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
