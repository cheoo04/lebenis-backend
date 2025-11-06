import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_provider.dart';
import '../widgets/stats_summary_cards.dart';
import '../widgets/timeline_chart.dart';
import '../widgets/peak_hours_chart.dart';
import '../widgets/status_distribution_chart.dart';
import '../widgets/earnings_breakdown_card.dart';
import '../widgets/date_range_selector.dart';
import 'heatmap_screen.dart';
import 'pdf_reports_screen.dart';

class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends ConsumerState<AnalyticsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load analytics on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalytics();
    });
  }

  void _loadAnalytics() {
    final dateRange = ref.read(dateRangeProvider);
    ref.read(analyticsProvider.notifier).refresh(dateRange);
  }

  Future<void> _handleRefresh() async {
    final dateRange = ref.read(dateRangeProvider);
    await ref.read(analyticsProvider.notifier).refresh(dateRange);
  }

  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(analyticsProvider);
    final dateRange = ref.watch(dateRangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PDFReportsScreen(),
                ),
              );
            },
            tooltip: 'PDF Reports',
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: analyticsState.heatmap != null &&
                    analyticsState.heatmap!.points.isNotEmpty
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HeatmapScreen(
                          heatmapPoints: analyticsState.heatmap!.points,
                        ),
                      ),
                    );
                  }
                : null,
            tooltip: 'View Heatmap',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: analyticsState.isLoading && analyticsState.summary == null
            ? const Center(child: CircularProgressIndicator())
            : analyticsState.error != null && analyticsState.summary == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          analyticsState.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAnalytics,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Date Range Selector
                        DateRangeSelector(
                          currentPeriod: dateRange.period,
                          startDate: dateRange.startDate,
                          endDate: dateRange.endDate,
                          onPeriodChanged: (period) {
                            ref
                                .read(dateRangeProvider.notifier)
                                .setPeriod(period);
                            _loadAnalytics();
                          },
                          onCustomRangeSelected: (start, end) {
                            ref
                                .read(dateRangeProvider.notifier)
                                .setCustomRange(start, end);
                            _loadAnalytics();
                          },
                        ),

                        // Loading indicator if refreshing
                        if (analyticsState.isLoading)
                          const LinearProgressIndicator(),

                        // Stats Summary Cards
                        if (analyticsState.summary != null)
                          StatsSummaryCards(summary: analyticsState.summary!),

                        // Timeline Chart
                        if (analyticsState.timeline != null)
                          TimelineChart(timeline: analyticsState.timeline!),

                        // Peak Hours Chart
                        if (analyticsState.peakHours != null)
                          PeakHoursChart(
                              peakHours: analyticsState.peakHours!),

                        // Status Distribution Chart
                        if (analyticsState.statusDistribution != null)
                          StatusDistributionChart(
                            statusDistribution:
                                analyticsState.statusDistribution!,
                          ),

                        // Earnings Breakdown
                        if (analyticsState.earningsBreakdown != null)
                          EarningsBreakdownCard(
                            breakdown: analyticsState.earningsBreakdown!,
                          ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
      ),
    );
  }
}
