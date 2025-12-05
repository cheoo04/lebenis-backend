import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationListNotifier extends Notifier<AsyncValue<List<NotificationModel>>> {
  @override
  AsyncValue<List<NotificationModel>> build() {
    return const AsyncValue.loading();
  }

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(notificationRepositoryProvider);
      final notifications = await repository.getNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.markAsRead(id);
      // Recharger les notifications
      await loadNotifications();
    } catch (e) {
      // Ignorer l'erreur silencieusement
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.markAllAsRead();
      // Recharger les notifications
      await loadNotifications();
    } catch (e) {
      // Ignorer l'erreur silencieusement
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.deleteNotification(id);
      // Recharger les notifications
      await loadNotifications();
    } catch (e) {
      // Ignorer l'erreur silencieusement
    }
  }
}

final notificationListProvider = NotifierProvider<NotificationListNotifier, AsyncValue<List<NotificationModel>>>(
  () => NotificationListNotifier(),
);

// Provider pour le nombre de notifications non lues
final unreadNotificationsCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return await repository.getUnreadCount();
});
