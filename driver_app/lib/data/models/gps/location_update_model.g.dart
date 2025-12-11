// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_update_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocationUpdateModelImpl _$$LocationUpdateModelImplFromJson(
        Map<String, dynamic> json) =>
    _$LocationUpdateModelImpl(
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

Map<String, dynamic> _$$LocationUpdateModelImplToJson(
        _$LocationUpdateModelImpl instance) =>
    <String, dynamic>{
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

_$LocationUpdateCreateDTOImpl _$$LocationUpdateCreateDTOImplFromJson(
        Map<String, dynamic> json) =>
    _$LocationUpdateCreateDTOImpl(
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

Map<String, dynamic> _$$LocationUpdateCreateDTOImplToJson(
        _$LocationUpdateCreateDTOImpl instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracy': instance.accuracy,
      'speed': instance.speed,
      'heading': instance.heading,
      'altitude': instance.altitude,
      'batteryLevel': instance.batteryLevel,
      'timestamp': instance.timestamp?.toIso8601String(),
    };

_$TrackingIntervalModelImpl _$$TrackingIntervalModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TrackingIntervalModelImpl(
      intervalSeconds: (json['intervalSeconds'] as num).toInt(),
      driverStatus: json['driverStatus'] as String,
      isMoving: json['isMoving'] as bool,
      recommendedAccuracy: json['recommendedAccuracy'] as String,
    );

Map<String, dynamic> _$$TrackingIntervalModelImplToJson(
        _$TrackingIntervalModelImpl instance) =>
    <String, dynamic>{
      'intervalSeconds': instance.intervalSeconds,
      'driverStatus': instance.driverStatus,
      'isMoving': instance.isMoving,
      'recommendedAccuracy': instance.recommendedAccuracy,
    };

_$TrackingSessionModelImpl _$$TrackingSessionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TrackingSessionModelImpl(
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
        _$TrackingSessionModelImpl instance) =>
    <String, dynamic>{
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
        Map<String, dynamic> json) =>
    _$TrackingStatisticsModelImpl(
      totalUpdates: (json['total_updates'] as num).toInt(),
      totalSessions: (json['total_sessions'] as num).toInt(),
      totalDistanceKm: (json['total_distance_km'] as num).toDouble(),
      averageAccuracyM: (json['average_accuracy_m'] as num).toDouble(),
      updatesPerDay: (json['updates_per_day'] as num).toDouble(),
    );

Map<String, dynamic> _$$TrackingStatisticsModelImplToJson(
        _$TrackingStatisticsModelImpl instance) =>
    <String, dynamic>{
      'total_updates': instance.totalUpdates,
      'total_sessions': instance.totalSessions,
      'total_distance_km': instance.totalDistanceKm,
      'average_accuracy_m': instance.averageAccuracyM,
      'updates_per_day': instance.updatesPerDay,
    };
