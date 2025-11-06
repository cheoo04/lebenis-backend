import 'package:freezed_annotation/freezed_annotation.dart';

part 'peak_hours_model.freezed.dart';
part 'peak_hours_model.g.dart';

@freezed
class PeakHourModel with _$PeakHourModel {
  const factory PeakHourModel({
    required int hour,
    @JsonKey(name: 'deliveries_count') required int deliveriesCount,
    @JsonKey(name: 'total_earnings') required double totalEarnings,
  }) = _PeakHourModel;

  factory PeakHourModel.fromJson(Map<String, dynamic> json) =>
      _$PeakHourModelFromJson(json);
}

@freezed
class PeakHoursResponseModel with _$PeakHoursResponseModel {
  const factory PeakHoursResponseModel({
    @JsonKey(name: 'peak_hours') required List<PeakHourModel> peakHours,
  }) = _PeakHoursResponseModel;

  factory PeakHoursResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PeakHoursResponseModelFromJson(json);
}
