import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_radius.dart';
import '../../../../shared/widgets/modern_button.dart';
import '../../../../shared/widgets/modern_card.dart';
import '../../../../data/providers/driver_provider.dart';
import '../../../../core/providers/auth_provider.dart';

/// Écran d'attente de vérification - bloque l'accès à toute l'app
class WaitingVerificationScreen extends ConsumerStatefulWidget {
  const WaitingVerificationScreen({super.key});

  @override
  ConsumerState<WaitingVerificationScreen> createState() => _WaitingVerificationScreenState();
}

class _WaitingVerificationScreenState extends ConsumerState<WaitingVerificationScreen> {
  Timer? _timer;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    // Poll every 10 seconds; safe-guard against overlapping calls
    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_isChecking) return;
      _isChecking = true;
      try {
        await ref.read(driverProvider.notifier).loadProfile();
        final verified = ref.read(isDriverVerifiedProvider);
        if (verified && mounted) {
          _timer?.cancel();
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (_) {
        // Ignorer les erreurs réseau intermittentes
      }
      _isChecking = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        // Récupérer le driver courant et déduire l'état des étapes
                        Builder(builder: (context) {
                          final driver = ref.watch(currentDriverProvider);

                          // Étape 1: création du compte -> terminée si driver non-null
                          final step1Completed = driver != null;

                          // Étape 2: vérification des documents -> considérée comme complétée
                          // si les pièces d'identité et doc. d'immatriculation sont fournies
                          final hasIdFront = driver?.identityCardFront != null && driver?.identityCardFront?.isNotEmpty == true;
                          final hasIdBack = driver?.identityCardBack != null && driver?.identityCardBack?.isNotEmpty == true;
                          final hasVehicleReg = driver?.vehicleRegistrationDocument != null && driver?.vehicleRegistrationDocument?.isNotEmpty == true;
                          final step2Completed = hasIdFront && hasIdBack && hasVehicleReg;
                          final step2InProgress = !step2Completed && (hasIdFront || hasIdBack || hasVehicleReg);

                          // Étape 3: validation du permis -> complétée si driversLicense présent
                          final hasLicense = driver?.driversLicense != null && driver?.driversLicense?.isNotEmpty == true;
                          final step3Completed = hasLicense;

                          // Étape 4: activation du compte -> complétée si driver.isVerified
                          final step4Completed = driver?.isVerified ?? false;
                          // Si les documents et permis sont fournis mais pas encore vérifiés,
                          // on considère l'activation comme 'En cours'
                          final step4InProgress = !step4Completed && (step2Completed && step3Completed || (driver?.verificationStatus == 'pending'));

                          return Column(
                            children: [
                              _buildVerificationStep(
                                '1',
                                'Création du compte',
                                step1Completed ? 'Complétée' : 'En attente',
                                step1Completed,
                              ),
                              _buildVerificationStep(
                                '2',
                                'Vérification des documents',
                                step2Completed
                                    ? 'Complétée'
                                    : step2InProgress
                                        ? 'En cours'
                                        : 'En attente',
                                step2Completed,
                              ),
                              _buildVerificationStep(
                                '3',
                                'Validation du permis',
                                step3Completed ? 'Complétée' : 'En attente',
                                step3Completed,
                              ),
                              _buildVerificationStep(
                                '4',
                                'Activation du compte',
                                step4Completed
                                    ? 'Complétée'
                                    : step4InProgress
                                        ? 'En cours'
                                        : 'En attente',
                                step4Completed,
                              ),
                            ],
                          );
                        }),
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
                    onPressed: () async {
                      try {
                        await ref.read(driverProvider.notifier).loadProfile();
                        final verified = ref.read(isDriverVerifiedProvider);
                        if (verified && context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/home');
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Votre compte est toujours en attente de vérification.')),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erreur lors de la vérification: $e')),
                          );
                        }
                      }
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
    // Déduire l'état à partir du texte de statut (simple et fiable pour l'instant)
    final normalized = status.trim().toLowerCase();
    final isInProgress = normalized == 'en cours' || normalized.contains('en cours');
    final isPending = normalized == 'en attente' || normalized.contains('en attente');

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
                  : isInProgress
                      ? AppColors.warning.withValues(alpha: 0.12)
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
                  : isInProgress
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
                          ),
                        )
                      : isPending
                          ? const Icon(
                              Icons.hourglass_empty,
                              color: AppColors.textSecondary,
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
                        : isInProgress
                            ? AppColors.warning
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
