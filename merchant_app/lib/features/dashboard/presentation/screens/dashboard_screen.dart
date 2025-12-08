import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_theme.dart';
import '../../../../data/providers/merchant_provider.dart';
import '../../../../data/providers/user_profile_provider.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/models/merchant_model.dart';
import '../../../../data/models/individual_model.dart';
import '../../../../shared/widgets/modern_stat_card.dart';
import '../../../../shared/widgets/modern_info_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../deliveries/presentation/screens/delivery_list_screen.dart';
import '../../../deliveries/presentation/screens/create_delivery_screen.dart';
import '../../../profile/presentation/screens/edit_profile_screen.dart';
import '../../../profile/presentation/screens/edit_individual_profile_screen.dart';
import '../widgets/dashboard_app_bar.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/action_cards_grid.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les stats uniquement pour les merchants
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isMerchant = ref.read(isMerchantProvider);
      if (isMerchant) {
        ref.read(merchantStatsProvider.notifier).loadStats();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final isMerchant = ref.watch(isMerchantProvider);

    // Vérifier le statut de vérification
    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          // Vérifier si l'utilisateur est authentifié
          final authState = ref.watch(authStateProvider);
          final isAuthenticated = authState.value != null;
          
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text('Erreur: Profil non trouvé'),
                  const SizedBox(height: 8),
                  Text(
                    isAuthenticated 
                      ? 'Impossible de charger votre profil' 
                      : 'Session expirée',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (isAuthenticated) {
                        ref.read(userProfileProvider.notifier).loadProfile();
                      } else {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    child: Text(isAuthenticated ? 'Réessayer' : 'Se connecter'),
                  ),
                  if (isAuthenticated) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Se déconnecter'),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        
        // Cas merchant: vérifier le statut de vérification
        if (profile is MerchantModel) {
          if (!profile.isVerified) {
            return _buildWaitingScreen(context, profile);
          }
          return _buildDashboard(context, ref, profile);
        }
        
        // Cas particulier: dashboard simplifié
        return _buildIndividualDashboard(context, ref, profile);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erreur: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(userProfileProvider.notifier).loadProfile();
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingScreen(BuildContext context, merchant) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Compte'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_empty,
                  size: 50,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Compte en attente de vérification',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Votre compte est en cours de vérification par notre équipe. Vous recevrez une notification une fois approuvé.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/waiting-approval');
                },
                child: const Text('Voir les détails'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, profile) {
    final statsAsync = ref.watch(merchantStatsProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const DashboardAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(merchantProfileProvider.notifier).refresh();
          ref.invalidate(merchantStatsProvider);
        },
        color: AppTheme.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient
              DashboardHeader(
                name: profile.businessName,
                badge: StatusBadge.fromStatus(profile.verificationStatus),
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

                      const SizedBox(height: 16),

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

                      const SizedBox(height: 8),

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

                      const SizedBox(height: 8),

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

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, dynamic stats) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Adaptation selon la taille d'écran
    final crossAxisCount = screenWidth > 900 ? 4 : (screenWidth > 600 ? 3 : 2);
    final childAspectRatio = screenWidth > 600 ? 1.1 : 0.95;
    final spacing = screenWidth > 600 ? 12.0 : 10.0;
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 2;
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
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

  Widget _buildIndividualDashboard(BuildContext context, WidgetRef ref, dynamic profile) {
    // Gérer à la fois IndividualModel et Map
    final String fullName;
    if (profile is IndividualModel) {
      fullName = profile.fullName;
    } else if (profile is Map) {
      fullName = '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim();
    } else {
      fullName = 'Utilisateur';
    }
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const DashboardAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(userProfileProvider.notifier).refresh();
        },
        color: AppTheme.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with gradient
              DashboardHeader(
                name: fullName.isNotEmpty ? fullName : 'Utilisateur',
                badge: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white30, width: 1),
                  ),
                  child: const Text(
                    'Particulier',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Profile summary card for particulier (responsive)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(radius: 28, child: Icon(Icons.person_outline, size: 32)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fullName.isNotEmpty ? fullName : 'Utilisateur', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              if (profile is IndividualModel) ...[
                                Text(profile.email, style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(profile.phone ?? 'Téléphone non renseigné', style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(profile.address ?? 'Adresse non renseignée', style: const TextStyle(color: Colors.grey)),
                              ] else if (profile is Map) ...[
                                Text(profile['email'] ?? '', style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(profile['phone'] ?? 'Téléphone non renseigné', style: const TextStyle(color: Colors.grey)),
                              ] else ...[
                                const Text('Informations de profil indisponibles', style: TextStyle(color: Colors.grey)),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () {
                            if (profile is IndividualModel) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => EditIndividualProfileScreen(individual: profile)),
                              );
                            } else {
                              Navigator.pushNamed(context, '/profile');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Grid simple pour particulier
                      _buildIndividualStatsGrid(context),

                      const SizedBox(height: 16),

                      // Section Actions rapides
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

                      const SizedBox(height: 8),

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

                      const SizedBox(height: 8),

                      ModernInfoCard(
                        icon: Icons.edit,
                        title: 'Modifier mon profil',
                        subtitle: 'Informations personnelles',
                        iconColor: Colors.purple,
                        onTap: () {
                          if (profile is IndividualModel) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditIndividualProfileScreen(individual: profile),
                              ),
                            );
                          } else if (profile is Map) {
                            final firstName = profile['first_name'] ?? '';
                            final lastName = profile['last_name'] ?? '';
                            final individual = IndividualModel(
                              id: profile['id'] ?? '',
                              userId: profile['user'] ?? '',
                              firstName: firstName,
                              lastName: lastName,
                              email: profile['email'] ?? '',
                              phone: profile['phone'],
                              address: profile['address'],
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditIndividualProfileScreen(individual: individual),
                              ),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndividualStatsGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 4 : 2;
    final childAspectRatio = screenWidth > 600 ? 1.1 : 0.95;
    final spacing = screenWidth > 600 ? 12.0 : 10.0;
    
    // Stats simplifiées pour particulier (statiques pour l'instant)
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children: [
        ModernStatCard(
          title: 'Livraisons',
          value: '0',
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
          value: '0.0%',
          icon: Icons.check_circle,
          color: Colors.green,
          subtitle: 'Livraisons réussies',
        ),
        ModernStatCard(
          title: 'Dépenses',
          value: '0',
          icon: Icons.payments,
          color: Colors.orange,
          subtitle: 'FCFA',
        ),
        ModernStatCard(
          title: 'En cours',
          value: '0',
          icon: Icons.pending_actions,
          color: Colors.purple,
          subtitle: 'Livraisons actives',
        ),
      ],
    );
  }
}