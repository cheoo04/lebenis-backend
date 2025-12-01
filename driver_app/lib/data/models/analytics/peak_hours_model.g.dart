// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peak_hours_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PeakHourModelImpl _$$PeakHourModelImplFromJson(Map<String, dynamic> json) =>
    _$PeakHourModelImpl(
      hour: (json['hour'] as num).toInt(),
      deliveriesCount: (json['deliveriesCount'] as num).toInt(),
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
    );

Map<String, dynamic> _$$PeakHourModelImplToJson(_$PeakHourModelImpl instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'deliveriesCount': instance.deliveriesCount,
      'totalEarnings': instance.totalEarnings,
    };

_$PeakHoursResponseModelImpl _$$PeakHoursResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$PeakHoursResponseModelImpl(
  peakHours: (json['peakHours'] as List<dynamic>)
      .map((e) => PeakHourModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$PeakHoursResponseModelImplToJson(
  _$PeakHoursResponseModelImpl instance,
) => <String, dynamic>{'peakHours': instance.peakHours};
