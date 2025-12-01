// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StatsSummaryModelImpl _$$StatsSummaryModelImplFromJson(
  Map<String, dynamic> json,
) => _$StatsSummaryModelImpl(
  totalDeliveries: (json['total_deliveries'] as num).toInt(),
  completedDeliveries: (json['completed_deliveries'] as num).toInt(),
  cancelledDeliveries: (json['cancelled_deliveries'] as num).toInt(),
  inProgressDeliveries: (json['in_progress_deliveries'] as num).toInt(),
  totalEarnings: (json['total_earnings'] as num).toDouble(),
  totalDistanceKm: (json['total_distance_km'] as num).toDouble(),
  successRate: (json['success_rate'] as num).toDouble(),
  averageDeliveryValue: (json['average_delivery_value'] as num).toDouble(),
);

Map<String, dynamic> _$$StatsSummaryModelImplToJson(
  _$StatsSummaryModelImpl instance,
) => <String, dynamic>{
  'total_deliveries': instance.totalDeliveries,
  'completed_deliveries': instance.completedDeliveries,
  'cancelled_deliveries': instance.cancelledDeliveries,
  'in_progress_deliveries': instance.inProgressDeliveries,
  'total_earnings': instance.totalEarnings,
  'total_distance_km': instance.totalDistanceKm,
  'success_rate': instance.successRate,
  'average_delivery_value': instance.averageDeliveryValue,
};
