import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/driver_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_radius.dart';

class AvailabilityToggle extends ConsumerWidget {
  const AvailabilityToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverState = ref.watch(driverProvider);
    final driver = driverState.driver;
    final isLoading = driverState.isLoading;

    if (driver == null) return const SizedBox.shrink();

    final availabilityStatus = driver.availabilityStatus;
    final isOnline = availabilityStatus != 'offline';

    // Couleur selon le statut
    Color statusColor;
    switch (availabilityStatus) {
      case 'available':
        statusColor = AppColors.success;
        break;
      case 'busy':
        statusColor = AppColors.warning;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      color: isOnline 
          ? statusColor.withValues(alpha: 0.1) 
          : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statut de disponibilité',
                        style: AppTypography.labelMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _getStatusMessage(availabilityStatus),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            
            // Boutons de statut
            Row(
              children: [
                Expanded(
                  child: _StatusButton(
                    label: 'Disponible',
                    icon: Icons.check_circle,
                    isSelected: availabilityStatus == 'available',
                    color: AppColors.success,
                    isLoading: isLoading,
                    onTap: () {
                      if (availabilityStatus != 'available') {
                        ref.read(driverProvider.notifier).goOnline();
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatusButton(
                    label: 'Occupé',
                    icon: Icons.timelapse,
                    isSelected: availabilityStatus == 'busy',
                    color: AppColors.warning,
                    isLoading: isLoading,
                    onTap: () {
                      if (availabilityStatus != 'busy') {
                        ref.read(driverProvider.notifier).goBusy();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: _StatusButton(
                label: 'Hors ligne',
                icon: Icons.power_settings_new,
                isSelected: availabilityStatus == 'offline',
                color: Colors.grey.shade700,
                isLoading: isLoading,
                onTap: () {
                  if (availabilityStatus != 'offline') {
                    ref.read(driverProvider.notifier).goOffline();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'available':
        return 'Vous recevez toutes les nouvelles livraisons';
      case 'busy':
        return 'Vous apparaissez comme occupé';
      case 'offline':
        return 'Vous ne recevez aucune livraison';
      default:
        return 'Statut inconnu';
    }
  }
}

/// Bouton de statut
class _StatusButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final bool isLoading;
  final VoidCallback? onTap;

  const _StatusButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? color : Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.md),
      elevation: isSelected ? 2 : 0,
      child: InkWell(
        onTap: isLoading || isSelected ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20.0,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected ? Colors.white : color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
