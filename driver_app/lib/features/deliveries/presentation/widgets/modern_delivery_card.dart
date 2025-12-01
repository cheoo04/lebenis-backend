// lib/features/deliveries/presentation/widgets/modern_delivery_card.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_radius.dart';
import '../../../../shared/widgets/modern_card.dart';
import '../../../../shared/widgets/status_chip.dart';

/// Carte de livraison moderne (style maquette)
class ModernDeliveryCard extends StatelessWidget {
  final String deliveryId;
  final String? merchantName;
  final String? pickupAddress;
  final String? deliveryAddress;
  final String status;
  final String? amount;
  final String? distance;
  final VoidCallback? onTap;

  const ModernDeliveryCard({
    super.key,
    required this.deliveryId,
    this.merchantName,
    this.pickupAddress,
    this.deliveryAddress,
    required this.status,
    this.amount,
    this.distance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingHorizontal,
        vertical: AppSpacing.elementSpacingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête : ID et statut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        _getStatusIcon(status),
                        color: _getStatusColor(status),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            merchantName ?? 'Marchand',
                            style: AppTypography.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '#$deliveryId',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: _getStatusLabel(status),
                color: _getStatusColor(status),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.lg),

          // Adresses
          if (pickupAddress != null) ...[
            _buildAddressRow(
              icon: Icons.store_outlined,
              label: 'Récupération',
              address: pickupAddress!,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          
          if (deliveryAddress != null) ...[
            _buildAddressRow(
              icon: Icons.location_on_outlined,
              label: 'Livraison',
              address: deliveryAddress!,
            ),
          ],

          // Informations supplémentaires
          if (amount != null || distance != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (distance != null)
                  Row(
                    children: [
                      Icon(
                        Icons.route_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        distance!,
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                if (amount != null)
                  Text(
                    amount!,
                    style: AppTypography.price.copyWith(fontSize: 18),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Ligne d'adresse
  Widget _buildAddressRow({
    required IconData icon,
    required String label,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption,
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: AppTypography.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Retourne la couleur selon le statut
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
      case 'en_attente':
        return AppColors.blue;
      case 'accepted':
      case 'acceptée':
        return AppColors.purple;
      case 'picked_up':
      case 'récupérée':
        return AppColors.orange;
      case 'in_transit':
      case 'en_cours':
        return AppColors.yellow;
      case 'delivered':
      case 'livrée':
        return AppColors.green;
      case 'cancelled':
      case 'annulée':
        return AppColors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  /// Retourne l'icône selon le statut
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
      case 'en_attente':
        return Icons.assignment_outlined;
      case 'accepted':
      case 'acceptée':
        return Icons.check_circle_outline;
      case 'picked_up':
      case 'récupérée':
        return Icons.shopping_bag_outlined;
      case 'in_transit':
      case 'en_cours':
        return Icons.local_shipping_outlined;
      case 'delivered':
      case 'livrée':
        return Icons.done_all;
      case 'cancelled':
      case 'annulée':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  /// Retourne le label selon le statut
  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'assigned':
        return 'Assignée';
      case 'accepted':
        return 'Acceptée';
      case 'picked_up':
        return 'Récupérée';
      case 'in_transit':
        return 'En cours';
      case 'delivered':
        return 'Livrée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }
}
