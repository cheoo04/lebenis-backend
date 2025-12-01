import 'package:flutter/material.dart';
import '../../../../core/constants/backend_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_radius.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool showIcon;
  final double? fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
    this.fontSize,
  });

  Color _getStatusColor() {
    switch (status) {
      case BackendConstants.deliveryStatusPendingAssignment:
        return AppColors.warning;
      case BackendConstants.deliveryStatusAssigned:
      case BackendConstants.deliveryStatusPickupInProgress:
      case BackendConstants.deliveryStatusPickedUp:
      case BackendConstants.deliveryStatusInTransit:
        return AppColors.info;
      case BackendConstants.deliveryStatusDelivered:
        return AppColors.success;
      case BackendConstants.deliveryStatusCancelled:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel() {
    return BackendConstants.getDeliveryStatusLabel(status);
  }

  IconData _getStatusIcon() {
    switch (status) {
      case BackendConstants.deliveryStatusPendingAssignment:
        return Icons.schedule;
      case BackendConstants.deliveryStatusAssigned:
        return Icons.check_circle_outline;
      case BackendConstants.deliveryStatusPickupInProgress:
        return Icons.local_shipping;
      case BackendConstants.deliveryStatusPickedUp:
        return Icons.inventory_2;
      case BackendConstants.deliveryStatusInTransit:
        return Icons.local_shipping;
      case BackendConstants.deliveryStatusDelivered:
        return Icons.check_circle;
      case BackendConstants.deliveryStatusCancelled:
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _getStatusIcon(),
              size: fontSize ?? 20.0,
              color: color,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            _getStatusLabel(),
            style: (fontSize != null
                    ? AppTypography.labelSmall.copyWith(fontSize: fontSize)
                    : AppTypography.labelSmall)
                .copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
