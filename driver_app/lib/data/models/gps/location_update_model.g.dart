// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_update_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LocationUpdateModel _$LocationUpdateModelFromJson(Map<String, dynamic> json) =>
    _LocationUpdateModel(
      id: (json['id'] as num).toInt(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      driverStatus: json['driverStatus'] as String,
      isMoving: json['isMoving'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      speed: (json['speed'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      batteryLevel: (json['batteryLevel'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$LocationUpdateModelToJson(
  _LocationUpdateModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'accuracy': instance.accuracy,
  'driverStatus': instance.driverStatus,
  'isMoving': instance.isMoving,
  'timestamp': instance.timestamp.toIso8601String(),
  'speed': instance.speed,
  'heading': instance.heading,
  'altitude': instance.altitude,
  'batteryLevel': instance.batteryLevel,
  'createdAt': instance.createdAt?.toIso8601String(),
};

_LocationUpdateCreateDTO _$LocationUpdateCreateDTOFromJson(
  Map<String, dynamic> json,
) => _LocationUpdateCreateDTO(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  accuracy: (json['accuracy'] as num?)?.toDouble(),
  speed: (json['speed'] as num?)?.toDouble(),
  heading: (json['heading'] as num?)?.toDouble(),
  altitude: (json['altitude'] as num?)?.toDouble(),
  batteryLevel: (json['batteryLevel'] as num?)?.toInt(),
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$LocationUpdateCreateDTOToJson(
  _LocationUpdateCreateDTO instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'accuracy': instance.accuracy,
  'speed': instance.speed,
  'heading': instance.heading,
  'altitude': instance.altitude,
  'batteryLevel': instance.batteryLevel,
  'timestamp': instance.timestamp?.toIso8601String(),
};

_TrackingIntervalModel _$TrackingIntervalModelFromJson(
  Map<String, dynamic> json,
) => _TrackingIntervalModel(
  intervalSeconds: (json['intervalSeconds'] as num).toInt(),
  driverStatus: json['driverStatus'] as String,
  isMoving: json['isMoving'] as bool,
  recommendedAccuracy: json['recommendedAccuracy'] as String,
);

Map<String, dynamic> _$TrackingIntervalModelToJson(
  _TrackingIntervalModel instance,
) => <String, dynamic>{
  'intervalSeconds': instance.intervalSeconds,
  'driverStatus': instance.driverStatus,
  'isMoving': instance.isMoving,
  'recommendedAccuracy': instance.recommendedAccuracy,
};

_TrackingSessionModel _$TrackingSessionModelFromJson(
  Map<String, dynamic> json,
) => _TrackingSessionModel(
  id: (json['id'] as num).toInt(),
  startedAt: DateTime.parse(json['started_at'] as String),
  endedAt: json['ended_at'] == null
      ? null
      : DateTime.parse(json['ended_at'] as String),
  totalUpdates: (json['total_updates'] as num).toInt(),
  averageAccuracy: (json['average_accuracy'] as num).toDouble(),
  totalDistanceKm: (json['total_distance_km'] as num).toDouble(),
  initialBatteryLevel: (json['initial_battery_level'] as num?)?.toInt(),
  finalBatteryLevel: (json['final_battery_level'] as num?)?.toInt(),
  durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
  batteryConsumption: (json['battery_consumption'] as num?)?.toInt(),
);

Map<String, dynamic> _$TrackingSessionModelToJson(
  _TrackingSessionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'started_at': instance.startedAt.toIso8601String(),
  'ended_at': instance.endedAt?.toIso8601String(),
  'total_updates': instance.totalUpdates,
  'average_accuracy': instance.averageAccuracy,
  'total_distance_km': instance.totalDistanceKm,
  'initial_battery_level': instance.initialBatteryLevel,
  'final_battery_level': instance.finalBatteryLevel,
  'duration_seconds': instance.durationSeconds,
  'battery_consumption': instance.batteryConsumption,
};

_TrackingStatisticsModel _$TrackingStatisticsModelFromJson(
  Map<String, dynamic> json,
) => _TrackingStatisticsModel(
  totalUpdates: (json['total_updates'] as num).toInt(),
  totalSessions: (json['total_sessions'] as num).toInt(),
  totalDistanceKm: (json['total_distance_km'] as num).toDouble(),
  averageAccuracyM: (json['average_accuracy_m'] as num).toDouble(),
  updatesPerDay: (json['updates_per_day'] as num).toDouble(),
);

Map<String, dynamic> _$TrackingStatisticsModelToJson(
  _TrackingStatisticsModel instance,
) => <String, dynamic>{
  'total_updates': instance.totalUpdates,
  'total_sessions': instance.totalSessions,
  'total_distance_km': instance.totalDistanceKm,
  'average_accuracy_m': instance.averageAccuracyM,
  'updates_per_day': instance.updatesPerDay,
};
