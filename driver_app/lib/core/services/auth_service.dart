// lib/core/services/auth_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

/// Service de gestion de l'authentification locale
/// Gère le stockage sécurisé des tokens JWT et des données utilisateur
class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ========== TOKENS JWT ==========

  /// Sauvegarder les tokens après connexion
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userType,
  }) async {
    await Future.wait([
      _storage.write(key: StorageKeys.accessToken, value: accessToken),
      _storage.write(key: StorageKeys.refreshToken, value: refreshToken),
      _storage.write(key: StorageKeys.userType, value: userType),
    ]);
  }

  /// Récupérer l'access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: StorageKeys.accessToken);
  }

  /// Récupérer le refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: StorageKeys.refreshToken);
  }

  /// Mettre à jour uniquement l'access token (après refresh)
  Future<void> updateAccessToken(String newAccessToken) async {
    await _storage.write(key: StorageKeys.accessToken, value: newAccessToken);
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

      // Import dynamique pour éviter la circularité
      // DioClient appellera cette méthode, mais elle ne peut pas importer DioClient
      // Solution: Cette méthode retourne le refresh token, et DioClient fait l'appel API
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
    await Future.wait([
      _storage.write(key: StorageKeys.userId, value: userId),
      _storage.write(key: StorageKeys.userEmail, value: email),
      _storage.write(key: StorageKeys.userType, value: userType),
      if (userName != null)
        _storage.write(key: StorageKeys.userName, value: userName),
    ]);
  }

  /// Récupérer l'ID utilisateur
  Future<String?> getUserId() async {
    return await _storage.read(key: StorageKeys.userId);
  }

  /// Récupérer l'email utilisateur
  Future<String?> getUserEmail() async {
    return await _storage.read(key: StorageKeys.userEmail);
  }

  /// Récupérer le type d'utilisateur
  Future<String?> getUserType() async {
    return await _storage.read(key: StorageKeys.userType);
  }

  // ========== DRIVER SPÉCIFIQUE ==========

  /// Sauvegarder les informations du driver
  Future<void> saveDriverInfo({
    required String driverId,
    String? phone,
    String? vehicleType,
  }) async {
    await Future.wait([
      _storage.write(key: StorageKeys.driverId, value: driverId),
      if (phone != null)
        _storage.write(key: StorageKeys.driverPhone, value: phone),
      if (vehicleType != null)
        _storage.write(key: StorageKeys.vehicleType, value: vehicleType),
    ]);
  }

  /// Récupérer l'ID du driver
  Future<String?> getDriverId() async {
    return await _storage.read(key: StorageKeys.driverId);
  }

  /// Sauvegarder le statut de disponibilité
  Future<void> saveAvailabilityStatus(String status) async {
    await _storage.write(key: StorageKeys.availabilityStatus, value: status);
  }

  /// Récupérer le statut de disponibilité
  Future<String?> getAvailabilityStatus() async {
    return await _storage.read(key: StorageKeys.availabilityStatus);
  }

  // ========== NOTIFICATIONS ==========

  /// Sauvegarder le token FCM
  Future<void> saveFcmToken(String token) async {
    await _storage.write(key: StorageKeys.fcmToken, value: token);
  }

  /// Récupérer le token FCM
  Future<String?> getFcmToken() async {
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
    final value = await _storage.read(key: StorageKeys.isFirstLaunch);
    return value == null || value == 'true';
  }

  /// Marquer l'app comme déjà lancée
  Future<void> markAsLaunched() async {
    await _storage.write(key: StorageKeys.isFirstLaunch, value: 'false');
  }

  // ========== DÉCONNEXION ==========

  /// Déconnexion complète (supprime tout sauf les préférences)
  Future<void> logout() async {
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

  /// Supprimer TOUTES les données (reset complet)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
