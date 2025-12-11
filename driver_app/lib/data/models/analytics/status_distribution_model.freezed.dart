// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'status_distribution_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StatusDistributionItemModel _$StatusDistributionItemModelFromJson(
    Map<String, dynamic> json) {
  return _StatusDistributionItemModel.fromJson(json);
}

/// @nodoc
mixin _$StatusDistributionItemModel {
  String get status => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StatusDistributionItemModelCopyWith<StatusDistributionItemModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatusDistributionItemModelCopyWith<$Res> {
  factory $StatusDistributionItemModelCopyWith(
          StatusDistributionItemModel value,
          $Res Function(StatusDistributionItemModel) then) =
      _$StatusDistributionItemModelCopyWithImpl<$Res,
          StatusDistributionItemModel>;
  @useResult
  $Res call({String status, int count});
}

/// @nodoc
class _$StatusDistributionItemModelCopyWithImpl<$Res,
        $Val extends StatusDistributionItemModel>
    implements $StatusDistributionItemModelCopyWith<$Res> {
  _$StatusDistributionItemModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? count = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StatusDistributionItemModelImplCopyWith<$Res>
    implements $StatusDistributionItemModelCopyWith<$Res> {
  factory _$$StatusDistributionItemModelImplCopyWith(
          _$StatusDistributionItemModelImpl value,
          $Res Function(_$StatusDistributionItemModelImpl) then) =
      __$$StatusDistributionItemModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String status, int count});
}

/// @nodoc
class __$$StatusDistributionItemModelImplCopyWithImpl<$Res>
    extends _$StatusDistributionItemModelCopyWithImpl<$Res,
        _$StatusDistributionItemModelImpl>
    implements _$$StatusDistributionItemModelImplCopyWith<$Res> {
  __$$StatusDistributionItemModelImplCopyWithImpl(
      _$StatusDistributionItemModelImpl _value,
      $Res Function(_$StatusDistributionItemModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? count = null,
  }) {
    return _then(_$StatusDistributionItemModelImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StatusDistributionItemModelImpl
    implements _StatusDistributionItemModel {
  const _$StatusDistributionItemModelImpl(
      {required this.status, required this.count});

  factory _$StatusDistributionItemModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$StatusDistributionItemModelImplFromJson(json);

  @override
  final String status;
  @override
  final int count;

  @override
  String toString() {
    return 'StatusDistributionItemModel(status: $status, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatusDistributionItemModelImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, status, count);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StatusDistributionItemModelImplCopyWith<_$StatusDistributionItemModelImpl>
      get copyWith => __$$StatusDistributionItemModelImplCopyWithImpl<
          _$StatusDistributionItemModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StatusDistributionItemModelImplToJson(
      this,
    );
  }
}

abstract class _StatusDistributionItemModel
    implements StatusDistributionItemModel {
  const factory _StatusDistributionItemModel(
      {required final String status,
      required final int count}) = _$StatusDistributionItemModelImpl;

  factory _StatusDistributionItemModel.fromJson(Map<String, dynamic> json) =
      _$StatusDistributionItemModelImpl.fromJson;

  @override
  String get status;
  @override
  int get count;
  @override
  @JsonKey(ignore: true)
  _$$StatusDistributionItemModelImplCopyWith<_$StatusDistributionItemModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

StatusDistributionResponseModel _$StatusDistributionResponseModelFromJson(
    Map<String, dynamic> json) {
  return _StatusDistributionResponseModel.fromJson(json);
}

/// @nodoc
mixin _$StatusDistributionResponseModel {
  List<StatusDistributionItemModel> get distribution =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StatusDistributionResponseModelCopyWith<StatusDistributionResponseModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatusDistributionResponseModelCopyWith<$Res> {
  factory $StatusDistributionResponseModelCopyWith(
          StatusDistributionResponseModel value,
          $Res Function(StatusDistributionResponseModel) then) =
      _$StatusDistributionResponseModelCopyWithImpl<$Res,
          StatusDistributionResponseModel>;
  @useResult
  $Res call({List<StatusDistributionItemModel> distribution});
}

/// @nodoc
class _$StatusDistributionResponseModelCopyWithImpl<$Res,
        $Val extends StatusDistributionResponseModel>
    implements $StatusDistributionResponseModelCopyWith<$Res> {
  _$StatusDistributionResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? distribution = null,
  }) {
    return _then(_value.copyWith(
      distribution: null == distribution
          ? _value.distribution
          : distribution // ignore: cast_nullable_to_non_nullable
              as List<StatusDistributionItemModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StatusDistributionResponseModelImplCopyWith<$Res>
    implements $StatusDistributionResponseModelCopyWith<$Res> {
  factory _$$StatusDistributionResponseModelImplCopyWith(
          _$StatusDistributionResponseModelImpl value,
          $Res Function(_$StatusDistributionResponseModelImpl) then) =
      __$$StatusDistributionResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<StatusDistributionItemModel> distribution});
}

/// @nodoc
class __$$StatusDistributionResponseModelImplCopyWithImpl<$Res>
    extends _$StatusDistributionResponseModelCopyWithImpl<$Res,
        _$StatusDistributionResponseModelImpl>
    implements _$$StatusDistributionResponseModelImplCopyWith<$Res> {
  __$$StatusDistributionResponseModelImplCopyWithImpl(
      _$StatusDistributionResponseModelImpl _value,
      $Res Function(_$StatusDistributionResponseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? distribution = null,
  }) {
    return _then(_$StatusDistributionResponseModelImpl(
      distribution: null == distribution
          ? _value._distribution
          : distribution // ignore: cast_nullable_to_non_nullable
              as List<StatusDistributionItemModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StatusDistributionResponseModelImpl
    implements _StatusDistributionResponseModel {
  const _$StatusDistributionResponseModelImpl(
      {required final List<StatusDistributionItemModel> distribution})
      : _distribution = distribution;

  factory _$StatusDistributionResponseModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$StatusDistributionResponseModelImplFromJson(json);

  final List<StatusDistributionItemModel> _distribution;
  @override
  List<StatusDistributionItemModel> get distribution {
    if (_distribution is EqualUnmodifiableListView) return _distribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_distribution);
  }

  @override
  String toString() {
    return 'StatusDistributionResponseModel(distribution: $distribution)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatusDistributionResponseModelImpl &&
            const DeepCollectionEquality()
                .equals(other._distribution, _distribution));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_distribution));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StatusDistributionResponseModelImplCopyWith<
          _$StatusDistributionResponseModelImpl>
      get copyWith => __$$StatusDistributionResponseModelImplCopyWithImpl<
          _$StatusDistributionResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StatusDistributionResponseModelImplToJson(
      this,
    );
  }
}

abstract class _StatusDistributionResponseModel
    implements StatusDistributionResponseModel {
  const factory _StatusDistributionResponseModel(
          {required final List<StatusDistributionItemModel> distribution}) =
      _$StatusDistributionResponseModelImpl;

  factory _StatusDistributionResponseModel.fromJson(Map<String, dynamic> json) =
      _$StatusDistributionResponseModelImpl.fromJson;

  @override
  List<StatusDistributionItemModel> get distribution;
  @override
  @JsonKey(ignore: true)
  _$$StatusDistributionResponseModelImplCopyWith<
          _$StatusDistributionResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
