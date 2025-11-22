// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageSender _$MessageSenderFromJson(Map<String, dynamic> json) =>
    _MessageSender(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      profilePhotoUrl: json['profile_photo_url'] as String?,
    );

Map<String, dynamic> _$MessageSenderToJson(_MessageSender instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'profile_photo_url': instance.profilePhotoUrl,
    };

_MessageModel _$MessageModelFromJson(Map<String, dynamic> json) =>
    _MessageModel(
      id: json['id'] as String,
      chatRoomId: json['chat_room'] as String,
      sender: MessageSender.fromJson(json['sender'] as Map<String, dynamic>),
      messageType: $enumDecode(_$MessageTypeEnumMap, json['message_type']),
      text: json['text'] as String?,
      imageUrl: json['image_url'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MessageModelToJson(_MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chat_room': instance.chatRoomId,
      'sender': instance.sender,
      'message_type': _$MessageTypeEnumMap[instance.messageType]!,
      'text': instance.text,
      'image_url': instance.imageUrl,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isRead': instance.isRead,
      'readAt': instance.readAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.location: 'location',
  MessageType.system: 'system',
};
