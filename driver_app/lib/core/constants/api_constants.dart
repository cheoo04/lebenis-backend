// lib/core/constants/api_constants.dart

class ApiConstants {
  static const String baseUrl = 'https://lebenis-backend.onrender.com';

  // ========== AUTH ==========
  static const String login = '/api/v1/auth/login/';
  static const String logout = '/api/v1/auth/logout/';
  static const String register = '/api/v1/auth/register/';
  static const String me = '/api/v1/auth/me/';
  static const String refreshToken = '/api/v1/auth/token/refresh/';
  static const String passwordResetRequest = '/api/v1/auth/password-reset/request/';
  static const String passwordResetConfirm = '/api/v1/auth/password-reset/confirm/';
  static const String changePassword = '/api/v1/auth/change-password/';

  // ========== DRIVER ==========
  static const String driverProfile = '/api/v1/drivers/me/';
  static const String driverMe = '/api/v1/drivers/me/';
  static const String myDeliveries = '/api/v1/drivers/my-deliveries/';
  static const String availableDeliveries = '/api/v1/drivers/available-deliveries/';
  static const String driverEarnings = '/api/v1/drivers/me/earnings/'; // OLD - à remplacer par paymentMyEarnings
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
  static const String notificationHistory = '/api/v1/notifications/history/';
  static const String markNotificationAsRead = '/api/v1/notifications/mark-as-read/';
  static const String unreadNotificationsCount = '/api/v1/notifications/unread-count/';

  // ========== PAYMENTS (Phase 2) ==========
  static const String paymentMyEarnings = '/api/v1/payments/payments/my-earnings/';
  static const String paymentMyPayouts = '/api/v1/payments/payments/my-payouts/';
  static const String paymentStats = '/api/v1/payments/payments/stats/';
  static const String paymentTransactions = '/api/v1/payments/payments/transactions/';

  // ========== BREAK MANAGEMENT ==========
  static const String startBreak = '/api/v1/drivers/start-break/';
  static const String endBreak = '/api/v1/drivers/end-break/';
  static const String breakStatus = '/api/v1/drivers/break-status/';

  // ========== HEALTH CHECK ==========
  static const String healthCheck = '/health/';

  // ========== TIMEOUTS ==========
  static const Duration connectTimeout = Duration(seconds: 60); // Increased for Render free tier (cold start)
  static const Duration receiveTimeout = Duration(seconds: 60); // Increased for Render free tier (cold start)
}
