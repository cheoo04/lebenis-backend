// lib/data/repositories/delivery_repository.dart

import 'package:flutter/foundation.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/database/hive_service.dart';
import '../../core/database/models/delivery_cache.dart';
import '../models/delivery_model.dart';
import 'package:dio/dio.dart';

/// Repository pour les livraisons avec support offline
/// Responsabilité: 
/// - getAvailableDeliveries(): Livraisons disponibles à accepter (pending_assignment)
/// - getMyDeliveries(): Mes livraisons assignées
/// - Actions: accept, reject, confirm pickup/delivery, cancel
/// - Cache local via Hive pour fonctionnement offline
class DeliveryRepository {
  final DioClient _dioClient;
  final HiveService _hiveService = HiveService.instance;

  DeliveryRepository(this._dioClient);

  /// Récupérer les livraisons DISPONIBLES à accepter (pending_assignment)
  /// Endpoint: /api/v1/drivers/available-deliveries/
  /// Retourne les livraisons dans les zones du driver, non encore assignées
  Future<List<DeliveryModel>> getAvailableDeliveries({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.availableDeliveries, // Utilise le bon endpoint
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );
      
      final data = response.data;
      
      // Si la réponse est null ou vide, retourner une liste vide
      if (data == null) {
        return [];
      }
      
      // Le backend retourne {count: X, deliveries: [...], driver_zones: [...]}
      if (data is Map && data.containsKey('deliveries')) {
        final deliveries = data['deliveries'];
        if (deliveries is List) {
          return deliveries
              .map((json) => DeliveryModel.fromJson(json))
              .toList();
        }
        return [];
      }
      
      // Si c'est une Map avec 'results' (pagination Django REST standard)
      if (data is Map && data.containsKey('results')) {
        final results = data['results'];
        if (results is List) {
          return results
              .map((json) => DeliveryModel.fromJson(json))
              .toList();
        }
        return [];
      }
      
      // Si c'est directement une liste
      if (data is List) {
        return data
            .map((json) => DeliveryModel.fromJson(json))
            .toList();
      }
      
      // Sinon, retourner une liste vide
      return [];
    } catch (e) {
      rethrow;
    }
  }

  /// Récupérer mes livraisons du driver connecté
  /// Avec mise en cache automatique pour le mode offline
  Future<List<DeliveryModel>> getMyDeliveries({
    String? status,
    int page = 1,
    int pageSize = 20,
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.myDeliveries,
        queryParameters: {
          if (status != null) 'status': status,
          'page': page,
          'page_size': pageSize,
        },
      );
      
      final data = response.data;
      
      if (data == null) {
        return _getCachedDeliveries(status: status);
      }
      
      List<DeliveryModel> deliveries = [];
      List<Map<String, dynamic>> rawData = [];
      
      // Parser la réponse
      if (data is Map && data.containsKey('results')) {
        final results = data['results'];
        if (results is List) {
          rawData = results.cast<Map<String, dynamic>>();
          deliveries = results.map((json) => DeliveryModel.fromJson(json)).toList();
        }
      } else if (data is List) {
        rawData = data.cast<Map<String, dynamic>>();
        deliveries = data.map((json) => DeliveryModel.fromJson(json)).toList();
      }
      
      // Mettre en cache les livraisons
      if (rawData.isNotEmpty) {
        await _cacheDeliveries(rawData);
      }
      
      return deliveries;
    } catch (e) {
      // En cas d'erreur réseau, utiliser le cache
      if (kDebugMode) {
        debugPrint('📴 Network error, using cache: $e');
      }
      return _getCachedDeliveries(status: status);
    }
  }

  /// Récupérer les livraisons depuis le cache local
  List<DeliveryModel> _getCachedDeliveries({String? status}) {
    try {
      List<DeliveryCache> cached;
      if (status != null) {
        cached = _hiveService.getDeliveriesByStatus(status);
      } else {
        cached = _hiveService.getCachedDeliveries();
      }
      return cached.map((c) => DeliveryModel.fromJson(c.toJson())).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error reading cache: $e');
      }
      return [];
    }
  }

  /// Mettre en cache les livraisons
  Future<void> _cacheDeliveries(List<Map<String, dynamic>> deliveriesJson) async {
    try {
      final caches = deliveriesJson.map((json) => DeliveryCache.fromJson(json)).toList();
      await _hiveService.cacheDeliveries(caches);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error caching deliveries: $e');
      }
    }
  }


  /// Démarrer une livraison (passer à in_progress)
  /// Utilise le bon endpoint backend : /api/v1/deliveries/{id}/confirm-pickup/
  /// Retourne le modèle de livraison mis à jour.
  Future<DeliveryModel> startDelivery(String id, {String? pickupPhoto, String? notes}) async {
    final data = <String, dynamic>{};
    if (notes != null) {
      data['notes'] = notes;
    }
    // Si une photo est fournie, uploader en multipart
    if (pickupPhoto != null) {
      final response = await _dioClient.uploadFile(
        ApiConstants.confirmPickup(id),
        filePath: pickupPhoto,
        fieldName: 'pickup_photo',
        additionalData: data,
      );
      final respData = response.data;
      final payload = (respData is Map && respData.containsKey('delivery')) ? respData['delivery'] : respData;
      return DeliveryModel.fromJson(payload);
    }
    // Sinon, simple POST
    final response = await _dioClient.post(
      ApiConstants.confirmPickup(id),
      data: data,
    );
    final respData = response.data;
    final payload = (respData is Map && respData.containsKey('delivery')) ? respData['delivery'] : respData;
    return DeliveryModel.fromJson(payload);
  }
  

  /// Récupérer les détails d'une livraison
  Future<DeliveryModel> getDeliveryDetails(String id) async {
    final response = await _dioClient.get(
      ApiConstants.deliveryDetails(id),
    );
    return DeliveryModel.fromJson(response.data);
  }

  /// Accepter une livraison
  Future<DeliveryModel> acceptDelivery(String id) async {
    final response = await _dioClient.post(
      ApiConstants.acceptDelivery(id),
    );
    return DeliveryModel.fromJson(response.data);
  }

  /// Refuser une livraison
  Future<void> rejectDelivery(String id, String reason) async {
    await _dioClient.post(
      ApiConstants.rejectDelivery(id),
      data: {'reason': reason},
    );
  }

  /// Confirmer récupération du colis (pickup)
  Future<DeliveryModel> confirmPickup({
    required String id,
    String? pickupPhoto,
    String? notes,
  }) async {
    final data = <String, dynamic>{};
    
    if (notes != null) {
      data['notes'] = notes;
    }

    // Si on a une photo, l'uploader
    if (pickupPhoto != null) {
      final response = await _dioClient.uploadFile(
        ApiConstants.confirmPickup(id),
        filePath: pickupPhoto,
        fieldName: 'pickup_photo',
        additionalData: data,
      );
      final respData = response.data;
      final payload = (respData is Map && respData.containsKey('delivery')) ? respData['delivery'] : respData;
      return DeliveryModel.fromJson(payload);
    }

    // Sinon, simple POST
    final response = await _dioClient.post(
      ApiConstants.confirmPickup(id),
      data: data,
    );
    final respData = response.data;
    final payload = (respData is Map && respData.containsKey('delivery')) ? respData['delivery'] : respData;
    return DeliveryModel.fromJson(payload);
  }

  /// Confirmer livraison au destinataire (delivery)
  Future<DeliveryModel> confirmDelivery({
    required String id,
    required String confirmationCode,
    String? deliveryPhoto,
    Uint8List? deliveryPhotoBytes,
    String? recipientSignature,
    Uint8List? recipientSignatureBytes,
    String? notes,
  }) async {
    final data = <String, dynamic>{
      'confirmation_code': confirmationCode,
    };
    if (notes != null) {
      data['notes'] = notes;
    }

    // Upload photo et signature si fournis
    if (deliveryPhoto != null || deliveryPhotoBytes != null || recipientSignature != null || recipientSignatureBytes != null) {
      // Vérifier le PIN d'abord pour éviter d'uploader de gros fichiers inutilement
      try {
        await _dioClient.post(
          ApiConstants.verifyPin(id),
          data: {'confirmation_code': confirmationCode},
        );
      } catch (e) {
        // Propager l'erreur pour que le provider/UI puisse l'afficher
        rethrow;
      }
      final formData = FormData();
      if (deliveryPhotoBytes != null) {
        formData.files.add(MapEntry(
          'delivery_photo',
          MultipartFile.fromBytes(deliveryPhotoBytes, filename: 'delivery_photo.png'),
        ));
      } else if (deliveryPhoto != null) {
        formData.files.add(MapEntry(
          'delivery_photo',
          await MultipartFile.fromFile(deliveryPhoto),
        ));
      }
      if (recipientSignatureBytes != null) {
        formData.files.add(MapEntry(
          'recipient_signature',
          MultipartFile.fromBytes(recipientSignatureBytes, filename: 'recipient_signature.png'),
        ));
      } else if (recipientSignature != null) {
        formData.files.add(MapEntry(
          'recipient_signature',
          await MultipartFile.fromFile(recipientSignature),
        ));
      }
      // Ajouter les autres données
      data.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
      final response = await _dioClient.post(
        ApiConstants.confirmDelivery(id),
        data: formData,
      );
      return DeliveryModel.fromJson(response.data);
    }
    // Sinon, simple POST
    final response = await _dioClient.post(
      ApiConstants.confirmDelivery(id),
      data: data,
    );
    final respData = response.data;
    final payload = (respData is Map && respData.containsKey('delivery')) ? respData['delivery'] : respData;
    return DeliveryModel.fromJson(payload);
  }

  /// Annuler une livraison
  Future<DeliveryModel> cancelDelivery(String id, String reason) async {
    final response = await _dioClient.post(
      ApiConstants.cancelDelivery(id),
      data: {'cancellation_reason': reason},
    );
    return DeliveryModel.fromJson(response.data);
  }
}
