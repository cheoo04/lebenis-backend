import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/auth_service.dart';

// ========== AUTH SERVICE PROVIDER ==========

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider pour le repository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final authService = ref.read(authServiceProvider);
  final dioClient = DioClient(authService);
  return NotificationRepository(dioClient: dioClient);
});

// État des notifications
class NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String? selectedType;

  NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.selectedType,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? selectedType,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      selectedType: selectedType ?? this.selectedType,
    );
  }
}

// Notifier pour gérer la logique

class NotificationNotifier extends Notifier<NotificationState> {
  late final NotificationRepository _repository;

  @override
  NotificationState build() {
    _repository = ref.read(notificationRepositoryProvider);
    return NotificationState();
  }

  /// Charge les notifications (page 1)
  Future<void> loadNotifications({String? notificationType}) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedType: notificationType,
    );

    try {
      final result = await _repository.getNotificationHistory(
        page: 1,
        pageSize: 20,
        notificationType: notificationType,
      );

      final notifications = result['notifications'] as List<NotificationModel>;
      final count = result['count'] as int;

      state = state.copyWith(
        notifications: notifications,
        currentPage: 1,
        hasMore: notifications.length < count,
        isLoading: false,
      );

      // Charger aussi le compteur de non lues
      await loadUnreadCount();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement des notifications',
      );
      developer.log('❌ Erreur loadNotifications: $e');
    }
  }

  /// Charge plus de notifications (pagination)
  Future<void> loadMoreNotifications() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final result = await _repository.getNotificationHistory(
        page: nextPage,
        pageSize: 20,
        notificationType: state.selectedType,
      );

      final newNotifications = result['notifications'] as List<NotificationModel>;
      final count = result['count'] as int;
      final allNotifications = [...state.notifications, ...newNotifications];

      state = state.copyWith(
        notifications: allNotifications,
        currentPage: nextPage,
        hasMore: allNotifications.length < count,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: 'Erreur lors du chargement',
      );
      developer.log('❌ Erreur loadMoreNotifications: $e');
    }
  }

  /// Charge le nombre de notifications non lues
  Future<void> loadUnreadCount() async {
    try {
      final count = await _repository.getUnreadCount();
      state = state.copyWith(unreadCount: count);
    } catch (e) {
      developer.log('❌ Erreur loadUnreadCount: $e');
    }
  }

  /// Marque une notification comme lue
  Future<void> markAsRead(String notificationId) async {
    try {
      final updatedNotification = await _repository.markAsRead(notificationId);

      // Mettre à jour la notification dans la liste
      final updatedList = state.notifications.map((n) {
        return n.id == notificationId ? updatedNotification : n;
      }).toList();

      // Décrémenter le compteur de non lues si nécessaire
      final notification = state.notifications.firstWhere((n) => n.id == notificationId);
      final newUnreadCount = notification.isRead
          ? state.unreadCount
          : (state.unreadCount - 1).clamp(0, double.infinity).toInt();

      state = state.copyWith(
        notifications: updatedList,
        unreadCount: newUnreadCount,
      );
    } catch (e) {
      developer.log('❌ Erreur markAsRead: $e');
      state = state.copyWith(
        error: 'Erreur lors de la mise à jour',
      );
    }
  }

  /// Marque toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();

      // Mettre à jour toutes les notifications
      final updatedList = state.notifications.map((n) {
        return n.copyWith(isRead: true, readAt: DateTime.now());
      }).toList();

      state = state.copyWith(
        notifications: updatedList,
        unreadCount: 0,
      );
    } catch (e) {
      developer.log('❌ Erreur markAllAsRead: $e');
      state = state.copyWith(
        error: 'Erreur lors de la mise à jour',
      );
    }
  }

  /// Supprime une notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);

      // Retirer la notification de la liste
      final notification = state.notifications.firstWhere((n) => n.id == notificationId);
      final updatedList = state.notifications.where((n) => n.id != notificationId).toList();

      // Décrémenter le compteur si c'était une notification non lue
      final newUnreadCount = notification.isRead
          ? state.unreadCount
          : (state.unreadCount - 1).clamp(0, double.infinity).toInt();

      state = state.copyWith(
        notifications: updatedList,
        unreadCount: newUnreadCount,
      );
    } catch (e) {
      developer.log('❌ Erreur deleteNotification: $e');
      state = state.copyWith(
        error: 'Erreur lors de la suppression',
      );
    }
  }

  /// Filtre par type de notification
  Future<void> filterByType(String? notificationType) async {
    await loadNotifications(notificationType: notificationType);
  }

  /// Rafraîchit la liste
  Future<void> refresh() async {
    await loadNotifications(notificationType: state.selectedType);
  }
}

// Provider principal
final notificationProvider = NotifierProvider<NotificationNotifier, NotificationState>(NotificationNotifier.new);
