import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_update_model.freezed.dart';
part 'location_update_model.g.dart';

/// Location Update Model
@freezed
class LocationUpdateModel with _$LocationUpdateModel {
  const factory LocationUpdateModel({
    required int id,
    required double latitude,
    required double longitude,
    required double accuracy,
    required String driverStatus,
    required bool isMoving,
    required DateTime timestamp,
    double? speed,
    double? heading,
    double? altitude,
    int? batteryLevel,
    DateTime? createdAt,
  }) = _LocationUpdateModel;

  factory LocationUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$LocationUpdateModelFromJson(json);
}

/// Location Update Create DTO
@freezed
class LocationUpdateCreateDTO with _$LocationUpdateCreateDTO {
  const factory LocationUpdateCreateDTO({
    required double latitude,
    required double longitude,
    double? accuracy,
    double? speed,
    double? heading,
    double? altitude,
    int? batteryLevel,
    DateTime? timestamp,
  }) = _LocationUpdateCreateDTO;

  factory LocationUpdateCreateDTO.fromJson(Map<String, dynamic> json) =>
      _$LocationUpdateCreateDTOFromJson(json);
}

/// Tracking Interval Response
@freezed
class TrackingIntervalModel with _$TrackingIntervalModel {
  const factory TrackingIntervalModel({
    required int intervalSeconds,
    required String driverStatus,
    required bool isMoving,
    required String recommendedAccuracy,
  }) = _TrackingIntervalModel;

  factory TrackingIntervalModel.fromJson(Map<String, dynamic> json) =>
      _$TrackingIntervalModelFromJson(json);
}

/// Tracking Session Model
@freezed
class TrackingSessionModel with _$TrackingSessionModel {
  const factory TrackingSessionModel({
    required int id,
    @JsonKey(name: 'started_at') required DateTime startedAt,
    @JsonKey(name: 'ended_at') DateTime? endedAt,
    @JsonKey(name: 'total_updates') required int totalUpdates,
    @JsonKey(name: 'average_accuracy') required double averageAccuracy,
    @JsonKey(name: 'total_distance_km') required double totalDistanceKm,
    @JsonKey(name: 'initial_battery_level') int? initialBatteryLevel,
    @JsonKey(name: 'final_battery_level') int? finalBatteryLevel,
    @JsonKey(name: 'duration_seconds') int? durationSeconds,
    @JsonKey(name: 'battery_consumption') int? batteryConsumption,
  }) = _TrackingSessionModel;

  factory TrackingSessionModel.fromJson(Map<String, dynamic> json) =>
      _$TrackingSessionModelFromJson(json);
}

/// Tracking Statistics Model
@freezed
class TrackingStatisticsModel with _$TrackingStatisticsModel {
  const factory TrackingStatisticsModel({
    @JsonKey(name: 'total_updates') required int totalUpdates,
    @JsonKey(name: 'total_sessions') required int totalSessions,
    @JsonKey(name: 'total_distance_km') required double totalDistanceKm,
    @JsonKey(name: 'average_accuracy_m') required double averageAccuracyM,
    @JsonKey(name: 'updates_per_day') required double updatesPerDay,
  }) = _TrackingStatisticsModel;

  factory TrackingStatisticsModel.fromJson(Map<String, dynamic> json) =>
      _$TrackingStatisticsModelFromJson(json);
}
