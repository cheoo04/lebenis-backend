// lib/features/home/presentation/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_radius.dart';
import '../../../../shared/widgets/modern_card.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/providers/delivery_provider.dart';
import '../../../../data/providers/payment_provider.dart';
import '../../../../data/providers/driver_provider.dart';
import '../../../../data/models/delivery_model.dart';
import '../widgets/widgets.dart';

/// Dashboard moderne avec grille de cartes colorées (style maquette)
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les données
    Future.microtask(() {
      ref.read(deliveryProvider.notifier).loadMyDeliveries();
      ref.read(paymentProvider.notifier).loadTransactions();
    });
  }

  /// Formatter le temps écoulé en français
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Il y a quelques secondes';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'Il y a $minutes minute${minutes > 1 ? 's' : ''}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'Il y a $hours heure${hours > 1 ? 's' : ''}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'Il y a $days jour${days > 1 ? 's' : ''}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'Il y a $months mois';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'Il y a $years an${years > 1 ? 's' : ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveryState = ref.watch(deliveryProvider);
    final paymentState = ref.watch(paymentProvider);
    final driverState = ref.watch(driverProvider);
    
    // Vérifier le statut de vérification
    if (driverState.driver != null && !driverState.driver!.isVerified) {
      return _buildWaitingScreen(context);
    }
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar personnalisée
            SliverToLayerAppBar(
              title: 'Dashboard',
            ),

            // Contenu
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Text(
                      'Bienvenue! 👋',
                      style: AppTypography.h3,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Que souhaitez-vous faire aujourd\'hui?',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // Grille de cartes 2x3
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.lg,
                      crossAxisSpacing: AppSpacing.lg,
                      childAspectRatio: 1,
                      children: [
                        ColoredDashboardCard(
                          icon: Icons.local_shipping_outlined,
                          title: 'Livraisons',
                          subtitle: 'Gérer vos courses',
                          color: AppColors.cardBlue,
                          onTap: () {
                            Navigator.pushNamed(context, '/deliveries');
                          },
                        ),
                        ColoredDashboardCard(
                          icon: Icons.chat_bubble_outline,
                          title: 'Messages',
                          subtitle: 'Discuter',
                          color: AppColors.cardOrange,
                          onTap: () {
                            Navigator.pushNamed(context, '/chat-conversations');
                          },
                        ),
                        ColoredDashboardCard(
                          icon: Icons.attach_money,
                          title: 'Gains',
                          subtitle: 'Vos revenus',
                          color: AppColors.cardGreen,
                          onTap: () {
                            Navigator.pushNamed(context, '/earnings');
                          },
                        ),
                        ColoredDashboardCard(
                          icon: Icons.history,
                          title: 'Historique',
                          subtitle: 'Vos courses',
                          color: AppColors.cardYellow,
                          onTap: () {
                            Navigator.pushNamed(context, '/transactions');
                          },
                        ),
                        ColoredDashboardCard(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'Alertes',
                          color: AppColors.cardRed,
                          onTap: () {
                            Navigator.pushNamed(context, '/notifications');
                          },
                        ),
                        ColoredDashboardCard(
                          icon: Icons.person_outline,
                          title: 'Profil',
                          subtitle: 'Vos infos',
                          color: AppColors.cardPurple,
                          onTap: () {
                            Navigator.pushNamed(context, '/profile');
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Section "Activité récente"
                    Text(
                      'Activité récente',
                      style: AppTypography.h4,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Cartes d'activité dynamiques
                    ..._buildRecentActivities(deliveryState, paymentState),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construire les activités récentes dynamiquement
  List<Widget> _buildRecentActivities(deliveryState, paymentState) {
    final activities = <Widget>[];
    
    // Récupérer les dernières livraisons terminées
    final List<DeliveryModel> completedDeliveries = deliveryState.deliveries
        .where((d) => d.status == 'completed')
        .toList()
        .cast<DeliveryModel>();
    
    completedDeliveries.sort((DeliveryModel a, DeliveryModel b) {
      final DateTime aDate = a.deliveryTime ?? a.createdAt;
      final DateTime bDate = b.deliveryTime ?? b.createdAt;
      return bDate.compareTo(aDate);
    });
    
    // Récupérer les dernières livraisons en cours
    final List<DeliveryModel> activeDeliveries = deliveryState.deliveries
        .where((d) => d.status == 'picked_up' || d.status == 'assigned')
        .toList()
        .cast<DeliveryModel>();
    
    activeDeliveries.sort((DeliveryModel a, DeliveryModel b) {
      final DateTime aDate = a.pickupTime ?? a.createdAt;
      final DateTime bDate = b.pickupTime ?? b.createdAt;
      return bDate.compareTo(aDate);
    });
    
    // Récupérer les derniers paiements
    final recentPayments = paymentState.transactions?.take(3).toList() ?? [];
    
    // Ajouter les livraisons terminées
    if (completedDeliveries.isNotEmpty) {
      final delivery = completedDeliveries.first;
      final timeAgo = _formatTimeAgo(delivery.deliveryTime ?? delivery.createdAt);
      activities.add(_buildActivityCard(
        icon: Icons.check_circle,
        title: 'Livraison terminée',
        subtitle: timeAgo,
        color: AppColors.green,
        onTap: () => Navigator.pushNamed(context, '/deliveries'),
      ));
      activities.add(const SizedBox(height: AppSpacing.md));
    }
    
    // Ajouter les livraisons actives
    if (activeDeliveries.isNotEmpty) {
      final delivery = activeDeliveries.first;
      final timeAgo = _formatTimeAgo(delivery.pickupTime ?? delivery.createdAt);
      activities.add(_buildActivityCard(
        icon: Icons.local_shipping,
        title: delivery.status == 'picked_up' ? 'Livraison en cours' : 'Nouvelle course assignée',
        subtitle: timeAgo,
        color: AppColors.blue,
        onTap: () => Navigator.pushNamed(context, '/deliveries'),
      ));
      activities.add(const SizedBox(height: AppSpacing.md));
    }
    
    // Ajouter les paiements récents
    if (recentPayments.isNotEmpty) {
      final payment = recentPayments.first;
      final timeAgo = _formatTimeAgo(payment.createdAt);
      activities.add(_buildActivityCard(
        icon: Icons.attach_money,
        title: 'Paiement reçu',
        subtitle: timeAgo,
        color: AppColors.green,
        onTap: () => Navigator.pushNamed(context, '/earnings'),
      ));
      activities.add(const SizedBox(height: AppSpacing.md));
    }
    
    // Si aucune activité
    if (activities.isEmpty) {
      activities.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Text(
              'Aucune activité récente',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }
    
    return activities;
  }

  /// Carte d'activité
  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return ActivityCard(
      icon: icon,
      title: title,
      subtitle: subtitle,
      color: color,
      onTap: onTap,
    );
  }

  /// Écran d'attente pour les chauffeurs non vérifiés
  Widget _buildWaitingScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Compte en attente'),
        backgroundColor: AppColors.surface,
        elevation: 0,
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
                
                // Bouton pour vérifier le statut
                SizedBox(
                  width: double.infinity,
                  child: ModernButton(
                    text: 'Vérifier le statut',
                    onPressed: () {
                      ref.invalidate(driverProvider);
                    },
                    variant: ButtonVariant.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
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
    return VerificationStep(
      number: number,
      title: title,
      status: status,
      isCompleted: isCompleted,
    );
  }
}
