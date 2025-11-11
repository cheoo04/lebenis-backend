import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider((ref) {
  // À configurer dans main.dart
  throw UnimplementedError();
});

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AsyncValue<UserModel?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(repository);
});

class AuthStateNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository repository;

  AuthStateNotifier(this.repository) : super(const AsyncValue.data(null)) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await repository.isLoggedIn();
    if (!isLoggedIn) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await repository.login(email: email, password: password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String businessName,
    required String phone,
    required String address,
    String? registreCommercePath,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await repository.registerMerchant(
        email: email,
        password: password,
        businessName: businessName,
        phone: phone,
        address: address,
        registreCommercePath: registreCommercePath,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await repository.logout();
    state = const AsyncValue.data(null);
  }
}