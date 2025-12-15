import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_room_model.freezed.dart';
part 'chat_room_model.g.dart';

@freezed
class ChatRoomModel with _$ChatRoomModel {
  const factory ChatRoomModel({
    required String id,
    @JsonKey(name: 'room_type') required String roomType,
    @JsonKey(name: 'delivery') String? deliveryId,
    @JsonKey(name: 'driver_info') required OtherUserModel driver,
    @JsonKey(name: 'last_message_text') String? lastMessage,
    @JsonKey(name: 'last_message_at') DateTime? lastMessageAt,
    @JsonKey(name: 'unread_count', defaultValue: 0) required int unreadCount,
    @JsonKey(name: 'is_archived', defaultValue: false) required bool isArchived,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ChatRoomModel;

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomModelFromJson(json);
}

@freezed
class OtherUserModel with _$OtherUserModel {
  const factory OtherUserModel({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'phone') String? phoneNumber,
    @JsonKey(name: 'profile_photo') String? profilePhotoUrl,
  }) = _OtherUserModel;

  factory OtherUserModel.fromJson(Map<String, dynamic> json) =>
      _$OtherUserModelFromJson(json);
}

@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id,
    @JsonKey(name: 'chat_room') required String roomId,
    @JsonKey(name: 'sender') required String senderId,
    @JsonKey(name: 'sender_name') required String senderName,
    @JsonKey(name: 'text') required String messageText,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'created_at') required DateTime timestamp,
    @JsonKey(name: 'is_read', defaultValue: false) required bool isRead,
    @JsonKey(name: 'message_type') String? messageType,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);
}
