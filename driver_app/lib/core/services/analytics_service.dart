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
    String? vehicleType,
    String? city,
  }) async {
    try {
      if (userType != null) {
        await _analytics.setUserProperty(name: 'user_type', value: userType);
      }
      if (vehicleType != null) {
        await _analytics.setUserProperty(name: 'vehicle_type', value: vehicleType);
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

  /// Logger l'acceptation d'une livraison
  Future<void> logDeliveryAccepted({
    required String deliveryId,
    String? commune,
    double? distance,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'delivery_accepted',
        parameters: {
          'delivery_id': deliveryId,
          if (commune != null) 'commune': commune,
          if (distance != null) 'distance_km': distance,
        },
      );
      debugPrint('📊 Analytics: Delivery accepted logged');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Logger la complétion d'une livraison
  Future<void> logDeliveryCompleted({
    required String deliveryId,
    double? earnings,
    int? durationMinutes,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'delivery_completed',
        parameters: {
          'delivery_id': deliveryId,
          if (earnings != null) 'earnings_cfa': earnings,
          if (durationMinutes != null) 'duration_minutes': durationMinutes,
        },
      );
      debugPrint('📊 Analytics: Delivery completed logged');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Logger le refus d'une livraison
  Future<void> logDeliveryRejected({
    required String deliveryId,
    String? reason,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'delivery_rejected',
        parameters: {
          'delivery_id': deliveryId,
          if (reason != null) 'reason': reason,
        },
      );
      debugPrint('📊 Analytics: Delivery rejected logged');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Logger le changement de disponibilité
  Future<void> logAvailabilityChanged({required bool isAvailable}) async {
    try {
      await _analytics.logEvent(
        name: 'availability_changed',
        parameters: {
          'is_available': isAvailable,
        },
      );
      debugPrint('📊 Analytics: Availability changed to $isAvailable');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }

  /// Logger la mise à jour de position
  Future<void> logLocationUpdated({
    required double latitude,
    required double longitude,
  }) async {
    // Ne pas logger chaque mise à jour pour éviter trop d'événements
    // Peut être utilisé pour des mises à jour importantes uniquement
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

  /// Logger les gains journaliers
  Future<void> logDailyEarnings({
    required double amount,
    required int deliveryCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'daily_earnings',
        parameters: {
          'amount_cfa': amount,
          'delivery_count': deliveryCount,
        },
      );
      debugPrint('📊 Analytics: Daily earnings logged');
    } catch (e) {
      debugPrint('❌ Analytics error: $e');
    }
  }
}
