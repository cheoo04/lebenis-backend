import 'package:freezed_annotation/freezed_annotation.dart';

part 'heatmap_point_model.freezed.dart';
part 'heatmap_point_model.g.dart';

@freezed
class HeatmapPointModel with _$HeatmapPointModel {
  const factory HeatmapPointModel({
    required double lat,
    required double lng,
    required int weight,
  }) = _HeatmapPointModel;

  factory HeatmapPointModel.fromJson(Map<String, dynamic> json) =>
      _$HeatmapPointModelFromJson(json);
}

@freezed
class HeatmapResponseModel with _$HeatmapResponseModel {
  const factory HeatmapResponseModel({
    required List<HeatmapPointModel> points,
  }) = _HeatmapResponseModel;

  factory HeatmapResponseModel.fromJson(Map<String, dynamic> json) =>
      _$HeatmapResponseModelFromJson(json);
}
