import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/offline_sync_service.dart';
import '../database/hive_service.dart';
import '../database/models/delivery_cache.dart';
import '../database/models/driver_profile_cache.dart';
import '../../data/providers/auth_provider.dart';

/// Provider pour le service Hive
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService.instance;
});

/// Provider pour le service de synchronisation offline
final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return OfflineSyncService(dioClient);
});

/// Provider pour l'état de connectivité
final connectivityProvider = StreamProvider<bool>((ref) {
  final syncService = ref.watch(offlineSyncServiceProvider);
  return syncService.connectivityStream;
});

/// Provider pour savoir si on est en ligne
final isOnlineProvider = Provider<bool>((ref) {
  final asyncConnectivity = ref.watch(connectivityProvider);
  return asyncConnectivity.when(
    data: (isOnline) => isOnline,
    loading: () => true, // Assume online while loading
    error: (e, st) => true,
  );
});

/// Provider pour la progression de synchronisation
final syncProgressProvider = StreamProvider<SyncProgress>((ref) {
  final syncService = ref.watch(offlineSyncServiceProvider);
  return syncService.syncProgressStream;
});

/// Provider pour les livraisons en cache
final cachedDeliveriesProvider = Provider<List<DeliveryCache>>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return hiveService.getCachedDeliveries();
});

/// Provider pour les livraisons actives en cache
final activeCachedDeliveriesProvider = Provider<List<DeliveryCache>>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return hiveService.getActiveDeliveries();
});

/// Provider pour le profil driver en cache
final cachedDriverProfileProvider = Provider<DriverProfileCache?>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return hiveService.getCachedDriverProfile();
});

/// Provider pour les statistiques offline
final offlineStatsProvider = Provider<Map<String, int>>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return hiveService.getStats();
});

/// Provider pour le nombre de requêtes en attente
final pendingRequestCountProvider = Provider<int>((ref) {
  final syncService = ref.watch(offlineSyncServiceProvider);
  return syncService.getPendingCount();
});

/// Notifier pour gérer la synchronisation manuelle
class SyncNotifier extends Notifier<AsyncValue<SyncResult?>> {
  @override
  AsyncValue<SyncResult?> build() {
    return const AsyncValue.data(null);
  }
  
  /// Forcer une synchronisation
  Future<void> forceSync() async {
    state = const AsyncValue.loading();
    try {
      final syncService = ref.read(offlineSyncServiceProvider);
      final result = await syncService.forceSync();
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  /// Clear all offline data
  Future<void> clearOfflineData() async {
    final syncService = ref.read(offlineSyncServiceProvider);
    await syncService.clearAll();
    state = const AsyncValue.data(null);
  }
}

final syncControllerProvider = NotifierProvider<SyncNotifier, AsyncValue<SyncResult?>>(() {
  return SyncNotifier();
});
