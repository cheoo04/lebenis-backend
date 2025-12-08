// lib/core/repositories/quartier_repository.dart
// Repository pour gérer les quartiers et le géocodage

import 'package:latlong2/latlong.dart';
import '../network/dio_client.dart';
import '../models/quartier_model.dart';

// Parse un champ dynamique en `double` en acceptant `num` ou `String`.
double _parseToDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

class QuartierRepository {
  final DioClient _dioClient;

  QuartierRepository({required DioClient dioClient}) : _dioClient = dioClient;

  /// Récupère tous les quartiers d'une commune
  /// Si commune est null, retourne tous les quartiers d'Abidjan
  Future<List<QuartierModel>> fetchQuartiers({String? commune}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (commune != null && commune.isNotEmpty) {
        queryParams['commune'] = commune;
      }

      final response = await _dioClient.get(
        '/api/v1/locations/quartiers/',
        queryParameters: queryParams,
      );

      final quartiers = (response.data['quartiers'] as List)
          .map((json) => QuartierModel.fromJson(json))
          .toList();

      return quartiers;
    } catch (e) {
      throw Exception('Impossible de charger les quartiers');
    }
  }

  /// Recherche des quartiers par nom (pour autocomplete)
  /// Retourne une liste de quartiers correspondant à la recherche
  Future<List<QuartierModel>> searchQuartiers(String query) async {
    if (query.length < 2) return [];

    try {
      final response = await _dioClient.get(
        '/api/v1/locations/quartiers/search/',
        queryParameters: {'q': query, 'limit': 10},
      );

      final results = (response.data['results'] as List)
          .map((json) => QuartierModel.fromJson(json))
          .toList();

      return results;
    } catch (e) {
      return [];
    }
  }

  /// Géocode un quartier pour obtenir ses coordonnées GPS
  /// Utilise d'abord les données locales, puis Nominatim si non trouvé
  Future<QuartierModel?> geocodeQuartier(String quartier, String commune) async {
    try {
      final response = await _dioClient.post(
        '/api/v1/locations/geocode-quartier/',
        data: {
          'quartier': quartier,
          'commune': commune,
        },
      );

      if (response.data['success'] == true) {
        return QuartierModel(
          nom: response.data['quartier'] ?? quartier,
          commune: response.data['commune'] ?? commune,
          latitude: _parseToDouble(response.data['latitude']),
          longitude: _parseToDouble(response.data['longitude']),
          source: response.data['source'],
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Géocode une adresse libre
  /// Utile quand l'utilisateur tape une adresse complète
  Future<LatLng?> geocodeAddress(String address, {String city = 'Abidjan'}) async {
    try {
      final response = await _dioClient.post(
        '/api/v1/locations/geocode-address/',
        data: {
          'address': address,
          'city': city,
        },
      );

      if (response.data['success'] == true) {
        return LatLng(
          _parseToDouble(response.data['latitude']),
          _parseToDouble(response.data['longitude']),
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Reverse geocoding: convertit des coordonnées GPS en adresse
  /// Utile après sélection sur une carte
  Future<String?> reverseGeocode(double latitude, double longitude) async {
    try {
      final response = await _dioClient.post(
        '/api/v1/locations/reverse-geocode/',
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.data['success'] == true) {
        return response.data['address'];
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Récupère des suggestions d'adresses (pour autocomplete)
  Future<List<AddressSuggestion>> getSuggestions(String query) async {
    if (query.length < 3) return [];

    try {
      final response = await _dioClient.get(
        '/api/v1/locations/suggestions/',
        queryParameters: {'q': query, 'limit': 5},
      );

      final suggestions = (response.data['suggestions'] as List)
          .map((json) => AddressSuggestion.fromJson(json))
          .toList();

      return suggestions;
    } catch (e) {
      return [];
    }
  }

  /// Liste les communes disponibles
  Future<List<String>> fetchCommunes() async {
    try {
      final response = await _dioClient.get('/api/v1/locations/communes/');
      return List<String>.from(response.data['communes']);
    } catch (e) {
      // Fallback sur les communes par défaut
      return [
        'COCODY', 'PLATEAU', 'YOPOUGON', 'MARCORY', 'ABOBO',
        'ADJAME', 'KOUMASSI', 'TREICHVILLE', 'PORT-BOUET', 'ATTECOUBE',
        'ANYAMA', 'BINGERVILLE', 'SONGON'
      ];
    }
  }
}
