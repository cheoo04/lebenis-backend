import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../data/models/chat/chat_room_model.dart';
import '../../../data/models/chat/message_model.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../core/services/notification_service.dart';
import '../services/chat_notification_service.dart';

// ==================== Providers de base ====================

/// Provider pour Firebase Database
final firebaseDatabaseProvider = Provider<FirebaseDatabase>((ref) {
  return FirebaseDatabase.instance;
});

/// Provider pour NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider pour ChatNotificationService
final chatNotificationServiceProvider = Provider<ChatNotificationService>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  final authService = ref.watch(authServiceProvider);
  final dioClient = ref.watch(dioClientProvider);
  
  return ChatNotificationService(
    notificationService: notificationService,
    authService: authService,
    dioClient: dioClient,
  );
});

/// Provider pour le ChatRepository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final firebaseDb = ref.watch(firebaseDatabaseProvider);
  final authService = ref.watch(authServiceProvider);
  
  return ChatRepository(
    dioClient: dioClient,
    firebaseDatabase: firebaseDb,
    authService: authService,
  );
});

// ==================== State Classes ====================

/// État de la liste des conversations
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

/// État d'une conversation spécifique
class ChatMessagesState {
  final List<MessageModel> messages;
  final bool isLoading;
  final String? error;
  final bool isSending;
  final Map<String, bool> typingIndicators; // userId -> isTyping

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

// ==================== StateNotifiers ====================

/// Notifier pour gérer la liste des conversations
class ChatRoomsNotifier extends Notifier<ChatRoomsState> {
  late final ChatRepository _repository;

  @override
  ChatRoomsState build() {
    _repository = ref.read(chatRepositoryProvider);
    return ChatRoomsState();
  }

  /// Charge la liste des conversations
  Future<void> loadChatRooms({
    String? roomType,
    String? deliveryId,
    bool includeArchived = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final rooms = await _repository.getChatRooms(
        roomType: roomType,
        deliveryId: deliveryId,
        includeArchived: includeArchived,
      );

      final unreadCount = await _repository.getUnreadCount();

      state = state.copyWith(
        rooms: rooms,
        totalUnread: unreadCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Rafraîchir la liste
  Future<void> refresh() async {
    await loadChatRooms();
  }

  /// Crée une nouvelle conversation
  Future<ChatRoomModel?> createChatRoom({
    required String otherUserId,
    String? deliveryId,
    String roomType = 'delivery',
    String? initialMessage,
  }) async {
    try {
      final newRoom = await _repository.createChatRoom(
        otherUserId: otherUserId,
        deliveryId: deliveryId,
        roomType: roomType,
        initialMessage: initialMessage,
      );

      // Ajouter la room à la liste (ou la mettre à jour si elle existe)
      final updatedRooms = [...state.rooms];
      final existingIndex = updatedRooms.indexWhere((r) => r.id == newRoom.id);
      
      if (existingIndex >= 0) {
        updatedRooms[existingIndex] = newRoom;
      } else {
        updatedRooms.insert(0, newRoom);
      }

      state = state.copyWith(rooms: updatedRooms);
      return newRoom;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Marquer une conversation comme lue
  Future<void> markAsRead(String roomId) async {
    try {
      await _repository.markRoomAsRead(roomId);

      // Mettre à jour localement
      final updatedRooms = state.rooms.map((room) {
        if (room.id == roomId) {
          return room.copyWith(unreadCount: 0);
        }
        return room;
      }).toList();

      // Recalculer le total
      final totalUnread = updatedRooms.fold<int>(
        0,
        (sum, room) => sum + room.unreadCount,
      );

      state = state.copyWith(
        rooms: updatedRooms,
        totalUnread: totalUnread,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Archiver/Désarchiver une conversation
  Future<void> archiveChatRoom(String roomId, {required bool archive}) async {
    try {
      await _repository.archiveChatRoom(roomId, archive: archive);

      // Retirer de la liste si archivée
      if (archive) {
        final updatedRooms = state.rooms.where((r) => r.id != roomId).toList();
        state = state.copyWith(rooms: updatedRooms);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// Notifier pour gérer les messages d'une conversation
class ChatMessagesNotifier extends Notifier<ChatMessagesState> {
  final String chatRoomId;
  late final ChatRepository _repository;

  ChatMessagesNotifier(this.chatRoomId);

  @override
  ChatMessagesState build() {
    _repository = ref.watch(chatRepositoryProvider);
    return ChatMessagesState();
  }

  /// Envoie un message texte
  Future<bool> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return false;
    state = state.copyWith(isSending: true);
    try {
      final message = await _repository.sendMessage(
        chatRoomId: chatRoomId,
        messageType: MessageType.text,
        text: text.trim(),
      );
      final updatedMessages = [...state.messages, message];
      state = state.copyWith(
        messages: updatedMessages,
        isSending: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Envoie une image
  Future<bool> sendImageMessage(String imageUrl, {String? caption}) async {
    state = state.copyWith(isSending: true);
    try {
      final message = await _repository.sendMessage(
        chatRoomId: chatRoomId,
        messageType: MessageType.image,
        imageUrl: imageUrl,
        text: caption,
      );
      final updatedMessages = [...state.messages, message];
      state = state.copyWith(
        messages: updatedMessages,
        isSending: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Envoie une localisation
  Future<bool> sendLocationMessage({
    required double latitude,
    required double longitude,
    String? text,
  }) async {
    state = state.copyWith(isSending: true);
    try {
      final message = await _repository.sendMessage(
        chatRoomId: chatRoomId,
        messageType: MessageType.location,
        latitude: latitude,
        longitude: longitude,
        text: text,
      );
      final updatedMessages = [...state.messages, message];
      state = state.copyWith(
        messages: updatedMessages,
        isSending: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Marque tous les messages comme lus
  Future<void> markAllAsRead() async {
    try {
      await _repository.markMessagesAsRead(chatRoomId: chatRoomId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Met à jour le typing indicator
  Future<void> setTyping(bool isTyping) async {
    await _repository.setTypingIndicator(chatRoomId, isTyping);
  }

  /// Met à jour les messages depuis Firebase
  void updateMessages(List<MessageModel> messages) {
    state = state.copyWith(messages: messages);
  }

  /// Met à jour les typing indicators
  void updateTypingIndicators(Map<String, bool> indicators) {
    state = state.copyWith(typingIndicators: indicators);
  }
}

// ==================== Providers ====================

/// Provider pour la liste des conversations
final chatRoomsProvider = NotifierProvider<ChatRoomsNotifier, ChatRoomsState>(ChatRoomsNotifier.new);

/// Provider pour les messages d'une conversation (factory)
final chatMessagesProvider = NotifierProvider.family<ChatMessagesNotifier, ChatMessagesState, String>(
  (chatRoomId) => ChatMessagesNotifier(chatRoomId),
);

/// Stream provider pour les messages temps réel d'une conversation
final messagesStreamProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, chatRoomId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchMessages(chatRoomId);
});

/// Stream provider pour les typing indicators
final typingIndicatorsStreamProvider =
    StreamProvider.family<Map<String, bool>, String>((ref, chatRoomId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.watchTypingIndicators(chatRoomId);
});

/// Provider pour le nombre total de messages non lus
final totalUnreadCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getUnreadCount();
});
