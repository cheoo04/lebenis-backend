// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'earnings_breakdown_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EarningsBreakdownModel {

@JsonKey(name: 'delivery_earnings') double get deliveryEarnings;@JsonKey(name: 'bonus_earnings') double get bonusEarnings;@JsonKey(name: 'tip_earnings') double get tipEarnings;@JsonKey(name: 'adjustment_earnings') double get adjustmentEarnings;@JsonKey(name: 'total_earnings') double get totalEarnings;
/// Create a copy of EarningsBreakdownModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EarningsBreakdownModelCopyWith<EarningsBreakdownModel> get copyWith => _$EarningsBreakdownModelCopyWithImpl<EarningsBreakdownModel>(this as EarningsBreakdownModel, _$identity);

  /// Serializes this EarningsBreakdownModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EarningsBreakdownModel&&(identical(other.deliveryEarnings, deliveryEarnings) || other.deliveryEarnings == deliveryEarnings)&&(identical(other.bonusEarnings, bonusEarnings) || other.bonusEarnings == bonusEarnings)&&(identical(other.tipEarnings, tipEarnings) || other.tipEarnings == tipEarnings)&&(identical(other.adjustmentEarnings, adjustmentEarnings) || other.adjustmentEarnings == adjustmentEarnings)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deliveryEarnings,bonusEarnings,tipEarnings,adjustmentEarnings,totalEarnings);

@override
String toString() {
  return 'EarningsBreakdownModel(deliveryEarnings: $deliveryEarnings, bonusEarnings: $bonusEarnings, tipEarnings: $tipEarnings, adjustmentEarnings: $adjustmentEarnings, totalEarnings: $totalEarnings)';
}


}

/// @nodoc
abstract mixin class $EarningsBreakdownModelCopyWith<$Res>  {
  factory $EarningsBreakdownModelCopyWith(EarningsBreakdownModel value, $Res Function(EarningsBreakdownModel) _then) = _$EarningsBreakdownModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'delivery_earnings') double deliveryEarnings,@JsonKey(name: 'bonus_earnings') double bonusEarnings,@JsonKey(name: 'tip_earnings') double tipEarnings,@JsonKey(name: 'adjustment_earnings') double adjustmentEarnings,@JsonKey(name: 'total_earnings') double totalEarnings
});




}
/// @nodoc
class _$EarningsBreakdownModelCopyWithImpl<$Res>
    implements $EarningsBreakdownModelCopyWith<$Res> {
  _$EarningsBreakdownModelCopyWithImpl(this._self, this._then);

  final EarningsBreakdownModel _self;
  final $Res Function(EarningsBreakdownModel) _then;

/// Create a copy of EarningsBreakdownModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? deliveryEarnings = null,Object? bonusEarnings = null,Object? tipEarnings = null,Object? adjustmentEarnings = null,Object? totalEarnings = null,}) {
  return _then(_self.copyWith(
deliveryEarnings: null == deliveryEarnings ? _self.deliveryEarnings : deliveryEarnings // ignore: cast_nullable_to_non_nullable
as double,bonusEarnings: null == bonusEarnings ? _self.bonusEarnings : bonusEarnings // ignore: cast_nullable_to_non_nullable
as double,tipEarnings: null == tipEarnings ? _self.tipEarnings : tipEarnings // ignore: cast_nullable_to_non_nullable
as double,adjustmentEarnings: null == adjustmentEarnings ? _self.adjustmentEarnings : adjustmentEarnings // ignore: cast_nullable_to_non_nullable
as double,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [EarningsBreakdownModel].
extension EarningsBreakdownModelPatterns on EarningsBreakdownModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EarningsBreakdownModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EarningsBreakdownModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EarningsBreakdownModel value)  $default,){
final _that = this;
switch (_that) {
case _EarningsBreakdownModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EarningsBreakdownModel value)?  $default,){
final _that = this;
switch (_that) {
case _EarningsBreakdownModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'delivery_earnings')  double deliveryEarnings, @JsonKey(name: 'bonus_earnings')  double bonusEarnings, @JsonKey(name: 'tip_earnings')  double tipEarnings, @JsonKey(name: 'adjustment_earnings')  double adjustmentEarnings, @JsonKey(name: 'total_earnings')  double totalEarnings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EarningsBreakdownModel() when $default != null:
return $default(_that.deliveryEarnings,_that.bonusEarnings,_that.tipEarnings,_that.adjustmentEarnings,_that.totalEarnings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'delivery_earnings')  double deliveryEarnings, @JsonKey(name: 'bonus_earnings')  double bonusEarnings, @JsonKey(name: 'tip_earnings')  double tipEarnings, @JsonKey(name: 'adjustment_earnings')  double adjustmentEarnings, @JsonKey(name: 'total_earnings')  double totalEarnings)  $default,) {final _that = this;
switch (_that) {
case _EarningsBreakdownModel():
return $default(_that.deliveryEarnings,_that.bonusEarnings,_that.tipEarnings,_that.adjustmentEarnings,_that.totalEarnings);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'delivery_earnings')  double deliveryEarnings, @JsonKey(name: 'bonus_earnings')  double bonusEarnings, @JsonKey(name: 'tip_earnings')  double tipEarnings, @JsonKey(name: 'adjustment_earnings')  double adjustmentEarnings, @JsonKey(name: 'total_earnings')  double totalEarnings)?  $default,) {final _that = this;
switch (_that) {
case _EarningsBreakdownModel() when $default != null:
return $default(_that.deliveryEarnings,_that.bonusEarnings,_that.tipEarnings,_that.adjustmentEarnings,_that.totalEarnings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EarningsBreakdownModel implements EarningsBreakdownModel {
  const _EarningsBreakdownModel({@JsonKey(name: 'delivery_earnings') required this.deliveryEarnings, @JsonKey(name: 'bonus_earnings') required this.bonusEarnings, @JsonKey(name: 'tip_earnings') required this.tipEarnings, @JsonKey(name: 'adjustment_earnings') required this.adjustmentEarnings, @JsonKey(name: 'total_earnings') required this.totalEarnings});
  factory _EarningsBreakdownModel.fromJson(Map<String, dynamic> json) => _$EarningsBreakdownModelFromJson(json);

@override@JsonKey(name: 'delivery_earnings') final  double deliveryEarnings;
@override@JsonKey(name: 'bonus_earnings') final  double bonusEarnings;
@override@JsonKey(name: 'tip_earnings') final  double tipEarnings;
@override@JsonKey(name: 'adjustment_earnings') final  double adjustmentEarnings;
@override@JsonKey(name: 'total_earnings') final  double totalEarnings;

/// Create a copy of EarningsBreakdownModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EarningsBreakdownModelCopyWith<_EarningsBreakdownModel> get copyWith => __$EarningsBreakdownModelCopyWithImpl<_EarningsBreakdownModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EarningsBreakdownModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EarningsBreakdownModel&&(identical(other.deliveryEarnings, deliveryEarnings) || other.deliveryEarnings == deliveryEarnings)&&(identical(other.bonusEarnings, bonusEarnings) || other.bonusEarnings == bonusEarnings)&&(identical(other.tipEarnings, tipEarnings) || other.tipEarnings == tipEarnings)&&(identical(other.adjustmentEarnings, adjustmentEarnings) || other.adjustmentEarnings == adjustmentEarnings)&&(identical(other.totalEarnings, totalEarnings) || other.totalEarnings == totalEarnings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,deliveryEarnings,bonusEarnings,tipEarnings,adjustmentEarnings,totalEarnings);

@override
String toString() {
  return 'EarningsBreakdownModel(deliveryEarnings: $deliveryEarnings, bonusEarnings: $bonusEarnings, tipEarnings: $tipEarnings, adjustmentEarnings: $adjustmentEarnings, totalEarnings: $totalEarnings)';
}


}

/// @nodoc
abstract mixin class _$EarningsBreakdownModelCopyWith<$Res> implements $EarningsBreakdownModelCopyWith<$Res> {
  factory _$EarningsBreakdownModelCopyWith(_EarningsBreakdownModel value, $Res Function(_EarningsBreakdownModel) _then) = __$EarningsBreakdownModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'delivery_earnings') double deliveryEarnings,@JsonKey(name: 'bonus_earnings') double bonusEarnings,@JsonKey(name: 'tip_earnings') double tipEarnings,@JsonKey(name: 'adjustment_earnings') double adjustmentEarnings,@JsonKey(name: 'total_earnings') double totalEarnings
});




}
/// @nodoc
class __$EarningsBreakdownModelCopyWithImpl<$Res>
    implements _$EarningsBreakdownModelCopyWith<$Res> {
  __$EarningsBreakdownModelCopyWithImpl(this._self, this._then);

  final _EarningsBreakdownModel _self;
  final $Res Function(_EarningsBreakdownModel) _then;

/// Create a copy of EarningsBreakdownModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? deliveryEarnings = null,Object? bonusEarnings = null,Object? tipEarnings = null,Object? adjustmentEarnings = null,Object? totalEarnings = null,}) {
  return _then(_EarningsBreakdownModel(
deliveryEarnings: null == deliveryEarnings ? _self.deliveryEarnings : deliveryEarnings // ignore: cast_nullable_to_non_nullable
as double,bonusEarnings: null == bonusEarnings ? _self.bonusEarnings : bonusEarnings // ignore: cast_nullable_to_non_nullable
as double,tipEarnings: null == tipEarnings ? _self.tipEarnings : tipEarnings // ignore: cast_nullable_to_non_nullable
as double,adjustmentEarnings: null == adjustmentEarnings ? _self.adjustmentEarnings : adjustmentEarnings // ignore: cast_nullable_to_non_nullable
as double,totalEarnings: null == totalEarnings ? _self.totalEarnings : totalEarnings // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
