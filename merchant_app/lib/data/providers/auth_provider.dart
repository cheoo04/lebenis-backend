
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../../core/providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final authService = ref.watch(authServiceProvider);
  return AuthRepository(dioClient, authService);
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
    } catch (e, st) {
      state = AsyncValue.error(e, st);
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
    } catch (e, st) {
      // DioClient a déjà formaté l'erreur dans ApiException
      state = AsyncValue.error(e.toString().replaceFirst('ApiException(0): ', ''), st);
    }
  }

  Future<void> logout() async {
    await repository.logout();
    state = const AsyncValue.data(null);
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(
  () => AuthNotifier(),
);