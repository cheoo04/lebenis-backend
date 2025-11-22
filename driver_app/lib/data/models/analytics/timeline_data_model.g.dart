// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimelineDataModel _$TimelineDataModelFromJson(Map<String, dynamic> json) =>
    _TimelineDataModel(
      date: json['date'] as String,
      deliveriesCount: (json['deliveriesCount'] as num).toInt(),
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
    );

Map<String, dynamic> _$TimelineDataModelToJson(_TimelineDataModel instance) =>
    <String, dynamic>{
      'date': instance.date,
      'deliveriesCount': instance.deliveriesCount,
      'totalEarnings': instance.totalEarnings,
    };

_TimelineResponseModel _$TimelineResponseModelFromJson(
  Map<String, dynamic> json,
) => _TimelineResponseModel(
  timeline: (json['timeline'] as List<dynamic>)
      .map((e) => TimelineDataModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TimelineResponseModelToJson(
  _TimelineResponseModel instance,
) => <String, dynamic>{'timeline': instance.timeline};
