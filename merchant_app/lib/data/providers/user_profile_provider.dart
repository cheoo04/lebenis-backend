import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/merchant_model.dart';
import '../models/individual_model.dart';
import 'auth_provider.dart';
import 'merchant_provider.dart';
import 'individual_provider.dart';

/// Provider générique qui charge le profil en fonction du type d'utilisateur
class UserProfileNotifier extends Notifier<AsyncValue<dynamic>> {
  @override
  AsyncValue<dynamic> build() {
    // Charger le profil au démarrage
    loadProfile();
    return const AsyncValue.loading();
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
        try {
          final merchantRepo = ref.read(merchantRepositoryProvider);
          final merchant = await merchantRepo.getProfile();
          state = AsyncValue.data(merchant);
        } catch (e, st) {
          // Si erreur, retourner les données du user
          state = AsyncValue.error(
            'Impossible de charger le profil marchand. Veuillez vérifier votre connexion.',
            st,
          );
        }
      } else if (userType == 'individual') {
        // Charger le profil particulier via IndividualRepository
        try {
          final individualRepo = ref.read(individualRepositoryProvider);
          final individual = await individualRepo.getProfile();
          state = AsyncValue.data(individual);
        } catch (e) {
          // Fallback: utiliser les données du user si le profil n'existe pas encore
          state = AsyncValue.data({
            'user_type': 'individual',
            'email': user.email,
            'first_name': user.firstName,
            'last_name': user.lastName,
            'phone': '',
          });
        }
      } else {
        state = AsyncValue.error(
          'Type d\'utilisateur non reconnu. Veuillez contacter le support.',
          StackTrace.current,
        );
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
  return profile.value is IndividualModel || 
         (profile.value is Map && profile.value['user_type'] == 'individual');
});
