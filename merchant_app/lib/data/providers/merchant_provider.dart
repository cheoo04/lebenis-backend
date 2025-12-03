import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/merchant_repository.dart';
import '../models/merchant_model.dart';
import '../models/merchant_stats_model.dart';
import '../../core/providers.dart';

final merchantRepositoryProvider = Provider<MerchantRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return MerchantRepository(dioClient);
});

class MerchantStatsNotifier extends Notifier<AsyncValue<MerchantStatsModel?>> {
  late final MerchantRepository repository;

  @override
  AsyncValue<MerchantStatsModel?> build() {
    repository = ref.watch(merchantRepositoryProvider);
    return const AsyncValue.loading();
  }

  Future<void> loadStats({int periodDays = 30}) async {
    state = const AsyncValue.loading();
    try {
      final stats = await repository.getStats(periodDays: periodDays);
      state = AsyncValue.data(stats);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh({int periodDays = 30}) async {
    await loadStats(periodDays: periodDays);
  }
}

final merchantStatsProvider = NotifierProvider<MerchantStatsNotifier, AsyncValue<MerchantStatsModel?>>(
  () => MerchantStatsNotifier(),
);

class MerchantNotifier extends Notifier<AsyncValue<MerchantModel?>> {
  late final MerchantRepository repository;

  @override
  AsyncValue<MerchantModel?> build() {
    repository = ref.watch(merchantRepositoryProvider);
    return const AsyncValue.data(null);
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

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final merchant = await repository.getProfile();
      state = AsyncValue.data(merchant);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Alias pour compatibilité
  Future<void> fetchProfile() => loadProfile();

  Future<void> refresh() async {
    await loadProfile();
  }
}

final merchantProfileProvider = NotifierProvider<MerchantNotifier, AsyncValue<MerchantModel?>>(
  () => MerchantNotifier(),
);