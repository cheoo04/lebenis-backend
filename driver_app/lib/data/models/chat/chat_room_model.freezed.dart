// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_room_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatParticipant _$ChatParticipantFromJson(Map<String, dynamic> json) {
  return _ChatParticipant.fromJson(json);
}

/// @nodoc
mixin _$ChatParticipant {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'phone_number')
  String get phoneNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_type')
  String get userType => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_photo_url')
  String? get profilePhotoUrl => throw _privateConstructorUsedError;

  /// Serializes this ChatParticipant to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatParticipant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatParticipantCopyWith<ChatParticipant> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatParticipantCopyWith<$Res> {
  factory $ChatParticipantCopyWith(
    ChatParticipant value,
    $Res Function(ChatParticipant) then,
  ) = _$ChatParticipantCopyWithImpl<$Res, ChatParticipant>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'full_name') String fullName,
    @JsonKey(name: 'phone_number') String phoneNumber,
    @JsonKey(name: 'user_type') String userType,
    @JsonKey(name: 'profile_photo_url') String? profilePhotoUrl,
  });
}

/// @nodoc
class _$ChatParticipantCopyWithImpl<$Res, $Val extends ChatParticipant>
    implements $ChatParticipantCopyWith<$Res> {
  _$ChatParticipantCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatParticipant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? phoneNumber = null,
    Object? userType = null,
    Object? profilePhotoUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            fullName: null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                      as String,
            phoneNumber: null == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String,
            userType: null == userType
                ? _value.userType
                : userType // ignore: cast_nullable_to_non_nullable
                      as String,
            profilePhotoUrl: freezed == profilePhotoUrl
                ? _value.profilePhotoUrl
                : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatParticipantImplCopyWith<$Res>
    implements $ChatParticipantCopyWith<$Res> {
  factory _$$ChatParticipantImplCopyWith(
    _$ChatParticipantImpl value,
    $Res Function(_$ChatParticipantImpl) then,
  ) = __$$ChatParticipantImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'full_name') String fullName,
    @JsonKey(name: 'phone_number') String phoneNumber,
    @JsonKey(name: 'user_type') String userType,
    @JsonKey(name: 'profile_photo_url') String? profilePhotoUrl,
  });
}

/// @nodoc
class __$$ChatParticipantImplCopyWithImpl<$Res>
    extends _$ChatParticipantCopyWithImpl<$Res, _$ChatParticipantImpl>
    implements _$$ChatParticipantImplCopyWith<$Res> {
  __$$ChatParticipantImplCopyWithImpl(
    _$ChatParticipantImpl _value,
    $Res Function(_$ChatParticipantImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatParticipant
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? phoneNumber = null,
    Object? userType = null,
    Object? profilePhotoUrl = freezed,
  }) {
    return _then(
      _$ChatParticipantImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
                  as String,
        phoneNumber: null == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String,
        userType: null == userType
            ? _value.userType
            : userType // ignore: cast_nullable_to_non_nullable
                  as String,
        profilePhotoUrl: freezed == profilePhotoUrl
            ? _value.profilePhotoUrl
            : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatParticipantImpl implements _ChatParticipant {
  const _$ChatParticipantImpl({
    required this.id,
    @JsonKey(name: 'full_name') required this.fullName,
    @JsonKey(name: 'phone_number') required this.phoneNumber,
    @JsonKey(name: 'user_type') required this.userType,
    @JsonKey(name: 'profile_photo_url') this.profilePhotoUrl,
  });

  factory _$ChatParticipantImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatParticipantImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  @override
  @JsonKey(name: 'user_type')
  final String userType;
  @override
  @JsonKey(name: 'profile_photo_url')
  final String? profilePhotoUrl;

  @override
  String toString() {
    return 'ChatParticipant(id: $id, fullName: $fullName, phoneNumber: $phoneNumber, userType: $userType, profilePhotoUrl: $profilePhotoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatParticipantImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.userType, userType) ||
                other.userType == userType) &&
            (identical(other.profilePhotoUrl, profilePhotoUrl) ||
                other.profilePhotoUrl == profilePhotoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    fullName,
    phoneNumber,
    userType,
    profilePhotoUrl,
  );

  /// Create a copy of ChatParticipant
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatParticipantImplCopyWith<_$ChatParticipantImpl> get copyWith =>
      __$$ChatParticipantImplCopyWithImpl<_$ChatParticipantImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatParticipantImplToJson(this);
  }
}

abstract class _ChatParticipant implements ChatParticipant {
  const factory _ChatParticipant({
    required final String id,
    @JsonKey(name: 'full_name') required final String fullName,
    @JsonKey(name: 'phone_number') required final String phoneNumber,
    @JsonKey(name: 'user_type') required final String userType,
    @JsonKey(name: 'profile_photo_url') final String? profilePhotoUrl,
  }) = _$ChatParticipantImpl;

  factory _ChatParticipant.fromJson(Map<String, dynamic> json) =
      _$ChatParticipantImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  @JsonKey(name: 'phone_number')
  String get phoneNumber;
  @override
  @JsonKey(name: 'user_type')
  String get userType;
  @override
  @JsonKey(name: 'profile_photo_url')
  String? get profilePhotoUrl;

  /// Create a copy of ChatParticipant
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatParticipantImplCopyWith<_$ChatParticipantImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DeliveryInfo _$DeliveryInfoFromJson(Map<String, dynamic> json) {
  return _DeliveryInfo.fromJson(json);
}

/// @nodoc
mixin _$DeliveryInfo {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'tracking_number')
  String get trackingNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'pickup_address')
  String? get pickupAddress => throw _privateConstructorUsedError;
  @JsonKey(name: 'delivery_address')
  String? get deliveryAddress => throw _privateConstructorUsedError;

  /// Serializes this DeliveryInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeliveryInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeliveryInfoCopyWith<DeliveryInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeliveryInfoCopyWith<$Res> {
  factory $DeliveryInfoCopyWith(
    DeliveryInfo value,
    $Res Function(DeliveryInfo) then,
  ) = _$DeliveryInfoCopyWithImpl<$Res, DeliveryInfo>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'tracking_number') String trackingNumber,
    @JsonKey(name: 'pickup_address') String? pickupAddress,
    @JsonKey(name: 'delivery_address') String? deliveryAddress,
  });
}

/// @nodoc
class _$DeliveryInfoCopyWithImpl<$Res, $Val extends DeliveryInfo>
    implements $DeliveryInfoCopyWith<$Res> {
  _$DeliveryInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeliveryInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trackingNumber = null,
    Object? pickupAddress = freezed,
    Object? deliveryAddress = freezed,
  }) {
    return _then(
      _value.copyWith(
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeliveryInfoImplCopyWith<$Res>
    implements $DeliveryInfoCopyWith<$Res> {
  factory _$$DeliveryInfoImplCopyWith(
    _$DeliveryInfoImpl value,
    $Res Function(_$DeliveryInfoImpl) then,
  ) = __$$DeliveryInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'tracking_number') String trackingNumber,
    @JsonKey(name: 'pickup_address') String? pickupAddress,
    @JsonKey(name: 'delivery_address') String? deliveryAddress,
  });
}

/// @nodoc
class __$$DeliveryInfoImplCopyWithImpl<$Res>
    extends _$DeliveryInfoCopyWithImpl<$Res, _$DeliveryInfoImpl>
    implements _$$DeliveryInfoImplCopyWith<$Res> {
  __$$DeliveryInfoImplCopyWithImpl(
    _$DeliveryInfoImpl _value,
    $Res Function(_$DeliveryInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeliveryInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trackingNumber = null,
    Object? pickupAddress = freezed,
    Object? deliveryAddress = freezed,
  }) {
    return _then(
      _$DeliveryInfoImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeliveryInfoImpl implements _DeliveryInfo {
  const _$DeliveryInfoImpl({
    required this.id,
    @JsonKey(name: 'tracking_number') required this.trackingNumber,
    @JsonKey(name: 'pickup_address') this.pickupAddress,
    @JsonKey(name: 'delivery_address') this.deliveryAddress,
  });

  factory _$DeliveryInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeliveryInfoImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'tracking_number')
  final String trackingNumber;
  @override
  @JsonKey(name: 'pickup_address')
  final String? pickupAddress;
  @override
  @JsonKey(name: 'delivery_address')
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

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    trackingNumber,
    pickupAddress,
    deliveryAddress,
  );

  /// Create a copy of DeliveryInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeliveryInfoImplCopyWith<_$DeliveryInfoImpl> get copyWith =>
      __$$DeliveryInfoImplCopyWithImpl<_$DeliveryInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeliveryInfoImplToJson(this);
  }
}

abstract class _DeliveryInfo implements DeliveryInfo {
  const factory _DeliveryInfo({
    required final String id,
    @JsonKey(name: 'tracking_number') required final String trackingNumber,
    @JsonKey(name: 'pickup_address') final String? pickupAddress,
    @JsonKey(name: 'delivery_address') final String? deliveryAddress,
  }) = _$DeliveryInfoImpl;

  factory _DeliveryInfo.fromJson(Map<String, dynamic> json) =
      _$DeliveryInfoImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'tracking_number')
  String get trackingNumber;
  @override
  @JsonKey(name: 'pickup_address')
  String? get pickupAddress;
  @override
  @JsonKey(name: 'delivery_address')
  String? get deliveryAddress;

  /// Create a copy of DeliveryInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeliveryInfoImplCopyWith<_$DeliveryInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatRoomModel _$ChatRoomModelFromJson(Map<String, dynamic> json) {
  return _ChatRoomModel.fromJson(json);
}

/// @nodoc
mixin _$ChatRoomModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'room_type')
  RoomType get roomType => throw _privateConstructorUsedError;
  @JsonKey(name: 'other_participant')
  ChatParticipant get otherParticipant => throw _privateConstructorUsedError;
  @JsonKey(name: 'delivery_info')
  DeliveryInfo? get deliveryInfo => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_message_text')
  String? get lastMessageText => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_message_at')
  DateTime? get lastMessageAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'unread_count')
  int get unreadCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_archived')
  bool get isArchived => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'firebase_path')
  String? get firebasePath => throw _privateConstructorUsedError;

  /// Serializes this ChatRoomModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatRoomModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatRoomModelCopyWith<ChatRoomModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatRoomModelCopyWith<$Res> {
  factory $ChatRoomModelCopyWith(
    ChatRoomModel value,
    $Res Function(ChatRoomModel) then,
  ) = _$ChatRoomModelCopyWithImpl<$Res, ChatRoomModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'room_type') RoomType roomType,
    @JsonKey(name: 'other_participant') ChatParticipant otherParticipant,
    @JsonKey(name: 'delivery_info') DeliveryInfo? deliveryInfo,
    @JsonKey(name: 'last_message_text') String? lastMessageText,
    @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
    @JsonKey(name: 'unread_count') int unreadCount,
    @JsonKey(name: 'is_archived') bool isArchived,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'firebase_path') String? firebasePath,
  });

  $ChatParticipantCopyWith<$Res> get otherParticipant;
  $DeliveryInfoCopyWith<$Res>? get deliveryInfo;
}

/// @nodoc
class _$ChatRoomModelCopyWithImpl<$Res, $Val extends ChatRoomModel>
    implements $ChatRoomModelCopyWith<$Res> {
  _$ChatRoomModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatRoomModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomType = null,
    Object? otherParticipant = null,
    Object? deliveryInfo = freezed,
    Object? lastMessageText = freezed,
    Object? lastMessageAt = freezed,
    Object? unreadCount = null,
    Object? isArchived = null,
    Object? createdAt = null,
    Object? firebasePath = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            roomType: null == roomType
                ? _value.roomType
                : roomType // ignore: cast_nullable_to_non_nullable
                      as RoomType,
            otherParticipant: null == otherParticipant
                ? _value.otherParticipant
                : otherParticipant // ignore: cast_nullable_to_non_nullable
                      as ChatParticipant,
            deliveryInfo: freezed == deliveryInfo
                ? _value.deliveryInfo
                : deliveryInfo // ignore: cast_nullable_to_non_nullable
                      as DeliveryInfo?,
            lastMessageText: freezed == lastMessageText
                ? _value.lastMessageText
                : lastMessageText // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastMessageAt: freezed == lastMessageAt
                ? _value.lastMessageAt
                : lastMessageAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            unreadCount: null == unreadCount
                ? _value.unreadCount
                : unreadCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isArchived: null == isArchived
                ? _value.isArchived
                : isArchived // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            firebasePath: freezed == firebasePath
                ? _value.firebasePath
                : firebasePath // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of ChatRoomModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChatParticipantCopyWith<$Res> get otherParticipant {
    return $ChatParticipantCopyWith<$Res>(_value.otherParticipant, (value) {
      return _then(_value.copyWith(otherParticipant: value) as $Val);
    });
  }

  /// Create a copy of ChatRoomModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DeliveryInfoCopyWith<$Res>? get deliveryInfo {
    if (_value.deliveryInfo == null) {
      return null;
    }

    return $DeliveryInfoCopyWith<$Res>(_value.deliveryInfo!, (value) {
      return _then(_value.copyWith(deliveryInfo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatRoomModelImplCopyWith<$Res>
    implements $ChatRoomModelCopyWith<$Res> {
  factory _$$ChatRoomModelImplCopyWith(
    _$ChatRoomModelImpl value,
    $Res Function(_$ChatRoomModelImpl) then,
  ) = __$$ChatRoomModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'room_type') RoomType roomType,
    @JsonKey(name: 'other_participant') ChatParticipant otherParticipant,
    @JsonKey(name: 'delivery_info') DeliveryInfo? deliveryInfo,
    @JsonKey(name: 'last_message_text') String? lastMessageText,
    @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
    @JsonKey(name: 'unread_count') int unreadCount,
    @JsonKey(name: 'is_archived') bool isArchived,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'firebase_path') String? firebasePath,
  });

  @override
  $ChatParticipantCopyWith<$Res> get otherParticipant;
  @override
  $DeliveryInfoCopyWith<$Res>? get deliveryInfo;
}

/// @nodoc
class __$$ChatRoomModelImplCopyWithImpl<$Res>
    extends _$ChatRoomModelCopyWithImpl<$Res, _$ChatRoomModelImpl>
    implements _$$ChatRoomModelImplCopyWith<$Res> {
  __$$ChatRoomModelImplCopyWithImpl(
    _$ChatRoomModelImpl _value,
    $Res Function(_$ChatRoomModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatRoomModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomType = null,
    Object? otherParticipant = null,
    Object? deliveryInfo = freezed,
    Object? lastMessageText = freezed,
    Object? lastMessageAt = freezed,
    Object? unreadCount = null,
    Object? isArchived = null,
    Object? createdAt = null,
    Object? firebasePath = freezed,
  }) {
    return _then(
      _$ChatRoomModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        roomType: null == roomType
            ? _value.roomType
            : roomType // ignore: cast_nullable_to_non_nullable
                  as RoomType,
        otherParticipant: null == otherParticipant
            ? _value.otherParticipant
            : otherParticipant // ignore: cast_nullable_to_non_nullable
                  as ChatParticipant,
        deliveryInfo: freezed == deliveryInfo
            ? _value.deliveryInfo
            : deliveryInfo // ignore: cast_nullable_to_non_nullable
                  as DeliveryInfo?,
        lastMessageText: freezed == lastMessageText
            ? _value.lastMessageText
            : lastMessageText // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastMessageAt: freezed == lastMessageAt
            ? _value.lastMessageAt
            : lastMessageAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        unreadCount: null == unreadCount
            ? _value.unreadCount
            : unreadCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isArchived: null == isArchived
            ? _value.isArchived
            : isArchived // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        firebasePath: freezed == firebasePath
            ? _value.firebasePath
            : firebasePath // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatRoomModelImpl implements _ChatRoomModel {
  const _$ChatRoomModelImpl({
    required this.id,
    @JsonKey(name: 'room_type') required this.roomType,
    @JsonKey(name: 'other_participant') required this.otherParticipant,
    @JsonKey(name: 'delivery_info') this.deliveryInfo,
    @JsonKey(name: 'last_message_text') this.lastMessageText,
    @JsonKey(name: 'last_message_at') this.lastMessageAt,
    @JsonKey(name: 'unread_count') this.unreadCount = 0,
    @JsonKey(name: 'is_archived') this.isArchived = false,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'firebase_path') this.firebasePath,
  });

  factory _$ChatRoomModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatRoomModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'room_type')
  final RoomType roomType;
  @override
  @JsonKey(name: 'other_participant')
  final ChatParticipant otherParticipant;
  @override
  @JsonKey(name: 'delivery_info')
  final DeliveryInfo? deliveryInfo;
  @override
  @JsonKey(name: 'last_message_text')
  final String? lastMessageText;
  @override
  @JsonKey(name: 'last_message_at')
  final DateTime? lastMessageAt;
  @override
  @JsonKey(name: 'unread_count')
  final int unreadCount;
  @override
  @JsonKey(name: 'is_archived')
  final bool isArchived;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'firebase_path')
  final String? firebasePath;

  @override
  String toString() {
    return 'ChatRoomModel(id: $id, roomType: $roomType, otherParticipant: $otherParticipant, deliveryInfo: $deliveryInfo, lastMessageText: $lastMessageText, lastMessageAt: $lastMessageAt, unreadCount: $unreadCount, isArchived: $isArchived, createdAt: $createdAt, firebasePath: $firebasePath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatRoomModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.roomType, roomType) ||
                other.roomType == roomType) &&
            (identical(other.otherParticipant, otherParticipant) ||
                other.otherParticipant == otherParticipant) &&
            (identical(other.deliveryInfo, deliveryInfo) ||
                other.deliveryInfo == deliveryInfo) &&
            (identical(other.lastMessageText, lastMessageText) ||
                other.lastMessageText == lastMessageText) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.firebasePath, firebasePath) ||
                other.firebasePath == firebasePath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    roomType,
    otherParticipant,
    deliveryInfo,
    lastMessageText,
    lastMessageAt,
    unreadCount,
    isArchived,
    createdAt,
    firebasePath,
  );

  /// Create a copy of ChatRoomModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatRoomModelImplCopyWith<_$ChatRoomModelImpl> get copyWith =>
      __$$ChatRoomModelImplCopyWithImpl<_$ChatRoomModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatRoomModelImplToJson(this);
  }
}

abstract class _ChatRoomModel implements ChatRoomModel {
  const factory _ChatRoomModel({
    required final String id,
    @JsonKey(name: 'room_type') required final RoomType roomType,
    @JsonKey(name: 'other_participant')
    required final ChatParticipant otherParticipant,
    @JsonKey(name: 'delivery_info') final DeliveryInfo? deliveryInfo,
    @JsonKey(name: 'last_message_text') final String? lastMessageText,
    @JsonKey(name: 'last_message_at') final DateTime? lastMessageAt,
    @JsonKey(name: 'unread_count') final int unreadCount,
    @JsonKey(name: 'is_archived') final bool isArchived,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'firebase_path') final String? firebasePath,
  }) = _$ChatRoomModelImpl;

  factory _ChatRoomModel.fromJson(Map<String, dynamic> json) =
      _$ChatRoomModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'room_type')
  RoomType get roomType;
  @override
  @JsonKey(name: 'other_participant')
  ChatParticipant get otherParticipant;
  @override
  @JsonKey(name: 'delivery_info')
  DeliveryInfo? get deliveryInfo;
  @override
  @JsonKey(name: 'last_message_text')
  String? get lastMessageText;
  @override
  @JsonKey(name: 'last_message_at')
  DateTime? get lastMessageAt;
  @override
  @JsonKey(name: 'unread_count')
  int get unreadCount;
  @override
  @JsonKey(name: 'is_archived')
  bool get isArchived;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'firebase_path')
  String? get firebasePath;

  /// Create a copy of ChatRoomModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatRoomModelImplCopyWith<_$ChatRoomModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
