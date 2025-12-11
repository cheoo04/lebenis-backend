// lib/data/repositories/driver_repository.dart

import 'package:flutter/foundation.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/database/hive_service.dart';
import '../../core/database/models/driver_profile_cache.dart';
import '../models/driver_model.dart';

/// Repository pour les opérations Driver avec support offline
/// Responsabilité: Gérer uniquement les données du DRIVER (profil, stats, disponibilité, position)
/// Les livraisons sont gérées par DeliveryRepository
class DriverRepository {
  final DioClient _dioClient;
  final HiveService _hiveService = HiveService.instance;

  DriverRepository(this._dioClient);

  /// Supprimer la photo de profil du driver
  Future<void> deleteProfilePhoto() async {
    await _dioClient.delete('/api/v1/auth/delete-profile-photo/');
  }

  /// Récupérer mon profil driver (avec cache offline)
  Future<DriverModel> getMyProfile({bool forceRefresh = false}) async {
    try {
      final response = await _dioClient.get(ApiConstants.driverMe);
      final driver = DriverModel.fromJson(response.data);
      
      // Mettre en cache le profil
      await _cacheProfile(response.data);
      
      return driver;
    } catch (e) {
      // En cas d'erreur réseau, utiliser le cache
      if (kDebugMode) {
        debugPrint('📴 Network error, using cached profile: $e');
      }
      final cached = _getCachedProfile();
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  /// Récupérer le profil depuis le cache
  DriverModel? _getCachedProfile() {
    try {
      final cached = _hiveService.getCachedDriverProfile();
      if (cached != null) {
        return DriverModel.fromJson(cached.toJson());
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error reading cached profile: $e');
      }
      return null;
    }
  }

  /// Mettre en cache le profil
  Future<void> _cacheProfile(Map<String, dynamic> profileJson) async {
    try {
      final cache = DriverProfileCache.fromJson(profileJson);
      await _hiveService.cacheDriverProfile(cache);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error caching profile: $e');
      }
    }
  }

  /// Mettre à jour disponibilité (available/busy/offline)
  /// Met aussi à jour le cache local
  Future<DriverModel> updateAvailability(String status) async {
    final response = await _dioClient.post(
      ApiConstants.toggleAvailability,
      data: {'availability_status': status},
    );
    final driver = DriverModel.fromJson(response.data['driver']);
    
    // Mettre à jour le cache
    await _hiveService.updateDriverAvailability(status == 'available');
    
    return driver;
  }

  /// Mettre à jour le profil du driver
  Future<DriverModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _dioClient.patch(
      ApiConstants.driverMe,
      data: data,
    );
    final driver = DriverModel.fromJson(response.data['driver']);
    
    // Mettre à jour le cache
    await _cacheProfile(response.data['driver']);
    
    return driver;
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
  /// Met à jour le cache local des earnings
  Future<Map<String, dynamic>> getMyEarnings({
    String? period, // 'today', 'week', 'month'
  }) async {
    final response = await _dioClient.get(
      ApiConstants.paymentMyEarnings,
      queryParameters: period != null ? {'period': period} : null,
    );
    
    // Mettre à jour les earnings en cache
    final data = response.data;
    if (data is Map<String, dynamic>) {
      await _hiveService.updateDriverEarnings(
        todayEarnings: double.tryParse(data['today']?.toString() ?? '0'),
        weekEarnings: double.tryParse(data['week']?.toString() ?? '0'),
        monthEarnings: double.tryParse(data['month']?.toString() ?? '0'),
      );
    }
    
    return response.data;
  }
}
