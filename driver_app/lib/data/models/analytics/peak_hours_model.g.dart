// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'peak_hours_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PeakHourModel _$PeakHourModelFromJson(Map<String, dynamic> json) =>
    _PeakHourModel(
      hour: (json['hour'] as num).toInt(),
      deliveriesCount: (json['deliveriesCount'] as num).toInt(),
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
    );

Map<String, dynamic> _$PeakHourModelToJson(_PeakHourModel instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'deliveriesCount': instance.deliveriesCount,
      'totalEarnings': instance.totalEarnings,
    };

_PeakHoursResponseModel _$PeakHoursResponseModelFromJson(
  Map<String, dynamic> json,
) => _PeakHoursResponseModel(
  peakHours: (json['peakHours'] as List<dynamic>)
      .map((e) => PeakHourModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PeakHoursResponseModelToJson(
  _PeakHoursResponseModel instance,
) => <String, dynamic>{'peakHours': instance.peakHours};
