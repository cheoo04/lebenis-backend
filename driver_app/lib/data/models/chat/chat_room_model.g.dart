// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatRoomModelImpl _$$ChatRoomModelImplFromJson(Map<String, dynamic> json) =>
    _$ChatRoomModelImpl(
      id: json['id'] as String,
      roomType: $enumDecode(_$RoomTypeEnumMap, json['roomType']),
      otherParticipant: ChatParticipant.fromJson(
          json['otherParticipant'] as Map<String, dynamic>),
      deliveryInfo: json['deliveryInfo'] == null
          ? null
          : DeliveryInfo.fromJson(json['deliveryInfo'] as Map<String, dynamic>),
      lastMessageText: json['lastMessageText'] as String?,
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String),
      unreadCount: (json['unreadCount'] as num).toInt(),
      isArchived: json['isArchived'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      firebasePath: json['firebasePath'] as String?,
    );

Map<String, dynamic> _$$ChatRoomModelImplToJson(_$ChatRoomModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'roomType': _$RoomTypeEnumMap[instance.roomType]!,
      'otherParticipant': instance.otherParticipant,
      'deliveryInfo': instance.deliveryInfo,
      'lastMessageText': instance.lastMessageText,
      'lastMessageAt': instance.lastMessageAt?.toIso8601String(),
      'unreadCount': instance.unreadCount,
      'isArchived': instance.isArchived,
      'createdAt': instance.createdAt.toIso8601String(),
      'firebasePath': instance.firebasePath,
    };

const _$RoomTypeEnumMap = {
  RoomType.delivery: 'delivery',
  RoomType.support: 'support',
};
