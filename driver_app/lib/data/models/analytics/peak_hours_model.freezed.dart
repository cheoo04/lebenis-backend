// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'peak_hours_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PeakHourModel _$PeakHourModelFromJson(Map<String, dynamic> json) {
  return _PeakHourModel.fromJson(json);
}

/// @nodoc
mixin _$PeakHourModel {
  int get hour => throw _privateConstructorUsedError;
  int get deliveriesCount => throw _privateConstructorUsedError;
  double get totalEarnings => throw _privateConstructorUsedError;

  /// Serializes this PeakHourModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PeakHourModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PeakHourModelCopyWith<PeakHourModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PeakHourModelCopyWith<$Res> {
  factory $PeakHourModelCopyWith(
    PeakHourModel value,
    $Res Function(PeakHourModel) then,
  ) = _$PeakHourModelCopyWithImpl<$Res, PeakHourModel>;
  @useResult
  $Res call({int hour, int deliveriesCount, double totalEarnings});
}

/// @nodoc
class _$PeakHourModelCopyWithImpl<$Res, $Val extends PeakHourModel>
    implements $PeakHourModelCopyWith<$Res> {
  _$PeakHourModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PeakHourModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? deliveriesCount = null,
    Object? totalEarnings = null,
  }) {
    return _then(
      _value.copyWith(
            hour: null == hour
                ? _value.hour
                : hour // ignore: cast_nullable_to_non_nullable
                      as int,
            deliveriesCount: null == deliveriesCount
                ? _value.deliveriesCount
                : deliveriesCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalEarnings: null == totalEarnings
                ? _value.totalEarnings
                : totalEarnings // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PeakHourModelImplCopyWith<$Res>
    implements $PeakHourModelCopyWith<$Res> {
  factory _$$PeakHourModelImplCopyWith(
    _$PeakHourModelImpl value,
    $Res Function(_$PeakHourModelImpl) then,
  ) = __$$PeakHourModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int hour, int deliveriesCount, double totalEarnings});
}

/// @nodoc
class __$$PeakHourModelImplCopyWithImpl<$Res>
    extends _$PeakHourModelCopyWithImpl<$Res, _$PeakHourModelImpl>
    implements _$$PeakHourModelImplCopyWith<$Res> {
  __$$PeakHourModelImplCopyWithImpl(
    _$PeakHourModelImpl _value,
    $Res Function(_$PeakHourModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PeakHourModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? deliveriesCount = null,
    Object? totalEarnings = null,
  }) {
    return _then(
      _$PeakHourModelImpl(
        hour: null == hour
            ? _value.hour
            : hour // ignore: cast_nullable_to_non_nullable
                  as int,
        deliveriesCount: null == deliveriesCount
            ? _value.deliveriesCount
            : deliveriesCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalEarnings: null == totalEarnings
            ? _value.totalEarnings
            : totalEarnings // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PeakHourModelImpl implements _PeakHourModel {
  const _$PeakHourModelImpl({
    required this.hour,
    required this.deliveriesCount,
    required this.totalEarnings,
  });

  factory _$PeakHourModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PeakHourModelImplFromJson(json);

  @override
  final int hour;
  @override
  final int deliveriesCount;
  @override
  final double totalEarnings;

  @override
  String toString() {
    return 'PeakHourModel(hour: $hour, deliveriesCount: $deliveriesCount, totalEarnings: $totalEarnings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeakHourModelImpl &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.deliveriesCount, deliveriesCount) ||
                other.deliveriesCount == deliveriesCount) &&
            (identical(other.totalEarnings, totalEarnings) ||
                other.totalEarnings == totalEarnings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, hour, deliveriesCount, totalEarnings);

  /// Create a copy of PeakHourModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PeakHourModelImplCopyWith<_$PeakHourModelImpl> get copyWith =>
      __$$PeakHourModelImplCopyWithImpl<_$PeakHourModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PeakHourModelImplToJson(this);
  }
}

abstract class _PeakHourModel implements PeakHourModel {
  const factory _PeakHourModel({
    required final int hour,
    required final int deliveriesCount,
    required final double totalEarnings,
  }) = _$PeakHourModelImpl;

  factory _PeakHourModel.fromJson(Map<String, dynamic> json) =
      _$PeakHourModelImpl.fromJson;

  @override
  int get hour;
  @override
  int get deliveriesCount;
  @override
  double get totalEarnings;

  /// Create a copy of PeakHourModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PeakHourModelImplCopyWith<_$PeakHourModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PeakHoursResponseModel _$PeakHoursResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _PeakHoursResponseModel.fromJson(json);
}

/// @nodoc
mixin _$PeakHoursResponseModel {
  List<PeakHourModel> get peakHours => throw _privateConstructorUsedError;

  /// Serializes this PeakHoursResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PeakHoursResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PeakHoursResponseModelCopyWith<PeakHoursResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PeakHoursResponseModelCopyWith<$Res> {
  factory $PeakHoursResponseModelCopyWith(
    PeakHoursResponseModel value,
    $Res Function(PeakHoursResponseModel) then,
  ) = _$PeakHoursResponseModelCopyWithImpl<$Res, PeakHoursResponseModel>;
  @useResult
  $Res call({List<PeakHourModel> peakHours});
}

/// @nodoc
class _$PeakHoursResponseModelCopyWithImpl<
  $Res,
  $Val extends PeakHoursResponseModel
>
    implements $PeakHoursResponseModelCopyWith<$Res> {
  _$PeakHoursResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PeakHoursResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? peakHours = null}) {
    return _then(
      _value.copyWith(
            peakHours: null == peakHours
                ? _value.peakHours
                : peakHours // ignore: cast_nullable_to_non_nullable
                      as List<PeakHourModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PeakHoursResponseModelImplCopyWith<$Res>
    implements $PeakHoursResponseModelCopyWith<$Res> {
  factory _$$PeakHoursResponseModelImplCopyWith(
    _$PeakHoursResponseModelImpl value,
    $Res Function(_$PeakHoursResponseModelImpl) then,
  ) = __$$PeakHoursResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<PeakHourModel> peakHours});
}

/// @nodoc
class __$$PeakHoursResponseModelImplCopyWithImpl<$Res>
    extends
        _$PeakHoursResponseModelCopyWithImpl<$Res, _$PeakHoursResponseModelImpl>
    implements _$$PeakHoursResponseModelImplCopyWith<$Res> {
  __$$PeakHoursResponseModelImplCopyWithImpl(
    _$PeakHoursResponseModelImpl _value,
    $Res Function(_$PeakHoursResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PeakHoursResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? peakHours = null}) {
    return _then(
      _$PeakHoursResponseModelImpl(
        peakHours: null == peakHours
            ? _value._peakHours
            : peakHours // ignore: cast_nullable_to_non_nullable
                  as List<PeakHourModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PeakHoursResponseModelImpl implements _PeakHoursResponseModel {
  const _$PeakHoursResponseModelImpl({
    required final List<PeakHourModel> peakHours,
  }) : _peakHours = peakHours;

  factory _$PeakHoursResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PeakHoursResponseModelImplFromJson(json);

  final List<PeakHourModel> _peakHours;
  @override
  List<PeakHourModel> get peakHours {
    if (_peakHours is EqualUnmodifiableListView) return _peakHours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_peakHours);
  }

  @override
  String toString() {
    return 'PeakHoursResponseModel(peakHours: $peakHours)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PeakHoursResponseModelImpl &&
            const DeepCollectionEquality().equals(
              other._peakHours,
              _peakHours,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_peakHours));

  /// Create a copy of PeakHoursResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PeakHoursResponseModelImplCopyWith<_$PeakHoursResponseModelImpl>
  get copyWith =>
      __$$PeakHoursResponseModelImplCopyWithImpl<_$PeakHoursResponseModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PeakHoursResponseModelImplToJson(this);
  }
}

abstract class _PeakHoursResponseModel implements PeakHoursResponseModel {
  const factory _PeakHoursResponseModel({
    required final List<PeakHourModel> peakHours,
  }) = _$PeakHoursResponseModelImpl;

  factory _PeakHoursResponseModel.fromJson(Map<String, dynamic> json) =
      _$PeakHoursResponseModelImpl.fromJson;

  @override
  List<PeakHourModel> get peakHours;

  /// Create a copy of PeakHoursResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PeakHoursResponseModelImplCopyWith<_$PeakHoursResponseModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
