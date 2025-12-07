import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/backend_constants.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/delivery_provider.dart';
import '../../../../data/providers/driver_provider.dart';
import '../../../../data/providers/delivery_provider.dart' as dp;
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
  bool _isLoadingAvailable = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Load deliveries on init with error handling
    Future.microtask(() async {
      try {
        // Vérifier si l'utilisateur est connecté avant de charger
        final authState = ref.read(authProvider);
        if (authState.isLoggedIn) {
          await ref.read(deliveryProvider.notifier).loadMyDeliveries();
          // Charger aussi les livraisons disponibles via le provider dédié
          await ref.read(dp.availableDeliveriesNotifierProvider.notifier).load();
        } else {
          // Si pas connecté, rediriger vers login
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        }
      } catch (e) {
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
            _selectedStatus = 'available'; // Livraisons disponibles à accepter
            _loadAvailableDeliveries();
            break;
          case 2:
            // In progress = assigned, pickup in progress, picked up, or in transit
            _selectedStatus = 'in_progress_group';
            break;
          case 3:
            // Completed = delivered
            _selectedStatus = BackendConstants.deliveryStatusDelivered;
            break;
          case 4:
            // Historique = annulées
            _selectedStatus = BackendConstants.deliveryStatusCancelled;
            break;
        }
      });
    }
  }

  Future<void> _loadAvailableDeliveries() async {
    if (_isLoadingAvailable) return;
    setState(() => _isLoadingAvailable = true);
    try {
      await ref.read(dp.availableDeliveriesNotifierProvider.notifier).load();
    } finally {
      if (mounted) setState(() => _isLoadingAvailable = false);
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
    
    // Livraisons disponibles à accepter (filtre spécial)
    if (_selectedStatus == 'available') {
      // Les livraisons disponibles sont déjà chargées via loadAvailableDeliveries
      return deliveries.where((d) => 
        d.status == BackendConstants.deliveryStatusPending
      ).toList();
    }
    
    // Handle in_progress group (multiple statuses)
    if (_selectedStatus == 'in_progress_group') {
      return deliveries.where((d) => 
        d.status == BackendConstants.deliveryStatusInProgress
      ).toList();
    }
    
    // Single status filter
    return deliveries.where((d) => d.status == _selectedStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    final deliveryState = ref.watch(deliveryProvider);
    final availableState = ref.watch(dp.availableDeliveriesNotifierProvider);
    final availableDeliveries = ref.watch(dp.availableDeliveriesProvider);
    final activeDeliveryCount = ref.watch(activeDeliveryCountProvider);
    final driver = ref.watch(currentDriverProvider);
    
    // Combiner les livraisons selon l'onglet sélectionné
    final allDeliveries = _selectedStatus == 'available' 
        ? availableDeliveries 
        : deliveryState.deliveries;
    
    final isLoading = _selectedStatus == 'available' 
        ? availableState.isLoading 
        : deliveryState.isLoading;

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
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTypography.label.copyWith(fontWeight: FontWeight.bold),
          unselectedLabelStyle: AppTypography.label,
          tabs: const [
            Tab(text: 'Toutes'),
            Tab(text: 'Disponibles'),
            Tab(text: 'En cours'),
            Tab(text: 'Terminées'),
            Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: isLoading && allDeliveries.isEmpty
          ? const LoadingWidget(message: 'Chargement des livraisons...')
          : (deliveryState.error != null || availableState.error != null) && allDeliveries.isEmpty
              ? ErrorDisplayWidget(
                  message: deliveryState.error ?? availableState.error ?? 'Erreur inconnue',
                  onRetry: _selectedStatus == 'available' 
                      ? _loadAvailableDeliveries 
                      : _refreshDeliveries,
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final filteredDeliveries = _filterDeliveries(allDeliveries);
                    
                    // Si liste vide
                    if (filteredDeliveries.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _selectedStatus == 'available' 
                            ? _loadAvailableDeliveries 
                            : _refreshDeliveries,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Center(
                              child: _selectedStatus == 'available'
                                  ? const _EmptyAvailableWidget()
                                  : const EmptyDeliveriesWidget(),
                            ),
                          ),
                        ),
                      );
                    }

                    // Liste avec livraisons
                    return RefreshIndicator(
                      onRefresh: _selectedStatus == 'available' 
                          ? _loadAvailableDeliveries 
                          : _refreshDeliveries,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          // Info banner pour livraisons disponibles
                          if (_selectedStatus == 'available')
                            SliverToBoxAdapter(
                              child: Container(
                                margin: const EdgeInsets.all(AppSpacing.md),
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: AppColors.info),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        'Ces livraisons sont disponibles dans votre zone. Cliquez pour accepter.',
                                        style: AppTypography.bodySmall.copyWith(
                                          color: AppColors.info,
                                        ),
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
                                    merchantName: delivery.merchant?['name'] ?? 'Client',
                                    pickupAddress: delivery.pickupAddress,
                                    deliveryAddress: delivery.deliveryAddress,
                                    status: delivery.status,
                                    amount: delivery.price.toString(),
                                    distance: delivery.distanceKm.toString(),
                                    onTap: () => _navigateToDetails(delivery),
                                    showAcceptButton: _selectedStatus == 'available',
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

/// Widget affiché quand il n'y a pas de livraisons disponibles
class _EmptyAvailableWidget extends StatelessWidget {
  const _EmptyAvailableWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off,
          size: 80,
          color: AppColors.textSecondary.withOpacity(0.5),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Aucune livraison disponible',
          style: AppTypography.h4.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Text(
            'Les nouvelles livraisons dans votre zone apparaitront ici. Tirez vers le bas pour actualiser.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ),
      ],
    );
  }
}
