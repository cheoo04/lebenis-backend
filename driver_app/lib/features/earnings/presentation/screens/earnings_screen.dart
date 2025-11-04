import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/driver_provider.dart';
import '../../../../data/models/driver_model.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/utils/formatters.dart';
import '../widgets/stats_card.dart';
import '../widgets/earnings_chart.dart';

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
    // Charger le profil ET les stats ET les earnings
    await Future.wait([
      ref.read(driverProvider.notifier).loadProfile(),
      ref.read(driverProvider.notifier).loadStats(),
      ref.read(driverProvider.notifier).loadEarnings(period: _getPeriodDays()),
    ]);
  }

  String _getPeriodDays() {
    switch (_selectedPeriod) {
      case 'week':
        return '7';
      case 'month':
        return '30';
      case 'year':
        return '365';
      default:
        return '30';
    }
  }

  List<EarningsData> _generateChartData() {
    final earningsState = ref.read(driverProvider).earnings;
    
    // Si on a des données du backend, les utiliser
    if (earningsState != null && earningsState['daily_breakdown'] != null) {
      final dailyData = earningsState['daily_breakdown'] as List;
      
      if (dailyData.isNotEmpty) {
        return dailyData.map((item) {
          final date = DateTime.parse(item['date']);
          final amount = double.tryParse(item['amount'].toString()) ?? 0.0;
          return EarningsData(
            label: _formatDateLabel(date),
            amount: amount,
            date: date,
          );
        }).toList();
      }
    }
    
    // Sinon, retourner des données vides (pas de factices)
    final now = DateTime.now();
    if (_selectedPeriod == 'week') {
      return List.generate(7, (index) {
        final date = now.subtract(Duration(days: 6 - index));
        return EarningsData(
          label: _getWeekdayLabel(date.weekday),
          amount: 0.0,
          date: date,
        );
      });
    } else if (_selectedPeriod == 'month') {
      return List.generate(4, (index) {
        final weekStart = now.subtract(Duration(days: (3 - index) * 7));
        return EarningsData(
          label: 'S${index + 1}',
          amount: 0.0,
          date: weekStart,
        );
      });
    } else {
      // year
      return List.generate(12, (index) {
        return EarningsData(
          label: _getMonthLabel(index + 1),
          amount: 0.0,
          date: DateTime(now.year, index + 1),
        );
      });
    }
  }

  String _formatDateLabel(DateTime date) {
    if (_selectedPeriod == 'week') {
      return _getWeekdayLabel(date.weekday);
    } else if (_selectedPeriod == 'month') {
      // Grouper par semaine
      return '${date.day}';
    } else {
      return _getMonthLabel(date.month);
    }
  }

  String _getWeekdayLabel(int weekday) {
    const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    return days[weekday - 1];
  }

  String _getMonthLabel(int month) {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return months[month - 1];
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'week':
        return 'Derniers 7 jours';
      case 'month':
        return 'Ce mois';
      case 'year':
        return 'Cette année';
      default:
        return '';
    }
  }

  String _getRatingValue(Map<String, dynamic>? stats, DriverModel? driver) {
    // Essayer d'obtenir le rating depuis les stats du backend
    if (stats != null) {
      final performanceData = stats['performance'] as Map<String, dynamic>?;
      if (performanceData != null && performanceData['rating'] != null) {
        final rating = double.tryParse(performanceData['rating'].toString()) ?? 0.0;
        return rating.toStringAsFixed(1);
      }
    }
    // Sinon utiliser le rating du driver
    return (driver?.rating ?? 0.0).toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final driverState = ref.watch(driverProvider);
    final driver = driverState.driver;
    final stats = driverState.stats;

    if (driverState.isLoading && driver == null) {
      return const Scaffold(
        body: LoadingWidget(message: 'Chargement des données...'),
      );
    }

    if (driverState.error != null && driver == null) {
      return Scaffold(
        body: ErrorDisplayWidget(
          message: driverState.error!,
          onRetry: _loadEarnings,
        ),
      );
    }

    // Extraire les données du backend
    final deliveriesData = stats?['deliveries'] as Map<String, dynamic>?;
    final earningsData = stats?['earnings'] as Map<String, dynamic>?;
    
    final totalEarnings = earningsData != null && earningsData['total_earned'] != null
        ? double.tryParse(earningsData['total_earned'].toString()) ?? 0.0
        : 0.0;
    final totalDeliveries = deliveriesData?['total_all_time'] as int? ?? 0;
    final completedDeliveries = deliveriesData?['delivered'] as int? ?? 0;
    final averagePerDelivery = completedDeliveries > 0 
        ? totalEarnings / completedDeliveries 
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Gains'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadEarnings,
        child: ListView(
          padding: const EdgeInsets.all(Dimensions.pagePadding),
          children: [
            // Summary Card
            EarningsSummaryCard(
              totalEarnings: totalEarnings,
              totalDeliveries: completedDeliveries,
              averagePerDelivery: averagePerDelivery,
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
                    const SizedBox(width: Dimensions.spacingS),
                    Expanded(
                      child: _PeriodChip(
                        label: 'Année',
                        isSelected: _selectedPeriod == 'year',
                        onTap: () {
                          setState(() => _selectedPeriod = 'year');
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
              'Statistiques',
              style: TextStyles.h3,
            ),
            const SizedBox(height: Dimensions.spacingM),

            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Total livraisons',
                    value: '$totalDeliveries',
                    icon: Icons.local_shipping,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: Dimensions.spacingM),
                Expanded(
                  child: StatsCard(
                    title: 'Terminées',
                    value: '$completedDeliveries',
                    icon: Icons.check_circle,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),

            const SizedBox(height: Dimensions.spacingM),

            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Gain moyen',
                    value: Formatters.formatPrice(averagePerDelivery),
                    icon: Icons.analytics,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: Dimensions.spacingM),
                Expanded(
                  child: StatsCard(
                    title: 'Note',
                    value: _getRatingValue(stats, driver),
                    icon: Icons.star,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),

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
                      'Les paiements sont effectués automatiquement chaque semaine sur votre compte bancaire.',
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
