import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_theme.dart';
import '../../../../data/providers/merchant_provider.dart';
import '../../../../data/providers/user_profile_provider.dart';

class WaitingApprovalScreen extends ConsumerWidget {
  const WaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Icône d'attente
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_empty_rounded,
                  size: 60,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(height: 32),
              
              // Titre
              const Text(
                'Compte en attente de vérification',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Description
              const Text(
                'Votre compte a été créé avec succès ! Nous examinons actuellement votre demande.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Étapes
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Prochaines étapes :',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStep(
                      icon: Icons.check_circle,
                      text: 'Votre compte a été créé',
                      isCompleted: true,
                    ),
                    const SizedBox(height: 12),
                    _buildStep(
                      icon: Icons.upload_file,
                      text: 'Uploadez vos documents (RCCM, pièce d\'identité) depuis votre profil',
                      isCompleted: false,
                    ),
                    const SizedBox(height: 12),
                    _buildStep(
                      icon: Icons.verified_user,
                      text: 'Notre équipe vérifiera vos informations',
                      isCompleted: false,
                    ),
                    const SizedBox(height: 12),
                    _buildStep(
                      icon: Icons.notifications_active,
                      text: 'Vous recevrez une notification une fois approuvé',
                      isCompleted: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Boutons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Aller à l'écran d'upload de documents
                        Navigator.pushNamed(context, '/upload-documents');
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Uploader mes documents'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // Recharger le profil pour vérifier le statut
                        await ref.read(merchantProfileProvider.notifier).loadProfile();
                        final profile = ref.read(merchantProfileProvider).value;
                        
                        if (context.mounted) {
                          if (profile?.verificationStatus == 'approved' || profile?.verificationStatus == 'verified') {
                            // Rafraîchir aussi le userProfileProvider pour que le dashboard soit à jour
                            await ref.read(userProfileProvider.notifier).loadProfile();
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Votre compte a été approuvé !'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pushReplacementNamed(context, '/dashboard');
                          } else if (profile?.verificationStatus == 'rejected') {
                            Navigator.pushReplacementNamed(context, '/rejected');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('⏳ Votre compte est toujours en attente'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Vérifier le statut'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      'Se déconnecter',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Note d'assistance
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Besoin d\'aide ? Contactez-nous au support@lebenis.com',
                        style: TextStyle(fontSize: 12, color: AppColors.text),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String text,
    required bool isCompleted,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: isCompleted ? AppColors.success : AppColors.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isCompleted ? AppColors.text : AppColors.textSecondary,
              fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
