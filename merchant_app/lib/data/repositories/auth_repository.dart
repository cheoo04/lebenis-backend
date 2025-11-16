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
    required String password2,
    required String firstName,
    required String lastName,
    required String phone,
    required String businessName,
    required String businessType,
    required String businessAddress,
    String? rccmDocumentPath,
    String? idDocumentPath,
  }) async {
    final formData = FormData();
    formData.fields
      ..add(MapEntry('email', email))
      ..add(MapEntry('password', password))
      ..add(MapEntry('password2', password2))
      ..add(MapEntry('first_name', firstName))
      ..add(MapEntry('last_name', lastName))
      ..add(MapEntry('phone', phone))
      ..add(MapEntry('user_type', 'merchant'))
      ..add(MapEntry('merchant_data[business_name]', businessName))
      ..add(MapEntry('merchant_data[business_type]', businessType))
      ..add(MapEntry('merchant_data[business_address]', businessAddress));
    if (rccmDocumentPath != null) {
      formData.files.add(MapEntry(
        'merchant_data[rccm_document]',
        await MultipartFile.fromFile(rccmDocumentPath, filename: 'rccm_document.pdf'),
      ));
    }
    if (idDocumentPath != null) {
      formData.files.add(MapEntry(
        'merchant_data[id_document]',
        await MultipartFile.fromFile(idDocumentPath, filename: 'id_document.pdf'),
      ));
    }

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
        // Optionally log error in production with a logger
      }
    }
    await authService.logout();
  }

  // Vérifier le statut de connexion
  Future<bool> isLoggedIn() async {
    return await authService.isLoggedIn();
  }
}