import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/navigation_utils.dart';

/// Widget d'affichage des informations GPS d'une livraison
/// Permet au livreur de naviguer directement vers le point GPS précis
class GpsInfoCard extends StatelessWidget {
  final String title;
  final String address;
  final double? latitude;
  final double? longitude;
  
  // Allow nullable coordinates (some deliveries may not have precise GPS)
  // Use nullable doubles for compatibility with `DeliveryModel` which may have nulls.
  // When null, `hasCoordinates` will be false.
  // Keep `distanceKm` nullable.
  final double? distanceKm;
  final Color? color;

  const GpsInfoCard({
    super.key,
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
    this.color,
  });

  // Updated: coordinates may be null
  bool get hasCoordinates => latitude != null && longitude != null && latitude != 0.0 && longitude != 0.0;

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
            
            // Boutons d'action GPS si les coordonnées sont disponibles
            if (hasCoordinates) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  // Bouton Navigation directe
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await openNavigationApp(
                            latitude: latitude!,
                            longitude: longitude!,
                            label: title,
                          );
                        } catch (e) {
                          // Ignore - the app will handle errors
                        }
                      },
                      icon: const Icon(Icons.navigation, size: 18),
                      label: const Text('Naviguer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color ?? Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Bouton Copier les coordonnées
                  IconButton(
                    onPressed: () {
                      final coords = '$latitude, $longitude';
                      Clipboard.setData(ClipboardData(text: coords));
                      // Note: Snackbar should be shown by parent if needed
                    },
                    icon: const Icon(Icons.copy, size: 20),
                    tooltip: 'Copier les coordonnées',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Indicateur de position précise
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.blue.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Position exacte sur carte',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
