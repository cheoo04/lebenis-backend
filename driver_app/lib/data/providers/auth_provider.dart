// lib/data/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/services/auth_service.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

// ========== PROVIDERS BASIQUES ==========

/// DioClient Provider
final dioClientProvider = Provider<DioClient>((ref) {
  final authService = ref.read(authServiceProvider);
  return DioClient(authService);
});

/// AuthService Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// AuthRepository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.read(dioClientProvider);
  final authService = ref.read(authServiceProvider);
  return AuthRepository(dioClient, authService);
});

// ========== AUTH STATE ==========

class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;
  final bool isLoggedIn;

  AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
    bool? isLoggedIn,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

// ========== AUTH NOTIFIER ==========


class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;
  late final AuthService _authService;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    _authService = ref.read(authServiceProvider);
    return AuthState();
  }

  /// Login
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.login(email, password);
      final user = UserModel.fromJson(response['user']);
      state = state.copyWith(
        isLoading: false,
        user: user,
        isLoggedIn: true,
      );
    } catch (e) {
      debugPrint('DEBUG LOGIN ERROR: $e');
      debugPrint('DEBUG ERROR TYPE: ${e.runtimeType}');
      final errorMessage = _getErrorMessage(e);
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      rethrow;
    }
  }

  /// Register Driver
  Future<void> registerDriver({
    required String email,
    required String password,
    required String phone,
    required String vehicleType,
    String? firstName,
    String? lastName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.registerDriver(
        email: email,
        password: password,
        phone: phone,
        vehicleType: vehicleType,
        firstName: firstName,
        lastName: lastName,
      );
      final user = UserModel.fromJson(response['user']);
      state = state.copyWith(
        isLoading: false,
        user: user,
        isLoggedIn: true,
      );
    } catch (e) {
      debugPrint('DEBUG REGISTER ERROR: $e');
      debugPrint('DEBUG ERROR TYPE: ${e.runtimeType}');
      final errorMessage = _getErrorMessage(e);
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.logout();
      state = AuthState();
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      state = state.copyWith(isLoading: false, error: errorMessage);
      rethrow;
    }
  }

  /// Check si connecté et charger les infos utilisateur
  Future<void> checkLoginStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    
    if (isLoggedIn) {
      // Charger les infos utilisateur depuis le storage
      try {
        final userId = await _authService.getUserId();
        final email = await _authService.getUserEmail();
        final userType = await _authService.getUserType();
        final userName = await _authService.getUserName();
        
        if (userId != null && email != null) {
          // Séparer le nom complet en prénom et nom de famille
          String? firstName;
          String? lastName;
          if (userName != null && userName.isNotEmpty) {
            final nameParts = userName.split(' ');
            firstName = nameParts.isNotEmpty ? nameParts[0] : null;
            lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;
          }
          
          final user = UserModel(
            id: userId,
            email: email,
            userType: userType ?? 'driver',
            firstName: firstName,
            lastName: lastName,
            isVerified: true,
            createdAt: DateTime.now(),
          );
          
          state = state.copyWith(
            isLoggedIn: true,
            user: user,
          );
          return;
        }
      } catch (e) {
        debugPrint('Erreur chargement infos utilisateur: $e');
      }
    }
    
    state = state.copyWith(isLoggedIn: isLoggedIn);
  }

  /// Demander la réinitialisation du mot de passe
  Future<bool> requestPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.requestPasswordReset(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      debugPrint('DEBUG PASSWORD RESET REQUEST ERROR: $e');
      final errorMessage = _getErrorMessage(e);
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    }
  }

  /// Confirmer la réinitialisation du mot de passe avec le code
  Future<bool> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.confirmPasswordReset(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      debugPrint('DEBUG PASSWORD RESET CONFIRM ERROR: $e');
      final errorMessage = _getErrorMessage(e);
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    }
  }

  /// Changer le mot de passe (utilisateur connecté)
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      debugPrint('DEBUG CHANGE PASSWORD ERROR: $e');
      final errorMessage = _getErrorMessage(e);
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    }
  }

  /// Convertir les erreurs en messages compréhensibles
  String _getErrorMessage(dynamic error) {
    // Si c'est une ApiException, utiliser directement son message
    if (error is ApiException) {
      return error.message;
    }
    
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('socketexception') || errorStr.contains('network')) {
      return 'Erreur de connexion. Vérifiez votre réseau.';
    } else if (errorStr.contains('timeout')) {
      return 'Connexion trop lente. Vérifiez votre réseau.';
    } else if (errorStr.contains('unauthorized') || errorStr.contains('401') || 
               errorStr.contains('aucun compte actif') || errorStr.contains('identifiants')) {
      return 'Email ou mot de passe incorrect.';
    } else if (errorStr.contains('email') && errorStr.contains('exist')) {
      return 'Cet email est déjà utilisé.';
    } else if (errorStr.contains('phone') && errorStr.contains('exist')) {
      return 'Ce numéro de téléphone est déjà utilisé.';
    } else if (errorStr.contains('invalid')) {
      return 'Données invalides. Vérifiez vos informations.';
    } else if (errorStr.contains('null') && errorStr.contains('subtype')) {
      return 'Erreur de données. Veuillez réessayer.';
    } else if (errorStr.contains('password') || errorStr.contains('mot de passe')) {
      // Si c'est une erreur de mot de passe, extraire le message complet
      final originalStr = error.toString();
      if (originalStr.contains('Exception:')) {
        return originalStr.split('Exception:')[1].trim();
      }
      return 'Le mot de passe ne respecte pas les critères de sécurité.';
    } else if (errorStr.contains('exception:')) {
      // Extraire le message après "Exception: "
      final parts = error.toString().split('Exception:');
      if (parts.length > 1) {
        return parts[1].trim();
      }
    }
    
    // Message par défaut avec l'erreur complète pour debug
    return 'Erreur: ${error.toString()}';
  }
}

/// Auth Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
