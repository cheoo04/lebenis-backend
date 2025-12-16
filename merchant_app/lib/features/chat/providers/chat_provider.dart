import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../data/models/chat/chat_room_model.dart';
import '../../../data/models/merchant_model.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/user_profile_provider.dart';
import '../../../core/providers.dart';

// Provider Firebase Database
final firebaseDatabaseProvider = Provider<FirebaseDatabase?>((ref) {
  try {
    return FirebaseDatabase.instance;
  } catch (e) {
    return null;
  }
});

// Provider ChatRepository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final firebaseDb = ref.watch(firebaseDatabaseProvider);
  return ChatRepository(dioClient, firebaseDatabase: firebaseDb);
});

// ==================== State Classes ====================

class ChatRoomsState {
  final List<ChatRoomModel> rooms;
  final bool isLoading;
  final String? error;
  final int totalUnread;

  ChatRoomsState({
    this.rooms = const [],
    this.isLoading = false,
    this.error,
    this.totalUnread = 0,
  });

  ChatRoomsState copyWith({
    List<ChatRoomModel>? rooms,
    bool? isLoading,
    String? error,
    int? totalUnread,
  }) {
    return ChatRoomsState(
      rooms: rooms ?? this.rooms,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalUnread: totalUnread ?? this.totalUnread,
    );
  }
}

class ChatMessagesState {
  final List<MessageModel> messages;
  final bool isLoading;
  final String? error;
  final bool isSending;
  final Map<String, bool> typingIndicators;

  ChatMessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.isSending = false,
    this.typingIndicators = const {},
  });

  ChatMessagesState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    String? error,
    bool? isSending,
    Map<String, bool>? typingIndicators,
  }) {
    return ChatMessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSending: isSending ?? this.isSending,
      typingIndicators: typingIndicators ?? this.typingIndicators,
    );
  }
}

// ==================== Notifiers ====================

/// Notifier pour la liste des conversations
class ChatRoomsNotifier extends Notifier<ChatRoomsState> {
  @override
  ChatRoomsState build() {
    loadChatRooms();
    return ChatRoomsState();
  }

  Future<void> loadChatRooms() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(chatRepositoryProvider);
      final rooms = await repository.getChatRooms();
      final unreadCount = await repository.getUnreadCount();

      state = ChatRoomsState(
        rooms: rooms,
        isLoading: false,
        totalUnread: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<ChatRoomModel?> createOrGetChatRoom({
    required String otherUserId,
    String? deliveryId,
    String? initialMessage,
  }) async {
    try {
      final repository = ref.read(chatRepositoryProvider);
      final authState = ref.read(authStateProvider);
      final currentUserId = authState.value?.id.toString() ?? '';
      
      debugPrint('[ChatProvider] createOrGetChatRoom - otherUserId: $otherUserId, currentUserId: $currentUserId, deliveryId: $deliveryId');
      
      if (currentUserId.isEmpty) {
        throw Exception('Utilisateur non connecté');
      }
      
      final room = await repository.createOrGetChatRoom(
        otherUserId: otherUserId,
        currentUserId: currentUserId,
        deliveryId: deliveryId,
        initialMessage: initialMessage,
      );
      
      debugPrint('[ChatProvider] Chat room created/retrieved: ${room.id}');

      // Recharger la liste
      await loadChatRooms();

      return room;
    } catch (e, stackTrace) {
      debugPrint('[ChatProvider] Error creating chat room: $e');
      debugPrint('[ChatProvider] StackTrace: $stackTrace');
      state = state.copyWith(error: e.toString());
      rethrow; // Propager l'erreur pour qu'elle soit affichée
    }
  }

  Future<void> markAsRead(String roomId) async {
    try {
      final repository = ref.read(chatRepositoryProvider);
      await repository.markAsRead(roomId);
      await loadChatRooms();
    } catch (e) {
      // Ignorer les erreurs
    }
  }

  Future<void> sendMessage(String roomId, String message) async {
    try {
      final repository = ref.read(chatRepositoryProvider);
      
      // Récupérer les infos du merchant pour l'expéditeur
      final profile = ref.read(userProfileProvider).value;
      String senderId = '';
      String senderName = 'Marchand';
      
      if (profile is MerchantModel) {
        // Utiliser l'ID utilisateur (pas l'ID du profil marchand)
        senderId = profile.userId.isNotEmpty ? profile.userId : profile.id;
        senderName = profile.businessName;
      }
      
      await repository.sendMessage(
        roomId: roomId,
        message: message,
        senderId: senderId,
        senderName: senderName,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Archiver une conversation
  Future<void> archiveChatRoom(String roomId) async {
    try {
      final repository = ref.read(chatRepositoryProvider);
      await repository.archiveChatRoom(roomId);
      // Retirer la conversation de la liste
      final updatedRooms = state.rooms.where((r) => r.id != roomId).toList();
      state = state.copyWith(rooms: updatedRooms);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

/// Provider pour la liste des conversations
final chatRoomsProvider =
    NotifierProvider<ChatRoomsNotifier, ChatRoomsState>(() {
  return ChatRoomsNotifier();
});

/// Provider pour les messages d'une conversation (Stream)
final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, roomId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getMessagesStream(roomId);
});
