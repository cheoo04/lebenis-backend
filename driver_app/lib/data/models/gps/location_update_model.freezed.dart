// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_update_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocationUpdateModel {

 int get id; double get latitude; double get longitude; double get accuracy; String get driverStatus; bool get isMoving; DateTime get timestamp; double? get speed; double? get heading; double? get altitude; int? get batteryLevel; DateTime? get createdAt;
/// Create a copy of LocationUpdateModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationUpdateModelCopyWith<LocationUpdateModel> get copyWith => _$LocationUpdateModelCopyWithImpl<LocationUpdateModel>(this as LocationUpdateModel, _$identity);

  /// Serializes this LocationUpdateModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationUpdateModel&&(identical(other.id, id) || other.id == id)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.driverStatus, driverStatus) || other.driverStatus == driverStatus)&&(identical(other.isMoving, isMoving) || other.isMoving == isMoving)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.altitude, altitude) || other.altitude == altitude)&&(identical(other.batteryLevel, batteryLevel) || other.batteryLevel == batteryLevel)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,latitude,longitude,accuracy,driverStatus,isMoving,timestamp,speed,heading,altitude,batteryLevel,createdAt);

@override
String toString() {
  return 'LocationUpdateModel(id: $id, latitude: $latitude, longitude: $longitude, accuracy: $accuracy, driverStatus: $driverStatus, isMoving: $isMoving, timestamp: $timestamp, speed: $speed, heading: $heading, altitude: $altitude, batteryLevel: $batteryLevel, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $LocationUpdateModelCopyWith<$Res>  {
  factory $LocationUpdateModelCopyWith(LocationUpdateModel value, $Res Function(LocationUpdateModel) _then) = _$LocationUpdateModelCopyWithImpl;
@useResult
$Res call({
 int id, double latitude, double longitude, double accuracy, String driverStatus, bool isMoving, DateTime timestamp, double? speed, double? heading, double? altitude, int? batteryLevel, DateTime? createdAt
});




}
/// @nodoc
class _$LocationUpdateModelCopyWithImpl<$Res>
    implements $LocationUpdateModelCopyWith<$Res> {
  _$LocationUpdateModelCopyWithImpl(this._self, this._then);

  final LocationUpdateModel _self;
  final $Res Function(LocationUpdateModel) _then;

/// Create a copy of LocationUpdateModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? latitude = null,Object? longitude = null,Object? accuracy = null,Object? driverStatus = null,Object? isMoving = null,Object? timestamp = null,Object? speed = freezed,Object? heading = freezed,Object? altitude = freezed,Object? batteryLevel = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,driverStatus: null == driverStatus ? _self.driverStatus : driverStatus // ignore: cast_nullable_to_non_nullable
as String,isMoving: null == isMoving ? _self.isMoving : isMoving // ignore: cast_nullable_to_non_nullable
as bool,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,heading: freezed == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double?,altitude: freezed == altitude ? _self.altitude : altitude // ignore: cast_nullable_to_non_nullable
as double?,batteryLevel: freezed == batteryLevel ? _self.batteryLevel : batteryLevel // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocationUpdateModel].
extension LocationUpdateModelPatterns on LocationUpdateModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationUpdateModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationUpdateModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationUpdateModel value)  $default,){
final _that = this;
switch (_that) {
case _LocationUpdateModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationUpdateModel value)?  $default,){
final _that = this;
switch (_that) {
case _LocationUpdateModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  double latitude,  double longitude,  double accuracy,  String driverStatus,  bool isMoving,  DateTime timestamp,  double? speed,  double? heading,  double? altitude,  int? batteryLevel,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationUpdateModel() when $default != null:
return $default(_that.id,_that.latitude,_that.longitude,_that.accuracy,_that.driverStatus,_that.isMoving,_that.timestamp,_that.speed,_that.heading,_that.altitude,_that.batteryLevel,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  double latitude,  double longitude,  double accuracy,  String driverStatus,  bool isMoving,  DateTime timestamp,  double? speed,  double? heading,  double? altitude,  int? batteryLevel,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _LocationUpdateModel():
return $default(_that.id,_that.latitude,_that.longitude,_that.accuracy,_that.driverStatus,_that.isMoving,_that.timestamp,_that.speed,_that.heading,_that.altitude,_that.batteryLevel,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  double latitude,  double longitude,  double accuracy,  String driverStatus,  bool isMoving,  DateTime timestamp,  double? speed,  double? heading,  double? altitude,  int? batteryLevel,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _LocationUpdateModel() when $default != null:
return $default(_that.id,_that.latitude,_that.longitude,_that.accuracy,_that.driverStatus,_that.isMoving,_that.timestamp,_that.speed,_that.heading,_that.altitude,_that.batteryLevel,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocationUpdateModel implements LocationUpdateModel {
  const _LocationUpdateModel({required this.id, required this.latitude, required this.longitude, required this.accuracy, required this.driverStatus, required this.isMoving, required this.timestamp, this.speed, this.heading, this.altitude, this.batteryLevel, this.createdAt});
  factory _LocationUpdateModel.fromJson(Map<String, dynamic> json) => _$LocationUpdateModelFromJson(json);

@override final  int id;
@override final  double latitude;
@override final  double longitude;
@override final  double accuracy;
@override final  String driverStatus;
@override final  bool isMoving;
@override final  DateTime timestamp;
@override final  double? speed;
@override final  double? heading;
@override final  double? altitude;
@override final  int? batteryLevel;
@override final  DateTime? createdAt;

/// Create a copy of LocationUpdateModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationUpdateModelCopyWith<_LocationUpdateModel> get copyWith => __$LocationUpdateModelCopyWithImpl<_LocationUpdateModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocationUpdateModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationUpdateModel&&(identical(other.id, id) || other.id == id)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.driverStatus, driverStatus) || other.driverStatus == driverStatus)&&(identical(other.isMoving, isMoving) || other.isMoving == isMoving)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.altitude, altitude) || other.altitude == altitude)&&(identical(other.batteryLevel, batteryLevel) || other.batteryLevel == batteryLevel)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,latitude,longitude,accuracy,driverStatus,isMoving,timestamp,speed,heading,altitude,batteryLevel,createdAt);

@override
String toString() {
  return 'LocationUpdateModel(id: $id, latitude: $latitude, longitude: $longitude, accuracy: $accuracy, driverStatus: $driverStatus, isMoving: $isMoving, timestamp: $timestamp, speed: $speed, heading: $heading, altitude: $altitude, batteryLevel: $batteryLevel, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$LocationUpdateModelCopyWith<$Res> implements $LocationUpdateModelCopyWith<$Res> {
  factory _$LocationUpdateModelCopyWith(_LocationUpdateModel value, $Res Function(_LocationUpdateModel) _then) = __$LocationUpdateModelCopyWithImpl;
@override @useResult
$Res call({
 int id, double latitude, double longitude, double accuracy, String driverStatus, bool isMoving, DateTime timestamp, double? speed, double? heading, double? altitude, int? batteryLevel, DateTime? createdAt
});




}
/// @nodoc
class __$LocationUpdateModelCopyWithImpl<$Res>
    implements _$LocationUpdateModelCopyWith<$Res> {
  __$LocationUpdateModelCopyWithImpl(this._self, this._then);

  final _LocationUpdateModel _self;
  final $Res Function(_LocationUpdateModel) _then;

/// Create a copy of LocationUpdateModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? latitude = null,Object? longitude = null,Object? accuracy = null,Object? driverStatus = null,Object? isMoving = null,Object? timestamp = null,Object? speed = freezed,Object? heading = freezed,Object? altitude = freezed,Object? batteryLevel = freezed,Object? createdAt = freezed,}) {
  return _then(_LocationUpdateModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracy: null == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double,driverStatus: null == driverStatus ? _self.driverStatus : driverStatus // ignore: cast_nullable_to_non_nullable
as String,isMoving: null == isMoving ? _self.isMoving : isMoving // ignore: cast_nullable_to_non_nullable
as bool,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,heading: freezed == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double?,altitude: freezed == altitude ? _self.altitude : altitude // ignore: cast_nullable_to_non_nullable
as double?,batteryLevel: freezed == batteryLevel ? _self.batteryLevel : batteryLevel // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$LocationUpdateCreateDTO {

 double get latitude; double get longitude; double? get accuracy; double? get speed; double? get heading; double? get altitude; int? get batteryLevel; DateTime? get timestamp;
/// Create a copy of LocationUpdateCreateDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationUpdateCreateDTOCopyWith<LocationUpdateCreateDTO> get copyWith => _$LocationUpdateCreateDTOCopyWithImpl<LocationUpdateCreateDTO>(this as LocationUpdateCreateDTO, _$identity);

  /// Serializes this LocationUpdateCreateDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationUpdateCreateDTO&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.altitude, altitude) || other.altitude == altitude)&&(identical(other.batteryLevel, batteryLevel) || other.batteryLevel == batteryLevel)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,accuracy,speed,heading,altitude,batteryLevel,timestamp);

@override
String toString() {
  return 'LocationUpdateCreateDTO(latitude: $latitude, longitude: $longitude, accuracy: $accuracy, speed: $speed, heading: $heading, altitude: $altitude, batteryLevel: $batteryLevel, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $LocationUpdateCreateDTOCopyWith<$Res>  {
  factory $LocationUpdateCreateDTOCopyWith(LocationUpdateCreateDTO value, $Res Function(LocationUpdateCreateDTO) _then) = _$LocationUpdateCreateDTOCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude, double? accuracy, double? speed, double? heading, double? altitude, int? batteryLevel, DateTime? timestamp
});




}
/// @nodoc
class _$LocationUpdateCreateDTOCopyWithImpl<$Res>
    implements $LocationUpdateCreateDTOCopyWith<$Res> {
  _$LocationUpdateCreateDTOCopyWithImpl(this._self, this._then);

  final LocationUpdateCreateDTO _self;
  final $Res Function(LocationUpdateCreateDTO) _then;

/// Create a copy of LocationUpdateCreateDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,Object? accuracy = freezed,Object? speed = freezed,Object? heading = freezed,Object? altitude = freezed,Object? batteryLevel = freezed,Object? timestamp = freezed,}) {
  return _then(_self.copyWith(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracy: freezed == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,heading: freezed == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double?,altitude: freezed == altitude ? _self.altitude : altitude // ignore: cast_nullable_to_non_nullable
as double?,batteryLevel: freezed == batteryLevel ? _self.batteryLevel : batteryLevel // ignore: cast_nullable_to_non_nullable
as int?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocationUpdateCreateDTO].
extension LocationUpdateCreateDTOPatterns on LocationUpdateCreateDTO {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationUpdateCreateDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationUpdateCreateDTO() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationUpdateCreateDTO value)  $default,){
final _that = this;
switch (_that) {
case _LocationUpdateCreateDTO():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationUpdateCreateDTO value)?  $default,){
final _that = this;
switch (_that) {
case _LocationUpdateCreateDTO() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double? accuracy,  double? speed,  double? heading,  double? altitude,  int? batteryLevel,  DateTime? timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationUpdateCreateDTO() when $default != null:
return $default(_that.latitude,_that.longitude,_that.accuracy,_that.speed,_that.heading,_that.altitude,_that.batteryLevel,_that.timestamp);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double? accuracy,  double? speed,  double? heading,  double? altitude,  int? batteryLevel,  DateTime? timestamp)  $default,) {final _that = this;
switch (_that) {
case _LocationUpdateCreateDTO():
return $default(_that.latitude,_that.longitude,_that.accuracy,_that.speed,_that.heading,_that.altitude,_that.batteryLevel,_that.timestamp);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitude,  double longitude,  double? accuracy,  double? speed,  double? heading,  double? altitude,  int? batteryLevel,  DateTime? timestamp)?  $default,) {final _that = this;
switch (_that) {
case _LocationUpdateCreateDTO() when $default != null:
return $default(_that.latitude,_that.longitude,_that.accuracy,_that.speed,_that.heading,_that.altitude,_that.batteryLevel,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocationUpdateCreateDTO implements LocationUpdateCreateDTO {
  const _LocationUpdateCreateDTO({required this.latitude, required this.longitude, this.accuracy, this.speed, this.heading, this.altitude, this.batteryLevel, this.timestamp});
  factory _LocationUpdateCreateDTO.fromJson(Map<String, dynamic> json) => _$LocationUpdateCreateDTOFromJson(json);

@override final  double latitude;
@override final  double longitude;
@override final  double? accuracy;
@override final  double? speed;
@override final  double? heading;
@override final  double? altitude;
@override final  int? batteryLevel;
@override final  DateTime? timestamp;

/// Create a copy of LocationUpdateCreateDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationUpdateCreateDTOCopyWith<_LocationUpdateCreateDTO> get copyWith => __$LocationUpdateCreateDTOCopyWithImpl<_LocationUpdateCreateDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocationUpdateCreateDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationUpdateCreateDTO&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.accuracy, accuracy) || other.accuracy == accuracy)&&(identical(other.speed, speed) || other.speed == speed)&&(identical(other.heading, heading) || other.heading == heading)&&(identical(other.altitude, altitude) || other.altitude == altitude)&&(identical(other.batteryLevel, batteryLevel) || other.batteryLevel == batteryLevel)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,accuracy,speed,heading,altitude,batteryLevel,timestamp);

@override
String toString() {
  return 'LocationUpdateCreateDTO(latitude: $latitude, longitude: $longitude, accuracy: $accuracy, speed: $speed, heading: $heading, altitude: $altitude, batteryLevel: $batteryLevel, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$LocationUpdateCreateDTOCopyWith<$Res> implements $LocationUpdateCreateDTOCopyWith<$Res> {
  factory _$LocationUpdateCreateDTOCopyWith(_LocationUpdateCreateDTO value, $Res Function(_LocationUpdateCreateDTO) _then) = __$LocationUpdateCreateDTOCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude, double? accuracy, double? speed, double? heading, double? altitude, int? batteryLevel, DateTime? timestamp
});




}
/// @nodoc
class __$LocationUpdateCreateDTOCopyWithImpl<$Res>
    implements _$LocationUpdateCreateDTOCopyWith<$Res> {
  __$LocationUpdateCreateDTOCopyWithImpl(this._self, this._then);

  final _LocationUpdateCreateDTO _self;
  final $Res Function(_LocationUpdateCreateDTO) _then;

/// Create a copy of LocationUpdateCreateDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? accuracy = freezed,Object? speed = freezed,Object? heading = freezed,Object? altitude = freezed,Object? batteryLevel = freezed,Object? timestamp = freezed,}) {
  return _then(_LocationUpdateCreateDTO(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracy: freezed == accuracy ? _self.accuracy : accuracy // ignore: cast_nullable_to_non_nullable
as double?,speed: freezed == speed ? _self.speed : speed // ignore: cast_nullable_to_non_nullable
as double?,heading: freezed == heading ? _self.heading : heading // ignore: cast_nullable_to_non_nullable
as double?,altitude: freezed == altitude ? _self.altitude : altitude // ignore: cast_nullable_to_non_nullable
as double?,batteryLevel: freezed == batteryLevel ? _self.batteryLevel : batteryLevel // ignore: cast_nullable_to_non_nullable
as int?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$TrackingIntervalModel {

 int get intervalSeconds; String get driverStatus; bool get isMoving; String get recommendedAccuracy;
/// Create a copy of TrackingIntervalModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackingIntervalModelCopyWith<TrackingIntervalModel> get copyWith => _$TrackingIntervalModelCopyWithImpl<TrackingIntervalModel>(this as TrackingIntervalModel, _$identity);

  /// Serializes this TrackingIntervalModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackingIntervalModel&&(identical(other.intervalSeconds, intervalSeconds) || other.intervalSeconds == intervalSeconds)&&(identical(other.driverStatus, driverStatus) || other.driverStatus == driverStatus)&&(identical(other.isMoving, isMoving) || other.isMoving == isMoving)&&(identical(other.recommendedAccuracy, recommendedAccuracy) || other.recommendedAccuracy == recommendedAccuracy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,intervalSeconds,driverStatus,isMoving,recommendedAccuracy);

@override
String toString() {
  return 'TrackingIntervalModel(intervalSeconds: $intervalSeconds, driverStatus: $driverStatus, isMoving: $isMoving, recommendedAccuracy: $recommendedAccuracy)';
}


}

/// @nodoc
abstract mixin class $TrackingIntervalModelCopyWith<$Res>  {
  factory $TrackingIntervalModelCopyWith(TrackingIntervalModel value, $Res Function(TrackingIntervalModel) _then) = _$TrackingIntervalModelCopyWithImpl;
@useResult
$Res call({
 int intervalSeconds, String driverStatus, bool isMoving, String recommendedAccuracy
});




}
/// @nodoc
class _$TrackingIntervalModelCopyWithImpl<$Res>
    implements $TrackingIntervalModelCopyWith<$Res> {
  _$TrackingIntervalModelCopyWithImpl(this._self, this._then);

  final TrackingIntervalModel _self;
  final $Res Function(TrackingIntervalModel) _then;

/// Create a copy of TrackingIntervalModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? intervalSeconds = null,Object? driverStatus = null,Object? isMoving = null,Object? recommendedAccuracy = null,}) {
  return _then(_self.copyWith(
intervalSeconds: null == intervalSeconds ? _self.intervalSeconds : intervalSeconds // ignore: cast_nullable_to_non_nullable
as int,driverStatus: null == driverStatus ? _self.driverStatus : driverStatus // ignore: cast_nullable_to_non_nullable
as String,isMoving: null == isMoving ? _self.isMoving : isMoving // ignore: cast_nullable_to_non_nullable
as bool,recommendedAccuracy: null == recommendedAccuracy ? _self.recommendedAccuracy : recommendedAccuracy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackingIntervalModel].
extension TrackingIntervalModelPatterns on TrackingIntervalModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackingIntervalModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackingIntervalModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackingIntervalModel value)  $default,){
final _that = this;
switch (_that) {
case _TrackingIntervalModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackingIntervalModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrackingIntervalModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int intervalSeconds,  String driverStatus,  bool isMoving,  String recommendedAccuracy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackingIntervalModel() when $default != null:
return $default(_that.intervalSeconds,_that.driverStatus,_that.isMoving,_that.recommendedAccuracy);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int intervalSeconds,  String driverStatus,  bool isMoving,  String recommendedAccuracy)  $default,) {final _that = this;
switch (_that) {
case _TrackingIntervalModel():
return $default(_that.intervalSeconds,_that.driverStatus,_that.isMoving,_that.recommendedAccuracy);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int intervalSeconds,  String driverStatus,  bool isMoving,  String recommendedAccuracy)?  $default,) {final _that = this;
switch (_that) {
case _TrackingIntervalModel() when $default != null:
return $default(_that.intervalSeconds,_that.driverStatus,_that.isMoving,_that.recommendedAccuracy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrackingIntervalModel implements TrackingIntervalModel {
  const _TrackingIntervalModel({required this.intervalSeconds, required this.driverStatus, required this.isMoving, required this.recommendedAccuracy});
  factory _TrackingIntervalModel.fromJson(Map<String, dynamic> json) => _$TrackingIntervalModelFromJson(json);

@override final  int intervalSeconds;
@override final  String driverStatus;
@override final  bool isMoving;
@override final  String recommendedAccuracy;

/// Create a copy of TrackingIntervalModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackingIntervalModelCopyWith<_TrackingIntervalModel> get copyWith => __$TrackingIntervalModelCopyWithImpl<_TrackingIntervalModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackingIntervalModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackingIntervalModel&&(identical(other.intervalSeconds, intervalSeconds) || other.intervalSeconds == intervalSeconds)&&(identical(other.driverStatus, driverStatus) || other.driverStatus == driverStatus)&&(identical(other.isMoving, isMoving) || other.isMoving == isMoving)&&(identical(other.recommendedAccuracy, recommendedAccuracy) || other.recommendedAccuracy == recommendedAccuracy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,intervalSeconds,driverStatus,isMoving,recommendedAccuracy);

@override
String toString() {
  return 'TrackingIntervalModel(intervalSeconds: $intervalSeconds, driverStatus: $driverStatus, isMoving: $isMoving, recommendedAccuracy: $recommendedAccuracy)';
}


}

/// @nodoc
abstract mixin class _$TrackingIntervalModelCopyWith<$Res> implements $TrackingIntervalModelCopyWith<$Res> {
  factory _$TrackingIntervalModelCopyWith(_TrackingIntervalModel value, $Res Function(_TrackingIntervalModel) _then) = __$TrackingIntervalModelCopyWithImpl;
@override @useResult
$Res call({
 int intervalSeconds, String driverStatus, bool isMoving, String recommendedAccuracy
});




}
/// @nodoc
class __$TrackingIntervalModelCopyWithImpl<$Res>
    implements _$TrackingIntervalModelCopyWith<$Res> {
  __$TrackingIntervalModelCopyWithImpl(this._self, this._then);

  final _TrackingIntervalModel _self;
  final $Res Function(_TrackingIntervalModel) _then;

/// Create a copy of TrackingIntervalModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? intervalSeconds = null,Object? driverStatus = null,Object? isMoving = null,Object? recommendedAccuracy = null,}) {
  return _then(_TrackingIntervalModel(
intervalSeconds: null == intervalSeconds ? _self.intervalSeconds : intervalSeconds // ignore: cast_nullable_to_non_nullable
as int,driverStatus: null == driverStatus ? _self.driverStatus : driverStatus // ignore: cast_nullable_to_non_nullable
as String,isMoving: null == isMoving ? _self.isMoving : isMoving // ignore: cast_nullable_to_non_nullable
as bool,recommendedAccuracy: null == recommendedAccuracy ? _self.recommendedAccuracy : recommendedAccuracy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TrackingSessionModel {

 int get id;@JsonKey(name: 'started_at') DateTime get startedAt;@JsonKey(name: 'ended_at') DateTime? get endedAt;@JsonKey(name: 'total_updates') int get totalUpdates;@JsonKey(name: 'average_accuracy') double get averageAccuracy;@JsonKey(name: 'total_distance_km') double get totalDistanceKm;@JsonKey(name: 'initial_battery_level') int? get initialBatteryLevel;@JsonKey(name: 'final_battery_level') int? get finalBatteryLevel;@JsonKey(name: 'duration_seconds') int? get durationSeconds;@JsonKey(name: 'battery_consumption') int? get batteryConsumption;
/// Create a copy of TrackingSessionModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackingSessionModelCopyWith<TrackingSessionModel> get copyWith => _$TrackingSessionModelCopyWithImpl<TrackingSessionModel>(this as TrackingSessionModel, _$identity);

  /// Serializes this TrackingSessionModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackingSessionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.totalUpdates, totalUpdates) || other.totalUpdates == totalUpdates)&&(identical(other.averageAccuracy, averageAccuracy) || other.averageAccuracy == averageAccuracy)&&(identical(other.totalDistanceKm, totalDistanceKm) || other.totalDistanceKm == totalDistanceKm)&&(identical(other.initialBatteryLevel, initialBatteryLevel) || other.initialBatteryLevel == initialBatteryLevel)&&(identical(other.finalBatteryLevel, finalBatteryLevel) || other.finalBatteryLevel == finalBatteryLevel)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.batteryConsumption, batteryConsumption) || other.batteryConsumption == batteryConsumption));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startedAt,endedAt,totalUpdates,averageAccuracy,totalDistanceKm,initialBatteryLevel,finalBatteryLevel,durationSeconds,batteryConsumption);

@override
String toString() {
  return 'TrackingSessionModel(id: $id, startedAt: $startedAt, endedAt: $endedAt, totalUpdates: $totalUpdates, averageAccuracy: $averageAccuracy, totalDistanceKm: $totalDistanceKm, initialBatteryLevel: $initialBatteryLevel, finalBatteryLevel: $finalBatteryLevel, durationSeconds: $durationSeconds, batteryConsumption: $batteryConsumption)';
}


}

/// @nodoc
abstract mixin class $TrackingSessionModelCopyWith<$Res>  {
  factory $TrackingSessionModelCopyWith(TrackingSessionModel value, $Res Function(TrackingSessionModel) _then) = _$TrackingSessionModelCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: 'started_at') DateTime startedAt,@JsonKey(name: 'ended_at') DateTime? endedAt,@JsonKey(name: 'total_updates') int totalUpdates,@JsonKey(name: 'average_accuracy') double averageAccuracy,@JsonKey(name: 'total_distance_km') double totalDistanceKm,@JsonKey(name: 'initial_battery_level') int? initialBatteryLevel,@JsonKey(name: 'final_battery_level') int? finalBatteryLevel,@JsonKey(name: 'duration_seconds') int? durationSeconds,@JsonKey(name: 'battery_consumption') int? batteryConsumption
});




}
/// @nodoc
class _$TrackingSessionModelCopyWithImpl<$Res>
    implements $TrackingSessionModelCopyWith<$Res> {
  _$TrackingSessionModelCopyWithImpl(this._self, this._then);

  final TrackingSessionModel _self;
  final $Res Function(TrackingSessionModel) _then;

/// Create a copy of TrackingSessionModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? startedAt = null,Object? endedAt = freezed,Object? totalUpdates = null,Object? averageAccuracy = null,Object? totalDistanceKm = null,Object? initialBatteryLevel = freezed,Object? finalBatteryLevel = freezed,Object? durationSeconds = freezed,Object? batteryConsumption = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,totalUpdates: null == totalUpdates ? _self.totalUpdates : totalUpdates // ignore: cast_nullable_to_non_nullable
as int,averageAccuracy: null == averageAccuracy ? _self.averageAccuracy : averageAccuracy // ignore: cast_nullable_to_non_nullable
as double,totalDistanceKm: null == totalDistanceKm ? _self.totalDistanceKm : totalDistanceKm // ignore: cast_nullable_to_non_nullable
as double,initialBatteryLevel: freezed == initialBatteryLevel ? _self.initialBatteryLevel : initialBatteryLevel // ignore: cast_nullable_to_non_nullable
as int?,finalBatteryLevel: freezed == finalBatteryLevel ? _self.finalBatteryLevel : finalBatteryLevel // ignore: cast_nullable_to_non_nullable
as int?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,batteryConsumption: freezed == batteryConsumption ? _self.batteryConsumption : batteryConsumption // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackingSessionModel].
extension TrackingSessionModelPatterns on TrackingSessionModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackingSessionModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackingSessionModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackingSessionModel value)  $default,){
final _that = this;
switch (_that) {
case _TrackingSessionModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackingSessionModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrackingSessionModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'started_at')  DateTime startedAt, @JsonKey(name: 'ended_at')  DateTime? endedAt, @JsonKey(name: 'total_updates')  int totalUpdates, @JsonKey(name: 'average_accuracy')  double averageAccuracy, @JsonKey(name: 'total_distance_km')  double totalDistanceKm, @JsonKey(name: 'initial_battery_level')  int? initialBatteryLevel, @JsonKey(name: 'final_battery_level')  int? finalBatteryLevel, @JsonKey(name: 'duration_seconds')  int? durationSeconds, @JsonKey(name: 'battery_consumption')  int? batteryConsumption)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackingSessionModel() when $default != null:
return $default(_that.id,_that.startedAt,_that.endedAt,_that.totalUpdates,_that.averageAccuracy,_that.totalDistanceKm,_that.initialBatteryLevel,_that.finalBatteryLevel,_that.durationSeconds,_that.batteryConsumption);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: 'started_at')  DateTime startedAt, @JsonKey(name: 'ended_at')  DateTime? endedAt, @JsonKey(name: 'total_updates')  int totalUpdates, @JsonKey(name: 'average_accuracy')  double averageAccuracy, @JsonKey(name: 'total_distance_km')  double totalDistanceKm, @JsonKey(name: 'initial_battery_level')  int? initialBatteryLevel, @JsonKey(name: 'final_battery_level')  int? finalBatteryLevel, @JsonKey(name: 'duration_seconds')  int? durationSeconds, @JsonKey(name: 'battery_consumption')  int? batteryConsumption)  $default,) {final _that = this;
switch (_that) {
case _TrackingSessionModel():
return $default(_that.id,_that.startedAt,_that.endedAt,_that.totalUpdates,_that.averageAccuracy,_that.totalDistanceKm,_that.initialBatteryLevel,_that.finalBatteryLevel,_that.durationSeconds,_that.batteryConsumption);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: 'started_at')  DateTime startedAt, @JsonKey(name: 'ended_at')  DateTime? endedAt, @JsonKey(name: 'total_updates')  int totalUpdates, @JsonKey(name: 'average_accuracy')  double averageAccuracy, @JsonKey(name: 'total_distance_km')  double totalDistanceKm, @JsonKey(name: 'initial_battery_level')  int? initialBatteryLevel, @JsonKey(name: 'final_battery_level')  int? finalBatteryLevel, @JsonKey(name: 'duration_seconds')  int? durationSeconds, @JsonKey(name: 'battery_consumption')  int? batteryConsumption)?  $default,) {final _that = this;
switch (_that) {
case _TrackingSessionModel() when $default != null:
return $default(_that.id,_that.startedAt,_that.endedAt,_that.totalUpdates,_that.averageAccuracy,_that.totalDistanceKm,_that.initialBatteryLevel,_that.finalBatteryLevel,_that.durationSeconds,_that.batteryConsumption);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrackingSessionModel implements TrackingSessionModel {
  const _TrackingSessionModel({required this.id, @JsonKey(name: 'started_at') required this.startedAt, @JsonKey(name: 'ended_at') this.endedAt, @JsonKey(name: 'total_updates') required this.totalUpdates, @JsonKey(name: 'average_accuracy') required this.averageAccuracy, @JsonKey(name: 'total_distance_km') required this.totalDistanceKm, @JsonKey(name: 'initial_battery_level') this.initialBatteryLevel, @JsonKey(name: 'final_battery_level') this.finalBatteryLevel, @JsonKey(name: 'duration_seconds') this.durationSeconds, @JsonKey(name: 'battery_consumption') this.batteryConsumption});
  factory _TrackingSessionModel.fromJson(Map<String, dynamic> json) => _$TrackingSessionModelFromJson(json);

@override final  int id;
@override@JsonKey(name: 'started_at') final  DateTime startedAt;
@override@JsonKey(name: 'ended_at') final  DateTime? endedAt;
@override@JsonKey(name: 'total_updates') final  int totalUpdates;
@override@JsonKey(name: 'average_accuracy') final  double averageAccuracy;
@override@JsonKey(name: 'total_distance_km') final  double totalDistanceKm;
@override@JsonKey(name: 'initial_battery_level') final  int? initialBatteryLevel;
@override@JsonKey(name: 'final_battery_level') final  int? finalBatteryLevel;
@override@JsonKey(name: 'duration_seconds') final  int? durationSeconds;
@override@JsonKey(name: 'battery_consumption') final  int? batteryConsumption;

/// Create a copy of TrackingSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackingSessionModelCopyWith<_TrackingSessionModel> get copyWith => __$TrackingSessionModelCopyWithImpl<_TrackingSessionModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackingSessionModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackingSessionModel&&(identical(other.id, id) || other.id == id)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.totalUpdates, totalUpdates) || other.totalUpdates == totalUpdates)&&(identical(other.averageAccuracy, averageAccuracy) || other.averageAccuracy == averageAccuracy)&&(identical(other.totalDistanceKm, totalDistanceKm) || other.totalDistanceKm == totalDistanceKm)&&(identical(other.initialBatteryLevel, initialBatteryLevel) || other.initialBatteryLevel == initialBatteryLevel)&&(identical(other.finalBatteryLevel, finalBatteryLevel) || other.finalBatteryLevel == finalBatteryLevel)&&(identical(other.durationSeconds, durationSeconds) || other.durationSeconds == durationSeconds)&&(identical(other.batteryConsumption, batteryConsumption) || other.batteryConsumption == batteryConsumption));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,startedAt,endedAt,totalUpdates,averageAccuracy,totalDistanceKm,initialBatteryLevel,finalBatteryLevel,durationSeconds,batteryConsumption);

@override
String toString() {
  return 'TrackingSessionModel(id: $id, startedAt: $startedAt, endedAt: $endedAt, totalUpdates: $totalUpdates, averageAccuracy: $averageAccuracy, totalDistanceKm: $totalDistanceKm, initialBatteryLevel: $initialBatteryLevel, finalBatteryLevel: $finalBatteryLevel, durationSeconds: $durationSeconds, batteryConsumption: $batteryConsumption)';
}


}

/// @nodoc
abstract mixin class _$TrackingSessionModelCopyWith<$Res> implements $TrackingSessionModelCopyWith<$Res> {
  factory _$TrackingSessionModelCopyWith(_TrackingSessionModel value, $Res Function(_TrackingSessionModel) _then) = __$TrackingSessionModelCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: 'started_at') DateTime startedAt,@JsonKey(name: 'ended_at') DateTime? endedAt,@JsonKey(name: 'total_updates') int totalUpdates,@JsonKey(name: 'average_accuracy') double averageAccuracy,@JsonKey(name: 'total_distance_km') double totalDistanceKm,@JsonKey(name: 'initial_battery_level') int? initialBatteryLevel,@JsonKey(name: 'final_battery_level') int? finalBatteryLevel,@JsonKey(name: 'duration_seconds') int? durationSeconds,@JsonKey(name: 'battery_consumption') int? batteryConsumption
});




}
/// @nodoc
class __$TrackingSessionModelCopyWithImpl<$Res>
    implements _$TrackingSessionModelCopyWith<$Res> {
  __$TrackingSessionModelCopyWithImpl(this._self, this._then);

  final _TrackingSessionModel _self;
  final $Res Function(_TrackingSessionModel) _then;

/// Create a copy of TrackingSessionModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? startedAt = null,Object? endedAt = freezed,Object? totalUpdates = null,Object? averageAccuracy = null,Object? totalDistanceKm = null,Object? initialBatteryLevel = freezed,Object? finalBatteryLevel = freezed,Object? durationSeconds = freezed,Object? batteryConsumption = freezed,}) {
  return _then(_TrackingSessionModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,totalUpdates: null == totalUpdates ? _self.totalUpdates : totalUpdates // ignore: cast_nullable_to_non_nullable
as int,averageAccuracy: null == averageAccuracy ? _self.averageAccuracy : averageAccuracy // ignore: cast_nullable_to_non_nullable
as double,totalDistanceKm: null == totalDistanceKm ? _self.totalDistanceKm : totalDistanceKm // ignore: cast_nullable_to_non_nullable
as double,initialBatteryLevel: freezed == initialBatteryLevel ? _self.initialBatteryLevel : initialBatteryLevel // ignore: cast_nullable_to_non_nullable
as int?,finalBatteryLevel: freezed == finalBatteryLevel ? _self.finalBatteryLevel : finalBatteryLevel // ignore: cast_nullable_to_non_nullable
as int?,durationSeconds: freezed == durationSeconds ? _self.durationSeconds : durationSeconds // ignore: cast_nullable_to_non_nullable
as int?,batteryConsumption: freezed == batteryConsumption ? _self.batteryConsumption : batteryConsumption // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$TrackingStatisticsModel {

@JsonKey(name: 'total_updates') int get totalUpdates;@JsonKey(name: 'total_sessions') int get totalSessions;@JsonKey(name: 'total_distance_km') double get totalDistanceKm;@JsonKey(name: 'average_accuracy_m') double get averageAccuracyM;@JsonKey(name: 'updates_per_day') double get updatesPerDay;
/// Create a copy of TrackingStatisticsModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackingStatisticsModelCopyWith<TrackingStatisticsModel> get copyWith => _$TrackingStatisticsModelCopyWithImpl<TrackingStatisticsModel>(this as TrackingStatisticsModel, _$identity);

  /// Serializes this TrackingStatisticsModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackingStatisticsModel&&(identical(other.totalUpdates, totalUpdates) || other.totalUpdates == totalUpdates)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.totalDistanceKm, totalDistanceKm) || other.totalDistanceKm == totalDistanceKm)&&(identical(other.averageAccuracyM, averageAccuracyM) || other.averageAccuracyM == averageAccuracyM)&&(identical(other.updatesPerDay, updatesPerDay) || other.updatesPerDay == updatesPerDay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUpdates,totalSessions,totalDistanceKm,averageAccuracyM,updatesPerDay);

@override
String toString() {
  return 'TrackingStatisticsModel(totalUpdates: $totalUpdates, totalSessions: $totalSessions, totalDistanceKm: $totalDistanceKm, averageAccuracyM: $averageAccuracyM, updatesPerDay: $updatesPerDay)';
}


}

/// @nodoc
abstract mixin class $TrackingStatisticsModelCopyWith<$Res>  {
  factory $TrackingStatisticsModelCopyWith(TrackingStatisticsModel value, $Res Function(TrackingStatisticsModel) _then) = _$TrackingStatisticsModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'total_updates') int totalUpdates,@JsonKey(name: 'total_sessions') int totalSessions,@JsonKey(name: 'total_distance_km') double totalDistanceKm,@JsonKey(name: 'average_accuracy_m') double averageAccuracyM,@JsonKey(name: 'updates_per_day') double updatesPerDay
});




}
/// @nodoc
class _$TrackingStatisticsModelCopyWithImpl<$Res>
    implements $TrackingStatisticsModelCopyWith<$Res> {
  _$TrackingStatisticsModelCopyWithImpl(this._self, this._then);

  final TrackingStatisticsModel _self;
  final $Res Function(TrackingStatisticsModel) _then;

/// Create a copy of TrackingStatisticsModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalUpdates = null,Object? totalSessions = null,Object? totalDistanceKm = null,Object? averageAccuracyM = null,Object? updatesPerDay = null,}) {
  return _then(_self.copyWith(
totalUpdates: null == totalUpdates ? _self.totalUpdates : totalUpdates // ignore: cast_nullable_to_non_nullable
as int,totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,totalDistanceKm: null == totalDistanceKm ? _self.totalDistanceKm : totalDistanceKm // ignore: cast_nullable_to_non_nullable
as double,averageAccuracyM: null == averageAccuracyM ? _self.averageAccuracyM : averageAccuracyM // ignore: cast_nullable_to_non_nullable
as double,updatesPerDay: null == updatesPerDay ? _self.updatesPerDay : updatesPerDay // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackingStatisticsModel].
extension TrackingStatisticsModelPatterns on TrackingStatisticsModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackingStatisticsModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackingStatisticsModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackingStatisticsModel value)  $default,){
final _that = this;
switch (_that) {
case _TrackingStatisticsModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackingStatisticsModel value)?  $default,){
final _that = this;
switch (_that) {
case _TrackingStatisticsModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_updates')  int totalUpdates, @JsonKey(name: 'total_sessions')  int totalSessions, @JsonKey(name: 'total_distance_km')  double totalDistanceKm, @JsonKey(name: 'average_accuracy_m')  double averageAccuracyM, @JsonKey(name: 'updates_per_day')  double updatesPerDay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackingStatisticsModel() when $default != null:
return $default(_that.totalUpdates,_that.totalSessions,_that.totalDistanceKm,_that.averageAccuracyM,_that.updatesPerDay);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_updates')  int totalUpdates, @JsonKey(name: 'total_sessions')  int totalSessions, @JsonKey(name: 'total_distance_km')  double totalDistanceKm, @JsonKey(name: 'average_accuracy_m')  double averageAccuracyM, @JsonKey(name: 'updates_per_day')  double updatesPerDay)  $default,) {final _that = this;
switch (_that) {
case _TrackingStatisticsModel():
return $default(_that.totalUpdates,_that.totalSessions,_that.totalDistanceKm,_that.averageAccuracyM,_that.updatesPerDay);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'total_updates')  int totalUpdates, @JsonKey(name: 'total_sessions')  int totalSessions, @JsonKey(name: 'total_distance_km')  double totalDistanceKm, @JsonKey(name: 'average_accuracy_m')  double averageAccuracyM, @JsonKey(name: 'updates_per_day')  double updatesPerDay)?  $default,) {final _that = this;
switch (_that) {
case _TrackingStatisticsModel() when $default != null:
return $default(_that.totalUpdates,_that.totalSessions,_that.totalDistanceKm,_that.averageAccuracyM,_that.updatesPerDay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrackingStatisticsModel implements TrackingStatisticsModel {
  const _TrackingStatisticsModel({@JsonKey(name: 'total_updates') required this.totalUpdates, @JsonKey(name: 'total_sessions') required this.totalSessions, @JsonKey(name: 'total_distance_km') required this.totalDistanceKm, @JsonKey(name: 'average_accuracy_m') required this.averageAccuracyM, @JsonKey(name: 'updates_per_day') required this.updatesPerDay});
  factory _TrackingStatisticsModel.fromJson(Map<String, dynamic> json) => _$TrackingStatisticsModelFromJson(json);

@override@JsonKey(name: 'total_updates') final  int totalUpdates;
@override@JsonKey(name: 'total_sessions') final  int totalSessions;
@override@JsonKey(name: 'total_distance_km') final  double totalDistanceKm;
@override@JsonKey(name: 'average_accuracy_m') final  double averageAccuracyM;
@override@JsonKey(name: 'updates_per_day') final  double updatesPerDay;

/// Create a copy of TrackingStatisticsModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackingStatisticsModelCopyWith<_TrackingStatisticsModel> get copyWith => __$TrackingStatisticsModelCopyWithImpl<_TrackingStatisticsModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrackingStatisticsModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackingStatisticsModel&&(identical(other.totalUpdates, totalUpdates) || other.totalUpdates == totalUpdates)&&(identical(other.totalSessions, totalSessions) || other.totalSessions == totalSessions)&&(identical(other.totalDistanceKm, totalDistanceKm) || other.totalDistanceKm == totalDistanceKm)&&(identical(other.averageAccuracyM, averageAccuracyM) || other.averageAccuracyM == averageAccuracyM)&&(identical(other.updatesPerDay, updatesPerDay) || other.updatesPerDay == updatesPerDay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalUpdates,totalSessions,totalDistanceKm,averageAccuracyM,updatesPerDay);

@override
String toString() {
  return 'TrackingStatisticsModel(totalUpdates: $totalUpdates, totalSessions: $totalSessions, totalDistanceKm: $totalDistanceKm, averageAccuracyM: $averageAccuracyM, updatesPerDay: $updatesPerDay)';
}


}

/// @nodoc
abstract mixin class _$TrackingStatisticsModelCopyWith<$Res> implements $TrackingStatisticsModelCopyWith<$Res> {
  factory _$TrackingStatisticsModelCopyWith(_TrackingStatisticsModel value, $Res Function(_TrackingStatisticsModel) _then) = __$TrackingStatisticsModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'total_updates') int totalUpdates,@JsonKey(name: 'total_sessions') int totalSessions,@JsonKey(name: 'total_distance_km') double totalDistanceKm,@JsonKey(name: 'average_accuracy_m') double averageAccuracyM,@JsonKey(name: 'updates_per_day') double updatesPerDay
});




}
/// @nodoc
class __$TrackingStatisticsModelCopyWithImpl<$Res>
    implements _$TrackingStatisticsModelCopyWith<$Res> {
  __$TrackingStatisticsModelCopyWithImpl(this._self, this._then);

  final _TrackingStatisticsModel _self;
  final $Res Function(_TrackingStatisticsModel) _then;

/// Create a copy of TrackingStatisticsModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalUpdates = null,Object? totalSessions = null,Object? totalDistanceKm = null,Object? averageAccuracyM = null,Object? updatesPerDay = null,}) {
  return _then(_TrackingStatisticsModel(
totalUpdates: null == totalUpdates ? _self.totalUpdates : totalUpdates // ignore: cast_nullable_to_non_nullable
as int,totalSessions: null == totalSessions ? _self.totalSessions : totalSessions // ignore: cast_nullable_to_non_nullable
as int,totalDistanceKm: null == totalDistanceKm ? _self.totalDistanceKm : totalDistanceKm // ignore: cast_nullable_to_non_nullable
as double,averageAccuracyM: null == averageAccuracyM ? _self.averageAccuracyM : averageAccuracyM // ignore: cast_nullable_to_non_nullable
as double,updatesPerDay: null == updatesPerDay ? _self.updatesPerDay : updatesPerDay // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
