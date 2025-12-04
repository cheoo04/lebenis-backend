// lib/shared/widgets/status_badge.dart

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String label;
  final Color? color;
  final IconData? icon;

  const StatusBadge({
    Key? key,
    required this.status,
    required this.label,
    this.color,
    this.icon,
  }) : super(key: key);

  factory StatusBadge.fromStatus(String status) {
    final info = _getStatusInfo(status);
    return StatusBadge(
      status: status,
      label: info['label'],
      color: info['color'],
      icon: info['icon'],
    );
  }

  static Map<String, dynamic> _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'pending_assignment':
        return {
          'label': 'En attente',
          'color': AppColors.pending,
          'icon': Icons.schedule_rounded,
        };
      case 'assigned':
        return {
          'label': 'Assignée',
          'color': AppColors.inTransit,
          'icon': Icons.person_pin_circle_rounded,
        };
      case 'pickup_confirmed':
        return {
          'label': 'Récupérée',
          'color': AppColors.info,
          'icon': Icons.check_box_rounded,
        };
      case 'in_transit':
        return {
          'label': 'En transit',
          'color': AppColors.inTransit,
          'icon': Icons.local_shipping_rounded,
        };
      case 'delivered':
        return {
          'label': 'Livrée',
          'color': AppColors.delivered,
          'icon': Icons.check_circle_rounded,
        };
      case 'cancelled':
        return {
          'label': 'Annulée',
          'color': AppColors.cancelled,
          'icon': Icons.cancel_rounded,
        };
      case 'approved':
        return {
          'label': 'Approuvé',
          'color': AppColors.success,
          'icon': Icons.verified_rounded,
        };
      case 'rejected':
        return {
          'label': 'Rejeté',
          'color': AppColors.error,
          'icon': Icons.cancel_rounded,
        };
      default:
        return {
          'label': status,
          'color': AppColors.textSecondary,
          'icon': Icons.help_outline_rounded,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(
          color: badgeColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: badgeColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: badgeColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
