import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class AuthService {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  
  // Dio instance séparée pour le refresh (évite les boucles infinies)
  final Dio _refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userTypeKey = 'user_type';

  // Sauvegarder les tokens après login
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userType,
  }) async {
    await storage.write(key: _accessTokenKey, value: accessToken);
    await storage.write(key: _refreshTokenKey, value: refreshToken);
    await storage.write(key: _userTypeKey, value: userType);
  }

  // Récupérer le token d'accès
  Future<String?> getAccessToken() async {
    return await storage.read(key: _accessTokenKey);
  }

  // Récupérer le refresh token
  Future<String?> getRefreshToken() async {
    return await storage.read(key: _refreshTokenKey);
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  // Récupérer le type d'utilisateur
  Future<String?> getUserType() async {
    return await storage.read(key: _userTypeKey);
  }

  // Rafraîchir le token d'accès
  Future<String?> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      final response = await _refreshDio.post(
        '/api/v1/auth/refresh/',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'] as String?;
        final newRefreshToken = response.data['refresh'] as String?;
        
        if (newAccessToken != null) {
          // Sauvegarder le nouveau access token
          await storage.write(key: _accessTokenKey, value: newAccessToken);
          
          // Si un nouveau refresh token est fourni (rotation activée), le sauvegarder
          if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
            await storage.write(key: _refreshTokenKey, value: newRefreshToken);
          }
          
          return newAccessToken;
        }
      }
      return null;
    } catch (e) {
      // Refresh a échoué (token expiré ou invalide)
      return null;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);
    await storage.delete(key: _userTypeKey);
  }
}