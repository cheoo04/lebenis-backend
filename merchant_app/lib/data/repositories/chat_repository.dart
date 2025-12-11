import 'package:firebase_database/firebase_database.dart';
import '../../core/network/dio_client.dart';
import '../models/chat/chat_room_model.dart';
import '../../core/constants/api_constants.dart';

class ChatRepository {
  final DioClient _dioClient;
  final FirebaseDatabase? _firebaseDatabase;

  ChatRepository(this._dioClient, {FirebaseDatabase? firebaseDatabase})
      : _firebaseDatabase = firebaseDatabase;

  // ==================== REST API (PostgreSQL) ====================

  /// Récupérer la liste des conversations
  Future<List<ChatRoomModel>> getChatRooms({
    String? roomType,
    String? deliveryId,
    bool includeArchived = false,
  }) async {
    final queryParams = <String, dynamic>{};
    if (roomType != null) queryParams['room_type'] = roomType;
    if (deliveryId != null) queryParams['delivery_id'] = deliveryId;
    if (includeArchived) queryParams['include_archived'] = 'true';

    final response = await _dioClient.get(
      '${ApiConstants.baseUrl}/api/v1/chat/rooms/',
      queryParameters: queryParams,
    );

    final List results = response.data['results'] ?? response.data;
    return results.map((json) => ChatRoomModel.fromJson(json)).toList();
  }

  /// Récupérer les détails d'une conversation
  Future<ChatRoomModel> getChatRoom(String roomId) async {
    final response = await _dioClient.get(
      '${ApiConstants.baseUrl}/api/v1/chat/rooms/$roomId/',
    );

    return ChatRoomModel.fromJson(response.data);
  }

  /// Créer ou récupérer une conversation existante
  Future<ChatRoomModel> createOrGetChatRoom({
    required String driverId,
    String? deliveryId,
    String? initialMessage,
  }) async {
    final response = await _dioClient.post(
      '${ApiConstants.baseUrl}/api/v1/chat/rooms/',
      data: {
        'other_user_id': driverId,
        if (deliveryId != null) 'delivery_id': deliveryId,
        'room_type': 'delivery',
        if (initialMessage != null) 'initial_message': initialMessage,
      },
    );

    return ChatRoomModel.fromJson(response.data);
  }

  /// Marquer les messages comme lus
  Future<void> markAsRead(String roomId) async {
    await _dioClient.post(
      '${ApiConstants.baseUrl}/api/v1/chat/rooms/$roomId/mark-as-read/',
    );
  }

  /// Archiver une conversation
  Future<void> archiveChatRoom(String roomId) async {
    await _dioClient.post(
      '${ApiConstants.baseUrl}/api/v1/chat/rooms/$roomId/archive/',
    );
  }

  /// Obtenir le nombre total de messages non lus
  Future<int> getUnreadCount() async {
    try {
      final response = await _dioClient.get(
        '${ApiConstants.baseUrl}/api/v1/chat/rooms/unread-count/',
      );
      return response.data['unread_count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ==================== Firebase Realtime Database ====================

  /// Stream des messages d'une conversation
  Stream<List<MessageModel>> getMessagesStream(String roomId) {
    if (_firebaseDatabase == null) {
      return Stream.value([]);
    }

    final messagesRef = _firebaseDatabase!
        .ref()
        .child('chat_rooms')
        .child(roomId)
        .child('messages');

    return messagesRef.onValue.map((event) {
      if (event.snapshot.value == null) return <MessageModel>[];

      final messagesMap = event.snapshot.value as Map<dynamic, dynamic>;
      final messages = <MessageModel>[];

      messagesMap.forEach((key, value) {
        final messageData = Map<String, dynamic>.from(value as Map);
        messageData['id'] = key;
        messageData['room_id'] = roomId;

        // Convertir timestamp si nécessaire
        if (messageData['timestamp'] is int) {
          messageData['timestamp'] =
              DateTime.fromMillisecondsSinceEpoch(messageData['timestamp']);
        } else if (messageData['timestamp'] is String) {
          messageData['timestamp'] = DateTime.parse(messageData['timestamp']);
        }

        messages.add(MessageModel.fromJson(messageData));
      });

      // Trier par timestamp (plus récent en dernier)
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return messages;
    });
  }

  /// Envoyer un message
  Future<void> sendMessage({
    required String roomId,
    required String message,
    String? imageUrl,
  }) async {
    if (_firebaseDatabase == null) {
      throw Exception('Firebase not available');
    }

    final messagesRef = _firebaseDatabase!
        .ref()
        .child('chat_rooms')
        .child(roomId)
        .child('messages');

    final newMessageRef = messagesRef.push();
    final timestamp = DateTime.now();

    await newMessageRef.set({
      'message_text': message,
      if (imageUrl != null) 'image_url': imageUrl,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'is_read': false,
      'message_type': imageUrl != null ? 'image' : 'text',
    });

    // Mettre à jour le backend via API
    await _dioClient.post(
      '${ApiConstants.baseUrl}/api/v1/chat/rooms/$roomId/messages/',
      data: {
        'message_text': message,
        if (imageUrl != null) 'image_url': imageUrl,
      },
    );
  }

  /// Indicateur de saisie (typing)
  Future<void> setTypingIndicator({
    required String roomId,
    required String userId,
    required bool isTyping,
  }) async {
    if (_firebaseDatabase == null) return;

    final typingRef = _firebaseDatabase!
        .ref()
        .child('chat_rooms')
        .child(roomId)
        .child('typing')
        .child(userId);

    if (isTyping) {
      await typingRef.set({
        'is_typing': true,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      await typingRef.remove();
    }
  }

  /// Stream des indicateurs de saisie
  Stream<Map<String, bool>> getTypingIndicatorsStream(String roomId) {
    if (_firebaseDatabase == null) {
      return Stream.value({});
    }

    final typingRef = _firebaseDatabase!
        .ref()
        .child('chat_rooms')
        .child(roomId)
        .child('typing');

    return typingRef.onValue.map((event) {
      if (event.snapshot.value == null) return <String, bool>{};

      final typingMap = event.snapshot.value as Map<dynamic, dynamic>;
      final indicators = <String, bool>{};

      typingMap.forEach((userId, value) {
        final data = Map<String, dynamic>.from(value as Map);
        indicators[userId.toString()] = data['is_typing'] ?? false;
      });

      return indicators;
    });
  }
}
