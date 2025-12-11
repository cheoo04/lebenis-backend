// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stats_summary_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StatsSummaryModel _$StatsSummaryModelFromJson(Map<String, dynamic> json) {
  return _StatsSummaryModel.fromJson(json);
}

/// @nodoc
mixin _$StatsSummaryModel {
  @JsonKey(name: 'total_deliveries')
  int get totalDeliveries => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_deliveries')
  int get completedDeliveries => throw _privateConstructorUsedError;
  @JsonKey(name: 'cancelled_deliveries')
  int get cancelledDeliveries => throw _privateConstructorUsedError;
  @JsonKey(name: 'in_progress_deliveries')
  int get inProgressDeliveries => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_earnings')
  double get totalEarnings => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_distance_km')
  double get totalDistanceKm => throw _privateConstructorUsedError;
  @JsonKey(name: 'success_rate')
  double get successRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_delivery_value')
  double get averageDeliveryValue => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StatsSummaryModelCopyWith<StatsSummaryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatsSummaryModelCopyWith<$Res> {
  factory $StatsSummaryModelCopyWith(
          StatsSummaryModel value, $Res Function(StatsSummaryModel) then) =
      _$StatsSummaryModelCopyWithImpl<$Res, StatsSummaryModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'total_deliveries') int totalDeliveries,
      @JsonKey(name: 'completed_deliveries') int completedDeliveries,
      @JsonKey(name: 'cancelled_deliveries') int cancelledDeliveries,
      @JsonKey(name: 'in_progress_deliveries') int inProgressDeliveries,
      @JsonKey(name: 'total_earnings') double totalEarnings,
      @JsonKey(name: 'total_distance_km') double totalDistanceKm,
      @JsonKey(name: 'success_rate') double successRate,
      @JsonKey(name: 'average_delivery_value') double averageDeliveryValue});
}

/// @nodoc
class _$StatsSummaryModelCopyWithImpl<$Res, $Val extends StatsSummaryModel>
    implements $StatsSummaryModelCopyWith<$Res> {
  _$StatsSummaryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDeliveries = null,
    Object? completedDeliveries = null,
    Object? cancelledDeliveries = null,
    Object? inProgressDeliveries = null,
    Object? totalEarnings = null,
    Object? totalDistanceKm = null,
    Object? successRate = null,
    Object? averageDeliveryValue = null,
  }) {
    return _then(_value.copyWith(
      totalDeliveries: null == totalDeliveries
          ? _value.totalDeliveries
          : totalDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      completedDeliveries: null == completedDeliveries
          ? _value.completedDeliveries
          : completedDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      cancelledDeliveries: null == cancelledDeliveries
          ? _value.cancelledDeliveries
          : cancelledDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      inProgressDeliveries: null == inProgressDeliveries
          ? _value.inProgressDeliveries
          : inProgressDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      totalEarnings: null == totalEarnings
          ? _value.totalEarnings
          : totalEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      totalDistanceKm: null == totalDistanceKm
          ? _value.totalDistanceKm
          : totalDistanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      successRate: null == successRate
          ? _value.successRate
          : successRate // ignore: cast_nullable_to_non_nullable
              as double,
      averageDeliveryValue: null == averageDeliveryValue
          ? _value.averageDeliveryValue
          : averageDeliveryValue // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StatsSummaryModelImplCopyWith<$Res>
    implements $StatsSummaryModelCopyWith<$Res> {
  factory _$$StatsSummaryModelImplCopyWith(_$StatsSummaryModelImpl value,
          $Res Function(_$StatsSummaryModelImpl) then) =
      __$$StatsSummaryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'total_deliveries') int totalDeliveries,
      @JsonKey(name: 'completed_deliveries') int completedDeliveries,
      @JsonKey(name: 'cancelled_deliveries') int cancelledDeliveries,
      @JsonKey(name: 'in_progress_deliveries') int inProgressDeliveries,
      @JsonKey(name: 'total_earnings') double totalEarnings,
      @JsonKey(name: 'total_distance_km') double totalDistanceKm,
      @JsonKey(name: 'success_rate') double successRate,
      @JsonKey(name: 'average_delivery_value') double averageDeliveryValue});
}

/// @nodoc
class __$$StatsSummaryModelImplCopyWithImpl<$Res>
    extends _$StatsSummaryModelCopyWithImpl<$Res, _$StatsSummaryModelImpl>
    implements _$$StatsSummaryModelImplCopyWith<$Res> {
  __$$StatsSummaryModelImplCopyWithImpl(_$StatsSummaryModelImpl _value,
      $Res Function(_$StatsSummaryModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDeliveries = null,
    Object? completedDeliveries = null,
    Object? cancelledDeliveries = null,
    Object? inProgressDeliveries = null,
    Object? totalEarnings = null,
    Object? totalDistanceKm = null,
    Object? successRate = null,
    Object? averageDeliveryValue = null,
  }) {
    return _then(_$StatsSummaryModelImpl(
      totalDeliveries: null == totalDeliveries
          ? _value.totalDeliveries
          : totalDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      completedDeliveries: null == completedDeliveries
          ? _value.completedDeliveries
          : completedDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      cancelledDeliveries: null == cancelledDeliveries
          ? _value.cancelledDeliveries
          : cancelledDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      inProgressDeliveries: null == inProgressDeliveries
          ? _value.inProgressDeliveries
          : inProgressDeliveries // ignore: cast_nullable_to_non_nullable
              as int,
      totalEarnings: null == totalEarnings
          ? _value.totalEarnings
          : totalEarnings // ignore: cast_nullable_to_non_nullable
              as double,
      totalDistanceKm: null == totalDistanceKm
          ? _value.totalDistanceKm
          : totalDistanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      successRate: null == successRate
          ? _value.successRate
          : successRate // ignore: cast_nullable_to_non_nullable
              as double,
      averageDeliveryValue: null == averageDeliveryValue
          ? _value.averageDeliveryValue
          : averageDeliveryValue // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StatsSummaryModelImpl implements _StatsSummaryModel {
  const _$StatsSummaryModelImpl(
      {@JsonKey(name: 'total_deliveries') required this.totalDeliveries,
      @JsonKey(name: 'completed_deliveries') required this.completedDeliveries,
      @JsonKey(name: 'cancelled_deliveries') required this.cancelledDeliveries,
      @JsonKey(name: 'in_progress_deliveries')
      required this.inProgressDeliveries,
      @JsonKey(name: 'total_earnings') required this.totalEarnings,
      @JsonKey(name: 'total_distance_km') required this.totalDistanceKm,
      @JsonKey(name: 'success_rate') required this.successRate,
      @JsonKey(name: 'average_delivery_value')
      required this.averageDeliveryValue});

  factory _$StatsSummaryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatsSummaryModelImplFromJson(json);

  @override
  @JsonKey(name: 'total_deliveries')
  final int totalDeliveries;
  @override
  @JsonKey(name: 'completed_deliveries')
  final int completedDeliveries;
  @override
  @JsonKey(name: 'cancelled_deliveries')
  final int cancelledDeliveries;
  @override
  @JsonKey(name: 'in_progress_deliveries')
  final int inProgressDeliveries;
  @override
  @JsonKey(name: 'total_earnings')
  final double totalEarnings;
  @override
  @JsonKey(name: 'total_distance_km')
  final double totalDistanceKm;
  @override
  @JsonKey(name: 'success_rate')
  final double successRate;
  @override
  @JsonKey(name: 'average_delivery_value')
  final double averageDeliveryValue;

  @override
  String toString() {
    return 'StatsSummaryModel(totalDeliveries: $totalDeliveries, completedDeliveries: $completedDeliveries, cancelledDeliveries: $cancelledDeliveries, inProgressDeliveries: $inProgressDeliveries, totalEarnings: $totalEarnings, totalDistanceKm: $totalDistanceKm, successRate: $successRate, averageDeliveryValue: $averageDeliveryValue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatsSummaryModelImpl &&
            (identical(other.totalDeliveries, totalDeliveries) ||
                other.totalDeliveries == totalDeliveries) &&
            (identical(other.completedDeliveries, completedDeliveries) ||
                other.completedDeliveries == completedDeliveries) &&
            (identical(other.cancelledDeliveries, cancelledDeliveries) ||
                other.cancelledDeliveries == cancelledDeliveries) &&
            (identical(other.inProgressDeliveries, inProgressDeliveries) ||
                other.inProgressDeliveries == inProgressDeliveries) &&
            (identical(other.totalEarnings, totalEarnings) ||
                other.totalEarnings == totalEarnings) &&
            (identical(other.totalDistanceKm, totalDistanceKm) ||
                other.totalDistanceKm == totalDistanceKm) &&
            (identical(other.successRate, successRate) ||
                other.successRate == successRate) &&
            (identical(other.averageDeliveryValue, averageDeliveryValue) ||
                other.averageDeliveryValue == averageDeliveryValue));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalDeliveries,
      completedDeliveries,
      cancelledDeliveries,
      inProgressDeliveries,
      totalEarnings,
      totalDistanceKm,
      successRate,
      averageDeliveryValue);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StatsSummaryModelImplCopyWith<_$StatsSummaryModelImpl> get copyWith =>
      __$$StatsSummaryModelImplCopyWithImpl<_$StatsSummaryModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StatsSummaryModelImplToJson(
      this,
    );
  }
}

abstract class _StatsSummaryModel implements StatsSummaryModel {
  const factory _StatsSummaryModel(
      {@JsonKey(name: 'total_deliveries') required final int totalDeliveries,
      @JsonKey(name: 'completed_deliveries')
      required final int completedDeliveries,
      @JsonKey(name: 'cancelled_deliveries')
      required final int cancelledDeliveries,
      @JsonKey(name: 'in_progress_deliveries')
      required final int inProgressDeliveries,
      @JsonKey(name: 'total_earnings') required final double totalEarnings,
      @JsonKey(name: 'total_distance_km') required final double totalDistanceKm,
      @JsonKey(name: 'success_rate') required final double successRate,
      @JsonKey(name: 'average_delivery_value')
      required final double averageDeliveryValue}) = _$StatsSummaryModelImpl;

  factory _StatsSummaryModel.fromJson(Map<String, dynamic> json) =
      _$StatsSummaryModelImpl.fromJson;

  @override
  @JsonKey(name: 'total_deliveries')
  int get totalDeliveries;
  @override
  @JsonKey(name: 'completed_deliveries')
  int get completedDeliveries;
  @override
  @JsonKey(name: 'cancelled_deliveries')
  int get cancelledDeliveries;
  @override
  @JsonKey(name: 'in_progress_deliveries')
  int get inProgressDeliveries;
  @override
  @JsonKey(name: 'total_earnings')
  double get totalEarnings;
  @override
  @JsonKey(name: 'total_distance_km')
  double get totalDistanceKm;
  @override
  @JsonKey(name: 'success_rate')
  double get successRate;
  @override
  @JsonKey(name: 'average_delivery_value')
  double get averageDeliveryValue;
  @override
  @JsonKey(ignore: true)
  _$$StatsSummaryModelImplCopyWith<_$StatsSummaryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
