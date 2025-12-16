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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatRoomModel _$ChatRoomModelFromJson(Map<String, dynamic> json) {
  return _ChatRoomModel.fromJson(json);
}

/// @nodoc
mixin _$ChatRoomModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'room_type')
  String get roomType => throw _privateConstructorUsedError;
  @JsonKey(name: 'delivery')
  String? get deliveryId => throw _privateConstructorUsedError;
  @JsonKey(name: 'driver_info')
  OtherUserModel get driver => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_message_text')
  String? get lastMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_message_at')
  DateTime? get lastMessageAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'unread_count', defaultValue: 0)
  int get unreadCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_archived', defaultValue: false)
  bool get isArchived => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

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
          ChatRoomModel value, $Res Function(ChatRoomModel) then) =
      _$ChatRoomModelCopyWithImpl<$Res, ChatRoomModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'room_type') String roomType,
      @JsonKey(name: 'delivery') String? deliveryId,
      @JsonKey(name: 'driver_info') OtherUserModel driver,
      @JsonKey(name: 'last_message_text') String? lastMessage,
      @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
      @JsonKey(name: 'unread_count', defaultValue: 0) int unreadCount,
      @JsonKey(name: 'is_archived', defaultValue: false) bool isArchived,
      @JsonKey(name: 'created_at') DateTime createdAt});

  $OtherUserModelCopyWith<$Res> get driver;
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
    Object? deliveryId = freezed,
    Object? driver = null,
    Object? lastMessage = freezed,
    Object? lastMessageAt = freezed,
    Object? unreadCount = null,
    Object? isArchived = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      roomType: null == roomType
          ? _value.roomType
          : roomType // ignore: cast_nullable_to_non_nullable
              as String,
      deliveryId: freezed == deliveryId
          ? _value.deliveryId
          : deliveryId // ignore: cast_nullable_to_non_nullable
              as String?,
      driver: null == driver
          ? _value.driver
          : driver // ignore: cast_nullable_to_non_nullable
              as OtherUserModel,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
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
    ) as $Val);
  }

  /// Create a copy of ChatRoomModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OtherUserModelCopyWith<$Res> get driver {
    return $OtherUserModelCopyWith<$Res>(_value.driver, (value) {
      return _then(_value.copyWith(driver: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChatRoomModelImplCopyWith<$Res>
    implements $ChatRoomModelCopyWith<$Res> {
  factory _$$ChatRoomModelImplCopyWith(
          _$ChatRoomModelImpl value, $Res Function(_$ChatRoomModelImpl) then) =
      __$$ChatRoomModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'room_type') String roomType,
      @JsonKey(name: 'delivery') String? deliveryId,
      @JsonKey(name: 'driver_info') OtherUserModel driver,
      @JsonKey(name: 'last_message_text') String? lastMessage,
      @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
      @JsonKey(name: 'unread_count', defaultValue: 0) int unreadCount,
      @JsonKey(name: 'is_archived', defaultValue: false) bool isArchived,
      @JsonKey(name: 'created_at') DateTime createdAt});

  @override
  $OtherUserModelCopyWith<$Res> get driver;
}

/// @nodoc
class __$$ChatRoomModelImplCopyWithImpl<$Res>
    extends _$ChatRoomModelCopyWithImpl<$Res, _$ChatRoomModelImpl>
    implements _$$ChatRoomModelImplCopyWith<$Res> {
  __$$ChatRoomModelImplCopyWithImpl(
      _$ChatRoomModelImpl _value, $Res Function(_$ChatRoomModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatRoomModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomType = null,
    Object? deliveryId = freezed,
    Object? driver = null,
    Object? lastMessage = freezed,
    Object? lastMessageAt = freezed,
    Object? unreadCount = null,
    Object? isArchived = null,
    Object? createdAt = null,
  }) {
    return _then(_$ChatRoomModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      roomType: null == roomType
          ? _value.roomType
          : roomType // ignore: cast_nullable_to_non_nullable
              as String,
      deliveryId: freezed == deliveryId
          ? _value.deliveryId
          : deliveryId // ignore: cast_nullable_to_non_nullable
              as String?,
      driver: null == driver
          ? _value.driver
          : driver // ignore: cast_nullable_to_non_nullable
              as OtherUserModel,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatRoomModelImpl implements _ChatRoomModel {
  const _$ChatRoomModelImpl(
      {required this.id,
      @JsonKey(name: 'room_type') required this.roomType,
      @JsonKey(name: 'delivery') this.deliveryId,
      @JsonKey(name: 'driver_info') required this.driver,
      @JsonKey(name: 'last_message_text') this.lastMessage,
      @JsonKey(name: 'last_message_at') this.lastMessageAt,
      @JsonKey(name: 'unread_count', defaultValue: 0) required this.unreadCount,
      @JsonKey(name: 'is_archived', defaultValue: false)
      required this.isArchived,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$ChatRoomModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatRoomModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'room_type')
  final String roomType;
  @override
  @JsonKey(name: 'delivery')
  final String? deliveryId;
  @override
  @JsonKey(name: 'driver_info')
  final OtherUserModel driver;
  @override
  @JsonKey(name: 'last_message_text')
  final String? lastMessage;
  @override
  @JsonKey(name: 'last_message_at')
  final DateTime? lastMessageAt;
  @override
  @JsonKey(name: 'unread_count', defaultValue: 0)
  final int unreadCount;
  @override
  @JsonKey(name: 'is_archived', defaultValue: false)
  final bool isArchived;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'ChatRoomModel(id: $id, roomType: $roomType, deliveryId: $deliveryId, driver: $driver, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, unreadCount: $unreadCount, isArchived: $isArchived, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatRoomModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.roomType, roomType) ||
                other.roomType == roomType) &&
            (identical(other.deliveryId, deliveryId) ||
                other.deliveryId == deliveryId) &&
            (identical(other.driver, driver) || other.driver == driver) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, roomType, deliveryId, driver,
      lastMessage, lastMessageAt, unreadCount, isArchived, createdAt);

  /// Create a copy of ChatRoomModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatRoomModelImplCopyWith<_$ChatRoomModelImpl> get copyWith =>
      __$$ChatRoomModelImplCopyWithImpl<_$ChatRoomModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatRoomModelImplToJson(
      this,
    );
  }
}

abstract class _ChatRoomModel implements ChatRoomModel {
  const factory _ChatRoomModel(
          {required final String id,
          @JsonKey(name: 'room_type') required final String roomType,
          @JsonKey(name: 'delivery') final String? deliveryId,
          @JsonKey(name: 'driver_info') required final OtherUserModel driver,
          @JsonKey(name: 'last_message_text') final String? lastMessage,
          @JsonKey(name: 'last_message_at') final DateTime? lastMessageAt,
          @JsonKey(name: 'unread_count', defaultValue: 0)
          required final int unreadCount,
          @JsonKey(name: 'is_archived', defaultValue: false)
          required final bool isArchived,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$ChatRoomModelImpl;

  factory _ChatRoomModel.fromJson(Map<String, dynamic> json) =
      _$ChatRoomModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'room_type')
  String get roomType;
  @override
  @JsonKey(name: 'delivery')
  String? get deliveryId;
  @override
  @JsonKey(name: 'driver_info')
  OtherUserModel get driver;
  @override
  @JsonKey(name: 'last_message_text')
  String? get lastMessage;
  @override
  @JsonKey(name: 'last_message_at')
  DateTime? get lastMessageAt;
  @override
  @JsonKey(name: 'unread_count', defaultValue: 0)
  int get unreadCount;
  @override
  @JsonKey(name: 'is_archived', defaultValue: false)
  bool get isArchived;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of ChatRoomModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatRoomModelImplCopyWith<_$ChatRoomModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OtherUserModel _$OtherUserModelFromJson(Map<String, dynamic> json) {
  return _OtherUserModel.fromJson(json);
}

/// @nodoc
mixin _$OtherUserModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'phone')
  String? get phoneNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_photo')
  String? get profilePhotoUrl => throw _privateConstructorUsedError;

  /// Serializes this OtherUserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OtherUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OtherUserModelCopyWith<OtherUserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OtherUserModelCopyWith<$Res> {
  factory $OtherUserModelCopyWith(
          OtherUserModel value, $Res Function(OtherUserModel) then) =
      _$OtherUserModelCopyWithImpl<$Res, OtherUserModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'full_name') String fullName,
      @JsonKey(name: 'phone') String? phoneNumber,
      @JsonKey(name: 'profile_photo') String? profilePhotoUrl});
}

/// @nodoc
class _$OtherUserModelCopyWithImpl<$Res, $Val extends OtherUserModel>
    implements $OtherUserModelCopyWith<$Res> {
  _$OtherUserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OtherUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? phoneNumber = freezed,
    Object? profilePhotoUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePhotoUrl: freezed == profilePhotoUrl
          ? _value.profilePhotoUrl
          : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OtherUserModelImplCopyWith<$Res>
    implements $OtherUserModelCopyWith<$Res> {
  factory _$$OtherUserModelImplCopyWith(_$OtherUserModelImpl value,
          $Res Function(_$OtherUserModelImpl) then) =
      __$$OtherUserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'full_name') String fullName,
      @JsonKey(name: 'phone') String? phoneNumber,
      @JsonKey(name: 'profile_photo') String? profilePhotoUrl});
}

/// @nodoc
class __$$OtherUserModelImplCopyWithImpl<$Res>
    extends _$OtherUserModelCopyWithImpl<$Res, _$OtherUserModelImpl>
    implements _$$OtherUserModelImplCopyWith<$Res> {
  __$$OtherUserModelImplCopyWithImpl(
      _$OtherUserModelImpl _value, $Res Function(_$OtherUserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of OtherUserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? phoneNumber = freezed,
    Object? profilePhotoUrl = freezed,
  }) {
    return _then(_$OtherUserModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      profilePhotoUrl: freezed == profilePhotoUrl
          ? _value.profilePhotoUrl
          : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OtherUserModelImpl implements _OtherUserModel {
  const _$OtherUserModelImpl(
      {required this.id,
      @JsonKey(name: 'full_name') required this.fullName,
      @JsonKey(name: 'phone') this.phoneNumber,
      @JsonKey(name: 'profile_photo') this.profilePhotoUrl});

  factory _$OtherUserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OtherUserModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  @JsonKey(name: 'phone')
  final String? phoneNumber;
  @override
  @JsonKey(name: 'profile_photo')
  final String? profilePhotoUrl;

  @override
  String toString() {
    return 'OtherUserModel(id: $id, fullName: $fullName, phoneNumber: $phoneNumber, profilePhotoUrl: $profilePhotoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OtherUserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.profilePhotoUrl, profilePhotoUrl) ||
                other.profilePhotoUrl == profilePhotoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, fullName, phoneNumber, profilePhotoUrl);

  /// Create a copy of OtherUserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OtherUserModelImplCopyWith<_$OtherUserModelImpl> get copyWith =>
      __$$OtherUserModelImplCopyWithImpl<_$OtherUserModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OtherUserModelImplToJson(
      this,
    );
  }
}

abstract class _OtherUserModel implements OtherUserModel {
  const factory _OtherUserModel(
          {required final String id,
          @JsonKey(name: 'full_name') required final String fullName,
          @JsonKey(name: 'phone') final String? phoneNumber,
          @JsonKey(name: 'profile_photo') final String? profilePhotoUrl}) =
      _$OtherUserModelImpl;

  factory _OtherUserModel.fromJson(Map<String, dynamic> json) =
      _$OtherUserModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  @JsonKey(name: 'phone')
  String? get phoneNumber;
  @override
  @JsonKey(name: 'profile_photo')
  String? get profilePhotoUrl;

  /// Create a copy of OtherUserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OtherUserModelImplCopyWith<_$OtherUserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) {
  return _MessageModel.fromJson(json);
}

/// @nodoc
mixin _$MessageModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'chat_room')
  String get roomId => throw _privateConstructorUsedError;
  @JsonKey(name: 'sender')
  String get senderId => throw _privateConstructorUsedError;
  @JsonKey(name: 'sender_name')
  String get senderName => throw _privateConstructorUsedError;
  @JsonKey(name: 'text')
  String get messageText => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'latitude')
  double? get latitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'longitude')
  double? get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get timestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_read', defaultValue: false)
  bool get isRead => throw _privateConstructorUsedError;
  @JsonKey(name: 'message_type')
  String? get messageType => throw _privateConstructorUsedError;

  /// Serializes this MessageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageModelCopyWith<MessageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageModelCopyWith<$Res> {
  factory $MessageModelCopyWith(
          MessageModel value, $Res Function(MessageModel) then) =
      _$MessageModelCopyWithImpl<$Res, MessageModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'chat_room') String roomId,
      @JsonKey(name: 'sender') String senderId,
      @JsonKey(name: 'sender_name') String senderName,
      @JsonKey(name: 'text') String messageText,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'latitude') double? latitude,
      @JsonKey(name: 'longitude') double? longitude,
      @JsonKey(name: 'created_at') DateTime timestamp,
      @JsonKey(name: 'is_read', defaultValue: false) bool isRead,
      @JsonKey(name: 'message_type') String? messageType});
}

/// @nodoc
class _$MessageModelCopyWithImpl<$Res, $Val extends MessageModel>
    implements $MessageModelCopyWith<$Res> {
  _$MessageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? senderId = null,
    Object? senderName = null,
    Object? messageText = null,
    Object? imageUrl = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? timestamp = null,
    Object? isRead = null,
    Object? messageType = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      senderName: null == senderName
          ? _value.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String,
      messageText: null == messageText
          ? _value.messageText
          : messageText // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      messageType: freezed == messageType
          ? _value.messageType
          : messageType // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageModelImplCopyWith<$Res>
    implements $MessageModelCopyWith<$Res> {
  factory _$$MessageModelImplCopyWith(
          _$MessageModelImpl value, $Res Function(_$MessageModelImpl) then) =
      __$$MessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'chat_room') String roomId,
      @JsonKey(name: 'sender') String senderId,
      @JsonKey(name: 'sender_name') String senderName,
      @JsonKey(name: 'text') String messageText,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'latitude') double? latitude,
      @JsonKey(name: 'longitude') double? longitude,
      @JsonKey(name: 'created_at') DateTime timestamp,
      @JsonKey(name: 'is_read', defaultValue: false) bool isRead,
      @JsonKey(name: 'message_type') String? messageType});
}

/// @nodoc
class __$$MessageModelImplCopyWithImpl<$Res>
    extends _$MessageModelCopyWithImpl<$Res, _$MessageModelImpl>
    implements _$$MessageModelImplCopyWith<$Res> {
  __$$MessageModelImplCopyWithImpl(
      _$MessageModelImpl _value, $Res Function(_$MessageModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? roomId = null,
    Object? senderId = null,
    Object? senderName = null,
    Object? messageText = null,
    Object? imageUrl = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? timestamp = null,
    Object? isRead = null,
    Object? messageType = freezed,
  }) {
    return _then(_$MessageModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      senderName: null == senderName
          ? _value.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String,
      messageText: null == messageText
          ? _value.messageText
          : messageText // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      messageType: freezed == messageType
          ? _value.messageType
          : messageType // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageModelImpl implements _MessageModel {
  const _$MessageModelImpl(
      {required this.id,
      @JsonKey(name: 'chat_room') required this.roomId,
      @JsonKey(name: 'sender') required this.senderId,
      @JsonKey(name: 'sender_name') required this.senderName,
      @JsonKey(name: 'text') required this.messageText,
      @JsonKey(name: 'image_url') this.imageUrl,
      @JsonKey(name: 'latitude') this.latitude,
      @JsonKey(name: 'longitude') this.longitude,
      @JsonKey(name: 'created_at') required this.timestamp,
      @JsonKey(name: 'is_read', defaultValue: false) required this.isRead,
      @JsonKey(name: 'message_type') this.messageType});

  factory _$MessageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'chat_room')
  final String roomId;
  @override
  @JsonKey(name: 'sender')
  final String senderId;
  @override
  @JsonKey(name: 'sender_name')
  final String senderName;
  @override
  @JsonKey(name: 'text')
  final String messageText;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  @JsonKey(name: 'latitude')
  final double? latitude;
  @override
  @JsonKey(name: 'longitude')
  final double? longitude;
  @override
  @JsonKey(name: 'created_at')
  final DateTime timestamp;
  @override
  @JsonKey(name: 'is_read', defaultValue: false)
  final bool isRead;
  @override
  @JsonKey(name: 'message_type')
  final String? messageType;

  @override
  String toString() {
    return 'MessageModel(id: $id, roomId: $roomId, senderId: $senderId, senderName: $senderName, messageText: $messageText, imageUrl: $imageUrl, latitude: $latitude, longitude: $longitude, timestamp: $timestamp, isRead: $isRead, messageType: $messageType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.messageText, messageText) ||
                other.messageText == messageText) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      roomId,
      senderId,
      senderName,
      messageText,
      imageUrl,
      latitude,
      longitude,
      timestamp,
      isRead,
      messageType);

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      __$$MessageModelImplCopyWithImpl<_$MessageModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageModelImplToJson(
      this,
    );
  }
}

abstract class _MessageModel implements MessageModel {
  const factory _MessageModel(
      {required final String id,
      @JsonKey(name: 'chat_room') required final String roomId,
      @JsonKey(name: 'sender') required final String senderId,
      @JsonKey(name: 'sender_name') required final String senderName,
      @JsonKey(name: 'text') required final String messageText,
      @JsonKey(name: 'image_url') final String? imageUrl,
      @JsonKey(name: 'latitude') final double? latitude,
      @JsonKey(name: 'longitude') final double? longitude,
      @JsonKey(name: 'created_at') required final DateTime timestamp,
      @JsonKey(name: 'is_read', defaultValue: false) required final bool isRead,
      @JsonKey(name: 'message_type')
      final String? messageType}) = _$MessageModelImpl;

  factory _MessageModel.fromJson(Map<String, dynamic> json) =
      _$MessageModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'chat_room')
  String get roomId;
  @override
  @JsonKey(name: 'sender')
  String get senderId;
  @override
  @JsonKey(name: 'sender_name')
  String get senderName;
  @override
  @JsonKey(name: 'text')
  String get messageText;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  @JsonKey(name: 'latitude')
  double? get latitude;
  @override
  @JsonKey(name: 'longitude')
  double? get longitude;
  @override
  @JsonKey(name: 'created_at')
  DateTime get timestamp;
  @override
  @JsonKey(name: 'is_read', defaultValue: false)
  bool get isRead;
  @override
  @JsonKey(name: 'message_type')
  String? get messageType;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
