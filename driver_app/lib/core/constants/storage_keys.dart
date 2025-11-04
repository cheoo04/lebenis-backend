// lib/core/constants/storage_keys.dart

/// Clés pour le stockage sécurisé (flutter_secure_storage)
/// Ces clés sont utilisées pour sauvegarder les données sensibles localement
class StorageKeys {
  // ========== AUTHENTIFICATION ==========
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  
  // ========== UTILISATEUR ==========
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userType = 'user_type';
  static const String userName = 'user_name';
  
  // ========== DRIVER ==========
  static const String driverId = 'driver_id';
  static const String driverPhone = 'driver_phone';
  static const String vehicleType = 'vehicle_type';
  static const String availabilityStatus = 'availability_status';
  
  // ========== NOTIFICATIONS ==========
  static const String fcmToken = 'fcm_token';
  static const String notificationsEnabled = 'notifications_enabled';
  
  // ========== SETTINGS ==========
  static const String isFirstLaunch = 'is_first_launch';
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String language = 'language';
  
  // ========== LOCATION ==========
  static const String lastKnownLat = 'last_known_lat';
  static const String lastKnownLng = 'last_known_lng';
}
