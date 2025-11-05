// lib/data/providers/driver_provider.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class DriverNotifier extends StateNotifier<DriverState> {
  final DriverRepository _repository;
  final Ref _ref;

  DriverNotifier(this._repository, this._ref) : super(DriverState());

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

  /// Upload une photo de profil
  /// Upload vers /api/v1/auth/me/ avec multipart/form-data via PATCH
  Future<String> uploadProfilePhoto(File photoFile) async {
    try {
      final dioClient = _ref.read(dioClientProvider);
      
      // Upload via multipart/form-data vers l'endpoint auth avec PATCH
      final response = await dioClient.uploadFile(
        '/api/v1/auth/me/',
        filePath: photoFile.path,
        fieldName: 'profile_photo',
        method: 'PATCH', // Utiliser PATCH au lieu de POST
      );
      
      // Le backend retourne l'utilisateur complet avec profile_photo mis à jour
      final data = response.data as Map<String, dynamic>;
      final photoUrl = data['profile_photo'] as String?;
      
      if (photoUrl == null || photoUrl.isEmpty) {
        throw Exception('URL de photo non retournée par le serveur');
      }
      
      return photoUrl;
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de la photo: $e');
    }
  }

  /// Mettre à jour le profil du driver
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedDriver = await _repository.updateProfile(data);
      state = state.copyWith(
        isLoading: false,
        driver: updatedDriver,
        successMessage: 'Profil mis à jour avec succès',
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
}

// ========== PROVIDER ==========

final driverProvider = StateNotifierProvider<DriverNotifier, DriverState>((ref) {
  final repository = ref.read(driverRepositoryProvider);
  return DriverNotifier(repository, ref);
});

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
