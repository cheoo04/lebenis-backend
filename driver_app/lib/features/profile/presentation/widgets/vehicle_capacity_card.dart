import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';

class VehicleCapacityCard extends StatelessWidget {
  final String vehicleType;

  const VehicleCapacityCard({super.key, required this.vehicleType});

  Map<String, dynamic> _getCapacityInfo(String type) {
    switch (type) {
      case 'moto':
        return {
          'weight': '15 kg',
          'dimensions': '50 × 40 × 50 cm',
          'description': 'Idéal pour petits colis (sac à dos)',
          'icon': Icons.backpack,
          'color': AppColors.info,
        };
      case 'tricycle':
        return {
          'weight': '100 kg',
          'dimensions': '120 × 80 × 80 cm',
          'description': 'Bon pour colis moyens (caisse arrière)',
          'icon': Icons.shopping_bag,
          'color': AppColors.warning,
        };
      case 'voiture':
        return {
          'weight': '200 kg',
          'dimensions': '150 × 100 × 100 cm',
          'description': 'Colis volumineux (coffre de voiture)',
          'icon': Icons.luggage,
          'color': AppColors.primary,
        };
      case 'camionnette':
        return {
          'weight': '500 kg',
          'dimensions': '300 × 150 × 150 cm',
          'description': 'Gros volumes (benne de camionnette)',
          'icon': Icons.inventory_2,
          'color': AppColors.success,
        };
      default:
        return {
          'weight': '30 kg',
          'dimensions': 'Non spécifié',
          'description': 'Capacité par défaut',
          'icon': Icons.local_shipping,
          'color': AppColors.textSecondary,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _getCapacityInfo(vehicleType);
    return Card(
      color: (info['color'] as Color).withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  info['icon'] as IconData,
                  color: info['color'] as Color,
                  size: Dimensions.iconL,
                ),
                const SizedBox(width: Dimensions.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Capacités maximales',
                        style: TextStyles.labelMedium.copyWith(
                          color: info['color'] as Color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: Dimensions.spacingXS),
                      Text(
                        info['description'] as String,
                        style: TextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.spacingM),
            Container(
              padding: const EdgeInsets.all(Dimensions.spacingM),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radiusM),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          Icons.scale,
                          color: info['color'] as Color,
                          size: Dimensions.iconM,
                        ),
                        const SizedBox(height: Dimensions.spacingXS),
                        Text(
                          info['weight'] as String,
                          style: TextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Poids max',
                          style: TextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: AppColors.border,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          Icons.straighten,
                          color: info['color'] as Color,
                          size: Dimensions.iconM,
                        ),
                        const SizedBox(height: Dimensions.spacingXS),
                        Text(
                          info['dimensions'] as String,
                          style: TextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Dimensions max',
                          style: TextStyles.caption,
                        ),
                      ],
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
}
