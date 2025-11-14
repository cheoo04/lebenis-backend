import 'package:freezed_annotation/freezed_annotation.dart';

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
  sending, // En cours d'envoi
  sent, // Envoyé au serveur
  delivered, // Reçu par le destinataire
  read, // Lu par le destinataire
  failed, // Échec d'envoi
}

/// Sender simple
@freezed
class MessageSender with _$MessageSender {
  const factory MessageSender({
    required String id,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'profile_photo_url') String? profilePhotoUrl,
  }) = _MessageSender;

  factory MessageSender.fromJson(Map<String, dynamic> json) =>
      _$MessageSenderFromJson(json);
}

@freezed
class MessageModel with _$MessageModel {
  const factory MessageModel({
    required String id,
    @JsonKey(name: 'chat_room') required String chatRoomId,
    required MessageSender sender,
    @JsonKey(name: 'message_type') required MessageType messageType,
    String? text,
    @JsonKey(name: 'image_url') String? imageUrl,
    double? latitude,
    double? longitude,
    @Default(false) bool isRead,
    DateTime? readAt,
    required DateTime createdAt,
    // Champs locaux (non sérialisés)
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(MessageStatus.sent)
    MessageStatus status,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(false) bool isMine,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  /// Factory pour créer un message depuis Firebase Realtime Database
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

/// Extension pour obtenir le preview du message
extension MessagePreview on MessageModel {
  String get preview {
    switch (messageType) {
      case MessageType.text:
        return text ?? '';
      case MessageType.image:
        return '📷 Photo';
      case MessageType.location:
        return '📍 Position';
      case MessageType.system:
        return text ?? 'Message système';
    }
  }

  bool get hasImage => messageType == MessageType.image && imageUrl != null;
  bool get hasLocation =>
      messageType == MessageType.location &&
      latitude != null &&
      longitude != null;
}
