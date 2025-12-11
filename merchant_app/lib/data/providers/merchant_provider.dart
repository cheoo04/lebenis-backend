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
  @override
  AsyncValue<MerchantStatsModel?> build() {
    // Déclencher le chargement initial automatiquement
    Future.microtask(() => loadStats());
    return const AsyncValue.loading();
  }

  Future<void> loadStats({int periodDays = 30}) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(merchantRepositoryProvider);
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
  @override
  AsyncValue<MerchantModel?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> updateProfile({
    required String merchantId,
    String? businessName,
    String? phone,
    String? businessAddress,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.watch(merchantRepositoryProvider);
      final updated = await repository.updateProfile(
        merchantId: merchantId,
        businessName: businessName,
        phone: phone,
        businessAddress: businessAddress,
      );
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateDocuments({
    required dynamic rccmDocument,
    required dynamic idDocument,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.watch(merchantRepositoryProvider);
      final updated = await repository.updateDocuments(
        rccmDocument: rccmDocument,
        idDocument: idDocument,
      );
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.watch(merchantRepositoryProvider);
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