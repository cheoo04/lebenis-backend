import 'package:freezed_annotation/freezed_annotation.dart';

part 'status_distribution_model.freezed.dart';
part 'status_distribution_model.g.dart';

@freezed
class StatusDistributionItemModel with _$StatusDistributionItemModel {
  const factory StatusDistributionItemModel({
    required String status,
    required int count,
  }) = _StatusDistributionItemModel;

  factory StatusDistributionItemModel.fromJson(Map<String, dynamic> json) =>
      _$StatusDistributionItemModelFromJson(json);
}

@freezed
class StatusDistributionResponseModel with _$StatusDistributionResponseModel {
  const factory StatusDistributionResponseModel({
    required List<StatusDistributionItemModel> distribution,
  }) = _StatusDistributionResponseModel;

  factory StatusDistributionResponseModel.fromJson(Map<String, dynamic> json) =>
      _$StatusDistributionResponseModelFromJson(json);
}
