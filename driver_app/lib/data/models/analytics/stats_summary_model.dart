import 'package:freezed_annotation/freezed_annotation.dart';

part 'stats_summary_model.freezed.dart';
part 'stats_summary_model.g.dart';

@freezed
class StatsSummaryModel with _$StatsSummaryModel {
  const factory StatsSummaryModel({
    @JsonKey(name: 'total_deliveries') required int totalDeliveries,
    @JsonKey(name: 'completed_deliveries') required int completedDeliveries,
    @JsonKey(name: 'cancelled_deliveries') required int cancelledDeliveries,
    @JsonKey(name: 'in_progress_deliveries') required int inProgressDeliveries,
    @JsonKey(name: 'total_earnings') required double totalEarnings,
    @JsonKey(name: 'total_distance_km') required double totalDistanceKm,
    @JsonKey(name: 'success_rate') required double successRate,
    @JsonKey(name: 'average_delivery_value') required double averageDeliveryValue,
  }) = _StatsSummaryModel;

  factory StatsSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$StatsSummaryModelFromJson(json);
}
