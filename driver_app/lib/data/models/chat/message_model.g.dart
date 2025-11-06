// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageSenderImpl _$$MessageSenderImplFromJson(Map<String, dynamic> json) =>
    _$MessageSenderImpl(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      profilePhotoUrl: json['profile_photo_url'] as String?,
    );

Map<String, dynamic> _$$MessageSenderImplToJson(_$MessageSenderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'profile_photo_url': instance.profilePhotoUrl,
    };

_$MessageModelImpl _$$MessageModelImplFromJson(Map<String, dynamic> json) =>
    _$MessageModelImpl(
      id: json['id'] as String,
      chatRoomId: json['chat_room'] as String,
      sender: MessageSender.fromJson(json['sender'] as Map<String, dynamic>),
      messageType: $enumDecode(_$MessageTypeEnumMap, json['message_type']),
      text: json['text'] as String?,
      imageUrl: json['image_url'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$MessageModelImplToJson(_$MessageModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chat_room': instance.chatRoomId,
      'sender': instance.sender,
      'message_type': _$MessageTypeEnumMap[instance.messageType]!,
      'text': instance.text,
      'image_url': instance.imageUrl,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'is_read': instance.isRead,
      'read_at': instance.readAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.location: 'location',
  MessageType.system: 'system',
};
