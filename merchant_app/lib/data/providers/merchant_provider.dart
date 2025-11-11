import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/merchant_repository.dart';
import '../models/merchant_model.dart';
import '../models/merchant_stats_model.dart';

final merchantRepositoryProvider = Provider((ref) {
  throw UnimplementedError();
});

final merchantProfileProvider = FutureProvider((ref) async {
  final repository = ref.watch(merchantRepositoryProvider);
  return repository.getProfile();
});

final merchantStatsProvider = FutureProvider((ref) async {
  final repository = ref.watch(merchantRepositoryProvider);
  return repository.getStats();
});

final merchantNotifierProvider = StateNotifierProvider<MerchantNotifier, AsyncValue<MerchantModel?>>((ref) {
  final repository = ref.watch(merchantRepositoryProvider);
  return MerchantNotifier(repository);
});

class MerchantNotifier extends StateNotifier<AsyncValue<MerchantModel?>> {
  final MerchantRepository repository;

  MerchantNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile({
    String? businessName,
    String? phone,
    String? address,
  }) async {
    state = const AsyncValue.loading();
    try {
      final updated = await repository.updateProfile(
        businessName: businessName,
        phone: phone,
        address: address,
      );
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await loadProfile();
  }
}