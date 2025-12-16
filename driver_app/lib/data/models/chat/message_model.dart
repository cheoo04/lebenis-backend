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

// Helper functions for JSON parsing
double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is String) return value.toLowerCase() == 'true';
  if (value is int) return value != 0;
  return false;
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
    @JsonKey(fromJson: _parseDouble) double? latitude,
    @JsonKey(fromJson: _parseDouble) double? longitude,
    @JsonKey(name: 'is_read', fromJson: _parseBool) required bool isRead,
    @JsonKey(name: 'read_at') DateTime? readAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
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
    // Gérer les différents formats de sender (backend: senderId, merchant: sender, driver: sender_id)
    final senderId = (firebaseData['sender_id'] ?? firebaseData['senderId'] ?? firebaseData['sender'] ?? '').toString();
    
    // Gérer les différents formats de text (backend: text, merchant: message_text)
    final text = (firebaseData['text'] ?? firebaseData['message_text'] ?? '').toString();
    
    // Gérer les différents formats de message_type (backend: type, apps: message_type)
    final messageType = (firebaseData['message_type'] ?? firebaseData['type'] ?? 'text').toString();
    
    // Gérer les différents formats de image_url (backend: imageUrl, apps: image_url)
    final imageUrl = (firebaseData['image_url'] ?? firebaseData['imageUrl'])?.toString();
    
    // Gérer les différents formats de timestamp (int milliseconds ou ISO string)
    DateTime createdAt;
    final timestamp = firebaseData['timestamp'];
    if (timestamp is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp is String) {
      createdAt = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }
    
    // Gérer is_read / isRead
    final isRead = (firebaseData['is_read'] ?? firebaseData['isRead'] ?? false) as bool;
    
    return MessageModel(
      id: messageId,
      chatRoomId: '', // Sera rempli par le contexte
      sender: MessageSender(
        id: senderId,
        fullName: (firebaseData['senderName'] ?? firebaseData['sender_name'] ?? '').toString(),
      ),
      messageType: _parseMessageType(messageType),
      text: text.isNotEmpty ? text : null,
      imageUrl: imageUrl,
      latitude: _parseDouble(firebaseData['latitude']),
      longitude: _parseDouble(firebaseData['longitude']),
      isRead: isRead,
      readAt: firebaseData['read_at'] != null
          ? DateTime.parse(firebaseData['read_at'] as String)
          : null,
      createdAt: createdAt,
      status: MessageStatus.delivered,
      isMine: senderId == currentUserId,
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
