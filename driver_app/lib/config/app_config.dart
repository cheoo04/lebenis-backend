// lib/config/app_config.dart

class AppConfig {
  // App Information
  static const String appName = 'LeBeni Driver';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Company Information
  static const String companyName = 'LeBeni Groups';
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

  static const List<String> vehicleTypes = [
    'moto',
    'voiture',
    'camionnette',
  ];

  static const Map<String, String> vehicleTypeLabels = {
    'moto': 'Moto',
    'voiture': 'Voiture',
    'camionnette': 'Camionnette',
  };

  // Communes principales d'Abidjan (Côte d'Ivoire)
  static const List<String> communes = [
    'Abobo',
    'Adjamé',
    'Attécoubé',
    'Cocody',
    'Koumassi',
    'Marcory',
    'Plateau',
    'Port-Bouët',
    'Treichville',
    'Yopougon',
    'Bingerville',
    'Songon',
    'Anyama',
    'Grand-Bassam',
    'Dabou',
  ];

  // Status des livraisons
  static const Map<String, String> deliveryStatuses = {
    'pending': 'En attente',
    'assigned': 'Assignée',
    'accepted': 'Acceptée',
    'picked_up': 'Récupérée',
    'in_transit': 'En transit',
    'delivered': 'Livrée',
    'cancelled': 'Annulée',
    'failed': 'Échouée',
  };

  // Status de disponibilité livreur
  static const Map<String, String> availabilityStatuses = {
    'available': 'Disponible',
    'busy': 'Occupé',
    'offline': 'Hors ligne',
  };

  // Limites et contraintes
  static const int maxDeliveryDistance = 50; // km
  static const int minPasswordLength = 6;
  static const int maxUploadFileSizeMB = 10;
  static const int phoneNumberLength = 9; // Sénégal

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Format de téléphone
  static const String phonePattern = r'^\d{9}$';
  static const String phonePrefix = '+221';

  // Validation
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // Default values
  static const double defaultLatitude = 14.6928; // Dakar
  static const double defaultLongitude = -17.4467;
  static const double defaultMapZoom = 12.0;

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Debounce/Throttle
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration autoSaveDebounce = Duration(seconds: 2);
}
