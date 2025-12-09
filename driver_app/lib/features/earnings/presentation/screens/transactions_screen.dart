// lib/features/earnings/presentation/screens/transactions_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/payment_provider.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_radius.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../widgets/transaction_card.dart';

/// Écran affichant l'historique complet des transactions avec filtres
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  // Filtres
  String? _selectedType; // collection, disbursement, refund
  String? _selectedStatus; // success, failed, pending

  @override
  void initState() {
    super.initState();
    // Charger les transactions au démarrage
    Future.microtask(() => _loadTransactions());
    
    // Pagination au scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    await ref.read(paymentProvider.notifier).loadTransactions(
      page: 1,
      transactionType: _selectedType,
      status: _selectedStatus,
    );
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    
    final state = ref.read(paymentProvider);
    if (!state.hasMore) return;

    setState(() => _isLoadingMore = true);
    
    await ref.read(paymentProvider.notifier).loadTransactions(
      page: state.currentPage + 1,
      transactionType: _selectedType,
      status: _selectedStatus,
    );
    
    setState(() => _isLoadingMore = false);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _applyFilters({String? type, String? status}) {
    setState(() {
      _selectedType = type;
      _selectedStatus = status;
    });
    _loadTransactions();
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedStatus = null;
    });
    _loadTransactions();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterSheet(
        selectedType: _selectedType,
        selectedStatus: _selectedStatus,
        onApply: (type, status) {
          _applyFilters(type: type, status: status);
          Navigator.pop(context);
        },
        onClear: () {
          _clearFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final transactions = paymentState.transactions ?? [];

    if (paymentState.isLoadingTransactions && transactions.isEmpty) {
      return const Scaffold(
        body: LoadingWidget(message: 'Chargement des transactions...'),
      );
    }

    if (paymentState.error != null && transactions.isEmpty) {
      return Scaffold(
        body: ErrorDisplayWidget(
          message: paymentState.error!,
          onRetry: _loadTransactions,
        ),
      );
    }

    // Calculer les stats
    final totalAmount = transactions.fold<double>(
      0,
      (sum, t) => sum + (t.transactionType == 'collection' ? t.amount : -t.amount),
    );
    final successCount = transactions.where((t) => t.status == 'success').length;
    final failedCount = transactions.where((t) => t.status == 'failed').length;
    final pendingCount = transactions.where((t) => t.status == 'pending').length;

    final hasActiveFilters = _selectedType != null || _selectedStatus != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique Transactions'),
        centerTitle: true,
        actions: [
          // Bouton filtres
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterSheet,
              ),
              if (hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: transactions.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadTransactions,
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
                            'Solde net',
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '${totalAmount >= 0 ? '+' : ''}${totalAmount.toStringAsFixed(0)} FCFA',
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
                                label: 'Réussies',
                                value: '$successCount',
                                color: AppColors.success,
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white24,
                              ),
                              _StatItem(
                                icon: Icons.error,
                                label: 'Échouées',
                                value: '$failedCount',
                                color: AppColors.error,
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
                                color: AppColors.warning,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Active Filters
                  if (hasActiveFilters)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        child: Wrap(
                          spacing: AppSpacing.sm,
                          children: [
                            if (_selectedType != null)
                              Chip(
                                label: Text(_getTypeLabel(_selectedType!)),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () => _applyFilters(status: _selectedStatus),
                              ),
                            if (_selectedStatus != null)
                              Chip(
                                label: Text(_getStatusLabel(_selectedStatus!)),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () => _applyFilters(type: _selectedType),
                              ),
                            TextButton.icon(
                              onPressed: _clearFilters,
                              icon: const Icon(Icons.clear_all, size: 16),
                              label: const Text('Effacer tout'),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Liste des transactions
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= transactions.length) {
                            return _isLoadingMore
                                ? const Padding(
                                    padding: EdgeInsets.all(AppSpacing.lg),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          }

                          final transaction = transactions[index];
                          return TransactionCard(
                            transaction: transaction,
                            onTap: () => _showTransactionDetails(transaction),
                          );
                        },
                        childCount: transactions.length + 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilters = _selectedType != null || _selectedStatus != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.receipt_long_outlined,
              size: 100,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              hasFilters ? 'Aucun résultat' : 'Aucune transaction',
              style: AppTypography.h3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hasFilters
                  ? 'Essayez de modifier vos filtres'
                  : 'Vos transactions apparaîtront ici',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Effacer les filtres'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showTransactionDetails(TransactionHistoryModel transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TransactionDetailsSheet(transaction: transaction),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'collection':
        return 'Paiement reçu';
      case 'disbursement':
        return 'Versement';
      case 'refund':
        return 'Remboursement';
      default:
        return type;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'success':
        return 'Réussi';
      case 'failed':
        return 'Échoué';
      case 'pending':
        return 'En attente';
      default:
        return status;
    }
  }
}

/// Widget pour afficher un stat item
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final statColor = color ?? Colors.white;

    return Column(
      children: [
        Icon(
          icon,
          color: statColor.withValues(alpha: 0.9),
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

/// Bottom sheet pour les filtres
class _FilterSheet extends StatefulWidget {
  final String? selectedType;
  final String? selectedStatus;
  final Function(String?, String?) onApply;
  final VoidCallback onClear;

  const _FilterSheet({
    this.selectedType,
    this.selectedStatus,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _type;
  String? _status;

  @override
  void initState() {
    super.initState();
    _type = widget.selectedType;
    _status = widget.selectedStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                      'Filtrer les transactions',
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

            // Filters
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type de transaction
                  Text(
                    'Type de transaction',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      _FilterChip(
                        label: 'Tous',
                        isSelected: _type == null,
                        onTap: () => setState(() => _type = null),
                      ),
                      _FilterChip(
                        label: 'Paiement reçu',
                        isSelected: _type == 'collection',
                        onTap: () => setState(() => _type = 'collection'),
                      ),
                      _FilterChip(
                        label: 'Versement',
                        isSelected: _type == 'disbursement',
                        onTap: () => setState(() => _type = 'disbursement'),
                      ),
                      _FilterChip(
                        label: 'Remboursement',
                        isSelected: _type == 'refund',
                        onTap: () => setState(() => _type = 'refund'),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Statut
                  Text(
                    'Statut',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      _FilterChip(
                        label: 'Tous',
                        isSelected: _status == null,
                        onTap: () => setState(() => _status = null),
                      ),
                      _FilterChip(
                        label: 'Réussi',
                        isSelected: _status == 'success',
                        color: AppColors.success,
                        onTap: () => setState(() => _status = 'success'),
                      ),
                      _FilterChip(
                        label: 'Échoué',
                        isSelected: _status == 'failed',
                        color: AppColors.error,
                        onTap: () => setState(() => _status = 'failed'),
                      ),
                      _FilterChip(
                        label: 'En attente',
                        isSelected: _status == 'pending',
                        color: AppColors.warning,
                        onTap: () => setState(() => _status = 'pending'),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Boutons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onClear,
                          child: const Text('Effacer'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => widget.onApply(_type, _status),
                          child: const Text('Appliquer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip pour les filtres
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected ? chipColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? chipColor : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet pour afficher les détails d'une transaction
class _TransactionDetailsSheet extends StatelessWidget {
  final TransactionHistoryModel transaction;

  const _TransactionDetailsSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
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
                        'Détails de la transaction',
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
                    TransactionCard(transaction: transaction),

                    const SizedBox(height: AppSpacing.lg),

                    // Détails supplémentaires
                    _DetailRow(
                      label: 'ID Transaction',
                      value: transaction.id,
                    ),
                    if (transaction.externalReference != null)
                      _DetailRow(
                        label: 'Référence externe',
                        value: transaction.externalReference!,
                      ),
                    _DetailRow(
                      label: 'Devise',
                      value: transaction.currency,
                    ),
                    if (transaction.metadata != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Métadonnées',
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          transaction.metadata.toString(),
                          style: AppTypography.bodySmall.copyWith(
                            fontFamily: 'monospace',
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

/// Widget pour afficher une ligne de détail
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
