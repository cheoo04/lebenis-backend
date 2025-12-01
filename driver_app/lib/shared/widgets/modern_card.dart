// lib/shared/widgets/modern_card.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// Carte moderne avec coins arrondis et ombre légère
class ModernCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final double? borderRadius;
  final Border? border;
  final Gradient? gradient;

  const ModernCard({
    super.key,
    required this.child,
    this.color,
    this.onTap,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.border,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPaddingMedium),
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppColors.surface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.card),
        border: border,
        boxShadow: elevation != null || elevation == 0
            ? []
            : [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: AppSpacing.elementSpacingSmall),
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(borderRadius ?? AppRadius.card),
                child: cardContent,
              ),
            )
          : cardContent,
    );
  }
}

/// Carte colorée pour le dashboard (style maquette)
class ColoredDashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback? onTap;

  const ColoredDashboardCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      color: color,
      onTap: onTap,
      borderRadius: AppRadius.cardLarge,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: AppColors.textWhite,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textWhite,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textWhite.withValues(alpha: 0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Carte de liste avec miniature (style maquette)
class ListItemCard extends StatelessWidget {
  final String? imageUrl;
  final Widget? imagePlaceholder;
  final String title;
  final String? subtitle;
  final String? price;
  final double? rating;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ListItemCard({
    super.key,
    this.imageUrl,
    this.imagePlaceholder,
    required this.title,
    this.subtitle,
    this.price,
    this.rating,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPaddingHorizontal,
        vertical: AppSpacing.elementSpacingSmall,
      ),
      child: Row(
        children: [
          // Image miniature
          if (imageUrl != null || imagePlaceholder != null)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadius.image),
              ),
              clipBehavior: Clip.antiAlias,
              child: imagePlaceholder ??
                  (imageUrl != null
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image, color: AppColors.textSecondary);
                          },
                        )
                      : const Icon(Icons.image, color: AppColors.textSecondary)),
            ),
          
          const SizedBox(width: AppSpacing.md),
          
          // Contenu principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (rating != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: AppColors.yellow,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating!.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Prix et trailing
          if (price != null || trailing != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (price != null)
                  Text(
                    price!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                  ),
                if (trailing != null) trailing!,
              ],
            ),
        ],
      ),
    );
  }
}
