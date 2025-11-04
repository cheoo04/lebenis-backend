// lib/shared/widgets/empty_state_widget.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Widget d'état vide (no data)
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final String? imagePath;
  final VoidCallback? onAction;
  final String? actionText;
  final IconData? actionIcon;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.imagePath,
    this.onAction,
    this.actionText,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image ou icône
            if (imagePath != null)
              Image.asset(
                imagePath!,
                width: 200,
                height: 200,
              )
            else
              Icon(
                icon ?? Icons.inbox,
                size: 100,
                color: AppColors.textHint,
              ),
            
            const SizedBox(height: 24),
            
            // Titre
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Message
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            // Bouton d'action
            if (onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon ?? Icons.add),
                label: Text(actionText ?? 'Ajouter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// État vide pour liste de livraisons
class EmptyDeliveriesWidget extends StatelessWidget {
  final VoidCallback? onRefresh;

  const EmptyDeliveriesWidget({
    super.key,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.local_shipping_outlined,
      title: 'Aucune livraison',
      message: 'Vous n\'avez pas encore de livraison assignée.\nPassez en ligne pour recevoir des courses.',
      onAction: onRefresh,
      actionText: 'Actualiser',
      actionIcon: Icons.refresh,
    );
  }
}

/// État vide pour recherche
class EmptySearchWidget extends StatelessWidget {
  final String? query;

  const EmptySearchWidget({
    super.key,
    this.query,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'Aucun résultat',
      message: query != null
          ? 'Aucun résultat pour "$query"'
          : 'Essayez une autre recherche',
    );
  }
}

/// État vide pour gains
class EmptyEarningsWidget extends StatelessWidget {
  const EmptyEarningsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Pas de gains',
      message: 'Vous n\'avez pas encore de gains.\nCommencez à livrer pour gagner de l\'argent !',
    );
  }
}

/// État vide personnalisé compact
class CompactEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const CompactEmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
