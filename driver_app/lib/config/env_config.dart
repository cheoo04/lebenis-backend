// lib/config/env_config.dart

/// Configuration des environnements (dev/production)
/// Utilise cette classe pour gérer les différentes URLs selon l'environnement
class EnvConfig {
  /// Environnement actuel
  static const Environment current = Environment.development;
  
  /// URL de base selon l'environnement
  static String get baseUrl {
    switch (current) {
      case Environment.development:
        return 'http://127.0.0.1:8000'; // Pour tests locaux
      case Environment.staging:
        return 'https://staging-backend.com'; // Si vous avez un staging
      case Environment.production:
        return 'https://lebenis-backend.onrender.com'; // Production
    }
  }
  
  /// Mode debug activé
  static bool get isDebug => current == Environment.development;
  
  /// Timeout pour les requêtes réseau
  static Duration get connectTimeout => const Duration(seconds: 30);
  static Duration get receiveTimeout => const Duration(seconds: 30);
}

/// Énumération des environnements disponibles
enum Environment {
  development,
  staging,
  production,
}
