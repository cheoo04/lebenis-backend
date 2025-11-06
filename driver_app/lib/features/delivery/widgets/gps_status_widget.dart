import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gps_provider.dart';

/// GPS Status Widget
/// 
/// Displays current GPS tracking status, position, and interval.
/// Can be placed in the driver dashboard or settings screen.
class GPSStatusWidget extends ConsumerWidget {
  const GPSStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gpsState = ref.watch(gpsStateProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.gps_fixed,
                  color: gpsState.isTracking ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'GPS Tracking',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                _buildStatusChip(gpsState.isTracking),
              ],
            ),
            
            const SizedBox(height: 12),
            
            if (gpsState.isTracking) ...[
              _buildInfoRow(
                'Status',
                _getStatusLabel(gpsState.driverStatus),
                Icons.person,
              ),
              
              if (gpsState.currentPosition != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Position',
                  '${gpsState.currentPosition!.latitude.toStringAsFixed(5)}, '
                  '${gpsState.currentPosition!.longitude.toStringAsFixed(5)}',
                  Icons.location_on,
                ),
                
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Accuracy',
                  '${gpsState.currentPosition!.accuracy.toStringAsFixed(1)}m',
                  Icons.my_location,
                ),
                
                if (gpsState.currentPosition!.speed > 0) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Speed',
                    '${(gpsState.currentPosition!.speed * 3.6).toStringAsFixed(1)} km/h',
                    Icons.speed,
                  ),
                ],
              ],
              
              const SizedBox(height: 8),
              _buildInfoRow(
                'Update Interval',
                '${gpsState.currentInterval}s',
                Icons.timer,
              ),
              
              if (gpsState.lastUpdate != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Last Update',
                  _formatLastUpdate(gpsState.lastUpdate!),
                  Icons.access_time,
                ),
              ],
            ],
            
            if (gpsState.errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        gpsState.errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
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
  
  Widget _buildStatusChip(bool isTracking) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isTracking ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTracking ? Colors.green : Colors.grey,
          width: 1,
        ),
      ),
      child: Text(
        isTracking ? 'Active' : 'Inactive',
        style: TextStyle(
          color: isTracking ? Colors.green : Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
  
  String _getStatusLabel(String status) {
    switch (status) {
      case 'available':
        return 'Disponible';
      case 'busy':
        return 'En livraison';
      case 'on_break':
        return 'En pause';
      case 'offline':
        return 'Hors service';
      default:
        return status;
    }
  }
  
  String _formatLastUpdate(DateTime lastUpdate) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }
}
