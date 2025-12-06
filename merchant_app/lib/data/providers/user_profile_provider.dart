import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/merchant_model.dart';
import '../models/user_model.dart';
import '../models/individual_model.dart';
import '../repositories/merchant_repository.dart';
import '../repositories/individual_repository.dart';
import '../../core/providers.dart';
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
      
      print('🔍 loadProfile: authState=$authState, user=$user');
      
      if (user == null) {
        print('❌ loadProfile: Utilisateur non authentifié');
        state = const AsyncValue.data(null);
        return;
      }

      // Récupérer le userType depuis UserModel
      final userType = user.userType;
      print('👤 loadProfile: userType=$userType, email=${user.email}');
      
      if (userType == 'merchant') {
        // Charger le profil merchant
        print('🏪 Chargement du profil merchant...');
        try {
          final merchantRepo = ref.read(merchantRepositoryProvider);
          final merchant = await merchantRepo.getProfile();
          print('✅ Profil merchant chargé: ${merchant.businessName}');
          state = AsyncValue.data(merchant);
        } catch (e, st) {
          print('❌ Erreur chargement profil merchant: $e');
          // Si erreur, retourner les données du user
          state = AsyncValue.error(
            'Impossible de charger le profil marchand. Veuillez vérifier votre connexion.',
            st,
          );
        }
      } else if (userType == 'individual') {
        // Charger le profil particulier via IndividualRepository
        print('👤 Chargement du profil individual...');
        try {
          final individualRepo = ref.read(individualRepositoryProvider);
          final individual = await individualRepo.getProfile();
          print('✅ Profil individual chargé: ${individual.fullName}');
          state = AsyncValue.data(individual);
        } catch (e, st) {
          print('⚠️ Profil individual non trouvé, utilisation des données du user');
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
        print('❌ Type d\'utilisateur inconnu: $userType');
        state = AsyncValue.error(
          'Type d\'utilisateur non reconnu. Veuillez contacter le support.',
          StackTrace.current,
        );
      }
    } catch (e, st) {
      print('❌ Erreur lors du chargement du profil: $e');
      print('Stack trace: $st');
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
