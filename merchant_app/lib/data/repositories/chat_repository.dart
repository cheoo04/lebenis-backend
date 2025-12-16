import 'package:flutter/foundation.dart';
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
    required String otherUserId,
    required String currentUserId,
    String? deliveryId,
    String? initialMessage,
  }) async {
    final response = await _dioClient.post(
      '${ApiConstants.baseUrl}/api/v1/chat/rooms/',
      data: {
        'other_user_id': otherUserId,
        if (deliveryId != null) 'delivery_id': deliveryId,
        'room_type': 'delivery',
        if (initialMessage != null) 'initial_message': initialMessage,
      },
    );

    final chatRoom = ChatRoomModel.fromJson(response.data);
    
    // Stocker les participants dans Firebase pour les règles de sécurité
    await _ensureParticipantsInFirebase(
      roomId: chatRoom.id,
      currentUserId: currentUserId,
      otherUserId: otherUserId,
    );

    return chatRoom;
  }
  
  /// S'assurer que les participants sont enregistrés dans Firebase
  Future<void> _ensureParticipantsInFirebase({
    required String roomId,
    required String currentUserId,
    required String otherUserId,
  }) async {
    if (_firebaseDatabase == null) return;
    
    final participantsRef = _firebaseDatabase!
        .ref()
        .child('chat_rooms')
        .child(roomId)
        .child('participants');
    
    // Ajouter les deux participants
    await participantsRef.update({
      currentUserId: true,
      otherUserId: true,
    });
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
        try {
          final rawData = Map<String, dynamic>.from(value as Map);
          
          // Convertir timestamp en DateTime
          DateTime timestamp;
          if (rawData['timestamp'] is int) {
            timestamp = DateTime.fromMillisecondsSinceEpoch(rawData['timestamp']);
          } else if (rawData['timestamp'] is String) {
            timestamp = DateTime.parse(rawData['timestamp']);
          } else {
            timestamp = DateTime.now();
          }
          
          // Construire les données compatibles avec MessageModel
          final messageData = <String, dynamic>{
            'id': key.toString(),
            'chat_room': roomId,
            'sender': rawData['sender_id']?.toString() ?? rawData['sender']?.toString() ?? '',
            'sender_name': rawData['sender_name']?.toString() ?? 'Utilisateur',
            'text': rawData['message_text']?.toString() ?? rawData['text']?.toString() ?? '',
            'image_url': rawData['image_url'],
            'created_at': timestamp.toIso8601String(),
            'is_read': rawData['is_read'] ?? false,
            'message_type': rawData['message_type']?.toString(),
          };

          messages.add(MessageModel.fromJson(messageData));
        } catch (e) {
          debugPrint('[ChatRepository] Erreur parsing message $key: $e');
        }
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
    required String senderId,
    required String senderName,
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

    // Format unifié compatible avec backend et driver_app
    await newMessageRef.set({
      'text': message,
      'message_text': message, // Rétro-compatibilité
      'sender': senderId,
      'senderId': senderId, // Compatibilité backend
      'sender_id': senderId, // Compatibilité driver
      'sender_name': senderName,
      if (imageUrl != null) 'image_url': imageUrl,
      if (imageUrl != null) 'imageUrl': imageUrl, // Compatibilité backend
      'timestamp': timestamp.millisecondsSinceEpoch,
      'is_read': false,
      'isRead': false, // Compatibilité backend
      'message_type': imageUrl != null ? 'image' : 'text',
      'type': imageUrl != null ? 'image' : 'text', // Compatibilité backend
    });

    // Mettre à jour le backend via API (backup DB)
    try {
      await _dioClient.post(
        '${ApiConstants.baseUrl}/api/v1/chat/messages/',
        data: {
          'chat_room_id': roomId,
          'message_type': imageUrl != null ? 'image' : 'text',
          'text': message,
          if (imageUrl != null) 'image_url': imageUrl,
        },
      );
    } catch (e) {
      // Ignorer l'erreur backend - le message est déjà dans Firebase
      debugPrint('[ChatRepository] Erreur sync backend: $e');
    }
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
