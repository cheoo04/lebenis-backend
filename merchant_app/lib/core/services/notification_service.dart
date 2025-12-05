import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/dio_client.dart';
import '../constants/api_constants.dart';

/// Service de gestion des notifications push Firebase pour Merchants
class NotificationService {
  FirebaseMessaging? _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final DioClient _dioClient;

  // Callback pour gérer la navigation
  Function(Map<String, dynamic>)? onNotificationTap;

  // Stockage du token FCM
  String? _fcmToken;

  NotificationService(this._dioClient);

  // ========== INITIALISATION ==========

  /// Initialiser le service de notifications (sans enregistrer le token)
  Future<void> initialize({bool firebaseEnabled = true}) async {
    if (!firebaseEnabled) {
      if (kDebugMode) {
        debugPrint('💡 Firebase non disponible sur cette plateforme');
      }
      return;
    }

    try {
      _fcm = FirebaseMessaging.instance;
      await _requestPermissions();
      await _initializeLocalNotifications();
      _configureFirebaseHandlers();
      // Ne pas enregistrer le token ici car l'utilisateur n'est pas authentifié
      // Le token sera enregistré après login via registerTokenAfterLogin()
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Erreur initialisation NotificationService: $e');
      }
    }
  }

  /// Enregistrer le token FCM après connexion réussie
  Future<void> registerTokenAfterLogin() async {
    if (_fcm == null) {
      if (kDebugMode) {
        debugPrint('⚠️ Firebase Messaging non initialisé');
      }
      return;
    }
    
    try {
      await _registerToken();
      if (kDebugMode) {
        debugPrint('✅ Token FCM enregistré après connexion');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur enregistrement token après connexion: $e');
      }
    }
  }

  /// Demander les permissions de notifications
  Future<void> _requestPermissions() async {
    if (_fcm == null) return;

    NotificationSettings settings = await _fcm!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ Permissions notifications accordées');
      } else {
        debugPrint('❌ Permissions notifications refusées');
      }
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
      try {
        final data = jsonDecode(details.payload!);
        onNotificationTap!(data);
      } catch (e) {
        if (kDebugMode) debugPrint('❌ Erreur parsing payload: $e');
      }
    }
  }

  /// Configurer les handlers Firebase
  void _configureFirebaseHandlers() {
    if (_fcm == null) return;

    // App en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // App en background - tap sur notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

    // App complètement fermée - tap sur notification
    _fcm!.getInitialMessage().then((message) {
      if (message != null) {
        _handleBackgroundMessageTap(message);
      }
    });

    // Rafraîchissement du token
    _fcm!.onTokenRefresh.listen(_handleTokenRefresh);
  }

  /// Handler pour messages en foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (kDebugMode) {
      debugPrint('📩 Notification reçue (foreground): ${message.notification?.title}');
    }

    // Afficher notification locale
    await _showLocalNotification(
      title: message.notification?.title ?? 'LeBeni\'s',
      body: message.notification?.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  /// Handler pour tap sur notification (background)
  void _handleBackgroundMessageTap(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('👆 Tap sur notification: ${message.data}');
    }

    if (onNotificationTap != null) {
      onNotificationTap!(message.data);
    }
  }

  /// Handler pour rafraîchissement du token
  Future<void> _handleTokenRefresh(String newToken) async {
    if (kDebugMode) {
      debugPrint('🔄 Token FCM rafraîchi');
    }
    _fcmToken = newToken;
    await _registerToken();
  }

  // ========== GESTION DES TOKENS ==========

  /// Enregistrer le token FCM sur le backend
  Future<void> _registerToken() async {
    if (_fcm == null) return;

    try {
      final token = await _fcm!.getToken();
      if (token == null) return;

      _fcmToken = token;

      await _dioClient.post(
        ApiConstants.registerFcmToken,
        data: {
          'token': token,
          'platform': _getPlatform(),
        },
      );

      if (kDebugMode) {
        debugPrint('✅ Token FCM enregistré: ${token.substring(0, 20)}...');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur enregistrement token: $e');
      }
    }
  }

  /// Supprimer le token FCM du backend
  Future<void> unregisterToken() async {
    if (_fcmToken == null) return;

    try {
      await _dioClient.post(
        '${ApiConstants.notifications}delete-token/',
        data: {'token': _fcmToken},
      );

      if (kDebugMode) {
        debugPrint('✅ Token FCM supprimé');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur suppression token: $e');
      }
    }
  }

  // ========== NOTIFICATIONS LOCALES ==========

  /// Afficher une notification locale
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'merchant_channel',
      'Merchant Notifications',
      channelDescription: 'Notifications pour les merchants',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
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
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Afficher une notification manuelle (pour tests)
  Future<void> showNotification(String title, String body) async {
    await _showLocalNotification(title: title, body: body);
  }

  // ========== UTILITAIRES ==========

  String _getPlatform() {
    if (defaultTargetPlatform == TargetPlatform.android) return 'android';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    return 'web';
  }

  /// Obtenir le token FCM actuel
  String? get fcmToken => _fcmToken;
}
