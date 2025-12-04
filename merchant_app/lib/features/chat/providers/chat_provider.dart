import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../data/models/chat/chat_room_model.dart';
import '../../../data/repositories/chat_repository.dart';
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
    required String driverId,
    String? deliveryId,
    String? initialMessage,
  }) async {
    try {
      final repository = ref.read(chatRepositoryProvider);
      final room = await repository.createOrGetChatRoom(
        driverId: driverId,
        deliveryId: deliveryId,
        initialMessage: initialMessage,
      );

      // Recharger la liste
      await loadChatRooms();

      return room;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
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
      await repository.sendMessage(roomId: roomId, message: message);
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
