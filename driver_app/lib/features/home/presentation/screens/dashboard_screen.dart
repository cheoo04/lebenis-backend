// lib/features/home/presentation/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../shared/widgets/modern_stat_card.dart';
import '../../../../shared/widgets/modern_card.dart';
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
      ref.read(driverProvider.notifier).loadStats();
      ref.read(driverProvider.notifier).loadEarnings();
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
                      'Bienvenue!',
                      style: AppTypography.h3,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Que souhaitez-vous faire aujourd\'hui?',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Statistiques en grille
                    _buildStatsGrid(driverState),

                    const SizedBox(height: AppSpacing.xxl),

                    // Section "Actions rapides"
                    Text(
                      'Actions rapides',
                      style: AppTypography.h4,
                    ),
                    const SizedBox(height: AppSpacing.md),

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

  Widget _buildStatsGrid(DriverState driverState) {
    final stats = driverState.stats;
    final earnings = driverState.earnings;
    
    // Extraire les stats
    final totalDeliveries = stats?['total_deliveries'] ?? 0;
    final completedDeliveries = stats?['completed_deliveries'] ?? 0;
    final averageRating = (stats?['average_rating'] ?? 0.0).toDouble();
    final todayEarnings = earnings?['today'] ?? 0.0;
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.2,
      children: [
        ModernStatCard(
          title: 'Courses totales',
          value: '$totalDeliveries',
          icon: Icons.local_shipping,
          color: AppColors.blue,
          subtitle: 'Total',
          onTap: () {
            Navigator.pushNamed(context, '/deliveries');
          },
        ),
        ModernStatCard(
          title: 'Terminées',
          value: '$completedDeliveries',
          icon: Icons.check_circle,
          color: AppColors.green,
          subtitle: 'Complétées',
        ),
        ModernStatCard(
          title: 'Note moyenne',
          value: averageRating.toStringAsFixed(1),
          icon: Icons.star,
          color: AppColors.orange,
          subtitle: '/5.0',
        ),
        ModernStatCard(
          title: 'Aujourd\'hui',
          value: '${todayEarnings.toStringAsFixed(0)}',
          icon: Icons.attach_money,
          color: AppColors.purple,
          subtitle: 'FCFA',
          onTap: () {
            Navigator.pushNamed(context, '/earnings');
          },
        ),
      ],
    );
  }

  /// Construire les activités récentes dynamiquement
  List<Widget> _buildRecentActivities(dynamic deliveryState, dynamic paymentState) {
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
}
