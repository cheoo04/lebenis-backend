import 'dart:developer' as developer;
import '../../core/network/dio_client.dart';
import '../models/notification_model.dart';
import '../../core/constants/api_constants.dart';

class NotificationRepository {
  final DioClient dioClient;

  NotificationRepository({required this.dioClient});

  /// Récupère l'historique des notifications avec pagination
  /// 
  /// [page] : Numéro de la page (défaut: 1)
  /// [pageSize] : Nombre d'items par page (défaut: 20)
  /// [notificationType] : Filtrer par type (optionnel)
  /// [isRead] : Filtrer par statut lu/non lu (optionnel)
  Future<Map<String, dynamic>> getNotificationHistory({
    int page = 1,
    int pageSize = 20,
    String? notificationType,
    bool? isRead,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (notificationType != null) {
        queryParams['notification_type'] = notificationType;
      }

      if (isRead != null) {
        queryParams['is_read'] = isRead;
      }

      final response = await dioClient.get(
        ApiConstants.notificationHistory,
        queryParameters: queryParams,
      );

      developer.log('📥 getNotificationHistory Response: ${response.statusCode}');

      final results = (response.data['results'] as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      return {
        'notifications': results,
        'count': response.data['count'] as int,
        'next': response.data['next'],
        'previous': response.data['previous'],
      };
    } catch (e) {
      developer.log('❌ Erreur getNotificationHistory: $e');
      rethrow;
    }
  }

  /// Récupère le nombre de notifications non lues
  Future<int> getUnreadCount() async {
    try {
      final response = await dioClient.get(
        '${ApiConstants.notificationHistory}unread_count/',
      );

      developer.log('📥 getUnreadCount Response: ${response.statusCode}');
      return response.data['unread_count'] as int;
    } catch (e) {
      developer.log('❌ Erreur getUnreadCount: $e');
      rethrow;
    }
  }

  /// Marque une notification comme lue
  /// 
  /// [notificationId] : ID de la notification
  Future<NotificationModel> markAsRead(String notificationId) async {
    try {
      final response = await dioClient.post(
        '${ApiConstants.notificationHistory}$notificationId/mark_as_read/',
      );

      developer.log('📥 markAsRead Response: ${response.statusCode}');
      return NotificationModel.fromJson(response.data);
    } catch (e) {
      developer.log('❌ Erreur markAsRead: $e');
      rethrow;
    }
  }

  /// Marque toutes les notifications comme lues
  Future<int> markAllAsRead() async {
    try {
      final response = await dioClient.post(
        '${ApiConstants.notificationHistory}mark_all_as_read/',
      );

      developer.log('📥 markAllAsRead Response: ${response.statusCode}');
      return response.data['count'] as int;
    } catch (e) {
      developer.log('❌ Erreur markAllAsRead: $e');
      rethrow;
    }
  }

  /// Supprime une notification
  /// 
  /// [notificationId] : ID de la notification à supprimer
  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await dioClient.delete(
        '${ApiConstants.notificationHistory}$notificationId/',
      );

      developer.log('📥 deleteNotification Response: ${response.statusCode}');
    } catch (e) {
      developer.log('❌ Erreur deleteNotification: $e');
      rethrow;
    }
  }

  /// Récupère uniquement les notifications non lues
  Future<List<NotificationModel>> getUnreadNotifications({
    int pageSize = 20,
  }) async {
    try {
      final result = await getNotificationHistory(
        page: 1,
        pageSize: pageSize,
        isRead: false,
      );

      return result['notifications'] as List<NotificationModel>;
    } catch (e) {
      developer.log('❌ Erreur getUnreadNotifications: $e');
      rethrow;
    }
  }

  /// Récupère les notifications par type
  Future<List<NotificationModel>> getNotificationsByType({
    required String notificationType,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final result = await getNotificationHistory(
        page: page,
        pageSize: pageSize,
        notificationType: notificationType,
      );

      return result['notifications'] as List<NotificationModel>;
    } catch (e) {
      developer.log('❌ Erreur getNotificationsByType: $e');
      rethrow;
    }
  }
}
