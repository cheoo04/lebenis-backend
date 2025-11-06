// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'heatmap_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HeatmapPointModelImpl _$$HeatmapPointModelImplFromJson(
  Map<String, dynamic> json,
) => _$HeatmapPointModelImpl(
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  weight: (json['weight'] as num).toInt(),
);

Map<String, dynamic> _$$HeatmapPointModelImplToJson(
  _$HeatmapPointModelImpl instance,
) => <String, dynamic>{
  'lat': instance.lat,
  'lng': instance.lng,
  'weight': instance.weight,
};

_$HeatmapResponseModelImpl _$$HeatmapResponseModelImplFromJson(
  Map<String, dynamic> json,
) => _$HeatmapResponseModelImpl(
  points: (json['points'] as List<dynamic>)
      .map((e) => HeatmapPointModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$HeatmapResponseModelImplToJson(
  _$HeatmapResponseModelImpl instance,
) => <String, dynamic>{'points': instance.points};
