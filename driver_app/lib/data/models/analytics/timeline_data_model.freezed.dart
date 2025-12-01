// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline_data_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TimelineDataModel _$TimelineDataModelFromJson(Map<String, dynamic> json) {
  return _TimelineDataModel.fromJson(json);
}

/// @nodoc
mixin _$TimelineDataModel {
  String get date => throw _privateConstructorUsedError;
  int get deliveriesCount => throw _privateConstructorUsedError;
  double get totalEarnings => throw _privateConstructorUsedError;

  /// Serializes this TimelineDataModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimelineDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimelineDataModelCopyWith<TimelineDataModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimelineDataModelCopyWith<$Res> {
  factory $TimelineDataModelCopyWith(
    TimelineDataModel value,
    $Res Function(TimelineDataModel) then,
  ) = _$TimelineDataModelCopyWithImpl<$Res, TimelineDataModel>;
  @useResult
  $Res call({String date, int deliveriesCount, double totalEarnings});
}

/// @nodoc
class _$TimelineDataModelCopyWithImpl<$Res, $Val extends TimelineDataModel>
    implements $TimelineDataModelCopyWith<$Res> {
  _$TimelineDataModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimelineDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? deliveriesCount = null,
    Object? totalEarnings = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$TimelineDataModelImplCopyWith<$Res>
    implements $TimelineDataModelCopyWith<$Res> {
  factory _$$TimelineDataModelImplCopyWith(
    _$TimelineDataModelImpl value,
    $Res Function(_$TimelineDataModelImpl) then,
  ) = __$$TimelineDataModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String date, int deliveriesCount, double totalEarnings});
}

/// @nodoc
class __$$TimelineDataModelImplCopyWithImpl<$Res>
    extends _$TimelineDataModelCopyWithImpl<$Res, _$TimelineDataModelImpl>
    implements _$$TimelineDataModelImplCopyWith<$Res> {
  __$$TimelineDataModelImplCopyWithImpl(
    _$TimelineDataModelImpl _value,
    $Res Function(_$TimelineDataModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimelineDataModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? deliveriesCount = null,
    Object? totalEarnings = null,
  }) {
    return _then(
      _$TimelineDataModelImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$TimelineDataModelImpl implements _TimelineDataModel {
  const _$TimelineDataModelImpl({
    required this.date,
    required this.deliveriesCount,
    required this.totalEarnings,
  });

  factory _$TimelineDataModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimelineDataModelImplFromJson(json);

  @override
  final String date;
  @override
  final int deliveriesCount;
  @override
  final double totalEarnings;

  @override
  String toString() {
    return 'TimelineDataModel(date: $date, deliveriesCount: $deliveriesCount, totalEarnings: $totalEarnings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimelineDataModelImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.deliveriesCount, deliveriesCount) ||
                other.deliveriesCount == deliveriesCount) &&
            (identical(other.totalEarnings, totalEarnings) ||
                other.totalEarnings == totalEarnings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, date, deliveriesCount, totalEarnings);

  /// Create a copy of TimelineDataModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimelineDataModelImplCopyWith<_$TimelineDataModelImpl> get copyWith =>
      __$$TimelineDataModelImplCopyWithImpl<_$TimelineDataModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TimelineDataModelImplToJson(this);
  }
}

abstract class _TimelineDataModel implements TimelineDataModel {
  const factory _TimelineDataModel({
    required final String date,
    required final int deliveriesCount,
    required final double totalEarnings,
  }) = _$TimelineDataModelImpl;

  factory _TimelineDataModel.fromJson(Map<String, dynamic> json) =
      _$TimelineDataModelImpl.fromJson;

  @override
  String get date;
  @override
  int get deliveriesCount;
  @override
  double get totalEarnings;

  /// Create a copy of TimelineDataModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimelineDataModelImplCopyWith<_$TimelineDataModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TimelineResponseModel _$TimelineResponseModelFromJson(
  Map<String, dynamic> json,
) {
  return _TimelineResponseModel.fromJson(json);
}

/// @nodoc
mixin _$TimelineResponseModel {
  List<TimelineDataModel> get timeline => throw _privateConstructorUsedError;

  /// Serializes this TimelineResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimelineResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimelineResponseModelCopyWith<TimelineResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimelineResponseModelCopyWith<$Res> {
  factory $TimelineResponseModelCopyWith(
    TimelineResponseModel value,
    $Res Function(TimelineResponseModel) then,
  ) = _$TimelineResponseModelCopyWithImpl<$Res, TimelineResponseModel>;
  @useResult
  $Res call({List<TimelineDataModel> timeline});
}

/// @nodoc
class _$TimelineResponseModelCopyWithImpl<
  $Res,
  $Val extends TimelineResponseModel
>
    implements $TimelineResponseModelCopyWith<$Res> {
  _$TimelineResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimelineResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? timeline = null}) {
    return _then(
      _value.copyWith(
            timeline: null == timeline
                ? _value.timeline
                : timeline // ignore: cast_nullable_to_non_nullable
                      as List<TimelineDataModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimelineResponseModelImplCopyWith<$Res>
    implements $TimelineResponseModelCopyWith<$Res> {
  factory _$$TimelineResponseModelImplCopyWith(
    _$TimelineResponseModelImpl value,
    $Res Function(_$TimelineResponseModelImpl) then,
  ) = __$$TimelineResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<TimelineDataModel> timeline});
}

/// @nodoc
class __$$TimelineResponseModelImplCopyWithImpl<$Res>
    extends
        _$TimelineResponseModelCopyWithImpl<$Res, _$TimelineResponseModelImpl>
    implements _$$TimelineResponseModelImplCopyWith<$Res> {
  __$$TimelineResponseModelImplCopyWithImpl(
    _$TimelineResponseModelImpl _value,
    $Res Function(_$TimelineResponseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimelineResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? timeline = null}) {
    return _then(
      _$TimelineResponseModelImpl(
        timeline: null == timeline
            ? _value._timeline
            : timeline // ignore: cast_nullable_to_non_nullable
                  as List<TimelineDataModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TimelineResponseModelImpl implements _TimelineResponseModel {
  const _$TimelineResponseModelImpl({
    required final List<TimelineDataModel> timeline,
  }) : _timeline = timeline;

  factory _$TimelineResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimelineResponseModelImplFromJson(json);

  final List<TimelineDataModel> _timeline;
  @override
  List<TimelineDataModel> get timeline {
    if (_timeline is EqualUnmodifiableListView) return _timeline;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_timeline);
  }

  @override
  String toString() {
    return 'TimelineResponseModel(timeline: $timeline)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimelineResponseModelImpl &&
            const DeepCollectionEquality().equals(other._timeline, _timeline));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_timeline));

  /// Create a copy of TimelineResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimelineResponseModelImplCopyWith<_$TimelineResponseModelImpl>
  get copyWith =>
      __$$TimelineResponseModelImplCopyWithImpl<_$TimelineResponseModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TimelineResponseModelImplToJson(this);
  }
}

abstract class _TimelineResponseModel implements TimelineResponseModel {
  const factory _TimelineResponseModel({
    required final List<TimelineDataModel> timeline,
  }) = _$TimelineResponseModelImpl;

  factory _TimelineResponseModel.fromJson(Map<String, dynamic> json) =
      _$TimelineResponseModelImpl.fromJson;

  @override
  List<TimelineDataModel> get timeline;

  /// Create a copy of TimelineResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimelineResponseModelImplCopyWith<_$TimelineResponseModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
