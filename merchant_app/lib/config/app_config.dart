// lib/config/app_config.dart

class AppConfig {
  // App Information
  static const String appName = 'LeBenis Merchant';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Company Information
  static const String companyName = 'LeBenis';
  static const String supportEmail = 'support@lebenis.sn';
  static const String supportPhone = '+221 77 123 45 67';

  // App Links
  static const String privacyPolicyUrl = 'https://lebenis.sn/privacy';
  static const String termsOfServiceUrl = 'https://lebenis.sn/terms';
  static const String websiteUrl = 'https://lebenis.sn';

  // Social Media
  static const String facebookUrl = 'https://facebook.com/lebenis';
  static const String instagramUrl = 'https://instagram.com/lebenis';
  static const String twitterUrl = 'https://twitter.com/lebenis';

  // Business Configuration
  static const String currency = 'FCFA';
  static const String locale = 'fr_CI'; // Français (Côte d'Ivoire)
  static const String timezone = 'Africa/Abidjan';

  // Delivery Configuration
  static const List<String> packageSizes = [
    'petit',
    'moyen',
    'grand',
    'tres_grand',
  ];

  static const Map<String, String> packageSizeLabels = {
    'petit': 'Petit (< 5 kg)',
    'moyen': 'Moyen (5-15 kg)',
    'grand': 'Grand (15-30 kg)',
    'tres_grand': 'Très Grand (> 30 kg)',
  };

  // ⚠️ Liste obsolète supprimée - utiliser l'API /api/v1/locations/communes/
  // Les communes sont maintenant gérées par le backend avec coordonnées GPS

  // Limites et contraintes
  static const int minPasswordLength = 6;
  static const int maxUploadFileSizeMB = 10;
  static const int phoneNumberLength = 8; // Côte d'Ivoire

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Format de téléphone
  static const String phonePattern = r'^\d{8}$';
  static const String phonePrefix = '+225';

  // Validation
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // Default values
  static const double defaultLatitude = 5.3486; // Abidjan
  static const double defaultLongitude = -4.0276;
  static const double defaultMapZoom = 12.0;

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Debounce/Throttle
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration autoSaveDebounce = Duration(seconds: 2);
}
