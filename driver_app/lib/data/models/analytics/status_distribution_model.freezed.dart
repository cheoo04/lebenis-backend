// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'status_distribution_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StatusDistributionItemModel {

 String get status; int get count;
/// Create a copy of StatusDistributionItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusDistributionItemModelCopyWith<StatusDistributionItemModel> get copyWith => _$StatusDistributionItemModelCopyWithImpl<StatusDistributionItemModel>(this as StatusDistributionItemModel, _$identity);

  /// Serializes this StatusDistributionItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusDistributionItemModel&&(identical(other.status, status) || other.status == status)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,count);

@override
String toString() {
  return 'StatusDistributionItemModel(status: $status, count: $count)';
}


}

/// @nodoc
abstract mixin class $StatusDistributionItemModelCopyWith<$Res>  {
  factory $StatusDistributionItemModelCopyWith(StatusDistributionItemModel value, $Res Function(StatusDistributionItemModel) _then) = _$StatusDistributionItemModelCopyWithImpl;
@useResult
$Res call({
 String status, int count
});




}
/// @nodoc
class _$StatusDistributionItemModelCopyWithImpl<$Res>
    implements $StatusDistributionItemModelCopyWith<$Res> {
  _$StatusDistributionItemModelCopyWithImpl(this._self, this._then);

  final StatusDistributionItemModel _self;
  final $Res Function(StatusDistributionItemModel) _then;

/// Create a copy of StatusDistributionItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? count = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StatusDistributionItemModel].
extension StatusDistributionItemModelPatterns on StatusDistributionItemModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatusDistributionItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatusDistributionItemModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatusDistributionItemModel value)  $default,){
final _that = this;
switch (_that) {
case _StatusDistributionItemModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatusDistributionItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _StatusDistributionItemModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatusDistributionItemModel() when $default != null:
return $default(_that.status,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status,  int count)  $default,) {final _that = this;
switch (_that) {
case _StatusDistributionItemModel():
return $default(_that.status,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status,  int count)?  $default,) {final _that = this;
switch (_that) {
case _StatusDistributionItemModel() when $default != null:
return $default(_that.status,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatusDistributionItemModel implements StatusDistributionItemModel {
  const _StatusDistributionItemModel({required this.status, required this.count});
  factory _StatusDistributionItemModel.fromJson(Map<String, dynamic> json) => _$StatusDistributionItemModelFromJson(json);

@override final  String status;
@override final  int count;

/// Create a copy of StatusDistributionItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusDistributionItemModelCopyWith<_StatusDistributionItemModel> get copyWith => __$StatusDistributionItemModelCopyWithImpl<_StatusDistributionItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatusDistributionItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusDistributionItemModel&&(identical(other.status, status) || other.status == status)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,count);

@override
String toString() {
  return 'StatusDistributionItemModel(status: $status, count: $count)';
}


}

/// @nodoc
abstract mixin class _$StatusDistributionItemModelCopyWith<$Res> implements $StatusDistributionItemModelCopyWith<$Res> {
  factory _$StatusDistributionItemModelCopyWith(_StatusDistributionItemModel value, $Res Function(_StatusDistributionItemModel) _then) = __$StatusDistributionItemModelCopyWithImpl;
@override @useResult
$Res call({
 String status, int count
});




}
/// @nodoc
class __$StatusDistributionItemModelCopyWithImpl<$Res>
    implements _$StatusDistributionItemModelCopyWith<$Res> {
  __$StatusDistributionItemModelCopyWithImpl(this._self, this._then);

  final _StatusDistributionItemModel _self;
  final $Res Function(_StatusDistributionItemModel) _then;

/// Create a copy of StatusDistributionItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? count = null,}) {
  return _then(_StatusDistributionItemModel(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$StatusDistributionResponseModel {

 List<StatusDistributionItemModel> get distribution;
/// Create a copy of StatusDistributionResponseModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatusDistributionResponseModelCopyWith<StatusDistributionResponseModel> get copyWith => _$StatusDistributionResponseModelCopyWithImpl<StatusDistributionResponseModel>(this as StatusDistributionResponseModel, _$identity);

  /// Serializes this StatusDistributionResponseModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatusDistributionResponseModel&&const DeepCollectionEquality().equals(other.distribution, distribution));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(distribution));

@override
String toString() {
  return 'StatusDistributionResponseModel(distribution: $distribution)';
}


}

/// @nodoc
abstract mixin class $StatusDistributionResponseModelCopyWith<$Res>  {
  factory $StatusDistributionResponseModelCopyWith(StatusDistributionResponseModel value, $Res Function(StatusDistributionResponseModel) _then) = _$StatusDistributionResponseModelCopyWithImpl;
@useResult
$Res call({
 List<StatusDistributionItemModel> distribution
});




}
/// @nodoc
class _$StatusDistributionResponseModelCopyWithImpl<$Res>
    implements $StatusDistributionResponseModelCopyWith<$Res> {
  _$StatusDistributionResponseModelCopyWithImpl(this._self, this._then);

  final StatusDistributionResponseModel _self;
  final $Res Function(StatusDistributionResponseModel) _then;

/// Create a copy of StatusDistributionResponseModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? distribution = null,}) {
  return _then(_self.copyWith(
distribution: null == distribution ? _self.distribution : distribution // ignore: cast_nullable_to_non_nullable
as List<StatusDistributionItemModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [StatusDistributionResponseModel].
extension StatusDistributionResponseModelPatterns on StatusDistributionResponseModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatusDistributionResponseModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatusDistributionResponseModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatusDistributionResponseModel value)  $default,){
final _that = this;
switch (_that) {
case _StatusDistributionResponseModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatusDistributionResponseModel value)?  $default,){
final _that = this;
switch (_that) {
case _StatusDistributionResponseModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<StatusDistributionItemModel> distribution)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatusDistributionResponseModel() when $default != null:
return $default(_that.distribution);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<StatusDistributionItemModel> distribution)  $default,) {final _that = this;
switch (_that) {
case _StatusDistributionResponseModel():
return $default(_that.distribution);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<StatusDistributionItemModel> distribution)?  $default,) {final _that = this;
switch (_that) {
case _StatusDistributionResponseModel() when $default != null:
return $default(_that.distribution);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatusDistributionResponseModel implements StatusDistributionResponseModel {
  const _StatusDistributionResponseModel({required final  List<StatusDistributionItemModel> distribution}): _distribution = distribution;
  factory _StatusDistributionResponseModel.fromJson(Map<String, dynamic> json) => _$StatusDistributionResponseModelFromJson(json);

 final  List<StatusDistributionItemModel> _distribution;
@override List<StatusDistributionItemModel> get distribution {
  if (_distribution is EqualUnmodifiableListView) return _distribution;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_distribution);
}


/// Create a copy of StatusDistributionResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatusDistributionResponseModelCopyWith<_StatusDistributionResponseModel> get copyWith => __$StatusDistributionResponseModelCopyWithImpl<_StatusDistributionResponseModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatusDistributionResponseModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatusDistributionResponseModel&&const DeepCollectionEquality().equals(other._distribution, _distribution));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_distribution));

@override
String toString() {
  return 'StatusDistributionResponseModel(distribution: $distribution)';
}


}

/// @nodoc
abstract mixin class _$StatusDistributionResponseModelCopyWith<$Res> implements $StatusDistributionResponseModelCopyWith<$Res> {
  factory _$StatusDistributionResponseModelCopyWith(_StatusDistributionResponseModel value, $Res Function(_StatusDistributionResponseModel) _then) = __$StatusDistributionResponseModelCopyWithImpl;
@override @useResult
$Res call({
 List<StatusDistributionItemModel> distribution
});




}
/// @nodoc
class __$StatusDistributionResponseModelCopyWithImpl<$Res>
    implements _$StatusDistributionResponseModelCopyWith<$Res> {
  __$StatusDistributionResponseModelCopyWithImpl(this._self, this._then);

  final _StatusDistributionResponseModel _self;
  final $Res Function(_StatusDistributionResponseModel) _then;

/// Create a copy of StatusDistributionResponseModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? distribution = null,}) {
  return _then(_StatusDistributionResponseModel(
distribution: null == distribution ? _self._distribution : distribution // ignore: cast_nullable_to_non_nullable
as List<StatusDistributionItemModel>,
  ));
}


}

// dart format on
