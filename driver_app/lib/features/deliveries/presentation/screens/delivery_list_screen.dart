import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/backend_constants.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/delivery_provider.dart';
import '../../../../data/providers/driver_provider.dart';
import '../../../../data/models/delivery_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_radius.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../widgets/modern_delivery_card.dart';

class DeliveryListScreen extends ConsumerStatefulWidget {
  const DeliveryListScreen({super.key});

  @override
  ConsumerState<DeliveryListScreen> createState() => _DeliveryListScreenState();
}

class _DeliveryListScreenState extends ConsumerState<DeliveryListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Load deliveries on init with error handling
    Future.microtask(() async {
      try {
        // Vérifier si l'utilisateur est connecté avant de charger
        final authState = ref.read(authProvider);
        if (authState.isLoggedIn) {
          await ref.read(deliveryProvider.notifier).loadMyDeliveries();
        } else {
          // Si pas connecté, rediriger vers login
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      } catch (e) {
        debugPrint('Error loading deliveries: $e');
        // Si erreur d'authentification, rediriger vers login
        if (e.toString().contains('Token invalide') || 
            e.toString().contains('token_not_valid') ||
            e.toString().contains('401')) {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      }
    });
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedStatus = 'all';
            break;
          case 1:
            // Pending = awaiting assignment or just assigned
            _selectedStatus = BackendConstants.deliveryStatusPendingAssignment;
            break;
          case 2:
            // In progress = assigned, pickup in progress, picked up, or in transit
            _selectedStatus = 'in_progress_group';
            break;
          case 3:
            // Completed = delivered
            _selectedStatus = BackendConstants.deliveryStatusDelivered;
            break;
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refreshDeliveries() async {
    await ref.read(deliveryProvider.notifier).loadMyDeliveries();
  }

  void _navigateToDetails(DeliveryModel delivery) {
    Navigator.of(context).pushNamed(
      '/delivery-details',
      arguments: delivery,
    );
  }

  List<DeliveryModel> _filterDeliveries(List<DeliveryModel> deliveries) {
    if (_selectedStatus == 'all') {
      return deliveries;
    }
    
    // Handle in_progress group (multiple statuses)
    if (_selectedStatus == 'in_progress_group') {
      return deliveries.where((d) => 
        d.status == BackendConstants.deliveryStatusAssigned ||
        d.status == BackendConstants.deliveryStatusPickupInProgress ||
        d.status == BackendConstants.deliveryStatusPickedUp ||
        d.status == BackendConstants.deliveryStatusInTransit
      ).toList();
    }
    
    // Single status filter
    return deliveries.where((d) => d.status == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final deliveryState = ref.watch(deliveryProvider);
    final activeDeliveryCount = ref.watch(activeDeliveryCountProvider);
    final driver = ref.watch(currentDriverProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Livraisons'),
        centerTitle: true,
        actions: [
          if (activeDeliveryCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: StatusChip(
                  label: '$activeDeliveryCount',
                  color: AppColors.orange,
                  icon: Icons.local_shipping_outlined,
                ),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTypography.label.copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: AppTypography.label,
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'En attente'),
            Tab(text: 'En cours'),
            Tab(text: 'Terminées'),
          ],
        ),
      ),
      body: deliveryState.isLoading && deliveryState.deliveries.isEmpty
          ? const LoadingWidget(message: 'Chargement des livraisons...')
          : deliveryState.error != null && deliveryState.deliveries.isEmpty
              ? ErrorDisplayWidget(
                  message: deliveryState.error!,
                  onRetry: _refreshDeliveries,
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final filteredDeliveries = _filterDeliveries(deliveryState.deliveries);
                    
                    // Si liste vide
                    if (filteredDeliveries.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _refreshDeliveries,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              children: [
                                // Message si driver non vérifié
                                if (driver != null && !driver.isVerified)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    margin: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
                                    decoration: BoxDecoration(
                                      color: AppColors.orange.withValues(alpha: 0.1),
                                      border: Border.all(color: AppColors.orange, width: 1),
                                      borderRadius: BorderRadius.circular(AppRadius.md),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: AppColors.orange,
                                          size: 24,
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Compte en attente de vérification',
                                                style: AppTypography.label.copyWith(
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: AppSpacing.xs),
                                              Text(
                                                'Votre compte sera activé prochainement. Vous pourrez accepter des livraisons une fois vérifié.',
                                                style: AppTypography.caption.copyWith(
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                
                                // État vide centré
                                const Center(
                                  child: EmptyDeliveriesWidget(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    // Liste avec livraisons
                    return RefreshIndicator(
                      onRefresh: _refreshDeliveries,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          // Message de vérification
                          if (driver != null && !driver.isVerified)
                            SliverToBoxAdapter(
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(AppSpacing.md),
                                margin: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
                                decoration: BoxDecoration(
                                  color: AppColors.orange.withValues(alpha: 0.1),
                                  border: Border.all(color: AppColors.orange, width: 1),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: AppColors.orange,
                                      size: 24,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Compte en attente de vérification',
                                            style: AppTypography.label.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpacing.xs),
                                          Text(
                                            'Votre compte sera activé prochainement. Vous pourrez accepter des livraisons une fois vérifié.',
                                            style: AppTypography.caption.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          
                          // Liste des livraisons
                          SliverPadding(
                            padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final delivery = filteredDeliveries[index];
                                  return ModernDeliveryCard(
                                    deliveryId: delivery.id,
                                    merchantName: delivery.merchant?['name'] ?? 'Marchand inconnu',
                                    pickupAddress: delivery.pickupAddress,
                                    deliveryAddress: delivery.deliveryAddress,
                                    status: delivery.status,
                                    amount: delivery.price.toString(),
                                    distance: delivery.distanceKm.toString(),
                                    onTap: () => _navigateToDetails(delivery),
                                  );
                                },
                                childCount: filteredDeliveries.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
