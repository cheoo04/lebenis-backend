// lib/core/services/notification_service.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

/// Service de gestion des notifications push Firebase
/// Gère:
/// - Réception des notifications
/// - Affichage des notifications locales
/// - Navigation lors du tap sur notification
class NotificationService {
  // Singleton instance
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() => _instance;
  
  NotificationService._internal();
  
  FirebaseMessaging? _fcm; // Nullable et initialisé plus tard
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Callback pour gérer la navigation
  Function(Map<String, dynamic>)? onNotificationTap;

  // ========== INITIALISATION ==========

  /// Initialiser le service de notifications
  /// [firebaseEnabled] : indique si Firebase est disponible sur cette plateforme
  Future<void> initialize({bool firebaseEnabled = true}) async {
    if (!firebaseEnabled) {
      if (kDebugMode) {
      }
      return;
    }
    
    try {
      // Initialiser Firebase Messaging
      _fcm = FirebaseMessaging.instance;
      
      // Demander les permissions
      await _requestPermissions();

      // Configurer les notifications locales
      await _initializeLocalNotifications();

      // Configurer les handlers Firebase
      _configureFirebaseHandlers();
    } catch (e) {
      if (kDebugMode) {
      }
    }
  }

  /// Demander les permissions de notifications
  Future<void> _requestPermissions() async {
    if (_fcm == null) return;
    
    NotificationSettings settings = await _fcm!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) debugPrint(' Permissions notifications accordées');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      if (kDebugMode) debugPrint(' Permissions notifications provisoires');
    } else {
      if (kDebugMode) debugPrint(' Permissions notifications refusées');
    }
  }

  /// Initialiser les notifications locales
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  /// Callback lors du tap sur notification
  void _onNotificationResponse(NotificationResponse details) {
    if (details.payload != null && onNotificationTap != null) {
      // Parser le payload JSON
      final data = {'payload': details.payload};
      onNotificationTap!(data);
    }
  }

  /// Configurer les handlers Firebase
  void _configureFirebaseHandlers() {
    if (_fcm == null) return;
    
    // Messages en premier plan (app ouverte)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Messages en arrière-plan (app fermée)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Message qui a ouvert l'app
    _fcm!.getInitialMessage().then((message) {
      if (message != null) {
        _handleBackgroundMessage(message);
      }
    });
  }

  // ========== HANDLERS DE MESSAGES ==========

  /// Gérer les messages reçus en premier plan
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
  if (kDebugMode) debugPrint(' Notification reçue (foreground): ${message.notification?.title}');

    // Afficher une notification locale
    await _showLocalNotification(
      title: message.notification?.title ?? 'Nouvelle notification',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  /// Gérer les messages qui ouvrent l'app
  void _handleBackgroundMessage(RemoteMessage message) {
    if (kDebugMode) debugPrint(' Notification ouverte (background): ${message.notification?.title}');

    if (onNotificationTap != null) {
      onNotificationTap!(message.data);
    }
  }

  // ========== AFFICHAGE NOTIFICATIONS ==========

  /// Afficher une notification locale
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'lebenis_driver_channel',
      'LeBenis Driver Notifications',
      channelDescription: 'Notifications pour l\'app livreur LeBenis',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond, // ID unique
      title,
      body,
      details,
      payload: payload,
    );
  }

  // ========== TOKEN FCM ==========

  /// Récupérer le token FCM de l'appareil
  Future<String?> getFcmToken() async {
    if (_fcm == null) return null;
    
    try {
      if (Platform.isIOS) {
        // Sur iOS, attendre l'autorisation avant de récupérer le token
        String? apnsToken = await _fcm!.getAPNSToken();
        if (apnsToken == null) {
          await Future.delayed(const Duration(seconds: 3));
        }
      }

      final token = await _fcm!.getToken();
        if (kDebugMode) debugPrint('🔑 FCM Token: $token');
      return token;
    } catch (e) {
        if (kDebugMode) debugPrint('❌ Erreur récupération FCM token: $e');
      return null;
    }
  }

  /// Écouter les changements de token FCM
  Stream<String> onTokenRefresh() {
    if (_fcm == null) return const Stream.empty();
    return _fcm!.onTokenRefresh;
  }

  // ========== TOPICS ==========

  /// S'abonner à un topic
  Future<void> subscribeToTopic(String topic) async {
    if (_fcm == null) return;
    await _fcm!.subscribeToTopic(topic);
    if (kDebugMode) debugPrint(' Abonné au topic: $topic');
  }

  /// Se désabonner d'un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (_fcm == null) return;
    await _fcm!.unsubscribeFromTopic(topic);
    if (kDebugMode) debugPrint('❌ Désabonné du topic: $topic');
  }

  // ========== BADGE ==========

  /// Réinitialiser le badge de notifications
  Future<void> clearBadge() async {
    if (_fcm == null) return;
    if (Platform.isIOS) {
      await _fcm!.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }
}

/// Handler pour les messages en arrière-plan (doit être une fonction top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) debugPrint(' Message reçu en arrière-plan: ${message.notification?.title}');
}
