import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Service pour tracker les événements Firebase Analytics
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(analytics: _analytics);

  /// Définir l'ID utilisateur pour le tracking
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
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
    try {
      if (userType != null) {
        await _analytics.setUserProperty(name: 'user_type', value: userType);
      }
      if (businessType != null) {
        await _analytics.setUserProperty(name: 'business_type', value: businessType);
      }
      if (city != null) {
        await _analytics.setUserProperty(name: 'city', value: city);
      }
      debugPrint('📊 Analytics: User properties set');
    } catch (e) {
      debugPrint('❌ Analytics error setting user properties: $e');
    }
  }

  /// Logger un événement de connexion
  Future<void> logLogin({String? method}) async {
    try {
      await _analytics.logLogin(loginMethod: method ?? 'email');
      debugPrint('📊 Analytics: Login logged');
    } catch (e) {
      debugPrint('❌ Analytics error logging login: $e');
    }
  }

  /// Logger un événement d'inscription
  Future<void> logSignUp({String? method}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method ?? 'email');
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
    try {
      await _analytics.logEvent(
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
    try {
      await _analytics.logEvent(
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
    try {
      await _analytics.logEvent(
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
    try {
      await _analytics.logEvent(
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
    try {
      await _analytics.logEvent(
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
    try {
      await _analytics.logEvent(
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
    try {
      await _analytics.logScreenView(
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
    try {
      await _analytics.logEvent(
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
