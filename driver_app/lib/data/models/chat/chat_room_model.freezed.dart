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

ChatRoomModel _$ChatRoomModelFromJson(Map<String, dynamic> json) {
  return _ChatRoomModel.fromJson(json);
}

/// @nodoc
mixin _$ChatRoomModel {
  String get id => throw _privateConstructorUsedError;
  RoomType get roomType => throw _privateConstructorUsedError;
  ChatParticipant get otherParticipant => throw _privateConstructorUsedError;
  DeliveryInfo? get deliveryInfo => throw _privateConstructorUsedError;
  String? get lastMessageText => throw _privateConstructorUsedError;
  DateTime? get lastMessageAt => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  bool get isArchived => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
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
    RoomType roomType,
    ChatParticipant otherParticipant,
    DeliveryInfo? deliveryInfo,
    String? lastMessageText,
    DateTime? lastMessageAt,
    int unreadCount,
    bool isArchived,
    DateTime createdAt,
    String? firebasePath,
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
    RoomType roomType,
    ChatParticipant otherParticipant,
    DeliveryInfo? deliveryInfo,
    String? lastMessageText,
    DateTime? lastMessageAt,
    int unreadCount,
    bool isArchived,
    DateTime createdAt,
    String? firebasePath,
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
    required this.roomType,
    required this.otherParticipant,
    this.deliveryInfo,
    this.lastMessageText,
    this.lastMessageAt,
    required this.unreadCount,
    required this.isArchived,
    required this.createdAt,
    this.firebasePath,
  });

  factory _$ChatRoomModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatRoomModelImplFromJson(json);

  @override
  final String id;
  @override
  final RoomType roomType;
  @override
  final ChatParticipant otherParticipant;
  @override
  final DeliveryInfo? deliveryInfo;
  @override
  final String? lastMessageText;
  @override
  final DateTime? lastMessageAt;
  @override
  final int unreadCount;
  @override
  final bool isArchived;
  @override
  final DateTime createdAt;
  @override
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
    required final RoomType roomType,
    required final ChatParticipant otherParticipant,
    final DeliveryInfo? deliveryInfo,
    final String? lastMessageText,
    final DateTime? lastMessageAt,
    required final int unreadCount,
    required final bool isArchived,
    required final DateTime createdAt,
    final String? firebasePath,
  }) = _$ChatRoomModelImpl;

  factory _ChatRoomModel.fromJson(Map<String, dynamic> json) =
      _$ChatRoomModelImpl.fromJson;

  @override
  String get id;
  @override
  RoomType get roomType;
  @override
  ChatParticipant get otherParticipant;
  @override
  DeliveryInfo? get deliveryInfo;
  @override
  String? get lastMessageText;
  @override
  DateTime? get lastMessageAt;
  @override
  int get unreadCount;
  @override
  bool get isArchived;
  @override
  DateTime get createdAt;
  @override
  String? get firebasePath;

  /// Create a copy of ChatRoomModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatRoomModelImplCopyWith<_$ChatRoomModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
