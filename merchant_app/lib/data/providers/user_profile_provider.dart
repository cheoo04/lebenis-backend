import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/merchant_model.dart';
import '../models/user_model.dart';
import '../repositories/merchant_repository.dart';
import '../../core/providers.dart';
import 'auth_provider.dart';
import 'merchant_provider.dart';

/// Provider générique qui charge le profil en fonction du type d'utilisateur
class UserProfileNotifier extends Notifier<AsyncValue<dynamic>> {
  @override
  AsyncValue<dynamic> build() {
    return const AsyncValue.data(null);
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final authState = ref.read(authStateProvider);
      final user = authState.value;
      
      if (user == null) {
        state = const AsyncValue.data(null);
        return;
      }

      // Récupérer le userType depuis UserModel
      final userType = user.userType;
      
      if (userType == 'merchant') {
        // Charger le profil merchant
        final merchantRepo = ref.read(merchantRepositoryProvider);
        final merchant = await merchantRepo.getProfile();
        state = AsyncValue.data(merchant);
      } else if (userType == 'individual') {
        // Pour l'instant, on utilise juste les données du user
        // TODO: créer un IndividualRepository si besoin
        state = AsyncValue.data({
          'user_type': 'individual',
          'email': user.email,
          'first_name': user.firstName,
          'last_name': user.lastName,
          'phone': '',
        });
      } else {
        state = AsyncValue.error('Type d\'utilisateur inconnu: $userType', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => loadProfile();
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, AsyncValue<dynamic>>(
  () => UserProfileNotifier(),
);

/// Helper pour savoir si l'utilisateur est un merchant
final isMerchantProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile.value is MerchantModel;
});

/// Helper pour savoir si l'utilisateur est un particulier
final isIndividualProvider = Provider<bool>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile.value is Map && profile.value['user_type'] == 'individual';
});
