import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/auth_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DioClient dioClient;
  final AuthService authService;

  AuthRepository(this.dioClient, this.authService);

  // Inscription marchand (sans documents - upload après connexion)
  Future<UserModel> register({
    required String email,
    required String password,
    required String password2,
    required String firstName,
    required String lastName,
    required String phone,
    required String userType,
    String? businessName,
    String? businessType,
    String? businessAddress,
  }) async {
    final data = {
      'email': email,
      'password': password,
      'password2': password2,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'user_type': userType,
    };
    
    // Ajouter les champs spécifiques aux commerçants
    if (userType == 'merchant') {
      if (businessName != null) data['business_name'] = businessName;
      if (businessType != null) data['business_type'] = businessType;
      if (businessAddress != null) data['business_address'] = businessAddress;
    }
    
    final response = await dioClient.post(ApiConstants.register, data: data);

    await authService.saveTokens(
      accessToken: response.data['access'],
      refreshToken: response.data['refresh'],
      userType: userType,
    );

    return UserModel.fromJson(response.data['user']);
  }
  
  // Alias pour compatibilité (déprécié)
  @Deprecated('Use register() instead. Will be removed in future versions.')
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
  }) async {
    return register(
      email: email,
      password: password,
      password2: password2,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      userType: 'merchant',
      businessName: businessName,
      businessType: businessType,
      businessAddress: businessAddress,
    );
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
      userType: response.data['user']['user_type'],
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