import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_room_model.freezed.dart';
part 'chat_room_model.g.dart';

enum RoomType {
  @JsonValue('delivery')
  delivery,
  @JsonValue('support')
  support,
}

/// Participant dans une conversation
@freezed
class ChatParticipant with _$ChatParticipant {
  const factory ChatParticipant({
    required String id,
    required String fullName,
    required String phoneNumber,
    required String userType,
    String? profilePhotoUrl,
  }) = _ChatParticipant;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) =>
      _$ChatParticipantFromJson(json);
}

/// Info livraison simplifiée
@freezed
class DeliveryInfo with _$DeliveryInfo {
  const factory DeliveryInfo({
    required String id,
    required String trackingNumber,
    String? pickupAddress,
    String? deliveryAddress,
  }) = _DeliveryInfo;

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) =>
      _$DeliveryInfoFromJson(json);
}

@freezed
class ChatRoomModel with _$ChatRoomModel {
  const factory ChatRoomModel({
    required String id,
    required RoomType roomType,
    required ChatParticipant otherParticipant,
    DeliveryInfo? deliveryInfo,
    String? lastMessageText,
    DateTime? lastMessageAt,
    @Default(0) int unreadCount,
    @Default(false) bool isArchived,
    required DateTime createdAt,
    String? firebasePath,
  }) = _ChatRoomModel;

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomModelFromJson(json);
}
