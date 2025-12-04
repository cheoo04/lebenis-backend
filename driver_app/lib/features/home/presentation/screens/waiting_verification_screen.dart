import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_radius.dart';
import '../../../../shared/widgets/modern_button.dart';
import '../../../../shared/widgets/modern_card.dart';
import '../../../../data/providers/driver_provider.dart';
import '../../../../core/providers/auth_provider.dart';

/// Écran d'attente de vérification - bloque l'accès à toute l'app
class WaitingVerificationScreen extends ConsumerWidget {
  const WaitingVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Compte en attente'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false, // Pas de bouton retour
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône de sablier
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_empty,
                    size: 60,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                
                // Titre
                Text(
                  'Compte en cours de vérification',
                  style: AppTypography.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Sous-titre
                Text(
                  'Votre compte chauffeur est en attente de vérification par notre équipe. Vous pourrez accéder aux livraisons une fois approuvé.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxxl),
                
                // Processus de vérification
                ModernCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Processus de vérification',
                          style: AppTypography.label,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildVerificationStep(
                          '1',
                          'Création du compte',
                          'Complétée',
                          true,
                        ),
                        _buildVerificationStep(
                          '2',
                          'Vérification des documents',
                          'En cours',
                          false,
                        ),
                        _buildVerificationStep(
                          '3',
                          'Validation du permis',
                          'En attente',
                          false,
                        ),
                        _buildVerificationStep(
                          '4',
                          'Activation du compte',
                          'En attente',
                          false,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                
                // Bouton pour compléter le profil
                SizedBox(
                  width: double.infinity,
                  child: ModernButton(
                    text: 'Compléter mon profil',
                    onPressed: () {
                      Navigator.of(context).pushNamed('/profile');
                    },
                    type: ModernButtonType.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Bouton pour vérifier le statut
                SizedBox(
                  width: double.infinity,
                  child: ModernButton(
                    text: 'Vérifier le statut',
                    onPressed: () {
                      ref.invalidate(driverProvider);
                    },
                    type: ModernButtonType.outlined,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                
                // Info de contact
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Des questions? Contactez-nous à support@lebenis.com',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Widget pour une étape de vérification
  Widget _buildVerificationStep(
    String number,
    String title,
    String status,
    bool isCompleted,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.green
                  : AppColors.textSecondary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : Text(
                      number,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium,
                ),
                Text(
                  status,
                  style: AppTypography.caption.copyWith(
                    color: isCompleted
                        ? AppColors.green
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
