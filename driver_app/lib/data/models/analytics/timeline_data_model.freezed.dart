// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline_data_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimelineDataModel {

 String get date; int get deliveriesCount; double get totalEarnings;
/// Create a copy of TimelineDataModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelineDataModelCopyWith<TimelineDataModel> get copyWith => _$TimelineDataModelCopyWithImpl<TimelineDataModel>(this as TimelineDataModel, _$identity);

  /// Serializes this TimelineDataModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineDataModel&&(identical(other.date, date) || other.date == date)&&(identical(other.deliveriesCount, deliveriesCount) || other.deliveriesCount == deliveriesCount)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,deliveriesCount,totalEarnings);

@override
String toString() {
  return 'TimelineDataModel(date: $date, deliveriesCount: $deliveriesCount, totalEarnings: $totalEarnings)';
}


}

/// @nodoc
abstract mixin class $TimelineDataModelCopyWith<$Res>  {
  factory $TimelineDataModelCopyWith(TimelineDataModel value, $Res Function(TimelineDataModel) _then) = _$TimelineDataModelCopyWithImpl;
@useResult
$Res call({
 String date, int deliveriesCount, double totalEarnings
});




}
/// @nodoc
class _$TimelineDataModelCopyWithImpl<$Res>
    implements $TimelineDataModelCopyWith<$Res> {
  _$TimelineDataModelCopyWithImpl(this._self, this._then);

  final TimelineDataModel _self;
  final $Res Function(TimelineDataModel) _then;

/// Create a copy of TimelineDataModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? deliveriesCount = null,Object? totalEarnings = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,deliveriesCount: null == deliveriesCount ? _self.deliveriesCount : deliveriesCount // ignore: cast_nullable_to_non_nullable
as int,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TimelineDataModel].
extension TimelineDataModelPatterns on TimelineDataModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimelineDataModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimelineDataModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimelineDataModel value)  $default,){
final _that = this;
switch (_that) {
case _TimelineDataModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimelineDataModel value)?  $default,){
final _that = this;
switch (_that) {
case _TimelineDataModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  int deliveriesCount,  double totalEarnings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimelineDataModel() when $default != null:
return $default(_that.date,_that.deliveriesCount,_that.totalEarnings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  int deliveriesCount,  double totalEarnings)  $default,) {final _that = this;
switch (_that) {
case _TimelineDataModel():
return $default(_that.date,_that.deliveriesCount,_that.totalEarnings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  int deliveriesCount,  double totalEarnings)?  $default,) {final _that = this;
switch (_that) {
case _TimelineDataModel() when $default != null:
return $default(_that.date,_that.deliveriesCount,_that.totalEarnings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimelineDataModel implements TimelineDataModel {
  const _TimelineDataModel({required this.date, required this.deliveriesCount, required this.totalEarnings});
  factory _TimelineDataModel.fromJson(Map<String, dynamic> json) => _$TimelineDataModelFromJson(json);

@override final  String date;
@override final  int deliveriesCount;
@override final  double totalEarnings;

/// Create a copy of TimelineDataModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimelineDataModelCopyWith<_TimelineDataModel> get copyWith => __$TimelineDataModelCopyWithImpl<_TimelineDataModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimelineDataModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimelineDataModel&&(identical(other.date, date) || other.date == date)&&(identical(other.deliveriesCount, deliveriesCount) || other.deliveriesCount == deliveriesCount)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,deliveriesCount,totalEarnings);

@override
String toString() {
  return 'TimelineDataModel(date: $date, deliveriesCount: $deliveriesCount, totalEarnings: $totalEarnings)';
}


}

/// @nodoc
abstract mixin class _$TimelineDataModelCopyWith<$Res> implements $TimelineDataModelCopyWith<$Res> {
  factory _$TimelineDataModelCopyWith(_TimelineDataModel value, $Res Function(_TimelineDataModel) _then) = __$TimelineDataModelCopyWithImpl;
@override @useResult
$Res call({
 String date, int deliveriesCount, double totalEarnings
});




}
/// @nodoc
class __$TimelineDataModelCopyWithImpl<$Res>
    implements _$TimelineDataModelCopyWith<$Res> {
  __$TimelineDataModelCopyWithImpl(this._self, this._then);

  final _TimelineDataModel _self;
  final $Res Function(_TimelineDataModel) _then;

/// Create a copy of TimelineDataModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? deliveriesCount = null,Object? totalEarnings = null,}) {
  return _then(_TimelineDataModel(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,deliveriesCount: null == deliveriesCount ? _self.deliveriesCount : deliveriesCount // ignore: cast_nullable_to_non_nullable
as int,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$TimelineResponseModel {

 List<TimelineDataModel> get timeline;
/// Create a copy of TimelineResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimelineResponseModelCopyWith<TimelineResponseModel> get copyWith => _$TimelineResponseModelCopyWithImpl<TimelineResponseModel>(this as TimelineResponseModel, _$identity);

  /// Serializes this TimelineResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimelineResponseModel&&const DeepCollectionEquality().equals(other.timeline, timeline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(timeline));

@override
String toString() {
  return 'TimelineResponseModel(timeline: $timeline)';
}


}

/// @nodoc
abstract mixin class $TimelineResponseModelCopyWith<$Res>  {
  factory $TimelineResponseModelCopyWith(TimelineResponseModel value, $Res Function(TimelineResponseModel) _then) = _$TimelineResponseModelCopyWithImpl;
@useResult
$Res call({
 List<TimelineDataModel> timeline
});




}
/// @nodoc
class _$TimelineResponseModelCopyWithImpl<$Res>
    implements $TimelineResponseModelCopyWith<$Res> {
  _$TimelineResponseModelCopyWithImpl(this._self, this._then);

  final TimelineResponseModel _self;
  final $Res Function(TimelineResponseModel) _then;

/// Create a copy of TimelineResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? timeline = null,}) {
  return _then(_self.copyWith(
timeline: null == timeline ? _self.timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<TimelineDataModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [TimelineResponseModel].
extension TimelineResponseModelPatterns on TimelineResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimelineResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimelineResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimelineResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _TimelineResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimelineResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _TimelineResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TimelineDataModel> timeline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimelineResponseModel() when $default != null:
return $default(_that.timeline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TimelineDataModel> timeline)  $default,) {final _that = this;
switch (_that) {
case _TimelineResponseModel():
return $default(_that.timeline);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TimelineDataModel> timeline)?  $default,) {final _that = this;
switch (_that) {
case _TimelineResponseModel() when $default != null:
return $default(_that.timeline);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimelineResponseModel implements TimelineResponseModel {
  const _TimelineResponseModel({required final  List<TimelineDataModel> timeline}): _timeline = timeline;
  factory _TimelineResponseModel.fromJson(Map<String, dynamic> json) => _$TimelineResponseModelFromJson(json);

 final  List<TimelineDataModel> _timeline;
@override List<TimelineDataModel> get timeline {
  if (_timeline is EqualUnmodifiableListView) return _timeline;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timeline);
}


/// Create a copy of TimelineResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimelineResponseModelCopyWith<_TimelineResponseModel> get copyWith => __$TimelineResponseModelCopyWithImpl<_TimelineResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimelineResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimelineResponseModel&&const DeepCollectionEquality().equals(other._timeline, _timeline));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_timeline));

@override
String toString() {
  return 'TimelineResponseModel(timeline: $timeline)';
}


}

/// @nodoc
abstract mixin class _$TimelineResponseModelCopyWith<$Res> implements $TimelineResponseModelCopyWith<$Res> {
  factory _$TimelineResponseModelCopyWith(_TimelineResponseModel value, $Res Function(_TimelineResponseModel) _then) = __$TimelineResponseModelCopyWithImpl;
@override @useResult
$Res call({
 List<TimelineDataModel> timeline
});




}
/// @nodoc
class __$TimelineResponseModelCopyWithImpl<$Res>
    implements _$TimelineResponseModelCopyWith<$Res> {
  __$TimelineResponseModelCopyWithImpl(this._self, this._then);

  final _TimelineResponseModel _self;
  final $Res Function(_TimelineResponseModel) _then;

/// Create a copy of TimelineResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? timeline = null,}) {
  return _then(_TimelineResponseModel(
timeline: null == timeline ? _self._timeline : timeline // ignore: cast_nullable_to_non_nullable
as List<TimelineDataModel>,
  ));
}


}

// dart format on
