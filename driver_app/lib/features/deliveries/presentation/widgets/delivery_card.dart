import 'package:flutter/material.dart';
import '../../../../data/models/delivery_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_radius.dart';
import '../../../../shared/utils/formatters.dart';
import 'status_badge.dart';

class DeliveryCard extends StatelessWidget {
  final DeliveryModel delivery;
  final VoidCallback onTap;
  /// Masquer la distance totale (utile en phase de récupération)
  final bool hideDistance;

  const DeliveryCard({
    super.key,
    required this.delivery,
    required this.onTap,
    this.hideDistance = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status & Tracking Number
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(status: delivery.status),
                  Text(
                    '#${delivery.trackingNumber}',
                    style: AppTypography.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              // Pickup & Delivery Addresses
              _AddressRow(
                icon: Icons.circle_outlined,
                iconColor: AppColors.success,
                address: delivery.pickupAddress,
                label: 'Récupération',
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              _AddressRow(
                icon: Icons.location_on,
                iconColor: AppColors.error,
                address: delivery.deliveryAddress,
                label: 'Livraison',
              ),
              
              const SizedBox(height: AppSpacing.md),
              
              Divider(height: 1, color: AppColors.border),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Footer: Price, Distance & Payment Method
              Row(
                children: [
                  // Price
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 18,
                          color: AppColors.green,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            Formatters.formatPrice(delivery.price),
                            style: AppTypography.price.copyWith(fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Distance (masquée si hideDistance = true)
                  if (delivery.distanceKm > 0 && !hideDistance)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.route,
                            size: 18,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              Formatters.formatDistance(delivery.distanceKm),
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Payment Method
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          delivery.paymentMethod == 'cod' ? Icons.money : Icons.check_circle,
                          size: 18,
                          color: delivery.paymentMethod == 'cod' ? AppColors.warning : AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            delivery.paymentMethod == 'cod' ? 'COD' : 'Prépayé',
                            style: AppTypography.caption.copyWith(
                              color: delivery.paymentMethod == 'cod' ? AppColors.warning : AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String address;
  final String label;

  const _AddressRow({
    required this.icon,
    required this.iconColor,
    required this.address,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: iconColor,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
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
}
