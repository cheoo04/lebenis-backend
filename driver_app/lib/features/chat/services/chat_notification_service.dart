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
      }
    }
  }

  /// Enregistrer le token FCM après connexion (méthode publique)
  Future<void> registerTokenAfterLogin() async {
    try {
      final token = await _notificationService.getFcmToken();
      
      if (token != null) {
        _currentFcmToken = token;
        await _sendTokenToBackend(token);
        await _subscribeToTopics();
        
        // Écouter les changements de token
        _notificationService.onTokenRefresh().listen((newToken) {
          _currentFcmToken = newToken;
          _sendTokenToBackend(newToken);
        });
        
        if (kDebugMode) {
        }
      }
    } catch (e) {
      if (kDebugMode) {
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
      }
    } catch (e) {
      if (kDebugMode) {
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
      }
    } catch (e) {
      if (kDebugMode) {
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
      }
    } catch (e) {
      if (kDebugMode) {
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
      }
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  /// Récupérer le token FCM actuel
  String? get currentToken => _currentFcmToken;
}
