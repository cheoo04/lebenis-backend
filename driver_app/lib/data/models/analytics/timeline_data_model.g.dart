// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TimelineDataModelImpl _$$TimelineDataModelImplFromJson(
  Map<String, dynamic> json,
) => _$TimelineDataModelImpl(
  date: json['date'] as String,
  deliveriesCount: (json['deliveriesCount'] as num).toInt(),
  totalEarnings: (json['totalEarnings'] as num).toDouble(),
);

Map<String, dynamic> _$$TimelineDataModelImplToJson(
  _$TimelineDataModelImpl instance,
) => <String, dynamic>{
  'date': instance.date,
  'deliveriesCount': instance.deliveriesCount,
  'totalEarnings': instance.totalEarnings,
};

_$TimelineResponseModelImpl _$$TimelineResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$TimelineResponseModelImpl(
  timeline: (json['timeline'] as List<dynamic>)
      .map((e) => TimelineDataModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$TimelineResponseModelImplToJson(
  _$TimelineResponseModelImpl instance,
) => <String, dynamic>{'timeline': instance.timeline};
