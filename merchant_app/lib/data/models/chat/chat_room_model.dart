import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_room_model.freezed.dart';
part 'chat_room_model.g.dart';

@freezed
class ChatRoomModel with _$ChatRoomModel {
  const factory ChatRoomModel({
    required String id,
    required String roomType,
    String? deliveryId,
    required OtherUserModel driver,
    String? lastMessage,
    DateTime? lastMessageAt,
    required int unreadCount,
    required bool isArchived,
    required DateTime createdAt,
  }) = _ChatRoomModel;

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomModelFromJson(json);
}

@freezed
class OtherUserModel with _$OtherUserModel {
  const factory OtherUserModel({
    required String id,
    required String fullName,
    String? phoneNumber,
    String? profilePhotoUrl,
  }) = _OtherUserModel;

  factory OtherUserModel.fromJson(Map<String, dynamic> json) =>
      _$OtherUserModelFromJson(json);
}

@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id,
    required String roomId,
    required String senderId,
    required String senderName,
    required String messageText,
    String? imageUrl,
    required DateTime timestamp,
    required bool isRead,
    String? messageType,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);
}
