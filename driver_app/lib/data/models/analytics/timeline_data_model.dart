import 'package:freezed_annotation/freezed_annotation.dart';

part 'timeline_data_model.freezed.dart';
part 'timeline_data_model.g.dart';

@freezed
class TimelineDataModel with _$TimelineDataModel {
  const factory TimelineDataModel({
    required String date,
    @JsonKey(name: 'deliveries_count') required int deliveriesCount,
    @JsonKey(name: 'total_earnings') required double totalEarnings,
  }) = _TimelineDataModel;

  factory TimelineDataModel.fromJson(Map<String, dynamic> json) =>
      _$TimelineDataModelFromJson(json);
}

@freezed
class TimelineResponseModel with _$TimelineResponseModel {
  const factory TimelineResponseModel({
    required List<TimelineDataModel> timeline,
  }) = _TimelineResponseModel;

  factory TimelineResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TimelineResponseModelFromJson(json);
}
