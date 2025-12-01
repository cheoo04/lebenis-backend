import 'dart:developer' as developer;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/auth_service.dart';
import '../models/chat/chat_room_model.dart';
import '../models/chat/message_model.dart';
import 'package:dio/dio.dart';


class ChatRepository {
  final DioClient _dioClient;
  final FirebaseDatabase _firebaseDatabase;
  final AuthService _authService;
  
  String? _cachedUserId;

  ChatRepository({
    required DioClient dioClient,
    required FirebaseDatabase firebaseDatabase,
    required AuthService authService,
  })  : _dioClient = dioClient,
        _firebaseDatabase = firebaseDatabase,
        _authService = authService;
  
  /// Récupère l'ID utilisateur (avec cache)
  Future<String> _getCurrentUserId() async {
    _cachedUserId ??= await _authService.getUserId();
    return _cachedUserId ?? '';
  }

  // ==================== REST API Endpoints ====================

  /// Récupère la liste des conversations
  Future<List<ChatRoomModel>> getChatRooms({
    String? roomType,
    String? deliveryId,
    bool includeArchived = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (roomType != null) queryParams['room_type'] = roomType;
      if (deliveryId != null) queryParams['delivery_id'] = deliveryId;
      if (includeArchived) queryParams['include_archived'] = 'true';

      final response = await _dioClient.get(
        '/chat/rooms/',
        queryParameters: queryParams,
      );

      final results = response.data['results'] as List;
      return results.map((json) => ChatRoomModel.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le nombre total de messages non lus
  Future<int> getUnreadCount() async {
    try {
      final response = await _dioClient.get('/chat/rooms/unread_count/');
      return response.data['unread_count'] as int;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Crée une nouvelle conversation (ou retourne une existante)
  Future<ChatRoomModel> createChatRoom({
    required String otherUserId,
    String? deliveryId,
    String roomType = 'delivery',
    String? initialMessage,
  }) async {
    try {
      final response = await _dioClient.post(
        '/chat/rooms/',
        data: {
          'other_user_id': otherUserId,
          if (deliveryId != null) 'delivery_id': deliveryId,
          'room_type': roomType,
          if (initialMessage != null) 'initial_message': initialMessage,
        },
      );

      return ChatRoomModel.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Marque une conversation comme lue
  Future<void> markRoomAsRead(String roomId) async {
    try {
      await _dioClient.post('/chat/rooms/$roomId/mark_as_read/');
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Archive/Désarchive une conversation
  Future<void> archiveChatRoom(String roomId, {required bool archive}) async {
    try {
      await _dioClient.post(
        '/chat/rooms/$roomId/archive/',
        data: {'archive': archive},
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère l'historique des messages (backup DB)
  Future<List<MessageModel>> getMessageHistory(String chatRoomId) async {
    try {
      final currentUserId = await _getCurrentUserId();
      final response = await _dioClient.get(
        '/chat/messages/',
        queryParameters: {'chat_room_id': chatRoomId},
      );

      final results = response.data['results'] as List;
      return results
          .map((json) => MessageModel.fromJson(json).copyWith(
                isMine: json['sender']['id'] == currentUserId,
              ))
          .toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Envoie un message (crée en DB + sync Firebase automatique)
  Future<MessageModel> sendMessage({
    required String chatRoomId,
    required MessageType messageType,
    String? text,
    String? imageUrl,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _dioClient.post(
        '/chat/messages/',
        data: {
          'chat_room_id': chatRoomId,
          'message_type': messageType.name,
          if (text != null) 'text': text,
          if (imageUrl != null) 'image_url': imageUrl,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
      );

      return MessageModel.fromJson(response.data).copyWith(
        isMine: true,
        status: MessageStatus.sent,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Marque des messages comme lus
  Future<void> markMessagesAsRead({
    List<String>? messageIds,
    String? chatRoomId,
  }) async {
    try {
      await _dioClient.post(
        '/chat/messages/mark_as_read/',
        data: {
          if (messageIds != null) 'message_ids': messageIds,
          if (chatRoomId != null) 'chat_room_id': chatRoomId,
        },
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== Firebase Realtime Database ====================

  /// Stream des messages temps réel pour une conversation
  Stream<List<MessageModel>> watchMessages(String chatRoomId) async* {
    final currentUserId = await _getCurrentUserId();
    final messagesRef = _firebaseDatabase
        .ref('chats/$chatRoomId/messages')
        .orderByChild('timestamp');

    await for (final event in messagesRef.onValue) {
      final messages = <MessageModel>[];

      if (event.snapshot.value != null) {
        final messagesMap = event.snapshot.value as Map<dynamic, dynamic>;

        messagesMap.forEach((key, value) {
          if (value != null) {
            try {
              final message = MessageModel.fromFirebase(
                key.toString(),
                value as Map<dynamic, dynamic>,
                currentUserId,
              ).copyWith(chatRoomId: chatRoomId);
              messages.add(message);
            } catch (e) {
              developer.log('❌ Erreur parsing message $key: $e');
            }
          }
        });
      }

      // Trier par timestamp (plus ancien en premier)
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      yield messages;
    }
  }

  /// Stream d'un seul message (pour les updates)
  Stream<MessageModel?> watchMessage(String chatRoomId, String messageId) async* {
    final currentUserId = await _getCurrentUserId();
    final messageRef =
        _firebaseDatabase.ref('chats/$chatRoomId/messages/$messageId');

    await for (final event in messageRef.onValue) {
      if (event.snapshot.value == null) {
        yield null;
      } else {
        yield MessageModel.fromFirebase(
          messageId,
          event.snapshot.value as Map<dynamic, dynamic>,
          currentUserId,
        ).copyWith(chatRoomId: chatRoomId);
      }
    }
  }

  /// Stream du typing indicator
  Stream<Map<String, bool>> watchTypingIndicators(String chatRoomId) async* {
    final currentUserId = await _getCurrentUserId();
    final typingRef = _firebaseDatabase.ref('chats/$chatRoomId/typing');

    await for (final event in typingRef.onValue) {
      final typingMap = <String, bool>{};

      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        data.forEach((userId, timestamp) {
          if (userId.toString() != currentUserId) {
            // Ignorer notre propre typing
            // Vérifier que le timestamp est récent (< 5 secondes)
            final typingTime = DateTime.parse(timestamp.toString());
            final isRecent =
                DateTime.now().difference(typingTime).inSeconds < 5;
            typingMap[userId.toString()] = isRecent;
          }
        });
      }

      yield typingMap;
    }
  }

  /// Définir notre typing indicator
  Future<void> setTypingIndicator(String chatRoomId, bool isTyping) async {
    try {
      final currentUserId = await _getCurrentUserId();
      final typingRef =
          _firebaseDatabase.ref('chats/$chatRoomId/typing/$currentUserId');

      if (isTyping) {
        await typingRef.set(DateTime.now().toIso8601String());
      } else {
        await typingRef.remove();
      }
    } catch (e) {
      developer.log('❌ Erreur typing indicator: $e');
    }
  }

  /// Marquer un message comme lu dans Firebase
  Future<void> markMessageAsReadInFirebase(
      String chatRoomId, String messageId) async {
    try {
      final messageRef =
          _firebaseDatabase.ref('chats/$chatRoomId/messages/$messageId');

      await messageRef.update({
        'is_read': true,
        'read_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      developer.log('❌ Erreur mark as read Firebase: $e');
    }
  }

  // ==================== Helpers ====================

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.statusCode == 404) {
        return Exception('Conversation introuvable');
      } else if (error.response?.statusCode == 403) {
        return Exception('Accès non autorisé');
      } else if (error.response?.data != null) {
        return Exception(error.response?.data['error'] ?? error.message);
      }
    }
    return Exception('Erreur réseau: $error');
  }
}
