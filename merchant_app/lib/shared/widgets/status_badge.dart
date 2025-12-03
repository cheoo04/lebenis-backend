// lib/shared/widgets/status_badge.dart

import 'package:flutter/material.dart';

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
          'color': Colors.orange,
          'icon': Icons.schedule,
        };
      case 'assigned':
        return {
          'label': 'Assignée',
          'color': Colors.blue,
          'icon': Icons.person_pin_circle,
        };
      case 'pickup_confirmed':
        return {
          'label': 'Récupérée',
          'color': Colors.indigo,
          'icon': Icons.check_box,
        };
      case 'in_transit':
        return {
          'label': 'En transit',
          'color': Colors.purple,
          'icon': Icons.local_shipping,
        };
      case 'delivered':
        return {
          'label': 'Livrée',
          'color': Colors.green,
          'icon': Icons.check_circle,
        };
      case 'cancelled':
        return {
          'label': 'Annulée',
          'color': Colors.red,
          'icon': Icons.cancel,
        };
      case 'approved':
        return {
          'label': 'Approuvé',
          'color': Colors.green,
          'icon': Icons.verified,
        };
      case 'rejected':
        return {
          'label': 'Rejeté',
          'color': Colors.red,
          'icon': Icons.cancel,
        };
      default:
        return {
          'label': status,
          'color': Colors.grey,
          'icon': Icons.help_outline,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: badgeColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
