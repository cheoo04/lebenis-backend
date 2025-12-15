
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../../core/providers.dart';
import '../../core/services/firebase_auth_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final authService = ref.watch(authServiceProvider);
  return AuthRepository(dioClient, authService);
});

/// Provider pour le service Firebase Auth
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return FirebaseAuthService(dioClient: dioClient);
});

class AuthNotifier extends Notifier<AsyncValue<UserModel?>> {
  late final AuthRepository repository;

  @override
  AsyncValue<UserModel?> build() {
    repository = ref.watch(authRepositoryProvider);
    return const AsyncValue.data(null);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await repository.login(
        email: email,
        password: password,
      );
      state = AsyncValue.data(user);
      
      // Authentifier sur Firebase pour le chat temps réel (non bloquant)
      _authenticateFirebase();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  /// Authentifie l'utilisateur sur Firebase (non bloquant)
  Future<void> _authenticateFirebase() async {
    try {
      final firebaseAuthService = ref.read(firebaseAuthServiceProvider);
      await firebaseAuthService.signInWithCustomToken();
    } catch (e) {
      // Ne pas bloquer le login si Firebase échoue
      debugPrint('[AuthProvider] Firebase auth failed (non-blocking): $e');
    }
  }

  Future<void> register({
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
    state = const AsyncValue.loading();
    try {
      final user = await repository.register(
        email: email,
        password: password,
        password2: password2,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        userType: userType,
        businessName: businessName,
        businessType: businessType,
        businessAddress: businessAddress,
      );
      state = AsyncValue.data(user);
      
      // Authentifier sur Firebase pour le chat temps réel (non bloquant)
      _authenticateFirebase();
    } catch (e, st) {
      // DioClient a déjà formaté l'erreur dans ApiException
      state = AsyncValue.error(e.toString().replaceFirst('ApiException(0): ', ''), st);
    }
  }

  Future<void> logout() async {
    // Déconnecter de Firebase aussi
    try {
      final firebaseAuthService = ref.read(firebaseAuthServiceProvider);
      await firebaseAuthService.signOut();
    } catch (e) {
      debugPrint('[AuthProvider] Firebase logout error: $e');
    }
    
    await repository.logout();
    state = const AsyncValue.data(null);
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(
  () => AuthNotifier(),
);