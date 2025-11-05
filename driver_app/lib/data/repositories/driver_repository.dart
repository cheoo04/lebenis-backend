// lib/data/repositories/driver_repository.dart

import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/driver_model.dart';

/// Repository pour les opérations Driver
/// Responsabilité: Gérer uniquement les données du DRIVER (profil, stats, disponibilité, position)
/// Les livraisons sont gérées par DeliveryRepository
class DriverRepository {
  final DioClient _dioClient;

  DriverRepository(this._dioClient);

  /// Récupérer mon profil driver
  Future<DriverModel> getMyProfile() async {
    final response = await _dioClient.get(ApiConstants.driverMe);
    return DriverModel.fromJson(response.data);
  }

  /// Mettre à jour disponibilité (available/busy/offline)
  Future<DriverModel> updateAvailability(String status) async {
    final response = await _dioClient.post(
      ApiConstants.toggleAvailability,
      data: {'availability_status': status},
    );
    return DriverModel.fromJson(response.data['driver']);
  }

  /// Mettre à jour le profil du driver
  Future<DriverModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _dioClient.patch(
      ApiConstants.driverMe,
      data: data,
    );
    // Backend retourne: { success: true, message: "...", driver: {...} }
    return DriverModel.fromJson(response.data['driver']);
  }

  /// Mettre à jour position GPS
  Future<void> updateLocation(double lat, double lng) async {
    await _dioClient.post(
      ApiConstants.updateLocation,
      data: {
        'current_latitude': lat,
        'current_longitude': lng,
      },
    );
  }

  /// Récupérer mes statistiques (gains, courses, rating)
  Future<Map<String, dynamic>> getMyStats() async {
    final response = await _dioClient.get(ApiConstants.myStats);
    return response.data;
  }

  /// Récupérer mes gains (par jour, semaine, mois)
  Future<Map<String, dynamic>> getMyEarnings({
    String? period, // 'today', 'week', 'month'
  }) async {
    final response = await _dioClient.get(
      ApiConstants.myEarnings,
      queryParameters: period != null ? {'period': period} : null,
    );
    return response.data;
  }
}
