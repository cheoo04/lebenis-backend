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

    final isAvailable = driver.isAvailable;
    final availabilityStatus = driver.availabilityStatus;

    return Card(
      color: isAvailable ? AppColors.success.withValues(alpha: 0.1) : Colors.grey.shade100,
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
                    color: isAvailable ? AppColors.success : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: Dimensions.spacingS),
                Text(
                  'Disponibilité',
                  style: TextStyles.labelLarge,
                ),
                const Spacer(),
                Switch(
                  value: isAvailable,
                  onChanged: isLoading
                      ? null
                      : (value) {
                          if (value) {
                            ref.read(driverProvider.notifier).goOnline();
                          } else {
                            ref.read(driverProvider.notifier).goOffline();
                          }
                        },
                  activeTrackColor: AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: Dimensions.spacingS),
            Text(
              _getStatusMessage(availabilityStatus),
              style: TextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (isAvailable) ...[
              const SizedBox(height: Dimensions.spacingM),
              const Divider(),
              const SizedBox(height: Dimensions.spacingM),
              Text(
                'Mode de disponibilité',
                style: TextStyles.labelMedium,
              ),
              const SizedBox(height: Dimensions.spacingS),
              Wrap(
                spacing: Dimensions.spacingS,
                children: [
                  _StatusChip(
                    label: 'Disponible',
                    icon: Icons.check_circle,
                    isSelected: availabilityStatus == 'online',
                    color: AppColors.success,
                    onTap: isLoading
                        ? null
                        : () {
                            ref.read(driverProvider.notifier).goOnline();
                          },
                  ),
                  _StatusChip(
                    label: 'Occupé',
                    icon: Icons.timelapse,
                    isSelected: availabilityStatus == 'busy',
                    color: AppColors.warning,
                    onTap: isLoading
                        ? null
                        : () {
                            ref.read(driverProvider.notifier).goBusy();
                          },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'online':
        return 'Vous êtes disponible pour recevoir des livraisons';
      case 'busy':
        return 'Vous apparaissez comme occupé, nouvelles livraisons limitées';
      case 'offline':
        return 'Vous n\'êtes pas disponible pour les livraisons';
      default:
        return '';
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback? onTap;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: Dimensions.iconS,
            color: isSelected ? Colors.white : color,
          ),
          const SizedBox(width: Dimensions.spacingXS),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: onTap == null ? null : (_) => onTap!(),
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyles.labelSmall.copyWith(
        color: isSelected ? Colors.white : color,
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color),
    );
  }
}
