import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';
import '../../../../shared/utils/formatters.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.primary;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(Dimensions.spacingS),
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(Dimensions.radiusS),
                    ),
                    child: Icon(
                      icon,
                      color: cardColor,
                      size: Dimensions.iconM,
                    ),
                  ),
                  const Spacer(),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: Dimensions.iconS,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
              const SizedBox(height: Dimensions.spacingM),
              Text(
                title,
                style: TextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: Dimensions.spacingXS),
              Text(
                value,
                style: TextStyles.h2.copyWith(
                  color: cardColor,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: Dimensions.spacingXS),
                Text(
                  subtitle!,
                  style: TextStyles.caption,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class EarningsSummaryCard extends StatelessWidget {
  final double totalEarnings;
  final int totalDeliveries;
  final double averagePerDelivery;
  final String period;

  const EarningsSummaryCard({
    super.key,
    required this.totalEarnings,
    required this.totalDeliveries,
    required this.averagePerDelivery,
    this.period = 'Ce mois',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: Dimensions.iconS,
                ),
                const SizedBox(width: Dimensions.spacingXS),
                Text(
                  period,
                  style: TextStyles.labelMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.spacingL),
            Text(
              'Gains totaux',
              style: TextStyles.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: Dimensions.spacingXS),
            Text(
              Formatters.formatPrice(totalEarnings),
              style: TextStyles.h1.copyWith(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Dimensions.spacingL),
            const Divider(color: Colors.white24),
            const SizedBox(height: Dimensions.spacingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                  label: 'Livraisons',
                  value: '$totalDeliveries',
                  icon: Icons.local_shipping,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white24,
                ),
                _StatItem(
                  label: 'Moyenne',
                  value: Formatters.formatPrice(averagePerDelivery),
                  icon: Icons.analytics,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.8),
            size: Dimensions.iconM,
          ),
          const SizedBox(width: Dimensions.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyles.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  value,
                  style: TextStyles.labelLarge.copyWith(
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
