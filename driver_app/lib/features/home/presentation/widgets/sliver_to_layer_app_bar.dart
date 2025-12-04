import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';

/// AppBar personnalisée pour le dashboard
class SliverToLayerAppBar extends StatelessWidget {
  final String title;

  const SliverToLayerAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.surface,
      elevation: 0,
      title: Text(
        title,
        style: AppTypography.h4,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textPrimary),
          onPressed: () {
            Navigator.pushNamed(context, '/deliveries');
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }
}
