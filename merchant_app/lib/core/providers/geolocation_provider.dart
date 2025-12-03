// lib/core/providers/geolocation_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../data/providers/pricing_provider.dart'; // Pour dioClientProvider
import '../models/commune_model.dart';
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
// Utilisation: ref.read(geocodeAddressProvider({'address': 'Cocody', 'city': 'Abidjan'}))
final geocodeAddressProvider = FutureProvider.family<LatLng?, Map<String, String>>((ref, params) async {
  final repository = ref.watch(geolocationRepositoryProvider);
  final address = params['address'] ?? '';
  final city = params['city'] ?? 'Abidjan';
  return repository.geocodeAddress(address, city: city);
});
