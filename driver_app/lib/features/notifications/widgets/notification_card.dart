import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_radius.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback? onMarkAsRead;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white
              : AppColors.primary.withValues(alpha: 0.05),
          border: Border(
            bottom: BorderSide(
              color: AppColors.border,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône type de notification
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  notification.typeIcon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Badge non lu
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      // Type de notification
                      Expanded(
                        child: Text(
                          notification.typeLabel,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Temps relatif
                      Text(
                        notification.relativeTime,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Titre
                  Text(
                    notification.title,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight:
                          notification.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Corps du message
                  Text(
                    notification.body,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Données additionnelles (si présentes)
                  if (notification.data.isNotEmpty && 
                      notification.data.containsKey('tracking_number'))
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '#${notification.data['tracking_number']}',
                          style: AppTypography.caption.copyWith(
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getIconBackgroundColor() {
    switch (notification.notificationType) {
      case 'new_delivery':
        return AppColors.primary.withValues(alpha: 0.1);
      case 'delivery_accepted':
        return AppColors.success.withValues(alpha: 0.1);
      case 'delivery_rejected':
        return AppColors.error.withValues(alpha: 0.1);
      case 'delivery_status_change':
        return AppColors.info.withValues(alpha: 0.1);
      case 'payment_received':
        return AppColors.warning.withValues(alpha: 0.1);
      case 'rating_received':
        return Colors.amber.withValues(alpha: 0.1);
      case 'system':
        return AppColors.textSecondary.withValues(alpha: 0.1);
      case 'promo':
        return Colors.purple.withValues(alpha: 0.1);
      default:
        return AppColors.border.withValues(alpha: 0.1);
    }
  }
}
