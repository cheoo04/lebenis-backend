// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'peak_hours_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PeakHourModel {

 int get hour; int get deliveriesCount; double get totalEarnings;
/// Create a copy of PeakHourModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeakHourModelCopyWith<PeakHourModel> get copyWith => _$PeakHourModelCopyWithImpl<PeakHourModel>(this as PeakHourModel, _$identity);

  /// Serializes this PeakHourModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeakHourModel&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.deliveriesCount, deliveriesCount) || other.deliveriesCount == deliveriesCount)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hour,deliveriesCount,totalEarnings);

@override
String toString() {
  return 'PeakHourModel(hour: $hour, deliveriesCount: $deliveriesCount, totalEarnings: $totalEarnings)';
}


}

/// @nodoc
abstract mixin class $PeakHourModelCopyWith<$Res>  {
  factory $PeakHourModelCopyWith(PeakHourModel value, $Res Function(PeakHourModel) _then) = _$PeakHourModelCopyWithImpl;
@useResult
$Res call({
 int hour, int deliveriesCount, double totalEarnings
});




}
/// @nodoc
class _$PeakHourModelCopyWithImpl<$Res>
    implements $PeakHourModelCopyWith<$Res> {
  _$PeakHourModelCopyWithImpl(this._self, this._then);

  final PeakHourModel _self;
  final $Res Function(PeakHourModel) _then;

/// Create a copy of PeakHourModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hour = null,Object? deliveriesCount = null,Object? totalEarnings = null,}) {
  return _then(_self.copyWith(
hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,deliveriesCount: null == deliveriesCount ? _self.deliveriesCount : deliveriesCount // ignore: cast_nullable_to_non_nullable
as int,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PeakHourModel].
extension PeakHourModelPatterns on PeakHourModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PeakHourModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PeakHourModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PeakHourModel value)  $default,){
final _that = this;
switch (_that) {
case _PeakHourModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PeakHourModel value)?  $default,){
final _that = this;
switch (_that) {
case _PeakHourModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int hour,  int deliveriesCount,  double totalEarnings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PeakHourModel() when $default != null:
return $default(_that.hour,_that.deliveriesCount,_that.totalEarnings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int hour,  int deliveriesCount,  double totalEarnings)  $default,) {final _that = this;
switch (_that) {
case _PeakHourModel():
return $default(_that.hour,_that.deliveriesCount,_that.totalEarnings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int hour,  int deliveriesCount,  double totalEarnings)?  $default,) {final _that = this;
switch (_that) {
case _PeakHourModel() when $default != null:
return $default(_that.hour,_that.deliveriesCount,_that.totalEarnings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PeakHourModel implements PeakHourModel {
  const _PeakHourModel({required this.hour, required this.deliveriesCount, required this.totalEarnings});
  factory _PeakHourModel.fromJson(Map<String, dynamic> json) => _$PeakHourModelFromJson(json);

@override final  int hour;
@override final  int deliveriesCount;
@override final  double totalEarnings;

/// Create a copy of PeakHourModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeakHourModelCopyWith<_PeakHourModel> get copyWith => __$PeakHourModelCopyWithImpl<_PeakHourModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PeakHourModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeakHourModel&&(identical(other.hour, hour) || other.hour == hour)&&(identical(other.deliveriesCount, deliveriesCount) || other.deliveriesCount == deliveriesCount)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,hour,deliveriesCount,totalEarnings);

@override
String toString() {
  return 'PeakHourModel(hour: $hour, deliveriesCount: $deliveriesCount, totalEarnings: $totalEarnings)';
}


}

/// @nodoc
abstract mixin class _$PeakHourModelCopyWith<$Res> implements $PeakHourModelCopyWith<$Res> {
  factory _$PeakHourModelCopyWith(_PeakHourModel value, $Res Function(_PeakHourModel) _then) = __$PeakHourModelCopyWithImpl;
@override @useResult
$Res call({
 int hour, int deliveriesCount, double totalEarnings
});




}
/// @nodoc
class __$PeakHourModelCopyWithImpl<$Res>
    implements _$PeakHourModelCopyWith<$Res> {
  __$PeakHourModelCopyWithImpl(this._self, this._then);

  final _PeakHourModel _self;
  final $Res Function(_PeakHourModel) _then;

/// Create a copy of PeakHourModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hour = null,Object? deliveriesCount = null,Object? totalEarnings = null,}) {
  return _then(_PeakHourModel(
hour: null == hour ? _self.hour : hour // ignore: cast_nullable_to_non_nullable
as int,deliveriesCount: null == deliveriesCount ? _self.deliveriesCount : deliveriesCount // ignore: cast_nullable_to_non_nullable
as int,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$PeakHoursResponseModel {

 List<PeakHourModel> get peakHours;
/// Create a copy of PeakHoursResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PeakHoursResponseModelCopyWith<PeakHoursResponseModel> get copyWith => _$PeakHoursResponseModelCopyWithImpl<PeakHoursResponseModel>(this as PeakHoursResponseModel, _$identity);

  /// Serializes this PeakHoursResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PeakHoursResponseModel&&const DeepCollectionEquality().equals(other.peakHours, peakHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(peakHours));

@override
String toString() {
  return 'PeakHoursResponseModel(peakHours: $peakHours)';
}


}

/// @nodoc
abstract mixin class $PeakHoursResponseModelCopyWith<$Res>  {
  factory $PeakHoursResponseModelCopyWith(PeakHoursResponseModel value, $Res Function(PeakHoursResponseModel) _then) = _$PeakHoursResponseModelCopyWithImpl;
@useResult
$Res call({
 List<PeakHourModel> peakHours
});




}
/// @nodoc
class _$PeakHoursResponseModelCopyWithImpl<$Res>
    implements $PeakHoursResponseModelCopyWith<$Res> {
  _$PeakHoursResponseModelCopyWithImpl(this._self, this._then);

  final PeakHoursResponseModel _self;
  final $Res Function(PeakHoursResponseModel) _then;

/// Create a copy of PeakHoursResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? peakHours = null,}) {
  return _then(_self.copyWith(
peakHours: null == peakHours ? _self.peakHours : peakHours // ignore: cast_nullable_to_non_nullable
as List<PeakHourModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [PeakHoursResponseModel].
extension PeakHoursResponseModelPatterns on PeakHoursResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PeakHoursResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PeakHoursResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PeakHoursResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _PeakHoursResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PeakHoursResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _PeakHoursResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PeakHourModel> peakHours)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PeakHoursResponseModel() when $default != null:
return $default(_that.peakHours);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PeakHourModel> peakHours)  $default,) {final _that = this;
switch (_that) {
case _PeakHoursResponseModel():
return $default(_that.peakHours);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PeakHourModel> peakHours)?  $default,) {final _that = this;
switch (_that) {
case _PeakHoursResponseModel() when $default != null:
return $default(_that.peakHours);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PeakHoursResponseModel implements PeakHoursResponseModel {
  const _PeakHoursResponseModel({required final  List<PeakHourModel> peakHours}): _peakHours = peakHours;
  factory _PeakHoursResponseModel.fromJson(Map<String, dynamic> json) => _$PeakHoursResponseModelFromJson(json);

 final  List<PeakHourModel> _peakHours;
@override List<PeakHourModel> get peakHours {
  if (_peakHours is EqualUnmodifiableListView) return _peakHours;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_peakHours);
}


/// Create a copy of PeakHoursResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PeakHoursResponseModelCopyWith<_PeakHoursResponseModel> get copyWith => __$PeakHoursResponseModelCopyWithImpl<_PeakHoursResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PeakHoursResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PeakHoursResponseModel&&const DeepCollectionEquality().equals(other._peakHours, _peakHours));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_peakHours));

@override
String toString() {
  return 'PeakHoursResponseModel(peakHours: $peakHours)';
}


}

/// @nodoc
abstract mixin class _$PeakHoursResponseModelCopyWith<$Res> implements $PeakHoursResponseModelCopyWith<$Res> {
  factory _$PeakHoursResponseModelCopyWith(_PeakHoursResponseModel value, $Res Function(_PeakHoursResponseModel) _then) = __$PeakHoursResponseModelCopyWithImpl;
@override @useResult
$Res call({
 List<PeakHourModel> peakHours
});




}
/// @nodoc
class __$PeakHoursResponseModelCopyWithImpl<$Res>
    implements _$PeakHoursResponseModelCopyWith<$Res> {
  __$PeakHoursResponseModelCopyWithImpl(this._self, this._then);

  final _PeakHoursResponseModel _self;
  final $Res Function(_PeakHoursResponseModel) _then;

/// Create a copy of PeakHoursResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? peakHours = null,}) {
  return _then(_PeakHoursResponseModel(
peakHours: null == peakHours ? _self._peakHours : peakHours // ignore: cast_nullable_to_non_nullable
as List<PeakHourModel>,
  ));
}


}

// dart format on
