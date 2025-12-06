// lib/data/providers/delivery_provider.dart
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/delivery_repository.dart';
import '../models/delivery_model.dart';
import '../models/driver_model.dart';
import 'auth_provider.dart';
import '../../core/constants/backend_constants.dart';

// ========== REPOSITORY PROVIDERS ==========

/// Delivery Repository Provider
final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return DeliveryRepository(dioClient);
});

// ========== DELIVERY STATE ==========

class DeliveryState {
  final bool isLoading;
  final List<DeliveryModel> deliveries;
  final DeliveryModel? activeDelivery;
  final String? error;
  final String? successMessage;

  DeliveryState({
    this.isLoading = false,
    this.deliveries = const [],
    this.activeDelivery,
    this.error,
    this.successMessage,
  });

  DeliveryState copyWith({
    bool? isLoading,
    List<DeliveryModel>? deliveries,
    DeliveryModel? activeDelivery,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearActiveDelivery = false,
  }) {
    return DeliveryState(
      isLoading: isLoading ?? this.isLoading,
      deliveries: deliveries ?? this.deliveries,
      activeDelivery: clearActiveDelivery ? null : (activeDelivery ?? this.activeDelivery),
      error: clearError ? null : error,
      successMessage: clearSuccess ? null : successMessage,
    );
  }
}

// ========== DELIVERY NOTIFIER ==========


class DeliveryNotifier extends Notifier<DeliveryState> {
  late final DeliveryRepository _deliveryRepository;

  @override
  DeliveryState build() {
    _deliveryRepository = ref.read(deliveryRepositoryProvider);
    return DeliveryState();
  }

  /// Charger les livraisons DISPONIBLES (pending_assignment)
  /// Ces sont les livraisons que le driver peut accepter
  Future<void> loadAvailableDeliveries() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final deliveries = await _deliveryRepository.getAvailableDeliveries();
      state = state.copyWith(
        isLoading: false,
        deliveries: deliveries,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Charger MES livraisons assignées (avec filtre status optionnel)
  Future<void> loadMyDeliveries({String? status}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final deliveries = await _deliveryRepository.getMyDeliveries(status: status);
      state = state.copyWith(
        isLoading: false,
        deliveries: deliveries,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Charger les détails d'une livraison
  Future<DeliveryModel?> loadDeliveryDetails(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final delivery = await _deliveryRepository.getDeliveryDetails(id);
      state = state.copyWith(isLoading: false);
      return delivery;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Accepter une livraison
  Future<bool> acceptDelivery(String id, {DriverModel? driver}) async {
    // Vérification préalable côté client
    if (driver != null) {
      if (!driver.isVerified) {
        state = state.copyWith(
          error: 'Votre compte n\'est pas encore vérifié. Veuillez attendre la validation de votre profil.',
        );
        return false;
      }
      
      if (!driver.isAvailable) {
        state = state.copyWith(
          error: 'Vous devez être en ligne (disponible) pour accepter une livraison. Veuillez passer en mode "Disponible" dans votre profil.',
        );
        return false;
      }
    }
    
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final delivery = await _deliveryRepository.acceptDelivery(id);
      
      // Mettre à jour la liste
      final updatedList = state.deliveries.map((d) {
        return d.id == id ? delivery : d;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        deliveries: updatedList,
        activeDelivery: delivery,
        successMessage: 'Livraison acceptée avec succès',
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

  /// Refuser une livraison
  Future<bool> rejectDelivery(String id, String reason) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _deliveryRepository.rejectDelivery(id, reason);
      
      // Retirer de la liste
      final updatedList = state.deliveries.where((d) => d.id != id).toList();

      state = state.copyWith(
        isLoading: false,
        deliveries: updatedList,
        successMessage: 'Livraison refusée',
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

  /// Confirmer la récupération du colis
  Future<bool> confirmPickup({
    required String id,
    String? pickupPhoto,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final delivery = await _deliveryRepository.confirmPickup(
        id: id,
        pickupPhoto: pickupPhoto,
        notes: notes,
      );

      // Mettre à jour la livraison active
      state = state.copyWith(
        isLoading: false,
        activeDelivery: delivery,
        successMessage: 'Colis récupéré avec succès',
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

  /// Confirmer la livraison au destinataire
  Future<bool> confirmDelivery({
    required String id,
    required String confirmationCode,
    String? deliveryPhoto,
    Uint8List? deliveryPhotoBytes,
    String? recipientSignature,
    Uint8List? recipientSignatureBytes,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final delivery = await _deliveryRepository.confirmDelivery(
        id: id,
        confirmationCode: confirmationCode,
        deliveryPhoto: deliveryPhoto,
        deliveryPhotoBytes: deliveryPhotoBytes,
        recipientSignature: recipientSignature,
        recipientSignatureBytes: recipientSignatureBytes,
        notes: notes,
      );

      // Retirer de la liste active, ajouter aux terminées
      final updatedList = state.deliveries.map((d) {
        return d.id == id ? delivery : d;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        deliveries: updatedList,
        activeDelivery: null,
        successMessage: 'Livraison terminée avec succès ! 🎉',
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

  /// Annuler une livraison
  Future<bool> cancelDelivery(String id, String reason) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final delivery = await _deliveryRepository.cancelDelivery(id, reason);
      
      // Mettre à jour la liste
      final updatedList = state.deliveries.map((d) {
        return d.id == id ? delivery : d;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        deliveries: updatedList,
        activeDelivery: null,
        successMessage: 'Livraison annulée',
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

  /// Définir la livraison active
  void setActiveDelivery(DeliveryModel? delivery) {
    state = state.copyWith(
      activeDelivery: delivery,
      clearActiveDelivery: delivery == null,
    );
  }

  /// Effacer les messages
  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  /// Rafraîchir les livraisons
  Future<void> refresh() async {
    await loadMyDeliveries();
  }
}

// ========== PROVIDER ==========

final deliveryProvider = NotifierProvider<DeliveryNotifier, DeliveryState>(DeliveryNotifier.new);

// ========== COMPUTED PROVIDERS ==========

/// Livraisons actives uniquement
final activeDeliveriesProvider = Provider<List<DeliveryModel>>((ref) {
  final deliveries = ref.watch(deliveryProvider).deliveries;
  return deliveries.where((d) => d.isActive).toList();
});

/// Livraisons terminées uniquement
final completedDeliveriesProvider = Provider<List<DeliveryModel>>((ref) {
  final deliveries = ref.watch(deliveryProvider).deliveries;
  return deliveries.where((d) => d.isCompleted).toList();
});

/// Nombre de livraisons actives
final activeDeliveryCountProvider = Provider<int>((ref) {
  return ref.watch(activeDeliveriesProvider).length;
});

/// Livraisons disponibles (pending_assignment) uniquement
final availableForAcceptanceProvider = Provider<List<DeliveryModel>>((ref) {
  final deliveries = ref.watch(deliveryProvider).deliveries;
  return deliveries.where((d) => 
    d.status == BackendConstants.deliveryStatusPendingAssignment
  ).toList();
});

/// Nombre de livraisons disponibles
final availableDeliveryCountProvider = Provider<int>((ref) {
  return ref.watch(availableForAcceptanceProvider).length;
});

// ========== AVAILABLE DELIVERIES PROVIDER (SEPARATE STATE) ==========

/// State pour les livraisons disponibles (via endpoint dédié)
class AvailableDeliveriesState {
  final bool isLoading;
  final List<DeliveryModel> deliveries;
  final String? error;

  AvailableDeliveriesState({
    this.isLoading = false,
    this.deliveries = const [],
    this.error,
  });

  AvailableDeliveriesState copyWith({
    bool? isLoading,
    List<DeliveryModel>? deliveries,
    String? error,
    bool clearError = false,
  }) {
    return AvailableDeliveriesState(
      isLoading: isLoading ?? this.isLoading,
      deliveries: deliveries ?? this.deliveries,
      error: clearError ? null : error,
    );
  }
}

class AvailableDeliveriesNotifier extends Notifier<AvailableDeliveriesState> {
  late final DeliveryRepository _repository;

  @override
  AvailableDeliveriesState build() {
    _repository = ref.read(deliveryRepositoryProvider);
    return AvailableDeliveriesState();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final deliveries = await _repository.getAvailableDeliveries();
      state = state.copyWith(isLoading: false, deliveries: deliveries);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async => load();
}

final availableDeliveriesNotifierProvider = 
    NotifierProvider<AvailableDeliveriesNotifier, AvailableDeliveriesState>(
      AvailableDeliveriesNotifier.new,
    );

/// Provider simple pour accéder à la liste des livraisons disponibles
final availableDeliveriesProvider = Provider<List<DeliveryModel>>((ref) {
  return ref.watch(availableDeliveriesNotifierProvider).deliveries;
});
