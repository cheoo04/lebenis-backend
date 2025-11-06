// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peak_hours_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PeakHourModelImpl _$$PeakHourModelImplFromJson(Map<String, dynamic> json) =>
    _$PeakHourModelImpl(
      hour: (json['hour'] as num).toInt(),
      deliveriesCount: (json['deliveries_count'] as num).toInt(),
      totalEarnings: (json['total_earnings'] as num).toDouble(),
    );

Map<String, dynamic> _$$PeakHourModelImplToJson(_$PeakHourModelImpl instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'deliveries_count': instance.deliveriesCount,
      'total_earnings': instance.totalEarnings,
    };

_$PeakHoursResponseModelImpl _$$PeakHoursResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$PeakHoursResponseModelImpl(
  peakHours: (json['peak_hours'] as List<dynamic>)
      .map((e) => PeakHourModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$PeakHoursResponseModelImplToJson(
  _$PeakHoursResponseModelImpl instance,
) => <String, dynamic>{'peak_hours': instance.peakHours};
