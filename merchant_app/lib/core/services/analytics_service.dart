import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Service pour tracker les événements Firebase Analytics
/// Compatible avec les plateformes qui ne supportent pas Firebase
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Vérifier si la plateforme supporte Firebase
  static bool get isSupported {
    return !kIsWeb && 
        (defaultTargetPlatform == TargetPlatform.android || 
         defaultTargetPlatform == TargetPlatform.iOS);
  }

  // Analytics instance - null si non supporté
  FirebaseAnalytics? get _analytics {
    if (!isSupported) return null;
    try {
      return FirebaseAnalytics.instance;
    } catch (e) {
      debugPrint('⚠️ Firebase Analytics not available: $e');
      return null;
    }
  }
  
  /// Observer pour la navigation - retourne un mock si Firebase non disponible
  NavigatorObserver get observer {
    if (!isSupported || _analytics == null) {
      return _NoOpNavigatorObserver();
    }
    return FirebaseAnalyticsObserver(analytics: _analytics!);
  }

  /// Définir l'ID utilisateur pour le tracking
  Future<void> setUserId(String? userId) async {
    if (_analytics == null) return;
    try {
      await _analytics!.setUserId(id: userId);
      debugPrint('📊 Analytics: User ID set to $userId');
    } catch (e) {
      debugPrint('❌ Analytics error setting user ID: $e');
    }
  }

  /// Définir les propriétés utilisateur
  Future<void> setUserProperties({
    String? userType,
    String? businessType,
    String? city,
  }) async {
    if (_analytics == null) return;
    try {
      if (userType != null) {
        await _analytics!.setUserProperty(name: 'user_type', value: userType);
      }
      if (businessType != null) {
        await _analytics!.setUserProperty(name: 'business_type', value: businessType);
      }
      if (city != null) {
        await _analytics!.setUserProperty(name: 'city', value: city);
      }
      debugPrint('📊 Analytics: User properties set');
    } catch (e) {
      debugPrint('❌ Analytics error setting user properties: $e');
    }
  }

  /// Logger un événement de connexion
  Future<void> logLogin({String? method}) async {
    if (_analytics == null) return;
    try {
      await _analytics!.logLogin(loginMethod: method ?? 'email');
      debugPrint('📊 Analytics: Login logged');
    } catch (e) {
      debugPrint('❌ Analytics error logging login: $e');
    }
  }

  /// Logger un événement d'inscription
  Future<void> logSignUp({String? method}) async {
    if (_analytics == null) return;
    try {
      await _analytics!.logSignUp(signUpMethod: method ?? 'email');
      debugPrint('📊 Analytics: Sign up logged');
    } catch (e) {
      debugPrint('❌ Analytics error logging sign up: $e');
    }
  }

  /// Logger la création d'une livraison
  Future<void> logDeliveryCreated({
    required String deliveryId,
    String? pickupCommune,
    String? deliveryCommune,
    double? price,
    double? weight,
  }) async {
    if (_analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: 'delivery_created',
        parameters: {
          'delivery_id': deliveryId,
          if (pickupCommune != null) 'pickup_commune': pickupCommune,
          if (deliveryCommune != null) 'delivery_commune': deliveryCommune,
          if (price != null) 'price_cfa': price,
          if (weight != null) 'weight_kg': weight,
        },
      );
      debugPrint('📊 Analytics: Delivery created logged');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Logger la livraison assignée
  Future<void> logDeliveryAssigned({
    required String deliveryId,
  }) async {
    if (_analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: 'delivery_assigned',
        parameters: {
          'delivery_id': deliveryId,
        },
      );
      debugPrint('📊 Analytics: Delivery assigned logged');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Logger la livraison complétée
  Future<void> logDeliveryCompleted({
    required String deliveryId,
    double? price,
    int? durationMinutes,
  }) async {
    if (_analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: 'delivery_completed',
        parameters: {
          'delivery_id': deliveryId,
          if (price != null) 'price_cfa': price,
          if (durationMinutes != null) 'duration_minutes': durationMinutes,
        },
      );
      debugPrint('📊 Analytics: Delivery completed logged');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Logger l'annulation d'une livraison
  Future<void> logDeliveryCancelled({
    required String deliveryId,
    String? reason,
  }) async {
    if (_analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: 'delivery_cancelled',
        parameters: {
          'delivery_id': deliveryId,
          if (reason != null) 'reason': reason,
        },
      );
      debugPrint('📊 Analytics: Delivery cancelled logged');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Logger un paiement
  Future<void> logPayment({
    required double amount,
    required String method,
    String? deliveryId,
  }) async {
    if (_analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: 'payment_made',
        parameters: {
          'amount_cfa': amount,
          'payment_method': method,
          if (deliveryId != null) 'delivery_id': deliveryId,
        },
      );
      debugPrint('📊 Analytics: Payment logged');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Logger un événement personnalisé
  Future<void> logCustomEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (_analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: name,
        parameters: parameters,
      );
      debugPrint('📊 Analytics: Custom event "$name" logged');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Logger la navigation vers un écran
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (_analytics == null) return;
    try {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      debugPrint('📊 Analytics: Screen view "$screenName" logged');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Logger les statistiques mensuelles
  Future<void> logMonthlyStats({
    required int deliveryCount,
    required double totalRevenue,
  }) async {
    if (_analytics == null) return;
    try {
      await _analytics!.logEvent(
        name: 'monthly_stats',
        parameters: {
          'delivery_count': deliveryCount,
          'total_revenue_cfa': totalRevenue,
        },
      );
      debugPrint('📊 Analytics: Monthly stats logged');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }
}

/// Observer vide pour les plateformes non supportées
class _NoOpNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {}
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {}
  
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {}
  
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {}
}
