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
  RoomType get roomType => throw _privateConstructorUsedError;
  @JsonKey(name: 'other_user_info')
  ChatParticipant get otherParticipant => throw _privateConstructorUsedError;
  @JsonKey(name: 'delivery_info')
  DeliveryInfo? get deliveryInfo => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_message_text')
  String? get lastMessageText => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_message_at')
  DateTime? get lastMessageAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'unread_count', defaultValue: 0)
  int get unreadCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_archived', defaultValue: false)
  bool get isArchived => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'firebase_path')
  String? get firebasePath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
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
      @JsonKey(name: 'room_type') RoomType roomType,
      @JsonKey(name: 'other_user_info') ChatParticipant otherParticipant,
      @JsonKey(name: 'delivery_info') DeliveryInfo? deliveryInfo,
      @JsonKey(name: 'last_message_text') String? lastMessageText,
      @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
      @JsonKey(name: 'unread_count', defaultValue: 0) int unreadCount,
      @JsonKey(name: 'is_archived', defaultValue: false) bool isArchived,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'firebase_path') String? firebasePath});

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
    return _then(_value.copyWith(
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
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ChatParticipantCopyWith<$Res> get otherParticipant {
    return $ChatParticipantCopyWith<$Res>(_value.otherParticipant, (value) {
      return _then(_value.copyWith(otherParticipant: value) as $Val);
    });
  }

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
          _$ChatRoomModelImpl value, $Res Function(_$ChatRoomModelImpl) then) =
      __$$ChatRoomModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'room_type') RoomType roomType,
      @JsonKey(name: 'other_user_info') ChatParticipant otherParticipant,
      @JsonKey(name: 'delivery_info') DeliveryInfo? deliveryInfo,
      @JsonKey(name: 'last_message_text') String? lastMessageText,
      @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
      @JsonKey(name: 'unread_count', defaultValue: 0) int unreadCount,
      @JsonKey(name: 'is_archived', defaultValue: false) bool isArchived,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'firebase_path') String? firebasePath});

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
      _$ChatRoomModelImpl _value, $Res Function(_$ChatRoomModelImpl) _then)
      : super(_value, _then);

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
    return _then(_$ChatRoomModelImpl(
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatRoomModelImpl implements _ChatRoomModel {
  const _$ChatRoomModelImpl(
      {required this.id,
      @JsonKey(name: 'room_type') required this.roomType,
      @JsonKey(name: 'other_user_info') required this.otherParticipant,
      @JsonKey(name: 'delivery_info') this.deliveryInfo,
      @JsonKey(name: 'last_message_text') this.lastMessageText,
      @JsonKey(name: 'last_message_at') this.lastMessageAt,
      @JsonKey(name: 'unread_count', defaultValue: 0) required this.unreadCount,
      @JsonKey(name: 'is_archived', defaultValue: false)
      required this.isArchived,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'firebase_path') this.firebasePath});

  factory _$ChatRoomModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatRoomModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'room_type')
  final RoomType roomType;
  @override
  @JsonKey(name: 'other_user_info')
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
  @JsonKey(name: 'unread_count', defaultValue: 0)
  final int unreadCount;
  @override
  @JsonKey(name: 'is_archived', defaultValue: false)
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

  @JsonKey(ignore: true)
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
      firebasePath);

  @JsonKey(ignore: true)
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
          @JsonKey(name: 'room_type') required final RoomType roomType,
          @JsonKey(name: 'other_user_info')
          required final ChatParticipant otherParticipant,
          @JsonKey(name: 'delivery_info') final DeliveryInfo? deliveryInfo,
          @JsonKey(name: 'last_message_text') final String? lastMessageText,
          @JsonKey(name: 'last_message_at') final DateTime? lastMessageAt,
          @JsonKey(name: 'unread_count', defaultValue: 0)
          required final int unreadCount,
          @JsonKey(name: 'is_archived', defaultValue: false)
          required final bool isArchived,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'firebase_path') final String? firebasePath}) =
      _$ChatRoomModelImpl;

  factory _ChatRoomModel.fromJson(Map<String, dynamic> json) =
      _$ChatRoomModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'room_type')
  RoomType get roomType;
  @override
  @JsonKey(name: 'other_user_info')
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
  @JsonKey(name: 'unread_count', defaultValue: 0)
  int get unreadCount;
  @override
  @JsonKey(name: 'is_archived', defaultValue: false)
  bool get isArchived;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'firebase_path')
  String? get firebasePath;
  @override
  @JsonKey(ignore: true)
  _$$ChatRoomModelImplCopyWith<_$ChatRoomModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
