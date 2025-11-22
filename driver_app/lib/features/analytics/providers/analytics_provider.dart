import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/analytics_repository.dart';
import '../../../data/models/analytics/stats_summary_model.dart';
import '../../../data/models/analytics/timeline_data_model.dart';
import '../../../data/models/analytics/heatmap_point_model.dart';
import '../../../data/models/analytics/status_distribution_model.dart';
import '../../../data/models/analytics/peak_hours_model.dart';
import '../../../data/models/analytics/earnings_breakdown_model.dart';
import '../../../data/providers/auth_provider.dart';

// Repository Provider
final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AnalyticsRepository(dioClient);
});

// Date Range State
class DateRangeState {
  final String period; // 'today', 'week', 'month', 'year', 'custom'
  final DateTime? startDate;
  final DateTime? endDate;

  DateRangeState({
    this.period = 'week',
    this.startDate,
    this.endDate,
  });

  DateRangeState copyWith({
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DateRangeState(
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  Map<String, dynamic> toQueryParams() {
    return {
      'period': period,
      if (startDate != null) 'start_date': _formatDate(startDate!),
      if (endDate != null) 'end_date': _formatDate(endDate!),
    };
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// Date Range Notifier
class DateRangeNotifier extends Notifier<DateRangeState> {
  @override
  DateRangeState build() => DateRangeState();

  void setPeriod(String period) {
    state = DateRangeState(period: period);
  }

  void setCustomRange(DateTime startDate, DateTime endDate) {
    state = DateRangeState(
      period: 'custom',
      startDate: startDate,
      endDate: endDate,
    );
  }
}

final dateRangeProvider = NotifierProvider<DateRangeNotifier, DateRangeState>(DateRangeNotifier.new);

// Analytics State
class AnalyticsState {
  final bool isLoading;
  final String? error;
  final StatsSummaryModel? summary;
  final TimelineResponseModel? timeline;
  final StatusDistributionResponseModel? statusDistribution;
  final HeatmapResponseModel? heatmap;
  final PeakHoursResponseModel? peakHours;
  final EarningsBreakdownModel? earningsBreakdown;

  AnalyticsState({
    this.isLoading = false,
    this.error,
    this.summary,
    this.timeline,
    this.statusDistribution,
    this.heatmap,
    this.peakHours,
    this.earningsBreakdown,
  });

  AnalyticsState copyWith({
    bool? isLoading,
    String? error,
    StatsSummaryModel? summary,
    TimelineResponseModel? timeline,
    StatusDistributionResponseModel? statusDistribution,
    HeatmapResponseModel? heatmap,
    PeakHoursResponseModel? peakHours,
    EarningsBreakdownModel? earningsBreakdown,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      summary: summary ?? this.summary,
      timeline: timeline ?? this.timeline,
      statusDistribution: statusDistribution ?? this.statusDistribution,
      heatmap: heatmap ?? this.heatmap,
      peakHours: peakHours ?? this.peakHours,
      earningsBreakdown: earningsBreakdown ?? this.earningsBreakdown,
    );
  }
}

// Analytics Notifier
class AnalyticsNotifier extends Notifier<AnalyticsState> {
  late final AnalyticsRepository _repository;

  @override
  AnalyticsState build() {
    _repository = ref.read(analyticsRepositoryProvider);
    return AnalyticsState();
  }

  Future<void> loadAllAnalytics({
    String period = 'week',
    String? startDate,
    String? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load all analytics in parallel
      final results = await Future.wait([
        _repository.getStatsSummary(
          period: period,
          startDate: startDate,
          endDate: endDate,
        ),
        _repository.getTimeline(
          period: period,
          startDate: startDate,
          endDate: endDate,
        ),
        _repository.getStatusDistribution(
          period: period,
          startDate: startDate,
          endDate: endDate,
        ),
        _repository.getHeatmap(
          period: period,
          startDate: startDate,
          endDate: endDate,
        ),
        _repository.getPeakHours(
          period: period,
          startDate: startDate,
          endDate: endDate,
        ),
        _repository.getEarningsBreakdown(
          period: period,
          startDate: startDate,
          endDate: endDate,
        ),
      ]);

      state = AnalyticsState(
        isLoading: false,
        summary: results[0] as StatsSummaryModel,
        timeline: results[1] as TimelineResponseModel,
        statusDistribution: results[2] as StatusDistributionResponseModel,
        heatmap: results[3] as HeatmapResponseModel,
        peakHours: results[4] as PeakHoursResponseModel,
        earningsBreakdown: results[5] as EarningsBreakdownModel,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh(DateRangeState dateRange) async {
    await loadAllAnalytics(
      period: dateRange.period,
      startDate: dateRange.startDate != null
          ? _formatDate(dateRange.startDate!)
          : null,
      endDate:
          dateRange.endDate != null ? _formatDate(dateRange.endDate!) : null,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

final analyticsProvider = NotifierProvider<AnalyticsNotifier, AnalyticsState>(AnalyticsNotifier.new);
