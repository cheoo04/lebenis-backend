// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earnings_breakdown_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EarningsBreakdownModelImpl _$$EarningsBreakdownModelImplFromJson(
        Map<String, dynamic> json) =>
    _$EarningsBreakdownModelImpl(
      deliveryEarnings: (json['delivery_earnings'] as num).toDouble(),
      bonusEarnings: (json['bonus_earnings'] as num).toDouble(),
      tipEarnings: (json['tip_earnings'] as num).toDouble(),
      adjustmentEarnings: (json['adjustment_earnings'] as num).toDouble(),
      totalEarnings: (json['total_earnings'] as num).toDouble(),
    );

Map<String, dynamic> _$$EarningsBreakdownModelImplToJson(
        _$EarningsBreakdownModelImpl instance) =>
    <String, dynamic>{
      'delivery_earnings': instance.deliveryEarnings,
      'bonus_earnings': instance.bonusEarnings,
      'tip_earnings': instance.tipEarnings,
      'adjustment_earnings': instance.adjustmentEarnings,
      'total_earnings': instance.totalEarnings,
    };
