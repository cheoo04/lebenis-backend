// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'heatmap_point_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HeatmapPointModel {

 double get lat; double get lng; int get weight;
/// Create a copy of HeatmapPointModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HeatmapPointModelCopyWith<HeatmapPointModel> get copyWith => _$HeatmapPointModelCopyWithImpl<HeatmapPointModel>(this as HeatmapPointModel, _$identity);

  /// Serializes this HeatmapPointModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HeatmapPointModel&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.weight, weight) || other.weight == weight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lat,lng,weight);

@override
String toString() {
  return 'HeatmapPointModel(lat: $lat, lng: $lng, weight: $weight)';
}


}

/// @nodoc
abstract mixin class $HeatmapPointModelCopyWith<$Res>  {
  factory $HeatmapPointModelCopyWith(HeatmapPointModel value, $Res Function(HeatmapPointModel) _then) = _$HeatmapPointModelCopyWithImpl;
@useResult
$Res call({
 double lat, double lng, int weight
});




}
/// @nodoc
class _$HeatmapPointModelCopyWithImpl<$Res>
    implements $HeatmapPointModelCopyWith<$Res> {
  _$HeatmapPointModelCopyWithImpl(this._self, this._then);

  final HeatmapPointModel _self;
  final $Res Function(HeatmapPointModel) _then;

/// Create a copy of HeatmapPointModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lat = null,Object? lng = null,Object? weight = null,}) {
  return _then(_self.copyWith(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [HeatmapPointModel].
extension HeatmapPointModelPatterns on HeatmapPointModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HeatmapPointModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HeatmapPointModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HeatmapPointModel value)  $default,){
final _that = this;
switch (_that) {
case _HeatmapPointModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HeatmapPointModel value)?  $default,){
final _that = this;
switch (_that) {
case _HeatmapPointModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double lat,  double lng,  int weight)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HeatmapPointModel() when $default != null:
return $default(_that.lat,_that.lng,_that.weight);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double lat,  double lng,  int weight)  $default,) {final _that = this;
switch (_that) {
case _HeatmapPointModel():
return $default(_that.lat,_that.lng,_that.weight);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double lat,  double lng,  int weight)?  $default,) {final _that = this;
switch (_that) {
case _HeatmapPointModel() when $default != null:
return $default(_that.lat,_that.lng,_that.weight);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HeatmapPointModel implements HeatmapPointModel {
  const _HeatmapPointModel({required this.lat, required this.lng, required this.weight});
  factory _HeatmapPointModel.fromJson(Map<String, dynamic> json) => _$HeatmapPointModelFromJson(json);

@override final  double lat;
@override final  double lng;
@override final  int weight;

/// Create a copy of HeatmapPointModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HeatmapPointModelCopyWith<_HeatmapPointModel> get copyWith => __$HeatmapPointModelCopyWithImpl<_HeatmapPointModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HeatmapPointModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HeatmapPointModel&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.weight, weight) || other.weight == weight));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,lat,lng,weight);

@override
String toString() {
  return 'HeatmapPointModel(lat: $lat, lng: $lng, weight: $weight)';
}


}

/// @nodoc
abstract mixin class _$HeatmapPointModelCopyWith<$Res> implements $HeatmapPointModelCopyWith<$Res> {
  factory _$HeatmapPointModelCopyWith(_HeatmapPointModel value, $Res Function(_HeatmapPointModel) _then) = __$HeatmapPointModelCopyWithImpl;
@override @useResult
$Res call({
 double lat, double lng, int weight
});




}
/// @nodoc
class __$HeatmapPointModelCopyWithImpl<$Res>
    implements _$HeatmapPointModelCopyWith<$Res> {
  __$HeatmapPointModelCopyWithImpl(this._self, this._then);

  final _HeatmapPointModel _self;
  final $Res Function(_HeatmapPointModel) _then;

/// Create a copy of HeatmapPointModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lat = null,Object? lng = null,Object? weight = null,}) {
  return _then(_HeatmapPointModel(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$HeatmapResponseModel {

 List<HeatmapPointModel> get points;
/// Create a copy of HeatmapResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HeatmapResponseModelCopyWith<HeatmapResponseModel> get copyWith => _$HeatmapResponseModelCopyWithImpl<HeatmapResponseModel>(this as HeatmapResponseModel, _$identity);

  /// Serializes this HeatmapResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HeatmapResponseModel&&const DeepCollectionEquality().equals(other.points, points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(points));

@override
String toString() {
  return 'HeatmapResponseModel(points: $points)';
}


}

/// @nodoc
abstract mixin class $HeatmapResponseModelCopyWith<$Res>  {
  factory $HeatmapResponseModelCopyWith(HeatmapResponseModel value, $Res Function(HeatmapResponseModel) _then) = _$HeatmapResponseModelCopyWithImpl;
@useResult
$Res call({
 List<HeatmapPointModel> points
});




}
/// @nodoc
class _$HeatmapResponseModelCopyWithImpl<$Res>
    implements $HeatmapResponseModelCopyWith<$Res> {
  _$HeatmapResponseModelCopyWithImpl(this._self, this._then);

  final HeatmapResponseModel _self;
  final $Res Function(HeatmapResponseModel) _then;

/// Create a copy of HeatmapResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? points = null,}) {
  return _then(_self.copyWith(
points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<HeatmapPointModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [HeatmapResponseModel].
extension HeatmapResponseModelPatterns on HeatmapResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HeatmapResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HeatmapResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HeatmapResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _HeatmapResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HeatmapResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _HeatmapResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<HeatmapPointModel> points)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HeatmapResponseModel() when $default != null:
return $default(_that.points);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<HeatmapPointModel> points)  $default,) {final _that = this;
switch (_that) {
case _HeatmapResponseModel():
return $default(_that.points);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<HeatmapPointModel> points)?  $default,) {final _that = this;
switch (_that) {
case _HeatmapResponseModel() when $default != null:
return $default(_that.points);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HeatmapResponseModel implements HeatmapResponseModel {
  const _HeatmapResponseModel({required final  List<HeatmapPointModel> points}): _points = points;
  factory _HeatmapResponseModel.fromJson(Map<String, dynamic> json) => _$HeatmapResponseModelFromJson(json);

 final  List<HeatmapPointModel> _points;
@override List<HeatmapPointModel> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}


/// Create a copy of HeatmapResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HeatmapResponseModelCopyWith<_HeatmapResponseModel> get copyWith => __$HeatmapResponseModelCopyWithImpl<_HeatmapResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HeatmapResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HeatmapResponseModel&&const DeepCollectionEquality().equals(other._points, _points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_points));

@override
String toString() {
  return 'HeatmapResponseModel(points: $points)';
}


}

/// @nodoc
abstract mixin class _$HeatmapResponseModelCopyWith<$Res> implements $HeatmapResponseModelCopyWith<$Res> {
  factory _$HeatmapResponseModelCopyWith(_HeatmapResponseModel value, $Res Function(_HeatmapResponseModel) _then) = __$HeatmapResponseModelCopyWithImpl;
@override @useResult
$Res call({
 List<HeatmapPointModel> points
});




}
/// @nodoc
class __$HeatmapResponseModelCopyWithImpl<$Res>
    implements _$HeatmapResponseModelCopyWith<$Res> {
  __$HeatmapResponseModelCopyWithImpl(this._self, this._then);

  final _HeatmapResponseModel _self;
  final $Res Function(_HeatmapResponseModel) _then;

/// Create a copy of HeatmapResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? points = null,}) {
  return _then(_HeatmapResponseModel(
points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<HeatmapPointModel>,
  ));
}


}

// dart format on
