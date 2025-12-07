// lib/data/repositories/geolocation_repository.dart

import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import '../../core/network/dio_client.dart';
import '../models/commune/commune_model.dart';

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
      return null;
    }
  }
}
