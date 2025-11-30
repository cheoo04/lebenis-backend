import 'package:flutter/material.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.cardPadding),
        child: Column(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: Dimensions.iconL,
            ),
            const SizedBox(height: Dimensions.spacingS),
            Text(
              value,
              style: TextStyles.h3,
            ),
            const SizedBox(height: Dimensions.spacingXS),
            Text(
              label,
              style: TextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
