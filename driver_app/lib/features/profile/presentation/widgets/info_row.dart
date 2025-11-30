import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: Dimensions.iconM,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: Dimensions.spacingM),
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
              Text(
                value,
                style: TextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
