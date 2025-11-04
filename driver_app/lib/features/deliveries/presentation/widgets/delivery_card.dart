import 'package:flutter/material.dart';
import '../../../../data/models/delivery_model.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';
import '../../../../shared/utils/formatters.dart';
import 'status_badge.dart';

class DeliveryCard extends StatelessWidget {
  final DeliveryModel delivery;
  final VoidCallback onTap;

  const DeliveryCard({
    super.key,
    required this.delivery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: Dimensions.spacingM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.cardPadding),
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
                    style: TextStyles.trackingNumber,
                  ),
                ],
              ),
              
              const SizedBox(height: Dimensions.spacingM),
              
              // Pickup & Delivery Addresses
              _AddressRow(
                icon: Icons.circle_outlined,
                iconColor: AppColors.success,
                address: delivery.pickupAddress,
                label: 'Récupération',
              ),
              
              const SizedBox(height: Dimensions.spacingS),
              
              _AddressRow(
                icon: Icons.location_on,
                iconColor: AppColors.error,
                address: delivery.deliveryAddress,
                label: 'Livraison',
              ),
              
              const SizedBox(height: Dimensions.spacingM),
              
              const Divider(),
              
              const SizedBox(height: Dimensions.spacingS),
              
              // Footer: Price & Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        size: Dimensions.iconS,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: Dimensions.spacingXS),
                      Text(
                        Formatters.formatPrice(delivery.price),
                        style: TextStyles.priceSmall,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: Dimensions.iconS,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: Dimensions.spacingXS),
                      Text(
                        Formatters.formatRelativeTime(delivery.createdAt),
                        style: TextStyles.caption,
                      ),
                    ],
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
          size: Dimensions.iconM,
          color: iconColor,
        ),
        const SizedBox(width: Dimensions.spacingS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: TextStyles.bodyMedium,
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
