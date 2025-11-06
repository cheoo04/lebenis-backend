// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MessageSender _$MessageSenderFromJson(Map<String, dynamic> json) {
  return _MessageSender.fromJson(json);
}

/// @nodoc
mixin _$MessageSender {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'full_name')
  String get fullName => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_photo_url')
  String? get profilePhotoUrl => throw _privateConstructorUsedError;

  /// Serializes this MessageSender to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageSender
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageSenderCopyWith<MessageSender> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageSenderCopyWith<$Res> {
  factory $MessageSenderCopyWith(
    MessageSender value,
    $Res Function(MessageSender) then,
  ) = _$MessageSenderCopyWithImpl<$Res, MessageSender>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'full_name') String fullName,
    @JsonKey(name: 'profile_photo_url') String? profilePhotoUrl,
  });
}

/// @nodoc
class _$MessageSenderCopyWithImpl<$Res, $Val extends MessageSender>
    implements $MessageSenderCopyWith<$Res> {
  _$MessageSenderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageSender
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
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
abstract class _$$MessageSenderImplCopyWith<$Res>
    implements $MessageSenderCopyWith<$Res> {
  factory _$$MessageSenderImplCopyWith(
    _$MessageSenderImpl value,
    $Res Function(_$MessageSenderImpl) then,
  ) = __$$MessageSenderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'full_name') String fullName,
    @JsonKey(name: 'profile_photo_url') String? profilePhotoUrl,
  });
}

/// @nodoc
class __$$MessageSenderImplCopyWithImpl<$Res>
    extends _$MessageSenderCopyWithImpl<$Res, _$MessageSenderImpl>
    implements _$$MessageSenderImplCopyWith<$Res> {
  __$$MessageSenderImplCopyWithImpl(
    _$MessageSenderImpl _value,
    $Res Function(_$MessageSenderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageSender
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? profilePhotoUrl = freezed,
  }) {
    return _then(
      _$MessageSenderImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        fullName: null == fullName
            ? _value.fullName
            : fullName // ignore: cast_nullable_to_non_nullable
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
class _$MessageSenderImpl implements _MessageSender {
  const _$MessageSenderImpl({
    required this.id,
    @JsonKey(name: 'full_name') required this.fullName,
    @JsonKey(name: 'profile_photo_url') this.profilePhotoUrl,
  });

  factory _$MessageSenderImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageSenderImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'full_name')
  final String fullName;
  @override
  @JsonKey(name: 'profile_photo_url')
  final String? profilePhotoUrl;

  @override
  String toString() {
    return 'MessageSender(id: $id, fullName: $fullName, profilePhotoUrl: $profilePhotoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageSenderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.profilePhotoUrl, profilePhotoUrl) ||
                other.profilePhotoUrl == profilePhotoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, fullName, profilePhotoUrl);

  /// Create a copy of MessageSender
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageSenderImplCopyWith<_$MessageSenderImpl> get copyWith =>
      __$$MessageSenderImplCopyWithImpl<_$MessageSenderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageSenderImplToJson(this);
  }
}

abstract class _MessageSender implements MessageSender {
  const factory _MessageSender({
    required final String id,
    @JsonKey(name: 'full_name') required final String fullName,
    @JsonKey(name: 'profile_photo_url') final String? profilePhotoUrl,
  }) = _$MessageSenderImpl;

  factory _MessageSender.fromJson(Map<String, dynamic> json) =
      _$MessageSenderImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'full_name')
  String get fullName;
  @override
  @JsonKey(name: 'profile_photo_url')
  String? get profilePhotoUrl;

  /// Create a copy of MessageSender
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageSenderImplCopyWith<_$MessageSenderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) {
  return _MessageModel.fromJson(json);
}

/// @nodoc
mixin _$MessageModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'chat_room')
  String get chatRoomId => throw _privateConstructorUsedError;
  MessageSender get sender => throw _privateConstructorUsedError;
  @JsonKey(name: 'message_type')
  MessageType get messageType => throw _privateConstructorUsedError;
  String? get text => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_read')
  bool get isRead => throw _privateConstructorUsedError;
  @JsonKey(name: 'read_at')
  DateTime? get readAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError; // Champs locaux (non sérialisés)
  @JsonKey(includeFromJson: false, includeToJson: false)
  MessageStatus get status => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isMine => throw _privateConstructorUsedError;

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
    MessageModel value,
    $Res Function(MessageModel) then,
  ) = _$MessageModelCopyWithImpl<$Res, MessageModel>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'chat_room') String chatRoomId,
    MessageSender sender,
    @JsonKey(name: 'message_type') MessageType messageType,
    String? text,
    @JsonKey(name: 'image_url') String? imageUrl,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'is_read') bool isRead,
    @JsonKey(name: 'read_at') DateTime? readAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(includeFromJson: false, includeToJson: false) MessageStatus status,
    @JsonKey(includeFromJson: false, includeToJson: false) bool isMine,
  });

  $MessageSenderCopyWith<$Res> get sender;
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
    Object? chatRoomId = null,
    Object? sender = null,
    Object? messageType = null,
    Object? text = freezed,
    Object? imageUrl = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? isRead = null,
    Object? readAt = freezed,
    Object? createdAt = null,
    Object? status = null,
    Object? isMine = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            chatRoomId: null == chatRoomId
                ? _value.chatRoomId
                : chatRoomId // ignore: cast_nullable_to_non_nullable
                      as String,
            sender: null == sender
                ? _value.sender
                : sender // ignore: cast_nullable_to_non_nullable
                      as MessageSender,
            messageType: null == messageType
                ? _value.messageType
                : messageType // ignore: cast_nullable_to_non_nullable
                      as MessageType,
            text: freezed == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                      as String?,
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
            isRead: null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                      as bool,
            readAt: freezed == readAt
                ? _value.readAt
                : readAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MessageStatus,
            isMine: null == isMine
                ? _value.isMine
                : isMine // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageSenderCopyWith<$Res> get sender {
    return $MessageSenderCopyWith<$Res>(_value.sender, (value) {
      return _then(_value.copyWith(sender: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MessageModelImplCopyWith<$Res>
    implements $MessageModelCopyWith<$Res> {
  factory _$$MessageModelImplCopyWith(
    _$MessageModelImpl value,
    $Res Function(_$MessageModelImpl) then,
  ) = __$$MessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'chat_room') String chatRoomId,
    MessageSender sender,
    @JsonKey(name: 'message_type') MessageType messageType,
    String? text,
    @JsonKey(name: 'image_url') String? imageUrl,
    double? latitude,
    double? longitude,
    @JsonKey(name: 'is_read') bool isRead,
    @JsonKey(name: 'read_at') DateTime? readAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(includeFromJson: false, includeToJson: false) MessageStatus status,
    @JsonKey(includeFromJson: false, includeToJson: false) bool isMine,
  });

  @override
  $MessageSenderCopyWith<$Res> get sender;
}

/// @nodoc
class __$$MessageModelImplCopyWithImpl<$Res>
    extends _$MessageModelCopyWithImpl<$Res, _$MessageModelImpl>
    implements _$$MessageModelImplCopyWith<$Res> {
  __$$MessageModelImplCopyWithImpl(
    _$MessageModelImpl _value,
    $Res Function(_$MessageModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chatRoomId = null,
    Object? sender = null,
    Object? messageType = null,
    Object? text = freezed,
    Object? imageUrl = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? isRead = null,
    Object? readAt = freezed,
    Object? createdAt = null,
    Object? status = null,
    Object? isMine = null,
  }) {
    return _then(
      _$MessageModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        chatRoomId: null == chatRoomId
            ? _value.chatRoomId
            : chatRoomId // ignore: cast_nullable_to_non_nullable
                  as String,
        sender: null == sender
            ? _value.sender
            : sender // ignore: cast_nullable_to_non_nullable
                  as MessageSender,
        messageType: null == messageType
            ? _value.messageType
            : messageType // ignore: cast_nullable_to_non_nullable
                  as MessageType,
        text: freezed == text
            ? _value.text
            : text // ignore: cast_nullable_to_non_nullable
                  as String?,
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
        isRead: null == isRead
            ? _value.isRead
            : isRead // ignore: cast_nullable_to_non_nullable
                  as bool,
        readAt: freezed == readAt
            ? _value.readAt
            : readAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MessageStatus,
        isMine: null == isMine
            ? _value.isMine
            : isMine // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageModelImpl implements _MessageModel {
  const _$MessageModelImpl({
    required this.id,
    @JsonKey(name: 'chat_room') required this.chatRoomId,
    required this.sender,
    @JsonKey(name: 'message_type') required this.messageType,
    this.text,
    @JsonKey(name: 'image_url') this.imageUrl,
    this.latitude,
    this.longitude,
    @JsonKey(name: 'is_read') this.isRead = false,
    @JsonKey(name: 'read_at') this.readAt,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    this.status = MessageStatus.sent,
    @JsonKey(includeFromJson: false, includeToJson: false) this.isMine = false,
  });

  factory _$MessageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'chat_room')
  final String chatRoomId;
  @override
  final MessageSender sender;
  @override
  @JsonKey(name: 'message_type')
  final MessageType messageType;
  @override
  final String? text;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  @JsonKey(name: 'is_read')
  final bool isRead;
  @override
  @JsonKey(name: 'read_at')
  final DateTime? readAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  // Champs locaux (non sérialisés)
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final MessageStatus status;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isMine;

  @override
  String toString() {
    return 'MessageModel(id: $id, chatRoomId: $chatRoomId, sender: $sender, messageType: $messageType, text: $text, imageUrl: $imageUrl, latitude: $latitude, longitude: $longitude, isRead: $isRead, readAt: $readAt, createdAt: $createdAt, status: $status, isMine: $isMine)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chatRoomId, chatRoomId) ||
                other.chatRoomId == chatRoomId) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.readAt, readAt) || other.readAt == readAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isMine, isMine) || other.isMine == isMine));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    chatRoomId,
    sender,
    messageType,
    text,
    imageUrl,
    latitude,
    longitude,
    isRead,
    readAt,
    createdAt,
    status,
    isMine,
  );

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      __$$MessageModelImplCopyWithImpl<_$MessageModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageModelImplToJson(this);
  }
}

abstract class _MessageModel implements MessageModel {
  const factory _MessageModel({
    required final String id,
    @JsonKey(name: 'chat_room') required final String chatRoomId,
    required final MessageSender sender,
    @JsonKey(name: 'message_type') required final MessageType messageType,
    final String? text,
    @JsonKey(name: 'image_url') final String? imageUrl,
    final double? latitude,
    final double? longitude,
    @JsonKey(name: 'is_read') final bool isRead,
    @JsonKey(name: 'read_at') final DateTime? readAt,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    final MessageStatus status,
    @JsonKey(includeFromJson: false, includeToJson: false) final bool isMine,
  }) = _$MessageModelImpl;

  factory _MessageModel.fromJson(Map<String, dynamic> json) =
      _$MessageModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'chat_room')
  String get chatRoomId;
  @override
  MessageSender get sender;
  @override
  @JsonKey(name: 'message_type')
  MessageType get messageType;
  @override
  String? get text;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  double? get latitude;
  @override
  double? get longitude;
  @override
  @JsonKey(name: 'is_read')
  bool get isRead;
  @override
  @JsonKey(name: 'read_at')
  DateTime? get readAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt; // Champs locaux (non sérialisés)
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  MessageStatus get status;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isMine;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
