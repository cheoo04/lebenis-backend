import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/individual_model.dart';
import '../repositories/individual_repository.dart';
import '../../core/providers.dart';

/// Provider du repository
final individualRepositoryProvider = Provider<IndividualRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return IndividualRepository(dioClient);
});

/// Provider du profil particulier
class IndividualProfileNotifier extends Notifier<AsyncValue<IndividualModel?>> {
  @override
  AsyncValue<IndividualModel?> build() {
    loadProfile();
    return const AsyncValue.loading();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(individualRepositoryProvider);
      final profile = await repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile({
    String? individualId,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
  }) async {
    final currentProfile = state.value;
    final idToUse = currentProfile?.id ?? individualId;
    if (idToUse == null) {
      throw Exception('Aucun profil à mettre à jour');
    }

    state = const AsyncValue.loading();
    try {
      final repository = ref.read(individualRepositoryProvider);
      final updatedProfile = await repository.updateProfile(
        individualId: idToUse,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        address: address,
      );
      state = AsyncValue.data(updatedProfile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> refresh() => loadProfile();
}

final individualProfileProvider = NotifierProvider<IndividualProfileNotifier, AsyncValue<IndividualModel?>>(
  () => IndividualProfileNotifier(),
);
