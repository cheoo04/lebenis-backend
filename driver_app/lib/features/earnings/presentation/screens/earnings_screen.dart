import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/payment_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/utils/formatters.dart';
import '../widgets/stats_card.dart';
import '../widgets/earnings_chart.dart';
import 'payouts_screen.dart';
import 'transactions_screen.dart';

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  String _selectedPeriod = 'week';

  @override
  void initState() {
    super.initState();
    // Charger les données après le build
    Future.microtask(() => _loadEarnings());
  }

  Future<void> _loadEarnings() async {
    // Charger earnings, stats et payouts
    await ref.read(paymentProvider.notifier).loadAll(period: _selectedPeriod);
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'today':
        return 'Aujourd\'hui';
      case 'week':
        return 'Derniers 7 jours';
      case 'month':
        return 'Ce mois';
      default:
        return '';
    }
  }

  List<EarningsData> _generateChartData() {
    final paymentState = ref.read(paymentProvider);
    final payments = paymentState.earningsPayments ?? [];
    
    if (payments.isEmpty) {
      // Retourner des données vides (pas de factices)
      return [];
    }
    
    // Grouper par jour pour le graphique
    final Map<String, double> dailyAmounts = {};
    
    for (final payment in payments) {
      final dateKey = '${payment.createdAt.year}-${payment.createdAt.month.toString().padLeft(2, '0')}-${payment.createdAt.day.toString().padLeft(2, '0')}';
      dailyAmounts[dateKey] = (dailyAmounts[dateKey] ?? 0) + payment.driverAmount;
    }
    
    // Convertir en liste triée
    final sortedEntries = dailyAmounts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    return sortedEntries.map((entry) {
      final date = DateTime.parse(entry.key);
      return EarningsData(
        label: _formatDateLabel(date),
        amount: entry.value,
        date: date,
      );
    }).toList();
  }

  String _formatDateLabel(DateTime date) {
    if (_selectedPeriod == 'week' || _selectedPeriod == 'today') {
      return _getWeekdayLabel(date.weekday);
    } else {
      return '${date.day}';
    }
  }

  String _getWeekdayLabel(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }

  Color _getPayoutStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'processing':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      case 'pending':
        return AppColors.info;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getPayoutStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'processing':
        return Icons.hourglass_empty;
      case 'failed':
        return Icons.error;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help_outline;
    }
  }

  String _formatPayoutDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final payoutDay = DateTime(date.year, date.month, date.day);

    if (payoutDay == today) {
      return 'Aujourd\'hui';
    } else if (payoutDay == yesterday) {
      return 'Hier';
    } else {
      final diff = today.difference(payoutDay).inDays;
      if (diff < 7) {
        return 'Il y a $diff jours';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final earnings = paymentState.earnings;
    final stats = paymentState.stats;

    if (paymentState.isLoading && earnings == null) {
      return const Scaffold(
        body: LoadingWidget(message: 'Chargement des données...'),
      );
    }

    if (paymentState.error != null && earnings == null) {
      return Scaffold(
        body: ErrorDisplayWidget(
          message: paymentState.error!,
          onRetry: _loadEarnings,
        ),
      );
    }

    // Extraire les données Phase 2
    final totalEarnings = double.tryParse(earnings?['total_driver_amount']?.toString() ?? '0') ?? 0.0;
    final paymentCount = int.tryParse(earnings?['payment_count']?.toString() ?? '0') ?? 0;
    
    // Stats lifetime depuis le nouveau endpoint
    final lifetimeData = stats?['lifetime'] as Map<String, dynamic>?;
    final totalLifetime = double.tryParse(lifetimeData?['total_earned']?.toString() ?? '0') ?? 0.0;
    final totalPayments = int.tryParse(lifetimeData?['total_payments']?.toString() ?? '0') ?? 0;
    final averagePerPayment = double.tryParse(lifetimeData?['average_per_payment']?.toString() ?? '0') ?? 0.0;
    
    // Payment methods breakdown
    final paymentMethods = stats?['payment_methods'] as Map<String, dynamic>?;
    final orangeCount = int.tryParse(paymentMethods?['orange_money']?.toString() ?? '0') ?? 0;
    final mtnCount = int.tryParse(paymentMethods?['mtn_momo']?.toString() ?? '0') ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Gains'),
        centerTitle: true,
        actions: [
          // Bouton transactions
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Transactions',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionsScreen(),
                ),
              );
            },
          ),
          // Bouton historique des versements
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historique versements',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PayoutsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadEarnings,
        child: ListView(
          padding: const EdgeInsets.all(Dimensions.pagePadding),
          children: [
            // Summary Card
            EarningsSummaryCard(
              totalEarnings: totalEarnings,
              totalDeliveries: paymentCount,
              averagePerDelivery: paymentCount > 0 ? totalEarnings / paymentCount : 0.0,
              period: _getPeriodLabel(),
            ),

            const SizedBox(height: Dimensions.spacingL),

            // Period Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.spacingS),
                child: Row(
                  children: [
                    Expanded(
                      child: _PeriodChip(
                        label: 'Aujourd\'hui',
                        isSelected: _selectedPeriod == 'today',
                        onTap: () {
                          setState(() => _selectedPeriod = 'today');
                          _loadEarnings();
                        },
                      ),
                    ),
                    const SizedBox(width: Dimensions.spacingS),
                    Expanded(
                      child: _PeriodChip(
                        label: 'Semaine',
                        isSelected: _selectedPeriod == 'week',
                        onTap: () {
                          setState(() => _selectedPeriod = 'week');
                          _loadEarnings();
                        },
                      ),
                    ),
                    const SizedBox(width: Dimensions.spacingS),
                    Expanded(
                      child: _PeriodChip(
                        label: 'Mois',
                        isSelected: _selectedPeriod == 'month',
                        onTap: () {
                          setState(() => _selectedPeriod = 'month');
                          _loadEarnings();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: Dimensions.spacingL),

            // Chart
            EarningsChart(
              data: _generateChartData(),
              period: _getPeriodLabel(),
            ),

            const SizedBox(height: Dimensions.spacingL),

            // Stats Grid
            Text(
              'Statistiques (Lifetime)',
              style: TextStyles.h3,
            ),
            const SizedBox(height: Dimensions.spacingM),

            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Total gagné',
                    value: Formatters.formatPrice(totalLifetime),
                    icon: Icons.monetization_on,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: Dimensions.spacingM),
                Expanded(
                  child: StatsCard(
                    title: 'Paiements',
                    value: '$totalPayments',
                    icon: Icons.payment,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),

            const SizedBox(height: Dimensions.spacingM),

            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Moyenne',
                    value: Formatters.formatPrice(averagePerPayment),
                    icon: Icons.analytics,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: Dimensions.spacingM),
                Expanded(
                  child: StatsCard(
                    title: 'Orange Money',
                    value: '$orangeCount',
                    subtitle: 'paiements',
                    icon: Icons.smartphone,
                    color: const Color(0xFFFF7900), // Orange color
                  ),
                ),
              ],
            ),

            const SizedBox(height: Dimensions.spacingM),

            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'MTN MoMo',
                    value: '$mtnCount',
                    subtitle: 'paiements',
                    icon: Icons.phone_android,
                    color: const Color(0xFFFFCC00), // MTN yellow
                  ),
                ),
                const SizedBox(width: Dimensions.spacingM),
                // Espace pour un futur stat
                const Expanded(
                  child: SizedBox(),
                ),
              ],
            ),

            const SizedBox(height: Dimensions.spacingXL),

            // Derniers versements
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Derniers versements',
                  style: TextStyles.h3,
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PayoutsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Voir tout'),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.spacingM),

            // Afficher les 3 derniers payouts
            if (paymentState.payouts != null && paymentState.payouts!.isNotEmpty) ...[
              ...paymentState.payouts!.take(3).map((payout) => Card(
                margin: const EdgeInsets.only(bottom: Dimensions.spacingM),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getPayoutStatusColor(payout.status).withValues(alpha: 0.1),
                    child: Icon(
                      _getPayoutStatusIcon(payout.status),
                      color: _getPayoutStatusColor(payout.status),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    Formatters.formatPrice(payout.totalAmount),
                    style: TextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${payout.paymentCount} paiements • ${_formatPayoutDate(payout.payoutDate)}',
                    style: TextStyles.caption,
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPayoutStatusColor(payout.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      payout.statusLabel,
                      style: TextStyles.caption.copyWith(
                        color: _getPayoutStatusColor(payout.status),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PayoutsScreen(),
                      ),
                    );
                  },
                ),
              )),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.cardPadding),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 48,
                          color: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: Dimensions.spacingM),
                        Text(
                          'Aucun versement pour le moment',
                          style: TextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: Dimensions.spacingXL),

            // Note
            Container(
              padding: const EdgeInsets.all(Dimensions.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimensions.radiusM),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: Dimensions.iconM,
                  ),
                  const SizedBox(width: Dimensions.spacingM),
                  Expanded(
                    child: Text(
                      'Les paiements sont regroupés et versés automatiquement chaque jour à 23h59.',
                      style: TextStyles.bodySmall.copyWith(
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
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusS),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: Dimensions.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(Dimensions.radiusS),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
