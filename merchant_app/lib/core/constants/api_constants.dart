class ApiConstants {
  static const String baseUrl = 'https://lebenis-backend.onrender.com'; // URL backend de l'API
  static const String merchantProfile = '/api/v1/merchants/';
  static const String merchantStats = '/api/v1/merchants/my_stats/';
  static const String register = '/api/v1/auth/register/';
  static const String login = '/api/v1/auth/login/';
  static const String logout = '/api/v1/auth/logout/';
  static const String deliveries = '/api/v1/deliveries/';
  static const String pricingEstimate = '/api/v1/pricing/zones/calculate/';
  static const String cloudinaryUpload = '/api/v1/cloudinary/upload/';
  static const String notifications = '/api/v1/notifications/main/';
  static const String registerFcmToken = '/api/v1/auth/register-fcm-token/';
  static const String invoices = '/api/v1/payments/invoices/';
  // ... autres endpoints
}