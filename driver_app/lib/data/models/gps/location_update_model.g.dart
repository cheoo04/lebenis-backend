// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_update_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocationUpdateModelImpl _$$LocationUpdateModelImplFromJson(
  Map<String, dynamic> json,
) => _$LocationUpdateModelImpl(
  id: (json['id'] as num).toInt(),
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  accuracy: (json['accuracy'] as num).toDouble(),
  driverStatus: json['driver_status'] as String,
  isMoving: json['is_moving'] as bool,
  timestamp: DateTime.parse(json['timestamp'] as String),
  speed: (json['speed'] as num?)?.toDouble(),
  heading: (json['heading'] as num?)?.toDouble(),
  altitude: (json['altitude'] as num?)?.toDouble(),
  batteryLevel: (json['battery_level'] as num?)?.toInt(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$LocationUpdateModelImplToJson(
  _$LocationUpdateModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'accuracy': instance.accuracy,
  'driver_status': instance.driverStatus,
  'is_moving': instance.isMoving,
  'timestamp': instance.timestamp.toIso8601String(),
  'speed': instance.speed,
  'heading': instance.heading,
  'altitude': instance.altitude,
  'battery_level': instance.batteryLevel,
  'created_at': instance.createdAt?.toIso8601String(),
};

_$LocationUpdateCreateDTOImpl _$$LocationUpdateCreateDTOImplFromJson(
  Map<String, dynamic> json,
) => _$LocationUpdateCreateDTOImpl(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  accuracy: (json['accuracy'] as num?)?.toDouble(),
  speed: (json['speed'] as num?)?.toDouble(),
  heading: (json['heading'] as num?)?.toDouble(),
  altitude: (json['altitude'] as num?)?.toDouble(),
  batteryLevel: (json['battery_level'] as num?)?.toInt(),
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$LocationUpdateCreateDTOImplToJson(
  _$LocationUpdateCreateDTOImpl instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'accuracy': instance.accuracy,
  'speed': instance.speed,
  'heading': instance.heading,
  'altitude': instance.altitude,
  'battery_level': instance.batteryLevel,
  'timestamp': instance.timestamp?.toIso8601String(),
};

_$TrackingIntervalModelImpl _$$TrackingIntervalModelImplFromJson(
  Map<String, dynamic> json,
) => _$TrackingIntervalModelImpl(
  intervalSeconds: (json['interval_seconds'] as num).toInt(),
  driverStatus: json['driver_status'] as String,
  isMoving: json['is_moving'] as bool,
  recommendedAccuracy: json['recommended_accuracy'] as String,
);

Map<String, dynamic> _$$TrackingIntervalModelImplToJson(
  _$TrackingIntervalModelImpl instance,
) => <String, dynamic>{
  'interval_seconds': instance.intervalSeconds,
  'driver_status': instance.driverStatus,
  'is_moving': instance.isMoving,
  'recommended_accuracy': instance.recommendedAccuracy,
};

_$TrackingSessionModelImpl _$$TrackingSessionModelImplFromJson(
  Map<String, dynamic> json,
) => _$TrackingSessionModelImpl(
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

Map<String, dynamic> _$$TrackingSessionModelImplToJson(
  _$TrackingSessionModelImpl instance,
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

_$TrackingStatisticsModelImpl _$$TrackingStatisticsModelImplFromJson(
  Map<String, dynamic> json,
) => _$TrackingStatisticsModelImpl(
  totalUpdates: (json['total_updates'] as num).toInt(),
  totalSessions: (json['total_sessions'] as num).toInt(),
  totalDistanceKm: (json['total_distance_km'] as num).toDouble(),
  averageAccuracyM: (json['average_accuracy_m'] as num).toDouble(),
  updatesPerDay: (json['updates_per_day'] as num).toDouble(),
);

Map<String, dynamic> _$$TrackingStatisticsModelImplToJson(
  _$TrackingStatisticsModelImpl instance,
) => <String, dynamic>{
  'total_updates': instance.totalUpdates,
  'total_sessions': instance.totalSessions,
  'total_distance_km': instance.totalDistanceKm,
  'average_accuracy_m': instance.averageAccuracyM,
  'updates_per_day': instance.updatesPerDay,
};
