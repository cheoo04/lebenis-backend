
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
    required String businessName,
    required String businessType,
    required String businessAddress,
    String? rccmDocumentPath,
    String? idDocumentPath,
  }) async {
    // DEBUG
    print('register called');
    state = const AsyncValue.loading();
    try {
      print('before repository.registerMerchant');
      final user = await repository.registerMerchant(
        email: email,
        password: password,
        password2: password2,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        businessName: businessName,
        businessType: businessType,
        businessAddress: businessAddress,
        rccmDocumentPath: rccmDocumentPath,
        idDocumentPath: idDocumentPath,
      );
      print('after repository.registerMerchant');
      state = AsyncValue.data(user);
    } on DioException catch (dioErr, st) {
      print('DioException catch');
      if (dioErr.type == DioExceptionType.connectionTimeout || dioErr.type == DioExceptionType.receiveTimeout) {
        state = AsyncValue.error('Le serveur ne répond pas. Veuillez vérifier votre connexion ou réessayer plus tard.', st);
      } else if (dioErr.response != null && dioErr.response?.data != null) {
        print('DioException backend response:');
        print(dioErr.response?.data);
        final data = dioErr.response?.data;
        String msg = 'Erreur inconnue';
        if (data is Map && data.isNotEmpty) {
          msg = data.toString();
        } else if (data is String) {
          msg = data;
        } else {
          msg = data.toString();
        }
        state = AsyncValue.error(msg, st);
      } else {
        state = AsyncValue.error('Erreur réseau ou serveur inattendue.', st);
      }
    } catch (e, st) {
      print('catch global error: $e');
      print('exception type: \'${e.runtimeType}\'');
      print('exception details: ${e.toString()}');
      // Affiche le champ details si présent (ApiException)
      dynamic details;
      try {
        details = (e as dynamic).details;
        print('exception.details: $details');
      } catch (_) {}
      String msg = e.toString();
      if (details != null) {
        if (details is Map && details.isNotEmpty) {
          msg = details.entries.map((entry) {
            final value = entry.value;
            if (value is List && value.isNotEmpty) {
              return "${entry.key}: ${value.join(", ")}";
            } else {
              return "${entry.key}: $value";
            }
          }).join("\n");
        } else if (details is List && details.isNotEmpty) {
          msg = details.join("\n");
        } else if (details is String) {
          msg = details;
        } else {
          msg = details.toString();
        }
      }
      state = AsyncValue.error(msg, st);
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