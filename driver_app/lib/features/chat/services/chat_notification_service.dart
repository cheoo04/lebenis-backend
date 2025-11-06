import 'package:flutter/foundation.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/network/dio_client.dart';

/// Service pour gérer les notifications push liées au chat
class ChatNotificationService {
  final NotificationService _notificationService;
  final DioClient _dioClient;
  
  String? _currentFcmToken;
  
  ChatNotificationService({
    required NotificationService notificationService,
    required AuthService authService,
    required DioClient dioClient,
  })  : _notificationService = notificationService,
        _dioClient = dioClient;

  /// Initialiser le service de notifications chat
  /// À appeler après la connexion de l'utilisateur
  Future<void> initialize() async {
    try {
      // Récupérer le token FCM
      final token = await _notificationService.getFcmToken();
      
      if (token != null) {
        _currentFcmToken = token;
        
        // Envoyer le token au backend
        await _sendTokenToBackend(token);
        
        if (kDebugMode) {
          debugPrint('✅ Chat notifications initialisées avec token: ${token.substring(0, 20)}...');
        }
      }
      
      // Écouter les changements de token
      _notificationService.onTokenRefresh().listen((newToken) {
        _currentFcmToken = newToken;
        _sendTokenToBackend(newToken);
      });
      
      // S'abonner aux topics de chat
      await _subscribeToTopics();
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Erreur initialisation ChatNotificationService: $e');
      }
    }
  }

  /// Envoyer le token FCM au backend
  Future<void> _sendTokenToBackend(String token) async {
    try {
      await _dioClient.post(
        '/notifications/register_token/',
        data: {
          'token': token,
          'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
          'device_name': '', // Peut être récupéré via device_info_plus si nécessaire
        },
      );
      
      if (kDebugMode) {
        debugPrint('📤 Token FCM envoyé au backend');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur envoi token au backend: $e');
      }
    }
  }

  /// S'abonner aux topics de notifications
  Future<void> _subscribeToTopics() async {
    try {
      // Topic général pour tous les livreurs
      await _notificationService.subscribeToTopic('drivers');
      
      // Topic pour les nouveaux messages de chat
      await _notificationService.subscribeToTopic('chat_messages');
      
      if (kDebugMode) {
        debugPrint('📢 Abonné aux topics de notifications');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Erreur abonnement topics: $e');
      }
    }
  }

  /// Se désabonner des topics (lors de la déconnexion)
  Future<void> unsubscribe() async {
    try {
      await _notificationService.unsubscribeFromTopic('drivers');
      await _notificationService.unsubscribeFromTopic('chat_messages');
      
      // Supprimer le token du backend
      if (_currentFcmToken != null) {
        await _deleteTokenFromBackend(_currentFcmToken!);
      }
      
      if (kDebugMode) {
        debugPrint('📢 Désabonné des topics de notifications');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Erreur désabonnement: $e');
      }
    }
  }

  /// Supprimer le token FCM du backend
  Future<void> _deleteTokenFromBackend(String token) async {
    try {
      await _dioClient.post(
        '/notifications/delete_token/',
        data: {'token': token},
      );
      
      if (kDebugMode) {
        debugPrint('🗑️ Token FCM supprimé du backend');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Erreur suppression token: $e');
      }
    }
  }

  /// Récupérer le token FCM actuel
  String? get currentToken => _currentFcmToken;
}
