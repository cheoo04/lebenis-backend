// lib/data/repositories/auth_repository.dart

import 'package:flutter/foundation.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/auth_service.dart';

/// Repository pour l'authentification
class AuthRepository {
  final DioClient _dioClient;
  final AuthService _authService;

  AuthRepository(this._dioClient, this._authService);

  /// Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      
      debugPrint('DEBUG LOGIN RESPONSE: ${response.data}');
      
      // Vérifier que la réponse contient les données nécessaires
      if (response.data == null || response.data is! Map) {
        throw Exception('Réponse invalide du serveur');
      }

      final data = response.data as Map<String, dynamic>;
      
      // Le backend peut renvoyer les tokens directement ou dans un sous-objet
      final accessToken = data['access'] ?? data['access_token'] ?? data['tokens']?['access'];
      final refreshToken = data['refresh'] ?? data['refresh_token'] ?? data['tokens']?['refresh'];
      
      if (accessToken == null || refreshToken == null) {
        debugPrint('DEBUG: Access token: $accessToken');
        debugPrint('DEBUG: Refresh token: $refreshToken');
        debugPrint('DEBUG: Full response: $data');
        throw Exception('Tokens manquants dans la réponse');
      }

      // Sauvegarder tokens
      await _authService.saveTokens(
        accessToken: accessToken.toString(),
        refreshToken: refreshToken.toString(),
        userType: data['user']?['user_type']?.toString() ?? 'driver',
      );
      
      return data;
    } catch (e) {
      debugPrint('DEBUG LOGIN REPOSITORY ERROR: $e');
      rethrow;
    }
  }

  /// Register Driver
  Future<Map<String, dynamic>> registerDriver({
    required String email,
    required String password,
    required String phone,
    required String vehicleType,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'password2': password, // Django requires password confirmation
          'phone': phone,
          'vehicle_type': vehicleType,
          'user_type': 'driver',
          if (firstName != null && firstName.isNotEmpty) 'first_name': firstName,
          if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
        },
      );
      
      debugPrint('DEBUG REGISTER RESPONSE: ${response.data}');
      
      // Vérifier le status code pour détecter les erreurs de validation
      if (response.statusCode == 400) {
        // Erreur de validation Django
        final data = response.data as Map<String, dynamic>;
        
        // Extraire les messages d'erreur
        final errors = <String>[];
        data.forEach((field, value) {
          if (value is List && value.isNotEmpty) {
            if (field == 'email') {
              errors.add('Email déjà utilisé');
            } else if (field == 'phone') {
              errors.add('Numéro de téléphone déjà utilisé');
            } else if (field == 'password' || field == 'password2') {
              errors.add(value[0].toString());
            } else {
              errors.add('$field: ${value[0]}');
            }
          }
        });
        
        throw Exception(errors.isNotEmpty ? errors.join('. ') : 'Erreur de validation');
      }
      
      // Vérifier que la réponse contient les données nécessaires
      if (response.data == null || response.data is! Map) {
        throw Exception('Réponse invalide du serveur');
      }

      final data = response.data as Map<String, dynamic>;
      
      // Le backend peut renvoyer les tokens directement ou dans un sous-objet
      final accessToken = data['access'] ?? data['access_token'] ?? data['tokens']?['access'];
      final refreshToken = data['refresh'] ?? data['refresh_token'] ?? data['tokens']?['refresh'];
      
      if (accessToken == null || refreshToken == null) {
        debugPrint('DEBUG: Access token: $accessToken');
        debugPrint('DEBUG: Refresh token: $refreshToken');
        debugPrint('DEBUG: Full response: $data');
        throw Exception('Inscription réussie mais tokens manquants. Veuillez vous connecter.');
      }

      await _authService.saveTokens(
        accessToken: accessToken.toString(),
        refreshToken: refreshToken.toString(),
        userType: 'driver',
      );
      
      return data;
    } catch (e) {
      debugPrint('DEBUG REGISTER REPOSITORY ERROR: $e');
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    final refreshToken = await _authService.getRefreshToken();
    if (refreshToken != null) {
      await _dioClient.post(
        ApiConstants.logout,
        data: {'refresh': refreshToken},
      );
    }
    await _authService.logout();
  }

  /// Mettre à jour le profil utilisateur (y compris profile_photo)
  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> data) async {
    final response = await _dioClient.patch(
      ApiConstants.me,
      data: data,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Demander la réinitialisation du mot de passe
  Future<void> requestPasswordReset(String email) async {
    await _dioClient.post(
      ApiConstants.passwordResetRequest,
      data: {'email': email},
    );
  }

  /// Confirmer la réinitialisation avec le code
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _dioClient.post(
      ApiConstants.passwordResetConfirm,
      data: {
        'email': email,
        'code': code,
        'new_password': newPassword,
      },
    );
  }

  /// Changer le mot de passe (utilisateur connecté)
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _dioClient.post(
      ApiConstants.changePassword,
      data: {
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirm': newPassword,
      },
    );
  }
}
