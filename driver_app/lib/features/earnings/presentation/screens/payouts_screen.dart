// lib/features/earnings/presentation/screens/payouts_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/payment_provider.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_radius.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../widgets/payout_card.dart';

/// Écran affichant l'historique des versements quotidiens automatiques (23:59)
class PayoutsScreen extends ConsumerStatefulWidget {
  const PayoutsScreen({super.key});

  @override
  ConsumerState<PayoutsScreen> createState() => _PayoutsScreenState();
}

class _PayoutsScreenState extends ConsumerState<PayoutsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    // Charger les payouts au démarrage
    Future.microtask(() => _loadPayouts());
    
    // Pagination au scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPayouts() async {
    await ref.read(paymentProvider.notifier).loadPayouts(page: 1);
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    
    final state = ref.read(paymentProvider);
    if (!state.hasMore) return;

    setState(() => _isLoadingMore = true);
    
    await ref.read(paymentProvider.notifier).loadPayouts(
      page: state.currentPage + 1,
    );
    
    setState(() => _isLoadingMore = false);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _showPayoutDetails(DailyPayoutModel payout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PayoutDetailsSheet(payout: payout),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final payouts = paymentState.payouts ?? [];

    if (paymentState.isLoadingPayouts && payouts.isEmpty) {
      return const Scaffold(
        body: LoadingWidget(message: 'Chargement des versements...'),
      );
    }

    if (paymentState.error != null && payouts.isEmpty) {
      return Scaffold(
        body: ErrorDisplayWidget(
          message: paymentState.error!,
          onRetry: _loadPayouts,
        ),
      );
    }

    if (payouts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Historique Versements'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 100,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Aucun versement',
                style: AppTypography.h3.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'Les paiements sont automatiquement versés\nchaque jour à 23h59',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Calculer les stats des payouts
    final totalAmount = payouts.fold<double>(
      0,
      (sum, payout) => sum + payout.totalAmount,
    );
    final completedCount = payouts.where((p) => p.status == 'completed').length;
    final pendingCount = payouts.where((p) => p.status == 'pending' || p.status == 'processing').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique Versements'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPayouts,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Header Stats
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    Text(
                      'Total versé',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${totalAmount.toStringAsFixed(0)} FCFA',
                      style: AppTypography.h1.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          icon: Icons.check_circle,
                          label: 'Complétés',
                          value: '$completedCount',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white24,
                        ),
                        _StatItem(
                          icon: Icons.pending,
                          label: 'En attente',
                          value: '$pendingCount',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white24,
                        ),
                        _StatItem(
                          icon: Icons.receipt_long,
                          label: 'Total',
                          value: '${payouts.length}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Info banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 24.0,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Versements automatiques quotidiens à 23h59',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Liste des payouts
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= payouts.length) {
                      // Loading indicator pour pagination
                      return _isLoadingMore
                          ? const Padding(
                              padding: EdgeInsets.all(AppSpacing.lg),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : const SizedBox.shrink();
                    }

                    final payout = payouts[index];
                    return PayoutCard(
                      payout: payout,
                      onTap: () => _showPayoutDetails(payout),
                    );
                  },
                  childCount: payouts.length + 1, // +1 pour le loading indicator
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour afficher un stat item dans le header
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 24.0,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet pour afficher les détails d'un payout
class _PayoutDetailsSheet extends StatelessWidget {
  final DailyPayoutModel payout;

  const _PayoutDetailsSheet({required this.payout});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Détails du versement',
                        style: AppTypography.h2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    // Payout info card
                    PayoutCard(payout: payout),

                    const SizedBox(height: AppSpacing.lg),

                    // Liste des paiements inclus
                    if (payout.payments.isNotEmpty) ...[
                      Text(
                        'Paiements inclus (${payout.payments.length})',
                        style: AppTypography.h3,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      
                      ...payout.payments.map((payment) => Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: Text(
                              payment.paymentMethodIcon,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          title: Text(
                            '${payment.driverAmount.toStringAsFixed(0)} FCFA',
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            payment.paymentMethodLabel,
                            style: AppTypography.caption,
                          ),
                          trailing: Text(
                            payment.statusLabel,
                            style: AppTypography.caption.copyWith(
                              color: payment.status == 'completed'
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      )),
                    ] else ...[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            'Détails des paiements non disponibles',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
