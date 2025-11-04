# Guide d'Intégration API - LeBeni's Backend

> **Production URL**: `https://lebenis-backend.onrender.com`  
> **Version**: 1.0.0  
> **Dernière mise à jour**: 3 novembre 2025

## 📋 Table des Matières

1. [Architecture Recommandée](#architecture-recommandée)
2. [Configuration Initiale](#configuration-initiale)
3. [Authentification JWT](#authentification-jwt)
4. [API Endpoints](#api-endpoints)
5. [Notifications Push](#notifications-push)
6. [Géolocalisation Temps Réel](#géolocalisation-temps-réel)
7. [Upload de Fichiers](#upload-de-fichiers)
8. [Gestion d'État](#gestion-détat)
9. [Best Practices](#best-practices)

---

## ⚠️ Codes HTTP & Gestion d'Erreurs

### Codes de Statut HTTP

Le backend LeBeni's utilise les codes HTTP standards :

| Code | Signification | Action Flutter |
|------|---------------|----------------|
| **200 OK** | Requête réussie | Traiter les données normalement |
| **201 Created** | Ressource créée | Afficher message de succès |
| **400 Bad Request** | Données invalides | Afficher erreurs de validation |
| **401 Unauthorized** | Token expiré/invalide | Rafraîchir token ou déconnecter |
| **403 Forbidden** | Accès refusé | Rediriger vers page d'erreur |
| **404 Not Found** | Ressource introuvable | Afficher message "non trouvé" |
| **500 Server Error** | Erreur serveur | Afficher "Réessayez plus tard" |

### Gestion Centralisée des Erreurs

```dart
// lib/core/network/api_exception.dart
import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, [this.statusCode, this.errors]);

  static ApiException fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Connexion trop lente. Vérifiez votre réseau.',
          null,
        );
        
      case DioExceptionType.connectionError:
        return ApiException('Pas de connexion internet', null);
        
      case DioExceptionType.badCertificate:
        return ApiException('Erreur de certificat SSL', null);
        
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        
        // Extraire le message d'erreur du backend
        String message = 'Erreur serveur';
        Map<String, dynamic>? errors;
        
        if (data is Map<String, dynamic>) {
          // Format standard Django REST Framework
          if (data.containsKey('detail')) {
            message = data['detail'].toString();
          } else if (data.containsKey('message')) {
            message = data['message'].toString();
          } else if (data.containsKey('error')) {
            message = data['error'].toString();
          } else {
            // Erreurs de validation (champs)
            errors = data;
            final errorMessages = <String>[];
            data.forEach((key, value) {
              if (value is List) {
                errorMessages.add('$key: ${value.join(", ")}');
              } else {
                errorMessages.add('$key: $value');
              }
            });
            message = errorMessages.join('\n');
          }
        }
        
        // Messages personnalisés selon le code
        switch (statusCode) {
          case 400:
            return ApiException(
              errors != null ? message : 'Données invalides',
              statusCode,
              errors,
            );
          case 401:
            return ApiException('Session expirée. Reconnectez-vous.', statusCode);
          case 403:
            return ApiException('Accès refusé', statusCode);
          case 404:
            return ApiException('Ressource introuvable', statusCode);
          case 500:
          case 502:
          case 503:
            return ApiException('Erreur serveur. Réessayez plus tard.', statusCode);
          default:
            return ApiException(message, statusCode, errors);
        }
        
      case DioExceptionType.cancel:
        return ApiException('Requête annulée', null);
        
      default:
        return ApiException('Erreur réseau inattendue', null);
    }
  }

  @override
  String toString() => message;
  
  // Helper pour afficher dans un SnackBar
  void showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: statusCode != null && statusCode! >= 500
            ? Colors.red.shade700
            : Colors.orange.shade700,
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
```

---

## 🏗️ Architecture Recommandée

### Structure du Projet Flutter

> **✨ MISE À JOUR v2.1.0** : Structure harmonisée avec FLUTTER_STRUCTURE_GUIDE.md  
> Architecture **Feature-First** pour meilleure scalabilité

```
lib/
├── config/                           # Configuration environnement
│   ├── env_config.dart               # Dev/Prod environments
│   └── app_config.dart               # Configuration globale
│
├── core/                             # Infrastructure réutilisable
│   ├── constants/
│   │   ├── api_constants.dart        # URLs, endpoints
│   │   ├── app_colors.dart           # Palette couleurs
│   │   ├── app_strings.dart          # Textes français
│   │   └── storage_keys.dart         # Clés SecureStorage
│   ├── network/
│   │   ├── dio_client.dart           # Client HTTP configuré
│   │   └── api_exception.dart        # Gestion erreurs
│   ├── routes/
│   │   └── app_router.dart           # Navigation
│   ├── services/
│   │   ├── auth_service.dart         # JWT storage & refresh
│   │   ├── notification_service.dart # FCM handling
│   │   ├── location_service.dart     # GPS tracking
│   │   └── upload_service.dart       # Upload fichiers
│   └── utils/
│       ├── validators.dart
│       ├── formatters.dart
│       └── helpers.dart
│
├── data/                             # Couche données
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── delivery_model.dart
│   │   ├── driver_model.dart
│   │   ├── merchant_model.dart
│   │   └── pricing_estimate.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── delivery_repository.dart
│   │   ├── driver_repository.dart
│   │   └── merchant_repository.dart
│   └── providers/                    # State management
│       ├── auth_provider.dart
│       ├── delivery_provider.dart
│       ├── merchant_provider.dart
│       └── location_provider.dart
│
├── features/                         # Organisation par domaine métier
│   ├── auth/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── login_screen.dart
│   │       │   ├── register_screen.dart
│   │       │   └── splash_screen.dart
│   │       └── widgets/
│   │           ├── login_form.dart
│   │           └── register_form.dart
│   │
│   ├── deliveries/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── create_delivery_screen.dart
│   │       │   ├── delivery_list_screen.dart
│   │       │   ├── delivery_details_screen.dart
│   │       │   ├── track_delivery_screen.dart
│   │       │   ├── active_delivery_screen.dart    # Livreur
│   │       │   └── confirm_delivery_screen.dart   # Livreur
│   │       └── widgets/
│   │           ├── delivery_card.dart
│   │           ├── status_badge.dart
│   │           ├── price_estimator.dart
│   │           └── delivery_map.dart
│   │
│   ├── dashboard/                    # Marchand only
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── dashboard_screen.dart
│   │       └── widgets/
│   │           ├── stats_overview.dart
│   │           └── quick_actions.dart
│   │
│   ├── earnings/                     # Livreur only
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── earnings_screen.dart
│   │       └── widgets/
│   │           ├── earnings_chart.dart
│   │           └── stats_card.dart
│   │
│   ├── profile/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── profile_screen.dart
│   │       │   └── edit_profile_screen.dart
│   │       └── widgets/
│   │           ├── availability_toggle.dart      # Livreur
│   │           └── verification_status.dart      # Marchand
│   │
│   └── scanner/                      # Livreur only
│       └── presentation/
│           └── screens/
│               └── qr_scanner_screen.dart
│
├── l10n/                             # Internationalisation
│   ├── app_fr.arb                    # Français (langue principale)
│   └── app_en.arb                    # Anglais (optionnel)
│
├── theme/                            # Thème personnalisé
│   ├── app_theme.dart                # ThemeData complet
│   ├── text_styles.dart              # Styles de texte
│   └── dimensions.dart               # Espacements, tailles
│
├── shared/                           # Widgets réutilisables
│   └── widgets/
│       ├── custom_button.dart
│       ├── custom_textfield.dart
│       ├── error_widget.dart
│       ├── loading_widget.dart
│       ├── empty_state.dart
│       ├── commune_dropdown.dart
│       └── network_image_cached.dart
│
└── main.dart
```

### Avantages de cette Architecture

✅ **Feature-First** : Chaque domaine métier est isolé  
✅ **Scalable** : Facile d'ajouter de nouvelles features  
✅ **Maintenable** : Code organisé par contexte métier  
✅ **Testable** : Tests par feature indépendants  
✅ **Réutilisable** : `core/` et `shared/` partagés

### Packages Flutter Recommandés

```yaml
dependencies:
  # HTTP & Networking
  dio: ^5.3.3
  
  # Storage sécurisé
  flutter_secure_storage: ^9.0.0
  
  # State Management
  riverpod: ^2.4.9                   # RECOMMANDÉ
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  
  # Géolocalisation
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  
  # Cartes
  google_maps_flutter: ^2.5.0
  # OU
  flutter_map: ^6.1.0
  
  # Images & Médias
  image_picker: ^1.0.4
  
  # Signature
  signature: ^5.4.1
  
  # Permissions
  permission_handler: ^11.1.0
  
  # Utilitaires
  device_info_plus: ^9.1.0           # Version Android
  intl: ^0.18.1                       # Formatage i18n
```

---

## ⚙️ Configuration Initiale

### 1. Constants API

```dart
// lib/core/constants/api_constants.dart
class ApiConstants {
  // Base URL
  static const String baseUrl = 'https://lebenis-backend.onrender.com';
  
  // Auth Endpoints
  static const String register = '/api/v1/auth/register/';
  static const String login = '/api/v1/auth/login/';
  static const String refresh = '/api/v1/auth/token/refresh/';
  static const String logout = '/api/v1/auth/logout/';
  
  // Merchant Endpoints
  static const String merchantProfile = '/api/v1/merchants/profile/';
  static const String merchantDeliveries = '/api/v1/merchants/deliveries/';
  
  // Driver Endpoints
  static const String driverProfile = '/api/v1/drivers/profile/';
  static const String driverLocation = '/api/v1/drivers/me/location/';
  static const String driverAvailability = '/api/v1/drivers/me/availability/';
  
  // Delivery Endpoints
  static const String deliveries = '/api/v1/deliveries/';
  static const String pricingEstimate = '/api/v1/pricing/estimate/';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

### 2. Client Dio avec Intercepteurs

```dart
// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../services/auth_service.dart';
import 'api_exception.dart';

class DioClient {
  late final Dio _dio;
  final AuthService _authService;

  DioClient(this._authService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          // Accepter tous les codes pour les gérer manuellement
          return status != null && status < 500;
        },
      ),
    );

    // Intercepteurs
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
        onResponse: _onResponse,
      ),
    );

    // Logs en développement
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ));
    }
  }

  // Ajouter le token JWT à chaque requête
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _authService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // Gérer automatiquement le refresh des tokens expirés
  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401) {
      // Éviter les boucles infinies de refresh
      final requestPath = error.requestOptions.path;
      if (requestPath.contains('/token/refresh')) {
        // Le refresh lui-même a échoué → déconnexion
        await _authService.logout();
        return handler.next(error);
      }

      try {
        // Tenter de rafraîchir le token
        final newToken = await _authService.refreshAccessToken();
        
        if (newToken != null) {
          // Réessayer la requête avec le nouveau token
          error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final response = await _dio.fetch(error.requestOptions);
          return handler.resolve(response);
        }
      } catch (e) {
        // Échec du refresh → déconnexion
        await _authService.logout();
      }
    }
    
    handler.next(error);
  }

  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    // Vérifier les erreurs côté métier (code 200 mais erreur dans le body)
    if (response.data is Map && response.data.containsKey('error')) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        ),
      );
      return;
    }
    
    handler.next(response);
  }

  // Méthodes publiques
  Dio get dio => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        options: options,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // Upload avec progression
  Future<Response> upload(
    String path, {
    required FormData data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        onSendProgress: onSendProgress,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
```

### 3. Gestion des Erreurs API

```dart
// lib/core/network/api_exception.dart
import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  static ApiException fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Délai de connexion dépassé', null);
        
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        
        String message = 'Erreur serveur';
        if (data is Map<String, dynamic>) {
          message = data['detail'] ?? 
                   data['message'] ?? 
                   data['error'] ?? 
                   message;
        }
        
        return ApiException(message, statusCode);
        
      case DioExceptionType.cancel:
        return ApiException('Requête annulée', null);
        
      case DioExceptionType.badCertificate:
        return ApiException('Erreur de certificat SSL', null);
        
      default:
        return ApiException(
          'Erreur de connexion. Vérifiez votre connexion internet.',
          null,
        );
    }
  }

  @override
  String toString() => message;
}
```

---

## 🔐 Authentification JWT

### Service d'Authentification

```dart
// lib/core/services/auth_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Clés de stockage
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userTypeKey = 'user_type';

  // Sauvegarder les tokens après login
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userType,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userTypeKey, value: userType);
  }

  // Récupérer le token d'accès
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  // Récupérer le refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  // Rafraîchir le token expiré
  Future<String?> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final dio = Dio();
      final response = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.refresh}',
        data: {'refresh': refreshToken},
      );

      final newAccessToken = response.data['access'];
      await _storage.write(key: _accessTokenKey, value: newAccessToken);
      
      return newAccessToken;
    } catch (e) {
      return null;
    }
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  // Récupérer le type d'utilisateur
  Future<String?> getUserType() async {
    return await _storage.read(key: _userTypeKey);
  }

  // Déconnexion
  Future<void> logout() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userTypeKey);
  }
}
```

### Repository d'Authentification

```dart
// lib/data/repositories/auth_repository.dart
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/auth_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DioClient _dioClient;
  final AuthService _authService;

  AuthRepository(this._dioClient, this._authService);

  // Inscription marchand
  Future<UserModel> registerMerchant({
    required String email,
    required String password,
    required String businessName,
    required String phone,
    required String address,
    String? registreCommercePath,
  }) async {
    final formData = FormData.fromMap({
      'email': email,
      'password': password,
      'business_name': businessName,
      'phone': phone,
      'address': address,
      'user_type': 'merchant',
      if (registreCommercePath != null)
        'registre_commerce': await MultipartFile.fromFile(
          registreCommercePath,
          filename: 'registre_commerce.pdf',
        ),
    });

    final response = await _dioClient.upload(
      ApiConstants.register,
      data: formData,
    );

    await _authService.saveTokens(
      accessToken: response.data['access'],
      refreshToken: response.data['refresh'],
      userType: 'merchant',
    );

    return UserModel.fromJson(response.data['user']);
  }

  // Inscription livreur
  Future<UserModel> registerDriver({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String vehicleType,
    String? permisConduirePath,
    String? carteGrisePath,
    String? photoPath,
  }) async {
    final formData = FormData.fromMap({
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'vehicle_type': vehicleType,
      'user_type': 'driver',
      if (permisConduirePath != null)
        'permis_conduire': await MultipartFile.fromFile(
          permisConduirePath,
          filename: 'permis.jpg',
        ),
      if (carteGrisePath != null)
        'carte_grise': await MultipartFile.fromFile(
          carteGrisePath,
          filename: 'carte_grise.jpg',
        ),
      if (photoPath != null)
        'photo': await MultipartFile.fromFile(
          photoPath,
          filename: 'photo.jpg',
        ),
    });

    final response = await _dioClient.upload(
      ApiConstants.register,
      data: formData,
    );

    await _authService.saveTokens(
      accessToken: response.data['access'],
      refreshToken: response.data['refresh'],
      userType: 'driver',
    );

    return UserModel.fromJson(response.data['user']);
  }

  // Connexion
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    await _authService.saveTokens(
      accessToken: response.data['access'],
      refreshToken: response.data['refresh'],
      userType: response.data['user_type'],
    );

    return UserModel.fromJson(response.data['user']);
  }

  // Déconnexion
  Future<void> logout() async {
    final refreshToken = await _authService.getRefreshToken();
    
    if (refreshToken != null) {
      try {
        await _dioClient.post(
          ApiConstants.logout,
          data: {'refresh': refreshToken},
        );
      } catch (e) {
        // Ignorer l'erreur, déconnexion locale de toute façon
        print('Erreur logout backend: $e');
      }
    }

    await _authService.logout();
  }

  // Vérifier le statut de connexion
  Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }

  // Récupérer le type d'utilisateur
  Future<String?> getUserType() async {
    return await _authService.getUserType();
  }
}
```

---

## 🚚 API Endpoints - App Marchand

### 1. Profil Marchand

```dart
// lib/data/repositories/merchant_repository.dart
class MerchantRepository {
  final DioClient _dioClient;

  MerchantRepository(this._dioClient);

  // Récupérer le profil
  Future<MerchantModel> getProfile() async {
    final response = await _dioClient.get(ApiConstants.merchantProfile);
    return MerchantModel.fromJson(response.data);
  }

  // Mettre à jour le profil
  Future<MerchantModel> updateProfile({
    String? businessName,
    String? phone,
    String? address,
  }) async {
    final response = await _dioClient.patch(
      ApiConstants.merchantProfile,
      data: {
        if (businessName != null) 'business_name': businessName,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
      },
    );
    return MerchantModel.fromJson(response.data);
  }
}
```

### 2. Gestion des Livraisons

```dart
// lib/data/repositories/delivery_repository.dart
import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/delivery_model.dart';
import '../models/pricing_estimate.dart';

class DeliveryRepository {
  final DioClient _dioClient;
  final Map<String, CachedData<DeliveryModel>> _cache = {};

  DeliveryRepository(this._dioClient);

  // Estimer le prix AVANT de créer la livraison
  Future<PricingEstimate> estimatePrice({
    required String pickupCommune,
    required String deliveryCommune,
    required String packageSize,
    bool isFragile = false,
    double? pickupLatitude,
    double? pickupLongitude,
    double? deliveryLatitude,
    double? deliveryLongitude,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.pricingEstimate,
      data: {
        'pickup_commune': pickupCommune,
        'delivery_commune': deliveryCommune,
        'package_size': packageSize,
        'is_fragile': isFragile,
        if (pickupLatitude != null) 'pickup_latitude': pickupLatitude,
        if (pickupLongitude != null) 'pickup_longitude': pickupLongitude,
        if (deliveryLatitude != null) 'delivery_latitude': deliveryLatitude,
        if (deliveryLongitude != null) 'delivery_longitude': deliveryLongitude,
      },
    );

    return PricingEstimate.fromJson(response.data);
  }

  // Créer une livraison
  Future<DeliveryModel> createDelivery({
    required String pickupAddress,
    required String pickupCommune,
    required double pickupLatitude,
    required double pickupLongitude,
    required String deliveryAddress,
    required String deliveryCommune,
    required double deliveryLatitude,
    required double deliveryLongitude,
    required String packageSize,
    required String recipientName,
    required String recipientPhone,
    String? packageDescription,
    String? notes,
    bool isFragile = false,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.deliveries,
      data: {
        'pickup_address': pickupAddress,
        'pickup_commune': pickupCommune,
        'pickup_latitude': pickupLatitude,
        'pickup_longitude': pickupLongitude,
        'delivery_address': deliveryAddress,
        'delivery_commune': deliveryCommune,
        'delivery_latitude': deliveryLatitude,
        'delivery_longitude': deliveryLongitude,
        'package_size': packageSize,
        'recipient_name': recipientName,
        'recipient_phone': recipientPhone,
        'is_fragile': isFragile,
        if (packageDescription != null) 'package_description': packageDescription,
        if (notes != null) 'notes': notes,
      },
    );

    final delivery = DeliveryModel.fromJson(response.data);
    _cache[delivery.id.toString()] = CachedData(delivery, const Duration(minutes: 5));
    return delivery;
  }

  // Assigner automatiquement un livreur disponible
  Future<DeliveryModel> assignDriver(
    String deliveryId, {
    double maxDistanceKm = 5.0,
    int maxAttempts = 3,
  }) async {
    final response = await _dioClient.post(
      '${ApiConstants.deliveries}$deliveryId/assign/',
      data: {
        'max_distance_km': maxDistanceKm,
        'max_attempts': maxAttempts,
      },
    );

    final delivery = DeliveryModel.fromJson(response.data);
    _cache[deliveryId] = CachedData(delivery, const Duration(minutes: 5));
    return delivery;
  }

  // Lister les livraisons avec filtres
  Future<List<DeliveryModel>> getDeliveries({
    String? status,
    String? search,
    String? ordering,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    
    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;
    if (ordering != null) queryParams['ordering'] = ordering;

    final response = await _dioClient.get(
      ApiConstants.merchantDeliveries,
      queryParameters: queryParams,
    );

    return (response.data['results'] as List)
        .map((json) => DeliveryModel.fromJson(json))
        .toList();
  }

  // Détails d'une livraison (avec cache 5 minutes)
  Future<DeliveryModel> getDeliveryDetails(String id) async {
    // Vérifier le cache
    if (_cache.containsKey(id) && !_cache[id]!.isExpired) {
      return _cache[id]!.data;
    }

    final response = await _dioClient.get('${ApiConstants.deliveries}$id/');
    final delivery = DeliveryModel.fromJson(response.data);

    // Mettre en cache pour 5 minutes
    _cache[id] = CachedData(delivery, const Duration(minutes: 5));

    return delivery;
  }

  // Annuler une livraison
  Future<DeliveryModel> cancelDelivery(String id, {String? reason}) async {
    final response = await _dioClient.post(
      '${ApiConstants.deliveries}$id/cancel/',
      data: reason != null ? {'reason': reason} : null,
    );

    _cache.remove(id); // Invalider le cache
    return DeliveryModel.fromJson(response.data);
  }

  // Rechercher des livraisons
  Future<List<DeliveryModel>> searchDeliveries(String query) async {
    return await getDeliveries(search: query);
  }

  // Vider le cache (à appeler lors du refresh)
  void clearCache() {
    _cache.clear();
  }

  // Invalider une entrée spécifique du cache
  void invalidateCache(String deliveryId) {
    _cache.remove(deliveryId);
  }
}

// Classe helper pour le cache
class CachedData<T> {
  final T data;
  final DateTime expiryTime;

  CachedData(this.data, Duration validity)
      : expiryTime = DateTime.now().add(validity);

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}
```

### Models de Données

```dart
// lib/data/models/pricing_estimate.dart
class PricingEstimate {
  final double basePrice;
  final double distancePrice;
  final double sizeMultiplier;
  final double fragileMultiplier;
  final double totalPrice;
  final double distance;
  final String breakdown;

  PricingEstimate({
    required this.basePrice,
    required this.distancePrice,
    required this.sizeMultiplier,
    required this.fragileMultiplier,
    required this.totalPrice,
    required this.distance,
    required this.breakdown,
  });

  factory PricingEstimate.fromJson(Map<String, dynamic> json) {
    return PricingEstimate(
      basePrice: (json['base_price'] ?? 0).toDouble(),
      distancePrice: (json['distance_price'] ?? 0).toDouble(),
      sizeMultiplier: (json['size_multiplier'] ?? 1).toDouble(),
      fragileMultiplier: (json['fragile_multiplier'] ?? 1).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      distance: (json['distance'] ?? 0).toDouble(),
      breakdown: json['breakdown'] ?? '',
    );
  }

  // Formater le prix en FCFA
  String get formattedPrice => '${totalPrice.toStringAsFixed(0)} FCFA';

  // Distance formattée
  String get formattedDistance => '${distance.toStringAsFixed(2)} km';
}

// lib/data/models/delivery_model.dart
import 'package:flutter/material.dart';

class DeliveryModel {
  final int id;
  final String trackingNumber;
  final String status;
  final String pickupAddress;
  final String pickupCommune;
  final double pickupLatitude;
  final double pickupLongitude;
  final String deliveryAddress;
  final String deliveryCommune;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final String packageSize;
  final String recipientName;
  final String recipientPhone;
  final String? packageDescription;
  final String? notes;
  final bool isFragile;
  final double price;
  final double distanceKm;
  final MerchantModel? merchant;
  final DriverModel? driver;
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? pickupTime;
  final DateTime? deliveryTime;
  final String? pickupPhoto;
  final String? deliveryPhoto;
  final String? signature;

  DeliveryModel({
    required this.id,
    required this.trackingNumber,
    required this.status,
    required this.pickupAddress,
    required this.pickupCommune,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.deliveryAddress,
    required this.deliveryCommune,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.packageSize,
    required this.recipientName,
    required this.recipientPhone,
    this.packageDescription,
    this.notes,
    required this.isFragile,
    required this.price,
    required this.distanceKm,
    this.merchant,
    this.driver,
    required this.createdAt,
    this.assignedAt,
    this.pickupTime,
    this.deliveryTime,
    this.pickupPhoto,
    this.deliveryPhoto,
    this.signature,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id'],
      trackingNumber: json['tracking_number'],
      status: json['status'],
      pickupAddress: json['pickup_address'],
      pickupCommune: json['pickup_commune'],
      pickupLatitude: json['pickup_latitude'].toDouble(),
      pickupLongitude: json['pickup_longitude'].toDouble(),
      deliveryAddress: json['delivery_address'],
      deliveryCommune: json['delivery_commune'] ?? '',
      deliveryLatitude: json['delivery_latitude'].toDouble(),
      deliveryLongitude: json['delivery_longitude'].toDouble(),
      packageSize: json['package_size'],
      recipientName: json['recipient_name'],
      recipientPhone: json['recipient_phone'],
      packageDescription: json['package_description'],
      notes: json['notes'],
      isFragile: json['is_fragile'] ?? false,
      price: json['price'].toDouble(),
      distanceKm: json['distance_km'].toDouble(),
      merchant: json['merchant'] != null
          ? MerchantModel.fromJson(json['merchant'])
          : null,
      driver: json['driver'] != null
          ? DriverModel.fromJson(json['driver'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'])
          : null,
      pickupTime: json['pickup_time'] != null
          ? DateTime.parse(json['pickup_time'])
          : null,
      deliveryTime: json['delivery_time'] != null
          ? DateTime.parse(json['delivery_time'])
          : null,
      pickupPhoto: json['pickup_photo'],
      deliveryPhoto: json['delivery_photo'],
      signature: json['signature'],
    );
  }

  // Helper pour afficher le statut en français
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'assigned':
        return 'Assigné';
      case 'accepted':
        return 'Accepté';
      case 'picked_up':
        return 'En cours';
      case 'in_transit':
        return 'En transit';
      case 'delivered':
        return 'Livré';
      case 'cancelled':
        return 'Annulé';
      case 'failed':
        return 'Échoué';
      default:
        return status;
    }
  }

  // Helper pour couleur du statut
  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
      case 'accepted':
        return Colors.blue;
      case 'picked_up':
      case 'in_transit':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper pour icône du statut
  IconData get statusIcon {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'assigned':
      case 'accepted':
        return Icons.person_pin;
      case 'picked_up':
        return Icons.local_shipping;
      case 'in_transit':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'failed':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  // Formater le prix
  String get formattedPrice => '${price.toStringAsFixed(0)} FCFA';

  // Formater la distance
  String get formattedDistance => '${distanceKm.toStringAsFixed(2)} km';

  // Date formatée
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return 'Il y a ${diff.inMinutes} min';
      }
      return 'Il y a ${diff.inHours}h';
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays} jours';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  // Vérifier si modifiable
  bool get canBeModified =>
      status == 'pending' || status == 'assigned';

  // Vérifier si annulable
  bool get canBeCancelled =>
      status != 'delivered' && status != 'cancelled' && status != 'failed';
}

// lib/data/models/merchant_model.dart
class MerchantModel {
  final int id;
  final String businessName;
  final String email;
  final String phone;
  final String address;
  final String verificationStatus;

  MerchantModel({
    required this.id,
    required this.businessName,
    required this.email,
    required this.phone,
    required this.address,
    required this.verificationStatus,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      id: json['id'],
      businessName: json['business_name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      verificationStatus: json['verification_status'] ?? 'pending',
    );
  }
}

// lib/data/models/driver_model.dart
class DriverModel {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String vehicleType;
  final String? photo;
  final String availabilityStatus;
  final double? currentLatitude;
  final double? currentLongitude;

  DriverModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.vehicleType,
    this.photo,
    required this.availabilityStatus,
    this.currentLatitude,
    this.currentLongitude,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      vehicleType: json['vehicle_type'],
      photo: json['photo'],
      availabilityStatus: json['availability_status'] ?? 'offline',
      currentLatitude: json['current_latitude']?.toDouble(),
      currentLongitude: json['current_longitude']?.toDouble(),
    );
  }

  String get fullName => '$firstName $lastName';

  bool get isAvailable => availabilityStatus == 'available';
}
```

---

## 🏍️ API Endpoints - App Livreur

### Repository Livreur

```dart
// lib/data/repositories/driver_repository.dart
class DriverRepository {
  final DioClient _dioClient;

  DriverRepository(this._dioClient);

  // Récupérer le profil
  Future<DriverModel> getProfile() async {
    final response = await _dioClient.get(ApiConstants.driverProfile);
    return DriverModel.fromJson(response.data);
  }

  // Mettre à jour la disponibilité
  Future<void> updateAvailability(String status) async {
    await _dioClient.patch(
      ApiConstants.driverAvailability,
      data: {'availability_status': status},
    );
  }

  // Mettre à jour la position GPS
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    await _dioClient.patch(
      ApiConstants.driverLocation,
      data: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  // Lister les courses assignées
  Future<List<DeliveryModel>> getMyDeliveries({String? status}) async {
    final response = await _dioClient.get(
      '/api/v1/drivers/me/deliveries/',
      queryParameters: status != null ? {'status': status} : null,
    );

    return (response.data['results'] as List)
        .map((json) => DeliveryModel.fromJson(json))
        .toList();
  }

  // Accepter une course
  Future<DeliveryModel> acceptDelivery(String deliveryId) async {
    final response = await _dioClient.post(
      '${ApiConstants.deliveries}$deliveryId/accept/',
    );
    return DeliveryModel.fromJson(response.data);
  }

  // Rejeter une course
  Future<void> rejectDelivery(String deliveryId) async {
    await _dioClient.post(
      '${ApiConstants.deliveries}$deliveryId/reject/',
    );
  }

  // Confirmer l'enlèvement avec photo
  Future<DeliveryModel> confirmPickup(
    String deliveryId,
    String photoPath,
  ) async {
    final formData = FormData.fromMap({
      'pickup_photo': await MultipartFile.fromFile(photoPath),
    });

    final response = await _dioClient.post(
      '${ApiConstants.deliveries}$deliveryId/confirm-pickup/',
      data: formData,
    );

    return DeliveryModel.fromJson(response.data);
  }

  // Confirmer la livraison avec signature et photo
  Future<DeliveryModel> confirmDelivery(
    String deliveryId,
    String signaturePath,
    String deliveryPhotoPath,
  ) async {
    final formData = FormData.fromMap({
      'signature': await MultipartFile.fromFile(signaturePath),
      'delivery_photo': await MultipartFile.fromFile(deliveryPhotoPath),
    });

    final response = await _dioClient.post(
      '${ApiConstants.deliveries}$deliveryId/confirm-delivery/',
      data: formData,
    );

    return DeliveryModel.fromJson(response.data);
  }
}
```

---

## 🔔 Notifications Push (FCM)

### Service de Notifications

```dart
// lib/core/services/notification_service.dart
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final DioClient _dioClient;

  NotificationService(this._dioClient);

  // Initialisation complète
  Future<void> initialize() async {
    // 1. Demander les permissions
    await _requestPermissions();

    // 2. Configurer les notifications locales
    await _setupLocalNotifications();

    // 3. Configurer les handlers FCM
    await _setupNotificationHandlers();

    // 4. Obtenir et enregistrer le token
    final token = await _fcm.getToken();
    if (token != null) {
      await _registerTokenWithBackend(token);
    }

    // 5. Écouter les rafraîchissements de token
    _fcm.onTokenRefresh.listen(_registerTokenWithBackend);
  }

  // Demander les permissions (Android 13+ et iOS)
  Future<void> _requestPermissions() async {
    // Android 13+ nécessite permission explicite
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        await Permission.notification.request();
      }
    }

    // iOS permissions
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  // Configuration des notifications locales
  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  // Configuration des handlers FCM
  Future<void> _setupNotificationHandlers() async {
    // App en FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // App en BACKGROUND (notification cliquée)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message.data);
    });

    // App TERMINÉE (lancée via notification)
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data);
    }
  }

  // Afficher une notification locale
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'lebenis_channel',
      'LeBenis Notifications',
      channelDescription: 'Notifications de livraison',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails();

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: message.data['delivery_id'],
    );
  }

  // Gérer le clic sur notification
  void _handleNotificationTap(Map<String, dynamic> data) {
    final deliveryId = data['delivery_id'];
    if (deliveryId != null) {
      // Navigation vers l'écran de détails
      navigatorKey.currentState?.pushNamed(
        '/delivery-details',
        arguments: deliveryId,
      );
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      navigatorKey.currentState?.pushNamed(
        '/delivery-details',
        arguments: response.payload,
      );
    }
  }

  // Enregistrer le token FCM auprès du backend
  Future<void> _registerTokenWithBackend(String token) async {
    try {
      await _dioClient.post(
        '/api/v1/notifications/register/',
        data: {'fcm_token': token},
      );
    } catch (e) {
      print('Erreur enregistrement FCM token: $e');
    }
  }

  // Supprimer le token au logout
  Future<void> unregisterToken() async {
    final token = await _fcm.getToken();
    if (token != null) {
      try {
        await _dioClient.post(
          '/api/v1/notifications/unregister/',
          data: {'fcm_token': token},
        );
      } catch (e) {
        print('Erreur suppression FCM token: $e');
      }
    }
  }
}

// GlobalKey pour la navigation depuis n'importe où
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
```

### Configuration Firebase

**Android (AndroidManifest.xml)**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/> <!-- Android 13+ -->

    <application ...>
        <!-- Service FCM -->
        <service
            android:name="com.google.firebase.messaging.FirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>

        <!-- Canal de notification par défaut -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="lebenis_channel" />
    </application>
</manifest>
```

**iOS (Info.plist)**
```xml
<dict>
    <!-- Background modes pour notifications -->
    <key>UIBackgroundModes</key>
    <array>
        <string>fetch</string>
        <string>remote-notification</string>
    </array>
    
    <!-- Permission pour notifications -->
    <key>NSUserNotificationsUsageDescription</key>
    <string>Recevoir les notifications de livraison</string>
</dict>
```

**Initialisation dans main.dart**
```dart
// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// Handler pour notifications en background (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configurer le handler background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialiser le service de notifications
  final authService = AuthService();
  final dioClient = DioClient(authService);
  final notificationService = NotificationService(dioClient);
  await notificationService.initialize();

  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LeBenis',
      navigatorKey: navigatorKey,
      // ... reste de la configuration
    );
  }
}
```

---

## 📍 Géolocalisation Temps Réel

### Service de Localisation GPS

```dart
// lib/core/services/location_service.dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../network/dio_client.dart';
import '../constants/api_constants.dart';

class LocationService {
  final DioClient _dioClient;
  Timer? _updateTimer;
  StreamSubscription<Position>? _positionStream;

  LocationService(this._dioClient);

  // Vérifier et demander les permissions
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Vérifier si le GPS est activé
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Obtenir la position actuelle
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  // Démarrer le tracking GPS (pour livreur en course)
  void startTracking() {
    // Mise à jour toutes les 30 secondes pour économiser la batterie
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      try {
        final position = await getCurrentPosition();
        await _updateBackendLocation(position);
      } catch (e) {
        print('Erreur mise à jour position: $e');
      }
    });
  }

  // Arrêter le tracking GPS
  void stopTracking() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  // Envoyer la position au backend
  Future<void> _updateBackendLocation(Position position) async {
    try {
      await _dioClient.patch(
        ApiConstants.driverLocation,
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      );
    } catch (e) {
      print('Erreur envoi position au backend: $e');
    }
  }

  // Calculer la distance entre deux points
  double calculateDistance(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    return Geolocator.distanceBetween(
      startLat,
      startLon,
      endLat,
      endLon,
    ) / 1000; // Convertir en km
  }

  // Nettoyage
  void dispose() {
    stopTracking();
    _positionStream?.cancel();
  }
}
```

### Utilisation dans l'app Livreur

```dart
// lib/features/deliveries/presentation/screens/active_delivery_screen.dart
class ActiveDeliveryScreen extends ConsumerStatefulWidget {
  final String deliveryId;

  const ActiveDeliveryScreen({required this.deliveryId});

  @override
  ConsumerState<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends ConsumerState<ActiveDeliveryScreen> {
  late final LocationService _locationService;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService(ref.read(dioClientProvider));
    
    // Démarrer le tracking quand le livreur accepte la course
    _startTracking();
  }

  Future<void> _startTracking() async {
    final hasPermission = await _locationService.requestLocationPermission();
    if (hasPermission) {
      _locationService.startTracking();
    }
  }

  @override
  void dispose() {
    _locationService.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Course en cours')),
      body: Column(
        children: [
          // Carte avec position en temps réel
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(5.3599, -4.0083), // Abidjan
                zoom: 12,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          
          // Actions
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _confirmPickup,
                  child: Text('Confirmer l\'enlèvement'),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _confirmDelivery,
                  child: Text('Confirmer la livraison'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPickup() async {
    // Prendre une photo
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      final repository = ref.read(driverRepositoryProvider);
      await repository.confirmPickup(widget.deliveryId, image.path);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enlèvement confirmé !')),
      );
    }
  }

  Future<void> _confirmDelivery() async {
    // Capturer la signature + photo
    // ... (voir section Upload de Fichiers)
  }
}
```

---

## 📤 Upload de Fichiers

### Service d'Upload

```dart
// lib/core/services/upload_service.dart
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class UploadService {
  final ImagePicker _picker = ImagePicker();

  // Sélectionner une image depuis la galerie
  Future<String?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, // Compression
    );
    return image?.path;
  }

  // Prendre une photo avec la caméra
  Future<String?> takePicture() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    return image?.path;
  }

  // Créer un MultipartFile pour l'upload
  Future<MultipartFile> createMultipartFile(String filePath) async {
    final fileName = path.basename(filePath);
    return await MultipartFile.fromFile(
      filePath,
      filename: fileName,
    );
  }

  // Upload avec indicateur de progression
  Future<Response> uploadWithProgress(
    DioClient dioClient,
    String endpoint,
    Map<String, dynamic> data, {
    Function(int, int)? onProgress,
  }) async {
    return await dioClient.dio.post(
      endpoint,
      data: FormData.fromMap(data),
      onSendProgress: onProgress,
    );
  }
}
```

### Exemple: Confirmation de livraison avec signature

```dart
// lib/features/deliveries/presentation/screens/confirm_delivery_screen.dart
import 'package:signature/signature.dart';

class ConfirmDeliveryScreen extends ConsumerStatefulWidget {
  final String deliveryId;

  @override
  ConsumerState<ConfirmDeliveryScreen> createState() => _ConfirmDeliveryScreenState();
}

class _ConfirmDeliveryScreenState extends ConsumerState<ConfirmDeliveryScreen> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Confirmation de livraison')),
      body: Column(
        children: [
          // Zone de signature
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: Signature(
                controller: _signatureController,
                backgroundColor: Colors.white,
              ),
            ),
          ),

          // Actions
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => _signatureController.clear(),
                  child: Text('Effacer'),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _confirmDelivery,
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Confirmer la livraison'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelivery() async {
    setState(() => _isLoading = true);

    try {
      // 1. Convertir la signature en image
      final signatureImage = await _signatureController.toPngBytes();
      if (signatureImage == null) {
        throw Exception('Signature manquante');
      }

      // 2. Sauvegarder temporairement
      final tempDir = await getTemporaryDirectory();
      final signatureFile = File('${tempDir.path}/signature.png');
      await signatureFile.writeAsBytes(signatureImage);

      // 3. Prendre une photo de la livraison
      final uploadService = UploadService();
      final photoPath = await uploadService.takePicture();
      
      if (photoPath == null) {
        throw Exception('Photo manquante');
      }

      // 4. Envoyer au backend
      final repository = ref.read(driverRepositoryProvider);
      await repository.confirmDelivery(
        widget.deliveryId,
        signatureFile.path,
        photoPath,
      );

      // 5. Navigation
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Livraison confirmée avec succès !')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }
}
```

---

## 🎯 Gestion d'État avec Riverpod

### Providers

```dart
// lib/data/providers/auth_provider.dart
import 'package:riverpod/riverpod.dart';

// Service providers
final authServiceProvider = Provider((ref) => AuthService());

final dioClientProvider = Provider((ref) {
  final authService = ref.read(authServiceProvider);
  return DioClient(authService);
});

// Repository providers
final authRepositoryProvider = Provider((ref) {
  final dioClient = ref.read(dioClientProvider);
  final authService = ref.read(authServiceProvider);
  return AuthRepository(dioClient, authService);
});

final deliveryRepositoryProvider = Provider((ref) {
  final dioClient = ref.read(dioClientProvider);
  return DeliveryRepository(dioClient);
});

final driverRepositoryProvider = Provider((ref) {
  final dioClient = ref.read(dioClientProvider);
  return DriverRepository(dioClient);
});

// État d'authentification
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  final authRepository = ref.read(authRepositoryProvider);
  return AuthNotifier(authService, authRepository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final AuthRepository _authRepository;

  AuthNotifier(this._authService, this._authRepository)
      : super(AuthState.initial()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      final userType = await _authService.getUserType();
      state = AuthState.authenticated(userType ?? 'unknown');
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthState.loading();
    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );
      final userType = await _authService.getUserType();
      state = AuthState.authenticated(userType ?? 'unknown');
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = AuthState.initial();
  }
}

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? userType;
  final String? error;

  AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    this.userType,
    this.error,
  });

  factory AuthState.initial() => AuthState(
        isAuthenticated: false,
        isLoading: false,
      );

  factory AuthState.loading() => AuthState(
        isAuthenticated: false,
        isLoading: true,
      );

  factory AuthState.authenticated(String userType) => AuthState(
        isAuthenticated: true,
        isLoading: false,
        userType: userType,
      );

  factory AuthState.error(String error) => AuthState(
        isAuthenticated: false,
        isLoading: false,
        error: error,
      );
}
```

```dart
// lib/data/providers/delivery_provider.dart
final activeDeliveriesProvider = FutureProvider.autoDispose<List<DeliveryModel>>(
  (ref) async {
    final repository = ref.read(deliveryRepositoryProvider);
    return await repository.getDeliveries(status: 'active');
  },
);

final deliveryDetailsProvider = FutureProvider.autoDispose
    .family<DeliveryModel, String>((ref, deliveryId) async {
  final repository = ref.read(deliveryRepositoryProvider);
  return await repository.getDeliveryDetails(deliveryId);
});

// Provider avec auto-refresh toutes les 30 secondes
final driverLocationProvider = StreamProvider.autoDispose<Position>((ref) {
  final locationService = LocationService(ref.read(dioClientProvider));
  
  return Stream.periodic(Duration(seconds: 30)).asyncMap((_) async {
    return await locationService.getCurrentPosition();
  });
});
```

---

## ✅ Best Practices

### 1. Sécurité

```dart
// ✅ TOUJOURS utiliser HTTPS
static const String baseUrl = 'https://lebenis-backend.onrender.com';

// ✅ Ne JAMAIS stocker les tokens en clair
// Utiliser flutter_secure_storage pour les tokens JWT

// ✅ Valider les entrées utilisateur
String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email requis';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Email invalide';
  }
  return null;
}

// ✅ Timeout sur les requêtes
static const Duration connectTimeout = Duration(seconds: 30);
static const Duration receiveTimeout = Duration(seconds: 30);
```

### 2. Performance

```dart
// ✅ Cache les données pour réduire les appels API
class CachedData<T> {
  final T data;
  final DateTime expiryTime;
  
  CachedData(this.data, Duration validity)
      : expiryTime = DateTime.now().add(validity);
  
  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

// ✅ Compression des images avant upload
final XFile? image = await _picker.pickImage(
  source: ImageSource.camera,
  imageQuality: 80, // 80% de qualité
  maxWidth: 1024,   // Max 1024px de largeur
);

// ✅ Pagination pour les listes longues
Future<List<DeliveryModel>> getDeliveries({
  int page = 1,
  int pageSize = 20,
}) async {
  final response = await _dioClient.get(
    ApiConstants.deliveries,
    queryParameters: {
      'page': page,
      'page_size': pageSize,
    },
  );
  return (response.data['results'] as List)
      .map((json) => DeliveryModel.fromJson(json))
      .toList();
}
```

### 3. UX

```dart
// ✅ Indicateurs de chargement
if (_isLoading) {
  return Center(child: CircularProgressIndicator());
}

// ✅ Gestion des erreurs utilisateur
try {
  await repository.createDelivery(...);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Livraison créée avec succès')),
  );
} on ApiException catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(e.message),
      backgroundColor: Colors.red,
    ),
  );
}

// ✅ Pull-to-refresh
RefreshIndicator(
  onRefresh: () async {
    ref.invalidate(activeDeliveriesProvider);
  },
  child: DeliveryList(),
)
```

### 4. Tests

```dart
// test/repositories/delivery_repository_test.dart
void main() {
  group('DeliveryRepository', () {
    late DeliveryRepository repository;
    late MockDioClient mockDioClient;

    setUp(() {
      mockDioClient = MockDioClient();
      repository = DeliveryRepository(mockDioClient);
    });

    test('should create delivery successfully', () async {
      // Arrange
      when(() => mockDioClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {'id': '123', 'status': 'pending'},
                statusCode: 201,
              ));

      // Act
      final delivery = await repository.createDelivery(
        pickupAddress: 'Cocody',
        // ... autres paramètres
      );

      // Assert
      expect(delivery.id, '123');
      expect(delivery.status, 'pending');
    });
  });
}
```

---

## 🎨 Exemple d'Écran Complet

### Création de Livraison (App Marchand)

```dart
// lib/features/deliveries/presentation/screens/create_delivery_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/delivery_provider.dart';
import '../../../../data/models/pricing_estimate.dart';
import '../../../../core/services/upload_service.dart';

class CreateDeliveryScreen extends StatefulWidget {
  const CreateDeliveryScreen({Key? key}) : super(key: key);

  @override
  State<CreateDeliveryScreen> createState() => _CreateDeliveryScreenState();
}

class _CreateDeliveryScreenState extends State<CreateDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uploadService = UploadService();

  // Controllers
  final _pickupAddressController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _packageDescController = TextEditingController();
  final _notesController = TextEditingController();

  // State
  String? _selectedPickupCommune;
  String? _selectedDeliveryCommune;
  String _selectedPackageSize = 'small';
  bool _isFragile = false;
  PricingEstimate? _estimate;
  bool _isLoadingPrice = false;
  bool _isCreating = false;

  // Communes de Côte d'Ivoire
  final List<String> _communes = [
    'Cocody',
    'Plateau',
    'Yopougon',
    'Marcory',
    'Abobo',
    'Adjamé',
    'Koumassi',
    'Treichville',
    'Port-Bouët',
    'Attécoubé',
  ];

  final List<Map<String, String>> _packageSizes = [
    {'value': 'small', 'label': 'Petit (< 5kg)'},
    {'value': 'medium', 'label': 'Moyen (5-15kg)'},
    {'value': 'large', 'label': 'Grand (15-30kg)'},
    {'value': 'extra_large', 'label': 'Très Grand (> 30kg)'},
  ];

  @override
  void dispose() {
    _pickupAddressController.dispose();
    _deliveryAddressController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _packageDescController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Livraison'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle('📍 Point de récupération'),
            const SizedBox(height: 8),
            _buildCommuneDropdown(
              value: _selectedPickupCommune,
              label: 'Commune de récupération',
              onChanged: (value) {
                setState(() => _selectedPickupCommune = value);
                _estimatePrice();
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _pickupAddressController,
              label: 'Adresse complète',
              hint: 'Ex: Rue 12, Quartier Riviera',
              icon: Icons.location_on,
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('📦 Point de livraison'),
            const SizedBox(height: 8),
            _buildCommuneDropdown(
              value: _selectedDeliveryCommune,
              label: 'Commune de livraison',
              onChanged: (value) {
                setState(() => _selectedDeliveryCommune = value);
                _estimatePrice();
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _deliveryAddressController,
              label: 'Adresse complète',
              hint: 'Ex: Avenue 7, Quartier Sicogi',
              icon: Icons.location_on,
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('👤 Destinataire'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _recipientNameController,
              label: 'Nom complet',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _recipientPhoneController,
              label: 'Téléphone',
              hint: '07 XX XX XX XX',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('📦 Détails du colis'),
            const SizedBox(height: 8),
            _buildPackageSizeSelector(),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _packageDescController,
              label: 'Description du colis',
              hint: 'Ex: Documents, vêtements, électronique...',
              icon: Icons.inventory_2,
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildFragileCheckbox(),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _notesController,
              label: 'Notes (optionnel)',
              hint: 'Instructions spéciales...',
              icon: Icons.note,
              maxLines: 3,
              required: false,
            ),
            const SizedBox(height: 24),

            // Estimation du prix
            if (_isLoadingPrice)
              const Center(child: CircularProgressIndicator())
            else if (_estimate != null)
              _buildPriceEstimateCard(),

            const SizedBox(height: 24),

            // Bouton créer
            ElevatedButton(
              onPressed: _isCreating ? null : _createDelivery,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isCreating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Créer la livraison',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCommuneDropdown({
    required String? value,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: _communes.map((commune) {
        return DropdownMenuItem(
          value: commune,
          child: Text(commune),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Requis' : null,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: required
          ? (v) => v?.isEmpty ?? true ? 'Requis' : null
          : null,
      onChanged: (_) => _estimatePrice(),
    );
  }

  Widget _buildPackageSizeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Taille du colis',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _packageSizes.map((size) {
            final isSelected = _selectedPackageSize == size['value'];
            return ChoiceChip(
              label: Text(size['label']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedPackageSize = size['value']!);
                _estimatePrice();
              },
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFragileCheckbox() {
    return CheckboxListTile(
      title: const Text('Colis fragile'),
      subtitle: const Text('Nécessite une manipulation délicate'),
      value: _isFragile,
      onChanged: (value) {
        setState(() => _isFragile = value ?? false);
        _estimatePrice();
      },
      controlAffinity: ListTileControlAffinity.leading,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      tileColor: Colors.grey.shade50,
    );
  }

  Widget _buildPriceEstimateCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Prix estimé',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _estimate!.formattedPrice,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Distance: ${_estimate!.formattedDistance}',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            if (_estimate!.breakdown.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _estimate!.breakdown,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _estimatePrice() async {
    if (_selectedPickupCommune == null || _selectedDeliveryCommune == null) {
      return;
    }

    setState(() => _isLoadingPrice = true);

    try {
      final provider = Provider.of<DeliveryProvider>(context, listen: false);
      final estimate = await provider.estimatePrice(
        pickupCommune: _selectedPickupCommune!,
        deliveryCommune: _selectedDeliveryCommune!,
        packageSize: _selectedPackageSize,
        isFragile: _isFragile,
      );

      setState(() {
        _estimate = estimate;
        _isLoadingPrice = false;
      });
    } catch (e) {
      setState(() => _isLoadingPrice = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur calcul prix: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _createDelivery() async {
    if (!_formKey.currentState!.validate()) return;

    if (_estimate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez calculer le prix d\'abord'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final provider = Provider.of<DeliveryProvider>(context, listen: false);

      // TODO: Récupérer les coordonnées réelles via geocoding
      final delivery = await provider.createDelivery(
        pickupCommune: _selectedPickupCommune!,
        pickupAddress: _pickupAddressController.text,
        pickupLat: 5.3599, // Coordonnées par défaut
        pickupLng: -4.0083,
        deliveryAddress: _deliveryAddressController.text,
        deliveryCommune: _selectedDeliveryCommune!,
        deliveryLat: 5.3364,
        deliveryLng: -4.0267,
        recipientName: _recipientNameController.text,
        recipientPhone: _recipientPhoneController.text,
        packageSize: _selectedPackageSize,
        packageDescription: _packageDescController.text,
        isFragile: _isFragile,
        notes: _notesController.text.isNotEmpty
            ? _notesController.text
            : null,
      );

      if (delivery != null) {
        // Assigner un livreur automatiquement
        final assigned = await provider.assignDriver(delivery.id.toString());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                assigned
                    ? '✅ Livraison créée et livreur assigné !'
                    : '✅ Livraison créée, recherche de livreur en cours...',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Retour à l'écran précédent
          Navigator.pop(context, delivery);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}
```

### Provider pour State Management

```dart
// lib/data/providers/delivery_provider.dart
import 'package:flutter/foundation.dart';
import '../repositories/delivery_repository.dart';
import '../models/delivery_model.dart';
import '../models/pricing_estimate.dart';

class DeliveryProvider extends ChangeNotifier {
  final DeliveryRepository _repository;

  DeliveryProvider(this._repository);

  List<DeliveryModel> _deliveries = [];
  bool _isLoading = false;
  String? _error;

  List<DeliveryModel> get deliveries => _deliveries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Charger les livraisons
  Future<void> loadDeliveries({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _deliveries = await _repository.getDeliveries(
        status: status,
        ordering: '-created_at',
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _deliveries = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Estimer le prix
  Future<PricingEstimate> estimatePrice({
    required String pickupCommune,
    required String deliveryCommune,
    required String packageSize,
    bool isFragile = false,
  }) async {
    return await _repository.estimatePrice(
      pickupCommune: pickupCommune,
      deliveryCommune: deliveryCommune,
      packageSize: packageSize,
      isFragile: isFragile,
    );
  }

  // Créer une livraison
  Future<DeliveryModel?> createDelivery({
    required String pickupCommune,
    required String pickupAddress,
    required double pickupLat,
    required double pickupLng,
    required String deliveryAddress,
    required String deliveryCommune,
    required double deliveryLat,
    required double deliveryLng,
    required String recipientName,
    required String recipientPhone,
    required String packageSize,
    required String packageDescription,
    bool isFragile = false,
    String? notes,
  }) async {
    try {
      final delivery = await _repository.createDelivery(
        pickupAddress: pickupAddress,
        pickupCommune: pickupCommune,
        pickupLatitude: pickupLat,
        pickupLongitude: pickupLng,
        deliveryAddress: deliveryAddress,
        deliveryCommune: deliveryCommune,
        deliveryLatitude: deliveryLat,
        deliveryLongitude: deliveryLng,
        packageSize: packageSize,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        packageDescription: packageDescription,
        isFragile: isFragile,
        notes: notes,
      );

      // Ajouter au début de la liste
      _deliveries.insert(0, delivery);
      notifyListeners();

      return delivery;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Assigner un livreur
  Future<bool> assignDriver(String deliveryId) async {
    try {
      final updatedDelivery = await _repository.assignDriver(deliveryId);

      // Mettre à jour dans la liste
      final index = _deliveries.indexWhere((d) => d.id.toString() == deliveryId);
      if (index != -1) {
        _deliveries[index] = updatedDelivery;
        notifyListeners();
      }

      return updatedDelivery.status == 'assigned' ||
          updatedDelivery.status == 'accepted';
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Rafraîchir les données
  Future<void> refresh({String? status}) async {
    _repository.clearCache();
    await loadDeliveries(status: status);
  }

  // Annuler une livraison
  Future<bool> cancelDelivery(String deliveryId, {String? reason}) async {
    try {
      await _repository.cancelDelivery(deliveryId, reason: reason);

      // Mettre à jour dans la liste
      final index = _deliveries.indexWhere((d) => d.id.toString() == deliveryId);
      if (index != -1) {
        _deliveries[index] = await _repository.getDeliveryDetails(deliveryId);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
```

---

## 📅 Roadmap de Développement

### Phase 1: App Marchand (2-3 semaines)

**Semaine 1: Authentification & Profil**
- ✅ Écran de connexion/inscription
- ✅ Upload du registre de commerce
- ✅ Affichage du profil avec statut de vérification
- ✅ Gestion des tokens JWT

**Semaine 2: Gestion des Livraisons**
- ✅ Calcul de prix en temps réel
- ✅ Création de livraison avec sélection sur carte
- ✅ Assignation automatique de livreur
- ✅ Liste des livraisons (filtrées par statut)

**Semaine 3: Tracking & Notifications**
- ✅ Suivi en temps réel du livreur sur carte
- ✅ Notifications push (statut de la livraison)
- ✅ Historique et recherche

### Phase 2: App Livreur (2-3 semaines)

**Semaine 1: Authentification & Disponibilité**
- ✅ Inscription avec documents (permis, carte grise, photo)
- ✅ Toggle disponibilité (disponible/occupé/hors ligne)
- ✅ Profil avec statistiques

**Semaine 2: Gestion des Courses**
- ✅ Tracking GPS continu (envoi toutes les 30s)
- ✅ Réception d'assignations par push
- ✅ Accepter/rejeter une course
- ✅ Navigation vers le point d'enlèvement

**Semaine 3: Exécution & Gains**
- ✅ Confirmation d'enlèvement avec photo
- ✅ Capture de signature client
- ✅ Confirmation de livraison avec preuve
- ✅ Dashboard des gains et statistiques

### Phase 3: Tests & Lancement (1-2 semaines)

- ✅ Tests end-to-end avec utilisateurs réels
- ✅ Corrections de bugs
- ✅ Optimisation des performances
- ✅ Soumission Play Store/App Store

---

## 🔗 Ressources Complémentaires

### Documentation Officielle Backend
- **API Documentation (Swagger)**: `https://lebenis-backend.onrender.com/swagger/`
- **Admin Panel**: `https://lebenis-backend.onrender.com/admin/`
- **Healthcheck**: `https://lebenis-backend.onrender.com/health/`
- **ReDoc API**: `https://lebenis-backend.onrender.com/redoc/`

### Endpoints Principaux

#### Authentification
- `POST /api/v1/auth/register/` - Inscription (merchant/driver)
- `POST /api/v1/auth/login/` - Connexion
- `POST /api/v1/auth/token/refresh/` - Rafraîchir le token
- `POST /api/v1/auth/logout/` - Déconnexion

#### Livraisons
- `GET /api/v1/deliveries/` - Liste des livraisons
- `POST /api/v1/deliveries/` - Créer une livraison
- `GET /api/v1/deliveries/{id}/` - Détails d'une livraison
- `POST /api/v1/deliveries/{id}/assign/` - Assigner un livreur
- `POST /api/v1/deliveries/{id}/cancel/` - Annuler

#### Pricing
- `POST /api/v1/pricing/estimate/` - Estimer le prix
- `GET /api/v1/pricing/communes/` - Liste des communes

#### Merchants
- `GET /api/v1/merchants/profile/` - Profil marchand
- `PATCH /api/v1/merchants/profile/` - Modifier profil
- `GET /api/v1/merchants/deliveries/` - Livraisons du marchand

#### Drivers
- `GET /api/v1/drivers/profile/` - Profil livreur
- `PATCH /api/v1/drivers/me/location/` - Mettre à jour position GPS
- `PATCH /api/v1/drivers/me/availability/` - Changer disponibilité
- `POST /api/v1/deliveries/{id}/accept/` - Accepter une course
- `POST /api/v1/deliveries/{id}/confirm-pickup/` - Confirmer enlèvement
- `POST /api/v1/deliveries/{id}/confirm-delivery/` - Confirmer livraison

### Codes HTTP Utilisés

| Code | Usage | Exemple |
|------|-------|---------|
| `200 OK` | Succès requête GET/PATCH | Récupération profil |
| `201 Created` | Ressource créée | Nouvelle livraison |
| `204 No Content` | Succès sans réponse | Suppression |
| `400 Bad Request` | Données invalides | Email déjà utilisé |
| `401 Unauthorized` | Token invalide/expiré | Reconnexion requise |
| `403 Forbidden` | Permissions insuffisantes | Accès marchand uniquement |
| `404 Not Found` | Ressource introuvable | Livraison inexistante |
| `500 Server Error` | Erreur serveur | Réessayer plus tard |

### Packages Flutter Essentiels

#### Networking
```yaml
dio: ^5.3.3                          # Client HTTP avec intercepteurs
```

#### State Management
```yaml
provider: ^6.1.1                     # State management simple
# OU
riverpod: ^2.4.9                     # State management avancé (RECOMMANDÉ)
flutter_riverpod: ^2.4.9             # Riverpod pour Flutter
```

#### Sécurité & Storage
```yaml
flutter_secure_storage: ^9.0.0      # Stockage sécurisé tokens JWT
```

#### Firebase
```yaml
firebase_core: ^2.24.2               # Firebase core
firebase_messaging: ^14.7.9          # Push notifications
flutter_local_notifications: ^16.1.0 # Notifications locales
```

#### Géolocalisation
```yaml
geolocator: ^10.1.0                  # GPS tracking
geocoding: ^2.1.1                    # Adresse ↔ Coordonnées
permission_handler: ^11.1.0          # Gestion permissions
```

#### Cartes
```yaml
google_maps_flutter: ^2.5.0          # Google Maps (payant après)
# OU
flutter_map: ^6.1.0                  # OpenStreetMap (gratuit)
latlong2: ^0.9.0                     # Coordonnées pour flutter_map
```

#### Images & Médias
```yaml
image_picker: ^1.0.4                 # Sélection photos/caméra
image_cropper: ^5.0.0                # Recadrage images
```

#### Signature
```yaml
signature: ^5.4.1                    # Capture signature client
```

#### Utilitaires
```yaml
device_info_plus: ^9.1.0             # Infos appareil (Android version)
intl: ^0.18.1                        # Formatage dates/nombres
path_provider: ^2.1.1                # Accès aux dossiers système
url_launcher: ^6.2.1                 # Ouvrir liens/téléphone
```

#### UI Components
```yaml
cached_network_image: ^3.3.0         # Images avec cache
shimmer: ^3.0.0                      # Effet loading skeleton
```

### Exemples de Réponses API

#### Login Success (200)
```json
{
  "access": "eyJhbGciOiJIUzI1NiIs...",
  "refresh": "eyJhbGciOiJIUzI1NiIs...",
  "user_type": "merchant",
  "user": {
    "id": 1,
    "email": "merchant@example.com",
    "business_name": "Mon Commerce"
  }
}
```

#### Pricing Estimate (200)
```json
{
  "base_price": 500.0,
  "distance_price": 1200.0,
  "size_multiplier": 1.5,
  "fragile_multiplier": 1.2,
  "total_price": 3060.0,
  "distance": 12.5,
  "breakdown": "Base: 500 FCFA + Distance (12.5 km × 100): 1250 FCFA × Taille (medium): 1.5 × Fragile: 1.2"
}
```

#### Delivery Created (201)
```json
{
  "id": 123,
  "tracking_number": "LB-2025-00123",
  "status": "pending",
  "pickup_address": "Rue 12, Cocody",
  "delivery_address": "Avenue 7, Yopougon",
  "recipient_name": "Jean Kouassi",
  "recipient_phone": "07 12 34 56 78",
  "package_size": "medium",
  "is_fragile": true,
  "price": 3060.0,
  "distance_km": 12.5,
  "created_at": "2025-11-03T10:30:00Z"
}
```

#### Error 400 (Validation)
```json
{
  "pickup_address": ["Ce champ est requis."],
  "recipient_phone": ["Format invalide. Utilisez: 07 XX XX XX XX"]
}
```

#### Error 401 (Token Expired)
```json
{
  "detail": "Token invalide ou expiré",
  "code": "token_not_valid"
}
```

### Architecture Patterns Recommandés

#### Clean Architecture
```
lib/
├── config/                   # Configuration environnement
│   ├── env_config.dart       # Dev/Prod
│   └── app_config.dart       # App config
├── core/                     # Code réutilisable
│   ├── constants/            # URLs, clés
│   ├── network/              # DioClient, ApiException
│   ├── services/             # AuthService, LocationService
│   └── utils/                # Helpers, validators
├── data/                     # Couche données
│   ├── models/               # Data classes (fromJson/toJson)
│   ├── repositories/         # Communication API
│   └── providers/            # State management
├── features/                 # Organisation par domaine métier
│   ├── auth/
│   │   └── presentation/
│   │       ├── screens/      # Écrans d'authentification
│   │       └── widgets/      # Widgets spécifiques
│   ├── deliveries/
│   │   └── presentation/
│   │       ├── screens/      # Écrans de livraison
│   │       └── widgets/      # Widgets spécifiques
│   └── profile/
│       └── presentation/
│           ├── screens/      # Écrans de profil
│           └── widgets/      # Widgets spécifiques
├── l10n/                     # Internationalisation
├── theme/                    # Thème personnalisé
├── shared/                   # Widgets réutilisables
│   └── widgets/              # Boutons, inputs, etc.
└── main.dart
```

#### Repository Pattern
```dart
// Avantages:
// - Séparation des responsabilités
// - Facilite les tests (mocking)
// - Cache centralisé
// - Gestion d'erreurs uniforme

class DeliveryRepository {
  final DioClient _client;
  final Map<String, CachedData> _cache;
  
  Future<Delivery> get(String id) async {
    // 1. Vérifier cache
    if (_cache.has(id)) return _cache.get(id);
    
    // 2. Appeler API
    final response = await _client.get('/deliveries/$id/');
    
    // 3. Mettre en cache
    final delivery = Delivery.fromJson(response.data);
    _cache.set(id, delivery, duration: Duration(minutes: 5));
    
    return delivery;
  }
}
```

### Best Practices Sécurité

#### ✅ À FAIRE
- **Utiliser HTTPS uniquement** (`https://lebenis-backend.onrender.com`)
- **Stocker tokens dans flutter_secure_storage** (jamais SharedPreferences)
- **Valider toutes les entrées utilisateur** (email, téléphone, montants)
- **Timeout sur les requêtes** (30 secondes max)
- **Gestion des tokens expirés** (refresh automatique)
- **Obfuscation du code** pour production
- **Certificat SSL pinning** pour API critique

#### ❌ À ÉVITER
- Stocker tokens en clair (SharedPreferences, Hive sans encryption)
- Logs sensibles en production (tokens, mots de passe)
- Requêtes HTTP non sécurisées
- Accepter tous les certificats SSL (`verify: false`)
- Envoyer mots de passe dans les logs

### Support & Contact

#### Équipe Développement
- **Email Support**: support@lebenis.ci (à configurer)
- **GitHub Repository**: https://github.com/cheoo04/lebenis-backend
- **Sentry Dashboard**: [Lien Sentry] (monitoring erreurs)

#### Ressources Externes
- **Flutter Documentation**: https://docs.flutter.dev/
- **Dio Package**: https://pub.dev/packages/dio
- **Riverpod**: https://riverpod.dev/
- **Firebase Flutter**: https://firebase.flutter.dev/
- **Geolocator**: https://pub.dev/packages/geolocator

### Checklist Avant Production

#### Backend
- [x] API déployée et accessible (Render.com)
- [x] Base de données PostgreSQL configurée (Neon.tech)
- [x] Sentry monitoring actif
- [x] SSL/HTTPS activé
- [x] Rate limiting configuré
- [x] Swagger documentation à jour

#### Flutter Apps
- [ ] Tests unitaires (repositories, models)
- [ ] Tests d'intégration (flux complets)
- [ ] Tests E2E (sur appareil réel)
- [ ] Performance optimisée (< 60ms par frame)
- [ ] Gestion offline (cache, retry)
- [ ] Permissions runtime (Android 13+)
- [ ] Icônes et splash screens
- [ ] Obfuscation code activée
- [ ] Signature apps (keystore Android, certificates iOS)
- [ ] Play Store / App Store metadata

---

**Version du guide**: 2.1.0  
**Date de création**: 3 novembre 2025  
**Dernière mise à jour**: 3 novembre 2025  
**Auteurs**: LeBeni's Dev Team  
**Backend Version**: 1.0.0 (Production)

*Ce guide sera mis à jour régulièrement en fonction de l'évolution du backend et des retours des développeurs.*

---

## 📝 Notes de Version

### v2.1.0 (3 novembre 2025) - Harmonisation Structure
- ✅ **HARMONISATION** avec FLUTTER_STRUCTURE_GUIDE.md
- ✅ Migration vers architecture **Feature-First**
- ✅ Chemins de fichiers mis à jour (`lib/features/` au lieu de `lib/presentation/`)
- ✅ Ajout dossiers `config/`, `theme/`, `l10n/`
- ✅ Structure 100% compatible entre les deux guides

### v2.0.0 (3 novembre 2025)
- ✅ Ajout gestion complète des erreurs HTTP avec codes détaillés
- ✅ Exemple d'écran complet (CreateDeliveryScreen) avec validation
- ✅ Provider pattern pour state management
- ✅ Configuration Firebase Android 13+ et iOS
- ✅ Models enrichis avec helpers (statusLabel, statusColor, formatters)
- ✅ Cache intelligent avec expiration
- ✅ Section "Ressources Complémentaires" étendue
- ✅ Best practices sécurité et architecture

### v1.0.0 (2 novembre 2025)
- ✅ Guide initial avec architecture recommandée
- ✅ Configuration Dio avec intercepteurs JWT
- ✅ Services d'authentification, géolocalisation, notifications
- ✅ Repositories complets (Auth, Delivery, Driver)
- ✅ Exemples de code fonctionnels
- ✅ Roadmap de développement
