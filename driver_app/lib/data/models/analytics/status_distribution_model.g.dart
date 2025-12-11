// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_distribution_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StatusDistributionItemModelImpl _$$StatusDistributionItemModelImplFromJson(
        Map<String, dynamic> json) =>
    _$StatusDistributionItemModelImpl(
      status: json['status'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$$StatusDistributionItemModelImplToJson(
        _$StatusDistributionItemModelImpl instance) =>
    <String, dynamic>{
      'status': instance.status,
      'count': instance.count,
    };

_$StatusDistributionResponseModelImpl
    _$$StatusDistributionResponseModelImplFromJson(Map<String, dynamic> json) =>
        _$StatusDistributionResponseModelImpl(
          distribution: (json['distribution'] as List<dynamic>)
              .map((e) => StatusDistributionItemModel.fromJson(
                  e as Map<String, dynamic>))
              .toList(),
        );

Map<String, dynamic> _$$StatusDistributionResponseModelImplToJson(
        _$StatusDistributionResponseModelImpl instance) =>
    <String, dynamic>{
      'distribution': instance.distribution,
    };
