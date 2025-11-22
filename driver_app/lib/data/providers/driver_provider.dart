import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../repositories/driver_repository.dart';
import '../models/driver_model.dart';
import 'auth_provider.dart';

// ========== REPOSITORY PROVIDER ==========

final driverRepositoryProvider = Provider<DriverRepository>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return DriverRepository(dioClient);
});

// ========== DRIVER STATE ==========

class DriverState {
  final bool isLoading;
  final DriverModel? driver;
  final Map<String, dynamic>? stats;
  final Map<String, dynamic>? earnings;
  final String? error;
  final String? successMessage;

  DriverState({
    this.isLoading = false,
    this.driver,
    this.stats,
    this.earnings,
    this.error,
    this.successMessage,
  });

  DriverState copyWith({
    bool? isLoading,
    DriverModel? driver,
    Map<String, dynamic>? stats,
    Map<String, dynamic>? earnings,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return DriverState(
      isLoading: isLoading ?? this.isLoading,
      driver: driver ?? this.driver,
      stats: stats ?? this.stats,
      earnings: earnings ?? this.earnings,
      error: clearError ? null : error,
      successMessage: clearSuccess ? null : successMessage,
    );
  }
}

// ========== DRIVER NOTIFIER ==========


class DriverNotifier extends Notifier<DriverState> {
  DriverRepository get _repository => ref.read(driverRepositoryProvider);

  @override
  DriverState build() {
    return DriverState();
  }

  /// Supprimer la photo de profil
  Future<bool> deleteProfilePhoto() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.deleteProfilePhoto();
      // Recharger le profil pour mettre à jour l'UI
      await loadProfile();
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Photo de profil supprimée avec succès',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Charger le profil du driver
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final driver = await _repository.getMyProfile();
      state = state.copyWith(
        isLoading: false,
        driver: driver,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Mettre à jour la disponibilité (available/busy/offline)
  Future<bool> updateAvailability(String status) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedDriver = await _repository.updateAvailability(status);
      state = state.copyWith(
        isLoading: false,
        driver: updatedDriver,
        successMessage: 'Disponibilité mise à jour',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Passer en disponible
  Future<bool> goOnline() async {
    return await updateAvailability('available');
  }

  /// Passer occupé
  Future<bool> goBusy() async {
    return await updateAvailability('busy');
  }

  /// Passer hors ligne
  Future<bool> goOffline() async {
    return await updateAvailability('offline');
  }

  /// Charger les statistiques (courses, rating, etc.)
  Future<void> loadStats() async {
    state = state.copyWith(clearError: true);
    try {
      final stats = await _repository.getMyStats();
      state = state.copyWith(stats: stats);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Charger les gains (aujourd'hui, semaine, mois)
  Future<void> loadEarnings({String? period}) async {
    state = state.copyWith(clearError: true);
    try {
      final earnings = await _repository.getMyEarnings(period: period);
      state = state.copyWith(earnings: earnings);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Rafraîchir toutes les données
  Future<void> refresh() async {
    await Future.wait([
      loadProfile(),
      loadStats(),
      loadEarnings(),
    ]);
  }

  /// Effacer les messages
  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  /// Upload une photo de profil - Support Web et Mobile via XFile
  /// Accepte XFile (web/mobile)
  Future<String> uploadProfilePhoto(
    XFile photoFile, [
    String? filename,
  ]) async {
    try {
      final dioClient = ref.read(dioClientProvider);
      Response response;

      MultipartFile multipartFile;
      if (kIsWeb) {
        // Sur le web : utiliser les bytes de XFile
        final bytes = await photoFile.readAsBytes();
        multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: filename ?? photoFile.name,
        );
      } else {
        // Sur mobile : utiliser le path de XFile
        multipartFile = await MultipartFile.fromFile(
          photoFile.path,
          filename: filename ?? photoFile.name,
        );
      }

      final formData = FormData();
      formData.files.add(MapEntry('photo', multipartFile));

      response = await dioClient.post(
        '/api/v1/auth/upload-profile-photo/',
        data: formData,
      );


      // Vérifier la réponse
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }

      final data = response.data as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Réponse vide du serveur');
      }

      // Backend retourne: { success: true, profile_photo: "url", ... }
      if (data['success'] != true) {
        throw Exception(data['error'] ?? data['message'] ?? 'Upload échoué');
      }

      final photoUrl = data['profile_photo'] as String?;
      if (photoUrl == null || photoUrl.isEmpty) {
        throw Exception('URL de photo non retournée par le serveur');
      }

      return photoUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de la photo: $e');
    }
  }


  // Ancienne méthode web supprimée : uploadProfilePhotoWeb n'est plus nécessaire car tout passe par XFile

  /// Mettre à jour le profil du driver
  /// Accepte un Map avec les champs à mettre à jour
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      print('💾 [DEBUG] updateProfile called with: $data');
      final updatedDriver = await _repository.updateProfile(data);
      // 🔄 Recharger le profil depuis le serveur pour obtenir la dernière URL Cloudinary
      print('🔄 [DEBUG] Profile updated - reloading from server...');
      await loadProfile();
      print('✅ [DEBUG] Profile reloaded from server');
      state = state.copyWith(
        isLoading: false,
        driver: updatedDriver,
        successMessage: 'Profil mis à jour avec succès',
      );
      return true;
    } catch (e) {
      print('❌ [DEBUG] updateProfile error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
}

// ========== PROVIDER ==========

final driverProvider = NotifierProvider<DriverNotifier, DriverState>(DriverNotifier.new);

// ========== COMPUTED PROVIDERS ==========

/// Profil driver actuel
final currentDriverProvider = Provider<DriverModel?>((ref) {
  return ref.watch(driverProvider).driver;
});

/// Statut de disponibilité actuel
final availabilityStatusProvider = Provider<String?>((ref) {
  return ref.watch(currentDriverProvider)?.availabilityStatus;
});

/// Vérifie si le driver est disponible
final isDriverAvailableProvider = Provider<bool>((ref) {
  return ref.watch(currentDriverProvider)?.isAvailable ?? false;
});

/// Vérifie si le driver est occupé
final isDriverBusyProvider = Provider<bool>((ref) {
  return ref.watch(currentDriverProvider)?.isBusy ?? false;
});

/// Vérifie si le driver est hors ligne
final isDriverOfflineProvider = Provider<bool>((ref) {
  return ref.watch(currentDriverProvider)?.isOffline ?? true;
});

/// Vérifie si le driver est vérifié
final isDriverVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(currentDriverProvider)?.isVerified ?? false;
});

/// Rating du driver
final driverRatingProvider = Provider<double>((ref) {
  return ref.watch(currentDriverProvider)?.rating ?? 0.0;
});

/// Nombre total de livraisons
final totalDeliveriesProvider = Provider<int>((ref) {
  return ref.watch(currentDriverProvider)?.totalDeliveries ?? 0;
});