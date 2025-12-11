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
  final String? trackingNumber;
  final String? merchantName;
  final String? recipientName;
  final String? pickupAddress;
  final String? pickupCommune;
  final String? deliveryAddress;
  final String? deliveryCommune;
  final String status;
  final String? amount;
  final String? distance;
  final DateTime? createdAt;
  final VoidCallback? onTap;
  final bool showAcceptButton;

  const ModernDeliveryCard({
    super.key,
    required this.deliveryId,
    this.trackingNumber,
    this.merchantName,
    this.recipientName,
    this.pickupAddress,
    this.pickupCommune,
    this.deliveryAddress,
    this.deliveryCommune,
    required this.status,
    this.amount,
    this.distance,
    this.createdAt,
    this.onTap,
    this.showAcceptButton = false,
  });

  String _formatAmount(String? amt) {
    if (amt == null) return '';
    try {
      final value = double.parse(amt);
      return '${value.toStringAsFixed(0)} FCFA';
    } catch (_) {
      return '$amt FCFA';
    }
  }

  String _formatDistance(String? dist) {
    if (dist == null) return '';
    try {
      final value = double.parse(dist);
      return '${value.toStringAsFixed(1)} km';
    } catch (_) {
      return '$dist km';
    }
  }

  String _formatTrackingNumber(String? tracking, String id) {
    if (tracking != null && tracking.isNotEmpty) {
      // Afficher seulement les 8 premiers caractères
      return '#${tracking.length > 12 ? tracking.substring(0, 12) : tracking}';
    }
    // Fallback: utiliser l'ID tronqué
    return '#${id.length > 8 ? id.substring(0, 8) : id}...';
  }

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
          // En-tête : Nom et statut
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
                            recipientName ?? merchantName ?? 'Client',
                            style: AppTypography.label.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTrackingNumber(trackingNumber, deliveryId),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
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

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),

          // Adresses avec communes
          if (pickupCommune != null || pickupAddress != null) ...[
              icon: Icons.inventory_2_outlined,
              label: 'Récupération',
              address: pickupCommune ?? pickupAddress ?? '',
              isPickup: true,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          
          if (deliveryCommune != null || deliveryAddress != null) ...[            _buildAddressRow(
              icon: Icons.location_on_outlined,
              label: 'Livraison',
              address: deliveryCommune ?? deliveryAddress ?? '',
              isPickup: false,
            ),
          ],

          // Informations supplémentaires (distance et montant)
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                // Distance
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.route_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDistance(distance),
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: AppColors.border,
                ),
                // Montant
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatAmount(amount),
                        style: AppTypography.price.copyWith(
                          fontSize: 16,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bouton Accepter pour livraisons disponibles
          if (showAcceptButton) ...[
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.check_circle_outline, size: 20),
                label: const Text('Voir les détails'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
              ),
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
    bool isPickup = false,
  }) {
    final color = isPickup ? AppColors.blue : AppColors.success;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textHint,
                  fontSize: 11,
                ),
              ),
              Text(
                address,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
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
