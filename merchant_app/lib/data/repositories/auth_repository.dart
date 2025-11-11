import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/auth_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DioClient dioClient;
  final AuthService authService;

  AuthRepository(this.dioClient, this.authService);

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

    final response = await dioClient.upload(
      ApiConstants.register,
      data: formData,
    );

    await authService.saveTokens(
      accessToken: response.data['access'],
      refreshToken: response.data['refresh'],
      userType: 'merchant',
    );

    return UserModel.fromJson(response.data['user']);
  }

  // Connexion
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await dioClient.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    await authService.saveTokens(
      accessToken: response.data['access'],
      refreshToken: response.data['refresh'],
      userType: response.data['user_type'],
    );

    return UserModel.fromJson(response.data['user']);
  }

  // Déconnexion
  Future<void> logout() async {
    final refreshToken = await authService.getRefreshToken();
    if (refreshToken != null) {
      try {
        await dioClient.post(
          ApiConstants.logout,
          data: {'refresh': refreshToken},
        );
      } catch (e) {
        print('Erreur logout backend: $e');
      }
    }
    await authService.logout();
  }

  // Vérifier le statut de connexion
  Future<bool> isLoggedIn() async {
    return await authService.isLoggedIn();
  }
}