import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/analytics/stats_summary_model.dart';
import '../models/analytics/timeline_data_model.dart';
import '../models/analytics/heatmap_point_model.dart';
import '../models/analytics/status_distribution_model.dart';
import '../models/analytics/peak_hours_model.dart';
import '../models/analytics/earnings_breakdown_model.dart';

class AnalyticsRepository {
  final DioClient _dioClient;

  AnalyticsRepository(this._dioClient);

  // Date period options: 'today', 'week', 'month', 'year', 'custom'
  Future<StatsSummaryModel> getStatsSummary({
    String period = 'week',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'period': period,
      };
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dioClient.get(
        '/deliveries/analytics/summary/',
        queryParameters: queryParams,
      );

      return StatsSummaryModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<TimelineResponseModel> getTimeline({
    String period = 'week',
    String? startDate,
    String? endDate,
    String granularity = 'day', // 'day' or 'hour'
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'period': period,
        'granularity': granularity,
      };
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dioClient.get(
        '/deliveries/analytics/timeline/',
        queryParameters: queryParams,
      );

      return TimelineResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<StatusDistributionResponseModel> getStatusDistribution({
    String period = 'week',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'period': period,
      };
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dioClient.get(
        '/deliveries/analytics/status_distribution/',
        queryParameters: queryParams,
      );

      return StatusDistributionResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<HeatmapResponseModel> getHeatmap({
    String period = 'week',
    String? startDate,
    String? endDate,
    int maxPoints = 500,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'period': period,
        'max_points': maxPoints,
      };
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dioClient.get(
        '/deliveries/analytics/heatmap/',
        queryParameters: queryParams,
      );

      return HeatmapResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<PeakHoursResponseModel> getPeakHours({
    String period = 'week',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'period': period,
      };
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dioClient.get(
        '/deliveries/analytics/peak_hours/',
        queryParameters: queryParams,
      );

      return PeakHoursResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<EarningsBreakdownModel> getEarningsBreakdown({
    String period = 'week',
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'period': period,
      };
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dioClient.get(
        '/deliveries/analytics/earnings_breakdown/',
        queryParameters: queryParams,
      );

      return EarningsBreakdownModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response?.statusCode == 404) {
      return 'Driver profile not found';
    } else if (e.response?.statusCode == 400) {
      return e.response?.data['error'] ?? 'Invalid request';
    } else if (e.response?.statusCode == 401) {
      return 'Authentication required';
    }
    return 'Failed to load analytics: ${e.message}';
  }
}
