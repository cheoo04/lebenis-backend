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

  /// Helper pour parser un double depuis Firebase (peut être String ou num)
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    return null;
  }

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
            'sender': rawData['senderId']?.toString() ?? rawData['sender_id']?.toString() ?? rawData['sender']?.toString() ?? '',
            'sender_name': rawData['senderName']?.toString() ?? rawData['sender_name']?.toString() ?? 'Utilisateur',
            'text': rawData['text']?.toString() ?? rawData['message_text']?.toString() ?? '',
            'image_url': rawData['imageUrl'] ?? rawData['image_url'],
            'latitude': _parseDouble(rawData['latitude']),
            'longitude': _parseDouble(rawData['longitude']),
            'created_at': timestamp.toIso8601String(),
            'is_read': rawData['isRead'] ?? rawData['is_read'] ?? false,
            'message_type': rawData['type']?.toString() ?? rawData['message_type']?.toString(),
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

  /// Envoyer un message via le backend (qui sync Firebase + envoie notif push)
  Future<void> sendMessage({
    required String roomId,
    required String message,
    String? imageUrl,
    double? latitude,
    double? longitude,
  }) async {
    await _dioClient.post(
      '${ApiConstants.baseUrl}/api/v1/chat/messages/',
      data: {
        'chat_room_id': roomId,
        'message_type': imageUrl != null ? 'image' : (latitude != null ? 'location' : 'text'),
        'text': message,
        if (imageUrl != null) 'image_url': imageUrl,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
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

}
