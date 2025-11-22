import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/zone_model.dart';
import '../repositories/zone_repository.dart';

import '../../core/network/dio_client.dart';
import '../../core/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final authService = ref.read(authServiceProvider);
  return DioClient(authService);
});

final zoneRepositoryProvider = Provider<ZoneRepository>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return ZoneRepository(dioClient);
});

class ZoneState {
  final List<ZoneModel> zones;
  final bool isLoading;
  final String? error;

  ZoneState({
    this.zones = const [],
    this.isLoading = false,
    this.error,
  });

  ZoneState copyWith({
    List<ZoneModel>? zones,
    bool? isLoading,
    String? error,
  }) {
    return ZoneState(
      zones: zones ?? this.zones,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}


class ZoneNotifier extends Notifier<ZoneState> {
  late final ZoneRepository repository;

  @override
  ZoneState build() {
    repository = ref.read(zoneRepositoryProvider);
    return ZoneState();
  }

  Future<void> loadZones() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final zones = await repository.fetchZones();
      state = state.copyWith(zones: zones, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void toggleZone(String id) {
    final updated = state.zones.map((z) =>
      z.id == id ? z.copyWith(selected: !z.selected) : z
    ).toList();
    state = state.copyWith(zones: updated);
  }

  Future<void> saveSelectedZones() async {
    final selectedIds = state.zones.where((z) => z.selected).map((z) => z.id).toList();
    await repository.saveSelectedZones(selectedIds);
  }
}

final zoneProvider = NotifierProvider<ZoneNotifier, ZoneState>(ZoneNotifier.new);
