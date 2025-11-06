import 'package:freezed_annotation/freezed_annotation.dart';

part 'earnings_breakdown_model.freezed.dart';
part 'earnings_breakdown_model.g.dart';

@freezed
class EarningsBreakdownModel with _$EarningsBreakdownModel {
  const factory EarningsBreakdownModel({
    @JsonKey(name: 'delivery_earnings') required double deliveryEarnings,
    @JsonKey(name: 'bonus_earnings') required double bonusEarnings,
    @JsonKey(name: 'tip_earnings') required double tipEarnings,
    @JsonKey(name: 'adjustment_earnings') required double adjustmentEarnings,
    @JsonKey(name: 'total_earnings') required double totalEarnings,
  }) = _EarningsBreakdownModel;

  factory EarningsBreakdownModel.fromJson(Map<String, dynamic> json) =>
      _$EarningsBreakdownModelFromJson(json);
}
