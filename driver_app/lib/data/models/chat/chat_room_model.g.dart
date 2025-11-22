// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatParticipant _$ChatParticipantFromJson(Map<String, dynamic> json) =>
    _ChatParticipant(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      userType: json['userType'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );

Map<String, dynamic> _$ChatParticipantToJson(_ChatParticipant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'phoneNumber': instance.phoneNumber,
      'userType': instance.userType,
      'profilePhotoUrl': instance.profilePhotoUrl,
    };

_DeliveryInfo _$DeliveryInfoFromJson(Map<String, dynamic> json) =>
    _DeliveryInfo(
      id: json['id'] as String,
      trackingNumber: json['trackingNumber'] as String,
      pickupAddress: json['pickupAddress'] as String?,
      deliveryAddress: json['deliveryAddress'] as String?,
    );

Map<String, dynamic> _$DeliveryInfoToJson(_DeliveryInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'trackingNumber': instance.trackingNumber,
      'pickupAddress': instance.pickupAddress,
      'deliveryAddress': instance.deliveryAddress,
    };

_ChatRoomModel _$ChatRoomModelFromJson(Map<String, dynamic> json) =>
    _ChatRoomModel(
      id: json['id'] as String,
      roomType: $enumDecode(_$RoomTypeEnumMap, json['roomType']),
      otherParticipant: ChatParticipant.fromJson(
        json['otherParticipant'] as Map<String, dynamic>,
      ),
      deliveryInfo: json['deliveryInfo'] == null
          ? null
          : DeliveryInfo.fromJson(json['deliveryInfo'] as Map<String, dynamic>),
      lastMessageText: json['lastMessageText'] as String?,
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      firebasePath: json['firebasePath'] as String?,
    );

Map<String, dynamic> _$ChatRoomModelToJson(_ChatRoomModel instance) =>
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
