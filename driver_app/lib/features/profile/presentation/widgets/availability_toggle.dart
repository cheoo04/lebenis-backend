import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/driver_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';

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
        padding: const EdgeInsets.all(Dimensions.cardPadding),
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
                const SizedBox(width: Dimensions.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statut de disponibilité',
                        style: TextStyles.labelMedium,
                      ),
                      const SizedBox(height: Dimensions.spacingXS),
                      Text(
                        _getStatusMessage(availabilityStatus),
                        style: TextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.spacingM),
            const Divider(),
            const SizedBox(height: Dimensions.spacingM),
            
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
                const SizedBox(width: Dimensions.spacingS),
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
            const SizedBox(height: Dimensions.spacingS),
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
      borderRadius: BorderRadius.circular(Dimensions.radiusM),
      elevation: isSelected ? 2 : 0,
      child: InkWell(
        onTap: isLoading || isSelected ? null : onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusM),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.spacingM,
            vertical: Dimensions.spacingS,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? color : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(Dimensions.radiusM),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: Dimensions.iconS,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: Dimensions.spacingS),
              Text(
                label,
                style: TextStyles.labelMedium.copyWith(
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
