// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heatmap_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HeatmapPointModel _$HeatmapPointModelFromJson(Map<String, dynamic> json) =>
    _HeatmapPointModel(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      weight: (json['weight'] as num).toInt(),
    );

Map<String, dynamic> _$HeatmapPointModelToJson(_HeatmapPointModel instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
      'weight': instance.weight,
    };

_HeatmapResponseModel _$HeatmapResponseModelFromJson(
  Map<String, dynamic> json,
) => _HeatmapResponseModel(
  points: (json['points'] as List<dynamic>)
      .map((e) => HeatmapPointModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$HeatmapResponseModelToJson(
  _HeatmapResponseModel instance,
) => <String, dynamic>{'points': instance.points};
