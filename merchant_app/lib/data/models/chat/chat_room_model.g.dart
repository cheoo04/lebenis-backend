// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatRoomModelImpl _$$ChatRoomModelImplFromJson(Map<String, dynamic> json) =>
    _$ChatRoomModelImpl(
      id: json['id'] as String,
      roomType: json['room_type'] as String,
      deliveryId: json['delivery'] as String?,
      driver:
          OtherUserModel.fromJson(json['driver_info'] as Map<String, dynamic>),
      lastMessage: json['last_message_text'] as String?,
      lastMessageAt: json['last_message_at'] == null
          ? null
          : DateTime.parse(json['last_message_at'] as String),
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ChatRoomModelImplToJson(_$ChatRoomModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'room_type': instance.roomType,
      'delivery': instance.deliveryId,
      'driver_info': instance.driver,
      'last_message_text': instance.lastMessage,
      'last_message_at': instance.lastMessageAt?.toIso8601String(),
      'unread_count': instance.unreadCount,
      'is_archived': instance.isArchived,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$OtherUserModelImpl _$$OtherUserModelImplFromJson(Map<String, dynamic> json) =>
    _$OtherUserModelImpl(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone'] as String?,
      profilePhotoUrl: json['profile_photo'] as String?,
    );

Map<String, dynamic> _$$OtherUserModelImplToJson(
        _$OtherUserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'phone': instance.phoneNumber,
      'profile_photo': instance.profilePhotoUrl,
    };

_$MessageModelImpl _$$MessageModelImplFromJson(Map<String, dynamic> json) =>
    _$MessageModelImpl(
      id: json['id'] as String,
      roomId: json['chat_room'] as String,
      senderId: json['sender'] as String,
      senderName: json['sender_name'] as String,
      messageText: json['text'] as String,
      imageUrl: json['image_url'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      timestamp: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      messageType: json['message_type'] as String?,
    );

Map<String, dynamic> _$$MessageModelImplToJson(_$MessageModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chat_room': instance.roomId,
      'sender': instance.senderId,
      'sender_name': instance.senderName,
      'text': instance.messageText,
      'image_url': instance.imageUrl,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'created_at': instance.timestamp.toIso8601String(),
      'is_read': instance.isRead,
      'message_type': instance.messageType,
    };
