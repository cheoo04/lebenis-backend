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
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'phone_number') required String phoneNumber,
    @JsonKey(name: 'user_type') required String userType,
    @JsonKey(name: 'profile_photo_url') String? profilePhotoUrl,
  }) = _ChatParticipant;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) =>
      _$ChatParticipantFromJson(json);
}

/// Info livraison simplifiée
@freezed
class DeliveryInfo with _$DeliveryInfo {
  const factory DeliveryInfo({
    required String id,
    @JsonKey(name: 'tracking_number') required String trackingNumber,
    @JsonKey(name: 'pickup_address') String? pickupAddress,
    @JsonKey(name: 'delivery_address') String? deliveryAddress,
  }) = _DeliveryInfo;

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) =>
      _$DeliveryInfoFromJson(json);
}

@freezed
class ChatRoomModel with _$ChatRoomModel {
  const factory ChatRoomModel({
    required String id,
    @JsonKey(name: 'room_type') required RoomType roomType,
    @JsonKey(name: 'other_participant') required ChatParticipant otherParticipant,
    @JsonKey(name: 'delivery_info') DeliveryInfo? deliveryInfo,
    @JsonKey(name: 'last_message_text') String? lastMessageText,
    @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
    @JsonKey(name: 'unread_count') @Default(0) int unreadCount,
    @JsonKey(name: 'is_archived') @Default(false) bool isArchived,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'firebase_path') String? firebasePath,
  }) = _ChatRoomModel;

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomModelFromJson(json);
}
