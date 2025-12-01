import 'package:freezed_annotation/freezed_annotation.dart';
import 'message_sender.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

enum MessageType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('location')
  location,
  @JsonValue('system')
  system,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

@freezed
class MessageModel with _$MessageModel {
  const MessageModel._();
  const factory MessageModel({
    required String id,
    @JsonKey(name: 'chat_room') required String chatRoomId,
    required MessageSender sender,
    @JsonKey(name: 'message_type') required MessageType messageType,
    String? text,
    @JsonKey(name: 'image_url') String? imageUrl,
    double? latitude,
    double? longitude,
    required bool isRead,
    DateTime? readAt,
    required DateTime createdAt,
    @Default(MessageStatus.sent)
    @JsonKey(includeFromJson: false, includeToJson: false)
    MessageStatus status,
    @Default(false)
    @JsonKey(includeFromJson: false, includeToJson: false)
    bool isMine,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  factory MessageModel.fromFirebase(
    String messageId,
    Map<dynamic, dynamic> firebaseData,
    String currentUserId,
  ) {
    return MessageModel(
      id: messageId,
      chatRoomId: '', // Sera rempli par le contexte
      sender: MessageSender(
        id: firebaseData['sender_id'] as String,
        fullName: '', // Sera enrichi depuis le cache
      ),
      messageType: _parseMessageType(firebaseData['message_type'] as String?),
      text: firebaseData['text'] as String?,
      imageUrl: firebaseData['image_url'] as String?,
      latitude: (firebaseData['latitude'] as num?)?.toDouble(),
      longitude: (firebaseData['longitude'] as num?)?.toDouble(),
      isRead: firebaseData['is_read'] as bool? ?? false,
      readAt: firebaseData['read_at'] != null
          ? DateTime.parse(firebaseData['read_at'] as String)
          : null,
      createdAt: DateTime.parse(firebaseData['timestamp'] as String),
      status: MessageStatus.delivered,
      isMine: firebaseData['sender_id'] == currentUserId,
    );
  }

  static MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'location':
        return MessageType.location;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }
}
