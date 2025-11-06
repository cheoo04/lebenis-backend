// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'heatmap_point_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HeatmapPointModel _$HeatmapPointModelFromJson(Map<String, dynamic> json) {
  return _HeatmapPointModel.fromJson(json);
}

/// @nodoc
mixin _$HeatmapPointModel {
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  int get weight => throw _privateConstructorUsedError;

  /// Serializes this HeatmapPointModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HeatmapPointModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HeatmapPointModelCopyWith<HeatmapPointModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HeatmapPointModelCopyWith<$Res> {
  factory $HeatmapPointModelCopyWith(
    HeatmapPointModel value,
    $Res Function(HeatmapPointModel) then,
  ) = _$HeatmapPointModelCopyWithImpl<$Res, HeatmapPointModel>;
  @useResult
  $Res call({double lat, double lng, int weight});
}

/// @nodoc
class _$HeatmapPointModelCopyWithImpl<$Res, $Val extends HeatmapPointModel>
    implements $HeatmapPointModelCopyWith<$Res> {
  _$HeatmapPointModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HeatmapPointModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? lat = null, Object? lng = null, Object? weight = null}) {
    return _then(
      _value.copyWith(
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
            weight: null == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HeatmapPointModelImplCopyWith<$Res>
    implements $HeatmapPointModelCopyWith<$Res> {
  factory _$$HeatmapPointModelImplCopyWith(
    _$HeatmapPointModelImpl value,
    $Res Function(_$HeatmapPointModelImpl) then,
  ) = __$$HeatmapPointModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double lat, double lng, int weight});
}

/// @nodoc
class __$$HeatmapPointModelImplCopyWithImpl<$Res>
    extends _$HeatmapPointModelCopyWithImpl<$Res, _$HeatmapPointModelImpl>
    implements _$$HeatmapPointModelImplCopyWith<$Res> {
  __$$HeatmapPointModelImplCopyWithImpl(
    _$HeatmapPointModelImpl _value,
    $Res Function(_$HeatmapPointModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HeatmapPointModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? lat = null, Object? lng = null, Object? weight = null}) {
    return _then(
      _$HeatmapPointModelImpl(
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
        weight: null == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HeatmapPointModelImpl implements _HeatmapPointModel {
  const _$HeatmapPointModelImpl({
    required this.lat,
    required this.lng,
    required this.weight,
  });

  factory _$HeatmapPointModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HeatmapPointModelImplFromJson(json);

  @override
  final double lat;
  @override
  final double lng;
  @override
  final int weight;

  @override
  String toString() {
    return 'HeatmapPointModel(lat: $lat, lng: $lng, weight: $weight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HeatmapPointModelImpl &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.weight, weight) || other.weight == weight));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, lat, lng, weight);

  /// Create a copy of HeatmapPointModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HeatmapPointModelImplCopyWith<_$HeatmapPointModelImpl> get copyWith =>
      __$$HeatmapPointModelImplCopyWithImpl<_$HeatmapPointModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HeatmapPointModelImplToJson(this);
  }
}

abstract class _HeatmapPointModel implements HeatmapPointModel {
  const factory _HeatmapPointModel({
    required final double lat,
    required final double lng,
    required final int weight,
  }) = _$HeatmapPointModelImpl;

  factory _HeatmapPointModel.fromJson(Map<String, dynamic> json) =
      _$HeatmapPointModelImpl.fromJson;

  @override
  double get lat;
  @override
  double get lng;
  @override
  int get weight;

  /// Create a copy of HeatmapPointModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HeatmapPointModelImplCopyWith<_$HeatmapPointModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HeatmapResponseModel _$HeatmapResponseModelFromJson(Map<String, dynamic> json) {
  return _HeatmapResponseModel.fromJson(json);
}

/// @nodoc
mixin _$HeatmapResponseModel {
  List<HeatmapPointModel> get points => throw _privateConstructorUsedError;

  /// Serializes this HeatmapResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HeatmapResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HeatmapResponseModelCopyWith<HeatmapResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HeatmapResponseModelCopyWith<$Res> {
  factory $HeatmapResponseModelCopyWith(
    HeatmapResponseModel value,
    $Res Function(HeatmapResponseModel) then,
  ) = _$HeatmapResponseModelCopyWithImpl<$Res, HeatmapResponseModel>;
  @useResult
  $Res call({List<HeatmapPointModel> points});
}

/// @nodoc
class _$HeatmapResponseModelCopyWithImpl<
  $Res,
  $Val extends HeatmapResponseModel
>
    implements $HeatmapResponseModelCopyWith<$Res> {
  _$HeatmapResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HeatmapResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? points = null}) {
    return _then(
      _value.copyWith(
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as List<HeatmapPointModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HeatmapResponseModelImplCopyWith<$Res>
    implements $HeatmapResponseModelCopyWith<$Res> {
  factory _$$HeatmapResponseModelImplCopyWith(
    _$HeatmapResponseModelImpl value,
    $Res Function(_$HeatmapResponseModelImpl) then,
  ) = __$$HeatmapResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<HeatmapPointModel> points});
}

/// @nodoc
class __$$HeatmapResponseModelImplCopyWithImpl<$Res>
    extends _$HeatmapResponseModelCopyWithImpl<$Res, _$HeatmapResponseModelImpl>
    implements _$$HeatmapResponseModelImplCopyWith<$Res> {
  __$$HeatmapResponseModelImplCopyWithImpl(
    _$HeatmapResponseModelImpl _value,
    $Res Function(_$HeatmapResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HeatmapResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? points = null}) {
    return _then(
      _$HeatmapResponseModelImpl(
        points: null == points
            ? _value._points
            : points // ignore: cast_nullable_to_non_nullable
                  as List<HeatmapPointModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HeatmapResponseModelImpl implements _HeatmapResponseModel {
  const _$HeatmapResponseModelImpl({
    required final List<HeatmapPointModel> points,
  }) : _points = points;

  factory _$HeatmapResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HeatmapResponseModelImplFromJson(json);

  final List<HeatmapPointModel> _points;
  @override
  List<HeatmapPointModel> get points {
    if (_points is EqualUnmodifiableListView) return _points;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_points);
  }

  @override
  String toString() {
    return 'HeatmapResponseModel(points: $points)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HeatmapResponseModelImpl &&
            const DeepCollectionEquality().equals(other._points, _points));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_points));

  /// Create a copy of HeatmapResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HeatmapResponseModelImplCopyWith<_$HeatmapResponseModelImpl>
  get copyWith =>
      __$$HeatmapResponseModelImplCopyWithImpl<_$HeatmapResponseModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HeatmapResponseModelImplToJson(this);
  }
}

abstract class _HeatmapResponseModel implements HeatmapResponseModel {
  const factory _HeatmapResponseModel({
    required final List<HeatmapPointModel> points,
  }) = _$HeatmapResponseModelImpl;

  factory _HeatmapResponseModel.fromJson(Map<String, dynamic> json) =
      _$HeatmapResponseModelImpl.fromJson;

  @override
  List<HeatmapPointModel> get points;

  /// Create a copy of HeatmapResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HeatmapResponseModelImplCopyWith<_$HeatmapResponseModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
