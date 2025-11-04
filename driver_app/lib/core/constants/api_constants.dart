// lib/core/constants/api_constants.dart

class ApiConstants {
  static const String baseUrl = 'https://lebenis-backend.onrender.com';

  // ========== AUTH ==========
  static const String login = '/api/v1/auth/login/';
  static const String logout = '/api/v1/auth/logout/';
  static const String register = '/api/v1/auth/register/';
  static const String me = '/api/v1/auth/me/';
  static const String refreshToken = '/api/v1/auth/token/refresh/';

  // ========== DRIVER ==========
  static const String driverProfile = '/api/v1/drivers/me/';
  static const String driverMe = '/api/v1/drivers/me/';
  static const String myDeliveries = '/api/v1/drivers/my-deliveries/';
  static const String availableDeliveries = '/api/v1/drivers/available-deliveries/';
  static const String myEarnings = '/api/v1/drivers/me/earnings/';
  static const String myStats = '/api/v1/drivers/my-stats/';
  static const String updateLocation = '/api/v1/drivers/update-location/';
  static const String toggleAvailability = '/api/v1/drivers/toggle-availability/';

  // ========== DELIVERIES ==========
  static const String deliveries = '/api/v1/deliveries/';
  static String deliveryDetails(String id) => '/api/v1/deliveries/$id/';
  static String acceptDelivery(String id) => '/api/v1/deliveries/$id/accept/';
  static String rejectDelivery(String id) => '/api/v1/deliveries/$id/reject/';
  static String confirmPickup(String id) => '/api/v1/deliveries/$id/confirm-pickup/';
  static String confirmDelivery(String id) => '/api/v1/deliveries/$id/confirm-delivery/';
  static String cancelDelivery(String id) => '/api/v1/deliveries/$id/cancel/';

  // ========== NOTIFICATIONS ==========
  static const String registerFcmToken = '/api/v1/notifications/register-token/';
  static const String unregisterFcmToken = '/api/v1/notifications/delete-token/';

  // ========== HEALTH CHECK ==========
  static const String healthCheck = '/health/';

  // ========== TIMEOUTS ==========
  static const Duration connectTimeout = Duration(seconds: 60); // Increased for Render free tier (cold start)
  static const Duration receiveTimeout = Duration(seconds: 60); // Increased for Render free tier (cold start)
}
