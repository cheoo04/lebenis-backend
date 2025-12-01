// lib/core/services/auth_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';
// ignore: avoid_web_libraries_in_flutter
// Import conditionnel : web = auth_service_web, autres = auth_service_stub
import 'auth_service_stub.dart'
  if (dart.library.html) 'auth_service_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service de gestion de l'authentification locale
/// Gère le stockage sécurisé des tokens JWT et des données utilisateur
class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool get _isWeb => kIsWeb;

  // Helpers pour le web
  String? _getFromWebStorage(String key) {
    if (!_isWeb) return null;
    return getFromWebStorage(key);
  }

  Future<void> _setToWebStorage(String key, String? value) async {
    if (!_isWeb) return;
    await setToWebStorage(key, value);
  }

  Future<void> _clearWebStorage() async {
    if (!_isWeb) return;
    await clearWebStorage();
  }

  // ========== TOKENS JWT ==========

  /// Sauvegarder les tokens après connexion
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userType,
  }) async {
    if (_isWeb) {
      await _setToWebStorage(StorageKeys.accessToken, accessToken);
      await _setToWebStorage(StorageKeys.refreshToken, refreshToken);
      await _setToWebStorage(StorageKeys.userType, userType);
    } else {
      await Future.wait([
        _storage.write(key: StorageKeys.accessToken, value: accessToken),
        _storage.write(key: StorageKeys.refreshToken, value: refreshToken),
        _storage.write(key: StorageKeys.userType, value: userType),
      ]);
    }
  }

  /// Récupérer l'access token
  Future<String?> getAccessToken() async {
    if (_isWeb) {
      return _getFromWebStorage(StorageKeys.accessToken);
    }
    return await _storage.read(key: StorageKeys.accessToken);
  }

  /// Récupérer le refresh token
  Future<String?> getRefreshToken() async {
    if (_isWeb) {
      return _getFromWebStorage(StorageKeys.refreshToken);
    }
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  /// Mettre à jour uniquement l'access token (après refresh)
  Future<void> updateAccessToken(String newAccessToken) async {
    if (_isWeb) {
      await _setToWebStorage(StorageKeys.accessToken, newAccessToken);
    } else {
      await _storage.write(key: StorageKeys.accessToken, value: newAccessToken);
    }
  }

  /// Rafraîchir l'access token avec le refresh token
  /// Cette méthode doit appeler l'endpoint backend `/api/v1/auth/token/refresh/`
  /// Elle est appelée automatiquement par DioClient en cas d'erreur 401
  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }
      return refreshToken;
    } catch (e) {
      return null;
    }
  }

  // ========== UTILISATEUR ==========

  /// Sauvegarder les informations utilisateur
  Future<void> saveUserInfo({
    required String userId,
    required String email,
    required String userType,
    String? userName,
  }) async {
    if (_isWeb) {
      await _setToWebStorage(StorageKeys.userId, userId);
      await _setToWebStorage(StorageKeys.userEmail, email);
      await _setToWebStorage(StorageKeys.userType, userType);
      if (userName != null) {
        await _setToWebStorage(StorageKeys.userName, userName);
      }
    } else {
      await Future.wait([
        _storage.write(key: StorageKeys.userId, value: userId),
        _storage.write(key: StorageKeys.userEmail, value: email),
        _storage.write(key: StorageKeys.userType, value: userType),
        if (userName != null)
          _storage.write(key: StorageKeys.userName, value: userName),
      ]);
    }
  }

  /// Récupérer l'ID utilisateur
  Future<String?> getUserId() async {
    if (_isWeb) {
      return _getFromWebStorage(StorageKeys.userId);
    }
    return await _storage.read(key: StorageKeys.userId);
  }

  /// Récupérer l'email utilisateur
  Future<String?> getUserEmail() async {
    if (_isWeb) {
      return _getFromWebStorage(StorageKeys.userEmail);
    }
    return await _storage.read(key: StorageKeys.userEmail);
  }

  /// Récupérer le type d'utilisateur
  Future<String?> getUserType() async {
    if (_isWeb) {
      return _getFromWebStorage(StorageKeys.userType);
    }
    return await _storage.read(key: StorageKeys.userType);
  }

  /// Récupérer le nom de l'utilisateur
  Future<String?> getUserName() async {
    if (_isWeb) {
      return _getFromWebStorage(StorageKeys.userName);
    }
    return await _storage.read(key: StorageKeys.userName);
  }

  // ========== DRIVER SPÉCIFIQUE ==========

  /// Sauvegarder les informations du driver
  Future<void> saveDriverInfo({
    required String driverId,
    String? phone,
    String? vehicleType,
  }) async {
    if (_isWeb) {
      await _setToWebStorage(StorageKeys.driverId, driverId);
      if (phone != null) await _setToWebStorage(StorageKeys.driverPhone, phone);
      if (vehicleType != null) await _setToWebStorage(StorageKeys.vehicleType, vehicleType);
    } else {
      await Future.wait([
        _storage.write(key: StorageKeys.driverId, value: driverId),
        if (phone != null)
          _storage.write(key: StorageKeys.driverPhone, value: phone),
        if (vehicleType != null)
          _storage.write(key: StorageKeys.vehicleType, value: vehicleType),
      ]);
    }
  }

  /// Récupérer l'ID du driver
  Future<String?> getDriverId() async {
    if (_isWeb) {
      return _getFromWebStorage(StorageKeys.driverId);
    }
    return await _storage.read(key: StorageKeys.driverId);
  }

  /// Sauvegarder le statut de disponibilité
  Future<void> saveAvailabilityStatus(String status) async {
    if (_isWeb) {
      await _setToWebStorage(StorageKeys.availabilityStatus, status);
    } else {
      await _storage.write(key: StorageKeys.availabilityStatus, value: status);
    }
  }

  /// Récupérer le statut de disponibilité
  Future<String?> getAvailabilityStatus() async {
    if (_isWeb) {
      return _getFromWebStorage(StorageKeys.availabilityStatus);
    }
    return await _storage.read(key: StorageKeys.availabilityStatus);
  }

  // ========== NOTIFICATIONS ==========

  /// Sauvegarder le token FCM
  Future<void> saveFcmToken(String token) async {
    if (_isWeb) {
      await _setToWebStorage(StorageKeys.fcmToken, token);
    } else {
      await _storage.write(key: StorageKeys.fcmToken, value: token);
    }
  }

  /// Récupérer le token FCM
  Future<String?> getFcmToken() async {
    if (_isWeb) {
      return _getFromWebStorage(StorageKeys.fcmToken);
    }
    return await _storage.read(key: StorageKeys.fcmToken);
  }

  // ========== ÉTAT AUTHENTIFICATION ==========

  /// Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && 
           accessToken.isNotEmpty && 
           refreshToken != null && 
           refreshToken.isNotEmpty;
  }

  /// Vérifier si c'est la première utilisation
  Future<bool> isFirstLaunch() async {
    if (_isWeb) {
      final value = _getFromWebStorage(StorageKeys.isFirstLaunch);
      return value == null || value == 'true';
    }
    final value = await _storage.read(key: StorageKeys.isFirstLaunch);
    return value == null || value == 'true';
  }

  /// Marquer l'app comme déjà lancée
  Future<void> markAsLaunched() async {
    if (_isWeb) {
      await _setToWebStorage(StorageKeys.isFirstLaunch, 'false');
    } else {
      await _storage.write(key: StorageKeys.isFirstLaunch, value: 'false');
    }
  }

  // ========== DÉCONNEXION ==========

  /// Déconnexion complète (supprime tout sauf les préférences)
  Future<void> logout() async {
    if (_isWeb) {
      await _clearWebStorage();
    } else {
      // Sauvegarder certaines préférences avant suppression
      final language = await _storage.read(key: StorageKeys.language);
      final hasSeenOnboarding = await _storage.read(key: StorageKeys.hasSeenOnboarding);

      // Tout supprimer
      await _storage.deleteAll();

      // Restaurer les préférences
      if (language != null) {
        await _storage.write(key: StorageKeys.language, value: language);
      }
      if (hasSeenOnboarding != null) {
        await _storage.write(key: StorageKeys.hasSeenOnboarding, value: hasSeenOnboarding);
      }
    }
  }

  /// Supprimer TOUTES les données (reset complet)
  Future<void> clearAll() async {
    if (_isWeb) {
      await _clearWebStorage();
    } else {
      await _storage.deleteAll();
    }
  }
}
