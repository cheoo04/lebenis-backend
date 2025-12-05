// lib/core/repositories/geolocation_repository.dart

import 'package:latlong2/latlong.dart';
import '../network/dio_client.dart';
import '../models/commune_model.dart';

class GeolocationRepository {
  final DioClient _dioClient;

  GeolocationRepository({required DioClient dioClient}) : _dioClient = dioClient;

  /// Récupère la liste de toutes les communes avec leurs coordonnées GPS
  Future<List<CommuneModel>> fetchCommunes() async {
    try {
      final response = await _dioClient.get('/api/v1/pricing/communes/');
      final communes = (response.data['communes'] as List)
          .map((json) => CommuneModel.fromJson(json))
          .toList();
      return communes;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des communes: $e');
    }
  }

  /// Récupère les coordonnées GPS d'une commune spécifique
  Future<LatLng?> getCommuneCoordinates(String commune) async {
    try {
      final response = await _dioClient.get(
        '/api/v1/pricing/communes/coordinates/',
        queryParameters: {'commune': commune},
      );
      return LatLng(
        (response.data['latitude'] as num).toDouble(),
        (response.data['longitude'] as num).toDouble(),
      );
    } catch (e) {
      print('Erreur lors de la récupération des coordonnées: $e');
      return null;
    }
  }

  /// Géocode une adresse complète pour obtenir ses coordonnées GPS
  Future<LatLng?> geocodeAddress(String address, {String city = 'Abidjan'}) async {
    try {
      final response = await _dioClient.post(
        '/api/v1/pricing/geocode/',
        data: {
          'address': address,
          'city': city,
        },
      );
      return LatLng(
        (response.data['latitude'] as num).toDouble(),
        (response.data['longitude'] as num).toDouble(),
      );
    } catch (e) {
      print('Géocodage échoué: $e');
      return null;
    }
  }

  /// Trouve la commune la plus proche d'une position GPS donnée
  Future<String?> getNearestCommune(double latitude, double longitude) async {
    try {
      print('🔍 Recherche commune proche de: $latitude, $longitude');
      final communes = await fetchCommunes();
      print('📍 ${communes.length} communes chargées');
      
      if (communes.isEmpty) {
        print('❌ Aucune commune disponible');
        return null;
      }

      // Calculer la distance pour chaque commune
      final Distance distance = const Distance();
      String? nearestCommune;
      double minDistance = double.infinity;

      for (final commune in communes) {
        final dist = distance.as(
          LengthUnit.Kilometer,
          LatLng(latitude, longitude),
          LatLng(commune.latitude, commune.longitude),
        );

        if (dist < minDistance) {
          minDistance = dist;
          nearestCommune = commune.commune;
        }
      }

      print('✓ Commune la plus proche: $nearestCommune (distance: ${minDistance.toStringAsFixed(2)} km)');
      return nearestCommune;
    } catch (e, stackTrace) {
      print('❌ Erreur lors de la recherche de la commune la plus proche: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
}
