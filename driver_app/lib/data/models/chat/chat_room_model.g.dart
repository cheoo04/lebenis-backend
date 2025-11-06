// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatParticipantImpl _$$ChatParticipantImplFromJson(
  Map<String, dynamic> json,
) => _$ChatParticipantImpl(
  id: json['id'] as String,
  fullName: json['full_name'] as String,
  phoneNumber: json['phone_number'] as String,
  userType: json['user_type'] as String,
  profilePhotoUrl: json['profile_photo_url'] as String?,
);

Map<String, dynamic> _$$ChatParticipantImplToJson(
  _$ChatParticipantImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'phone_number': instance.phoneNumber,
  'user_type': instance.userType,
  'profile_photo_url': instance.profilePhotoUrl,
};

_$DeliveryInfoImpl _$$DeliveryInfoImplFromJson(Map<String, dynamic> json) =>
    _$DeliveryInfoImpl(
      id: json['id'] as String,
      trackingNumber: json['tracking_number'] as String,
      pickupAddress: json['pickup_address'] as String?,
      deliveryAddress: json['delivery_address'] as String?,
    );

Map<String, dynamic> _$$DeliveryInfoImplToJson(_$DeliveryInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tracking_number': instance.trackingNumber,
      'pickup_address': instance.pickupAddress,
      'delivery_address': instance.deliveryAddress,
    };

_$ChatRoomModelImpl _$$ChatRoomModelImplFromJson(Map<String, dynamic> json) =>
    _$ChatRoomModelImpl(
      id: json['id'] as String,
      roomType: $enumDecode(_$RoomTypeEnumMap, json['room_type']),
      otherParticipant: ChatParticipant.fromJson(
        json['other_participant'] as Map<String, dynamic>,
      ),
      deliveryInfo: json['delivery_info'] == null
          ? null
          : DeliveryInfo.fromJson(
              json['delivery_info'] as Map<String, dynamic>,
            ),
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
      'other_participant': instance.otherParticipant,
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
