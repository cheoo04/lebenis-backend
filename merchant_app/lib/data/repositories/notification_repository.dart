import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';

class NotificationRepository {
  final DioClient dioClient;

  NotificationRepository(this.dioClient);

  Future<List<NotificationModel>> getNotifications() async {
    final response = await dioClient.get(ApiConstants.notifications);
    
    // Gérer la réponse paginée
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('results')) {
      final list = data['results'] as List;
      return list.map((e) => NotificationModel.fromJson(e)).toList();
    }
    
    // Fallback si c'est une liste directe
    final list = response.data as List;
    return list.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> markAsRead(String id) async {
    await dioClient.post('${ApiConstants.notifications}$id/mark-as-read/');
  }

  Future<void> markAllAsRead() async {
    await dioClient.post('${ApiConstants.notifications}mark-all-as-read/');
  }

  Future<void> deleteNotification(String id) async {
    await dioClient.delete('${ApiConstants.notifications}$id/');
  }

  Future<int> getUnreadCount() async {
    try {
      // Utiliser le endpoint history au lieu de main
      final response = await dioClient.get('/api/v1/notifications/history/unread-count/');
      return response.data['unread_count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return NotificationRepository(dioClient);
});
