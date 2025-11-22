// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stats_summary_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StatsSummaryModel {

@JsonKey(name: 'total_deliveries') int get totalDeliveries;@JsonKey(name: 'completed_deliveries') int get completedDeliveries;@JsonKey(name: 'cancelled_deliveries') int get cancelledDeliveries;@JsonKey(name: 'in_progress_deliveries') int get inProgressDeliveries;@JsonKey(name: 'total_earnings') double get totalEarnings;@JsonKey(name: 'total_distance_km') double get totalDistanceKm;@JsonKey(name: 'success_rate') double get successRate;@JsonKey(name: 'average_delivery_value') double get averageDeliveryValue;
/// Create a copy of StatsSummaryModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsSummaryModelCopyWith<StatsSummaryModel> get copyWith => _$StatsSummaryModelCopyWithImpl<StatsSummaryModel>(this as StatsSummaryModel, _$identity);

  /// Serializes this StatsSummaryModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsSummaryModel&&(identical(other.totalDeliveries, totalDeliveries) || other.totalDeliveries == totalDeliveries)&&(identical(other.completedDeliveries, completedDeliveries) || other.completedDeliveries == completedDeliveries)&&(identical(other.cancelledDeliveries, cancelledDeliveries) || other.cancelledDeliveries == cancelledDeliveries)&&(identical(other.inProgressDeliveries, inProgressDeliveries) || other.inProgressDeliveries == inProgressDeliveries)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings)&&(identical(other.totalDistanceKm, totalDistanceKm) || other.totalDistanceKm == totalDistanceKm)&&(identical(other.successRate, successRate) || other.successRate == successRate)&&(identical(other.averageDeliveryValue, averageDeliveryValue) || other.averageDeliveryValue == averageDeliveryValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalDeliveries,completedDeliveries,cancelledDeliveries,inProgressDeliveries,totalEarnings,totalDistanceKm,successRate,averageDeliveryValue);

@override
String toString() {
  return 'StatsSummaryModel(totalDeliveries: $totalDeliveries, completedDeliveries: $completedDeliveries, cancelledDeliveries: $cancelledDeliveries, inProgressDeliveries: $inProgressDeliveries, totalEarnings: $totalEarnings, totalDistanceKm: $totalDistanceKm, successRate: $successRate, averageDeliveryValue: $averageDeliveryValue)';
}


}

/// @nodoc
abstract mixin class $StatsSummaryModelCopyWith<$Res>  {
  factory $StatsSummaryModelCopyWith(StatsSummaryModel value, $Res Function(StatsSummaryModel) _then) = _$StatsSummaryModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'total_deliveries') int totalDeliveries,@JsonKey(name: 'completed_deliveries') int completedDeliveries,@JsonKey(name: 'cancelled_deliveries') int cancelledDeliveries,@JsonKey(name: 'in_progress_deliveries') int inProgressDeliveries,@JsonKey(name: 'total_earnings') double totalEarnings,@JsonKey(name: 'total_distance_km') double totalDistanceKm,@JsonKey(name: 'success_rate') double successRate,@JsonKey(name: 'average_delivery_value') double averageDeliveryValue
});




}
/// @nodoc
class _$StatsSummaryModelCopyWithImpl<$Res>
    implements $StatsSummaryModelCopyWith<$Res> {
  _$StatsSummaryModelCopyWithImpl(this._self, this._then);

  final StatsSummaryModel _self;
  final $Res Function(StatsSummaryModel) _then;

/// Create a copy of StatsSummaryModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalDeliveries = null,Object? completedDeliveries = null,Object? cancelledDeliveries = null,Object? inProgressDeliveries = null,Object? totalEarnings = null,Object? totalDistanceKm = null,Object? successRate = null,Object? averageDeliveryValue = null,}) {
  return _then(_self.copyWith(
totalDeliveries: null == totalDeliveries ? _self.totalDeliveries : totalDeliveries // ignore: cast_nullable_to_non_nullable
as int,completedDeliveries: null == completedDeliveries ? _self.completedDeliveries : completedDeliveries // ignore: cast_nullable_to_non_nullable
as int,cancelledDeliveries: null == cancelledDeliveries ? _self.cancelledDeliveries : cancelledDeliveries // ignore: cast_nullable_to_non_nullable
as int,inProgressDeliveries: null == inProgressDeliveries ? _self.inProgressDeliveries : inProgressDeliveries // ignore: cast_nullable_to_non_nullable
as int,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,totalDistanceKm: null == totalDistanceKm ? _self.totalDistanceKm : totalDistanceKm // ignore: cast_nullable_to_non_nullable
as double,successRate: null == successRate ? _self.successRate : successRate // ignore: cast_nullable_to_non_nullable
as double,averageDeliveryValue: null == averageDeliveryValue ? _self.averageDeliveryValue : averageDeliveryValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [StatsSummaryModel].
extension StatsSummaryModelPatterns on StatsSummaryModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatsSummaryModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsSummaryModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatsSummaryModel value)  $default,){
final _that = this;
switch (_that) {
case _StatsSummaryModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatsSummaryModel value)?  $default,){
final _that = this;
switch (_that) {
case _StatsSummaryModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_deliveries')  int totalDeliveries, @JsonKey(name: 'completed_deliveries')  int completedDeliveries, @JsonKey(name: 'cancelled_deliveries')  int cancelledDeliveries, @JsonKey(name: 'in_progress_deliveries')  int inProgressDeliveries, @JsonKey(name: 'total_earnings')  double totalEarnings, @JsonKey(name: 'total_distance_km')  double totalDistanceKm, @JsonKey(name: 'success_rate')  double successRate, @JsonKey(name: 'average_delivery_value')  double averageDeliveryValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsSummaryModel() when $default != null:
return $default(_that.totalDeliveries,_that.completedDeliveries,_that.cancelledDeliveries,_that.inProgressDeliveries,_that.totalEarnings,_that.totalDistanceKm,_that.successRate,_that.averageDeliveryValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'total_deliveries')  int totalDeliveries, @JsonKey(name: 'completed_deliveries')  int completedDeliveries, @JsonKey(name: 'cancelled_deliveries')  int cancelledDeliveries, @JsonKey(name: 'in_progress_deliveries')  int inProgressDeliveries, @JsonKey(name: 'total_earnings')  double totalEarnings, @JsonKey(name: 'total_distance_km')  double totalDistanceKm, @JsonKey(name: 'success_rate')  double successRate, @JsonKey(name: 'average_delivery_value')  double averageDeliveryValue)  $default,) {final _that = this;
switch (_that) {
case _StatsSummaryModel():
return $default(_that.totalDeliveries,_that.completedDeliveries,_that.cancelledDeliveries,_that.inProgressDeliveries,_that.totalEarnings,_that.totalDistanceKm,_that.successRate,_that.averageDeliveryValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'total_deliveries')  int totalDeliveries, @JsonKey(name: 'completed_deliveries')  int completedDeliveries, @JsonKey(name: 'cancelled_deliveries')  int cancelledDeliveries, @JsonKey(name: 'in_progress_deliveries')  int inProgressDeliveries, @JsonKey(name: 'total_earnings')  double totalEarnings, @JsonKey(name: 'total_distance_km')  double totalDistanceKm, @JsonKey(name: 'success_rate')  double successRate, @JsonKey(name: 'average_delivery_value')  double averageDeliveryValue)?  $default,) {final _that = this;
switch (_that) {
case _StatsSummaryModel() when $default != null:
return $default(_that.totalDeliveries,_that.completedDeliveries,_that.cancelledDeliveries,_that.inProgressDeliveries,_that.totalEarnings,_that.totalDistanceKm,_that.successRate,_that.averageDeliveryValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatsSummaryModel implements StatsSummaryModel {
  const _StatsSummaryModel({@JsonKey(name: 'total_deliveries') required this.totalDeliveries, @JsonKey(name: 'completed_deliveries') required this.completedDeliveries, @JsonKey(name: 'cancelled_deliveries') required this.cancelledDeliveries, @JsonKey(name: 'in_progress_deliveries') required this.inProgressDeliveries, @JsonKey(name: 'total_earnings') required this.totalEarnings, @JsonKey(name: 'total_distance_km') required this.totalDistanceKm, @JsonKey(name: 'success_rate') required this.successRate, @JsonKey(name: 'average_delivery_value') required this.averageDeliveryValue});
  factory _StatsSummaryModel.fromJson(Map<String, dynamic> json) => _$StatsSummaryModelFromJson(json);

@override@JsonKey(name: 'total_deliveries') final  int totalDeliveries;
@override@JsonKey(name: 'completed_deliveries') final  int completedDeliveries;
@override@JsonKey(name: 'cancelled_deliveries') final  int cancelledDeliveries;
@override@JsonKey(name: 'in_progress_deliveries') final  int inProgressDeliveries;
@override@JsonKey(name: 'total_earnings') final  double totalEarnings;
@override@JsonKey(name: 'total_distance_km') final  double totalDistanceKm;
@override@JsonKey(name: 'success_rate') final  double successRate;
@override@JsonKey(name: 'average_delivery_value') final  double averageDeliveryValue;

/// Create a copy of StatsSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsSummaryModelCopyWith<_StatsSummaryModel> get copyWith => __$StatsSummaryModelCopyWithImpl<_StatsSummaryModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatsSummaryModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsSummaryModel&&(identical(other.totalDeliveries, totalDeliveries) || other.totalDeliveries == totalDeliveries)&&(identical(other.completedDeliveries, completedDeliveries) || other.completedDeliveries == completedDeliveries)&&(identical(other.cancelledDeliveries, cancelledDeliveries) || other.cancelledDeliveries == cancelledDeliveries)&&(identical(other.inProgressDeliveries, inProgressDeliveries) || other.inProgressDeliveries == inProgressDeliveries)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings)&&(identical(other.totalDistanceKm, totalDistanceKm) || other.totalDistanceKm == totalDistanceKm)&&(identical(other.successRate, successRate) || other.successRate == successRate)&&(identical(other.averageDeliveryValue, averageDeliveryValue) || other.averageDeliveryValue == averageDeliveryValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalDeliveries,completedDeliveries,cancelledDeliveries,inProgressDeliveries,totalEarnings,totalDistanceKm,successRate,averageDeliveryValue);

@override
String toString() {
  return 'StatsSummaryModel(totalDeliveries: $totalDeliveries, completedDeliveries: $completedDeliveries, cancelledDeliveries: $cancelledDeliveries, inProgressDeliveries: $inProgressDeliveries, totalEarnings: $totalEarnings, totalDistanceKm: $totalDistanceKm, successRate: $successRate, averageDeliveryValue: $averageDeliveryValue)';
}


}

/// @nodoc
abstract mixin class _$StatsSummaryModelCopyWith<$Res> implements $StatsSummaryModelCopyWith<$Res> {
  factory _$StatsSummaryModelCopyWith(_StatsSummaryModel value, $Res Function(_StatsSummaryModel) _then) = __$StatsSummaryModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'total_deliveries') int totalDeliveries,@JsonKey(name: 'completed_deliveries') int completedDeliveries,@JsonKey(name: 'cancelled_deliveries') int cancelledDeliveries,@JsonKey(name: 'in_progress_deliveries') int inProgressDeliveries,@JsonKey(name: 'total_earnings') double totalEarnings,@JsonKey(name: 'total_distance_km') double totalDistanceKm,@JsonKey(name: 'success_rate') double successRate,@JsonKey(name: 'average_delivery_value') double averageDeliveryValue
});




}
/// @nodoc
class __$StatsSummaryModelCopyWithImpl<$Res>
    implements _$StatsSummaryModelCopyWith<$Res> {
  __$StatsSummaryModelCopyWithImpl(this._self, this._then);

  final _StatsSummaryModel _self;
  final $Res Function(_StatsSummaryModel) _then;

/// Create a copy of StatsSummaryModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalDeliveries = null,Object? completedDeliveries = null,Object? cancelledDeliveries = null,Object? inProgressDeliveries = null,Object? totalEarnings = null,Object? totalDistanceKm = null,Object? successRate = null,Object? averageDeliveryValue = null,}) {
  return _then(_StatsSummaryModel(
totalDeliveries: null == totalDeliveries ? _self.totalDeliveries : totalDeliveries // ignore: cast_nullable_to_non_nullable
as int,completedDeliveries: null == completedDeliveries ? _self.completedDeliveries : completedDeliveries // ignore: cast_nullable_to_non_nullable
as int,cancelledDeliveries: null == cancelledDeliveries ? _self.cancelledDeliveries : cancelledDeliveries // ignore: cast_nullable_to_non_nullable
as int,inProgressDeliveries: null == inProgressDeliveries ? _self.inProgressDeliveries : inProgressDeliveries // ignore: cast_nullable_to_non_nullable
as int,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,totalDistanceKm: null == totalDistanceKm ? _self.totalDistanceKm : totalDistanceKm // ignore: cast_nullable_to_non_nullable
as double,successRate: null == successRate ? _self.successRate : successRate // ignore: cast_nullable_to_non_nullable
as double,averageDeliveryValue: null == averageDeliveryValue ? _self.averageDeliveryValue : averageDeliveryValue // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
