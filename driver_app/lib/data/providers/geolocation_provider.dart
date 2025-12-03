// lib/data/providers/geolocation_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/network/dio_client.dart';
import '../models/commune/commune_model.dart';
import '../repositories/geolocation_repository.dart';

// Provider du repository
final geolocationRepositoryProvider = Provider<GeolocationRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return GeolocationRepository(dioClient: dioClient);
});

// Provider pour la liste des communes
final communesProvider = FutureProvider<List<CommuneModel>>((ref) async {
  final repository = ref.watch(geolocationRepositoryProvider);
  return repository.fetchCommunes();
});

// Provider pour obtenir les coordonnées d'une commune spécifique
final communeCoordinatesProvider = FutureProvider.family<LatLng?, String>((ref, commune) async {
  final repository = ref.watch(geolocationRepositoryProvider);
  return repository.getCommuneCoordinates(commune);
});

// Provider pour géocoder une adresse
class GeocodeAddressNotifier extends StateNotifier<AsyncValue<LatLng?>> {
  final GeolocationRepository _repository;

  GeocodeAddressNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> geocodeAddress(String address, {String city = 'Abidjan'}) async {
    state = const AsyncValue.loading();
    try {
      final coords = await _repository.geocodeAddress(address, city: city);
      state = AsyncValue.data(coords);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final geocodeAddressProvider = StateNotifierProvider<GeocodeAddressNotifier, AsyncValue<LatLng?>>((ref) {
  final repository = ref.watch(geolocationRepositoryProvider);
  return GeocodeAddressNotifier(repository);
});
