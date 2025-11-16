import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/zone_model.dart';
import '../repositories/zone_repository.dart';

final zoneRepositoryProvider = Provider<ZoneRepository>((ref) => ZoneRepository());

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

class ZoneNotifier extends StateNotifier<ZoneState> {
  final ZoneRepository repository;
  ZoneNotifier(this.repository) : super(ZoneState());

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

final zoneProvider = StateNotifierProvider<ZoneNotifier, ZoneState>((ref) {
  final repo = ref.watch(zoneRepositoryProvider);
  return ZoneNotifier(repo);
});
