// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'delivery_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DeliveryInfo _$DeliveryInfoFromJson(Map<String, dynamic> json) {
  return _DeliveryInfo.fromJson(json);
}

/// @nodoc
mixin _$DeliveryInfo {
  String get id => throw _privateConstructorUsedError;
  String get trackingNumber => throw _privateConstructorUsedError;
  String? get pickupAddress => throw _privateConstructorUsedError;
  String? get deliveryAddress => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DeliveryInfoCopyWith<DeliveryInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeliveryInfoCopyWith<$Res> {
  factory $DeliveryInfoCopyWith(
          DeliveryInfo value, $Res Function(DeliveryInfo) then) =
      _$DeliveryInfoCopyWithImpl<$Res, DeliveryInfo>;
  @useResult
  $Res call(
      {String id,
      String trackingNumber,
      String? pickupAddress,
      String? deliveryAddress});
}

/// @nodoc
class _$DeliveryInfoCopyWithImpl<$Res, $Val extends DeliveryInfo>
    implements $DeliveryInfoCopyWith<$Res> {
  _$DeliveryInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trackingNumber = null,
    Object? pickupAddress = freezed,
    Object? deliveryAddress = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      trackingNumber: null == trackingNumber
          ? _value.trackingNumber
          : trackingNumber // ignore: cast_nullable_to_non_nullable
              as String,
      pickupAddress: freezed == pickupAddress
          ? _value.pickupAddress
          : pickupAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveryAddress: freezed == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeliveryInfoImplCopyWith<$Res>
    implements $DeliveryInfoCopyWith<$Res> {
  factory _$$DeliveryInfoImplCopyWith(
          _$DeliveryInfoImpl value, $Res Function(_$DeliveryInfoImpl) then) =
      __$$DeliveryInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String trackingNumber,
      String? pickupAddress,
      String? deliveryAddress});
}

/// @nodoc
class __$$DeliveryInfoImplCopyWithImpl<$Res>
    extends _$DeliveryInfoCopyWithImpl<$Res, _$DeliveryInfoImpl>
    implements _$$DeliveryInfoImplCopyWith<$Res> {
  __$$DeliveryInfoImplCopyWithImpl(
      _$DeliveryInfoImpl _value, $Res Function(_$DeliveryInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trackingNumber = null,
    Object? pickupAddress = freezed,
    Object? deliveryAddress = freezed,
  }) {
    return _then(_$DeliveryInfoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      trackingNumber: null == trackingNumber
          ? _value.trackingNumber
          : trackingNumber // ignore: cast_nullable_to_non_nullable
              as String,
      pickupAddress: freezed == pickupAddress
          ? _value.pickupAddress
          : pickupAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      deliveryAddress: freezed == deliveryAddress
          ? _value.deliveryAddress
          : deliveryAddress // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeliveryInfoImpl implements _DeliveryInfo {
  const _$DeliveryInfoImpl(
      {required this.id,
      required this.trackingNumber,
      this.pickupAddress,
      this.deliveryAddress});

  factory _$DeliveryInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeliveryInfoImplFromJson(json);

  @override
  final String id;
  @override
  final String trackingNumber;
  @override
  final String? pickupAddress;
  @override
  final String? deliveryAddress;

  @override
  String toString() {
    return 'DeliveryInfo(id: $id, trackingNumber: $trackingNumber, pickupAddress: $pickupAddress, deliveryAddress: $deliveryAddress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeliveryInfoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.trackingNumber, trackingNumber) ||
                other.trackingNumber == trackingNumber) &&
            (identical(other.pickupAddress, pickupAddress) ||
                other.pickupAddress == pickupAddress) &&
            (identical(other.deliveryAddress, deliveryAddress) ||
                other.deliveryAddress == deliveryAddress));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, trackingNumber, pickupAddress, deliveryAddress);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DeliveryInfoImplCopyWith<_$DeliveryInfoImpl> get copyWith =>
      __$$DeliveryInfoImplCopyWithImpl<_$DeliveryInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeliveryInfoImplToJson(
      this,
    );
  }
}

abstract class _DeliveryInfo implements DeliveryInfo {
  const factory _DeliveryInfo(
      {required final String id,
      required final String trackingNumber,
      final String? pickupAddress,
      final String? deliveryAddress}) = _$DeliveryInfoImpl;

  factory _DeliveryInfo.fromJson(Map<String, dynamic> json) =
      _$DeliveryInfoImpl.fromJson;

  @override
  String get id;
  @override
  String get trackingNumber;
  @override
  String? get pickupAddress;
  @override
  String? get deliveryAddress;
  @override
  @JsonKey(ignore: true)
  _$$DeliveryInfoImplCopyWith<_$DeliveryInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
