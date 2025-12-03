import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_theme.dart';
import '../../../../data/providers/merchant_provider.dart';
import '../../../../shared/widgets/modern_stat_card.dart';
import '../../../../shared/widgets/modern_info_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../deliveries/presentation/screens/delivery_list_screen.dart';
import '../../../deliveries/presentation/screens/create_delivery_screen.dart';
import '../../../profile/presentation/screens/edit_profile_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(merchantProfileProvider);
    final statsAsync = ref.watch(merchantStatsProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // ignore: unused_result
          ref.refresh(merchantProfileProvider);
          // ignore: unused_result
          ref.refresh(merchantStatsProvider);
        },
        color: AppTheme.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: profileAsync.when(
                  data: (profile) {
                    if (profile == null) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bienvenue,',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.businessName ?? 'Merchant',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        StatusBadge.fromStatus(profile.verificationStatus ?? 'pending'),
                      ],
                    );
                  },
                  loading: () => const SizedBox(height: 80),
                  error: (err, st) => const SizedBox(height: 80),
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Grid
                      statsAsync.when(
                        data: (stats) => _buildStatsGrid(context, stats),
                        loading: () => _buildLoadingGrid(),
                        error: (err, st) => _buildErrorCard(err.toString()),
                      ),

                      const SizedBox(height: 24),

                      // Quick Actions
                      const Text(
                        'Actions rapides',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),

                      ModernInfoCard(
                        icon: Icons.add_circle,
                        title: 'Créer une livraison',
                        subtitle: 'Nouvelle demande de livraison',
                        iconColor: AppTheme.primaryColor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CreateDeliveryScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      ModernInfoCard(
                        icon: Icons.list_alt,
                        title: 'Mes livraisons',
                        subtitle: 'Voir toutes les livraisons',
                        iconColor: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DeliveryListScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      ModernInfoCard(
                        icon: Icons.edit,
                        title: 'Modifier mon profil',
                        subtitle: 'Informations du commerce',
                        iconColor: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateDeliveryScreen()),
          );
        },
        backgroundColor: AppTheme.accentColor,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle livraison'),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, dynamic stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        ModernStatCard(
          title: 'Livraisons',
          value: '${stats.periodDeliveries ?? 0}',
          icon: Icons.local_shipping,
          color: Colors.blue,
          subtitle: 'Ce mois',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DeliveryListScreen()),
            );
          },
        ),
        ModernStatCard(
          title: 'Taux succès',
          value: '${(stats.successRate ?? 0).toStringAsFixed(1)}%',
          icon: Icons.check_circle,
          color: Colors.green,
          subtitle: 'Livraisons réussies',
        ),
        ModernStatCard(
          title: 'Revenus',
          value: '${(stats.totalRevenue ?? 0).toStringAsFixed(0)}',
          icon: Icons.attach_money,
          color: Colors.orange,
          subtitle: 'FCFA',
        ),
        ModernStatCard(
          title: 'En cours',
          value: '${stats.activeDeliveries ?? 0}',
          icon: Icons.pending_actions,
          color: Colors.purple,
          subtitle: 'Livraisons actives',
        ),
      ],
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: List.generate(
        4,
        (index) => Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Erreur de chargement',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red[800],
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