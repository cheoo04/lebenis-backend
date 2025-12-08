import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../data/providers/auth_provider.dart';

class SliverToLayerAppBar extends ConsumerWidget {
  final String title;

  const SliverToLayerAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        IconButton(
          icon: const Icon(Icons.logout, color: AppColors.textPrimary),
          tooltip: 'Déconnexion',
          onPressed: () async {
            // Capture navigator before async gap to avoid using BuildContext after await
            final navigator = Navigator.of(context);
            await ref.read(authProvider.notifier).logout();
            navigator.pushReplacementNamed('/login');
          },
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }
}
