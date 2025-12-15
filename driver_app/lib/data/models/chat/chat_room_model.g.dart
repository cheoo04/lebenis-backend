// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatRoomModelImpl _$$ChatRoomModelImplFromJson(Map<String, dynamic> json) =>
    _$ChatRoomModelImpl(
      id: json['id'] as String,
      roomType: $enumDecode(_$RoomTypeEnumMap, json['room_type']),
      otherParticipant: ChatParticipant.fromJson(
          json['other_user_info'] as Map<String, dynamic>),
      deliveryInfo: json['delivery_info'] == null
          ? null
          : DeliveryInfo.fromJson(
              json['delivery_info'] as Map<String, dynamic>),
      lastMessageText: json['last_message_text'] as String?,
      lastMessageAt: json['last_message_at'] == null
          ? null
          : DateTime.parse(json['last_message_at'] as String),
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      firebasePath: json['firebase_path'] as String?,
    );

Map<String, dynamic> _$$ChatRoomModelImplToJson(_$ChatRoomModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'room_type': _$RoomTypeEnumMap[instance.roomType]!,
      'other_user_info': instance.otherParticipant,
      'delivery_info': instance.deliveryInfo,
      'last_message_text': instance.lastMessageText,
      'last_message_at': instance.lastMessageAt?.toIso8601String(),
      'unread_count': instance.unreadCount,
      'is_archived': instance.isArchived,
      'created_at': instance.createdAt.toIso8601String(),
      'firebase_path': instance.firebasePath,
    };

const _$RoomTypeEnumMap = {
  RoomType.delivery: 'delivery',
  RoomType.support: 'support',
};
