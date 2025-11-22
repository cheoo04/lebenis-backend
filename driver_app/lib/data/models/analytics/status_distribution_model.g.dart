// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_distribution_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StatusDistributionItemModel _$StatusDistributionItemModelFromJson(
  Map<String, dynamic> json,
) => _StatusDistributionItemModel(
  status: json['status'] as String,
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$StatusDistributionItemModelToJson(
  _StatusDistributionItemModel instance,
) => <String, dynamic>{'status': instance.status, 'count': instance.count};

_StatusDistributionResponseModel _$StatusDistributionResponseModelFromJson(
  Map<String, dynamic> json,
) => _StatusDistributionResponseModel(
  distribution: (json['distribution'] as List<dynamic>)
      .map(
        (e) => StatusDistributionItemModel.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$StatusDistributionResponseModelToJson(
  _StatusDistributionResponseModel instance,
) => <String, dynamic>{'distribution': instance.distribution};
