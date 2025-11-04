// lib/data/repositories/delivery_repository.dart

import 'package:flutter/foundation.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/delivery_model.dart';
import 'package:dio/dio.dart';

/// Repository pour les livraisons
/// Responsabilité: 
/// - getAvailableDeliveries(): Livraisons disponibles à accepter (pending_assignment)
/// - getMyDeliveries(): Mes livraisons assignées
/// - Actions: accept, reject, confirm pickup/delivery, cancel
class DeliveryRepository {
  final DioClient _dioClient;

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
      debugPrint('DEBUG: Unexpected available deliveries format: ${data.runtimeType}');
      return [];
    } catch (e) {
      debugPrint('DEBUG: Error loading available deliveries: $e');
      rethrow;
    }
  }

  /// Récupérer mes livraisons du driver connecté
  Future<List<DeliveryModel>> getMyDeliveries({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConstants.myDeliveries, // Utilise l'endpoint spécifique driver
        queryParameters: {
          if (status != null) 'status': status,
          'page': page,
          'page_size': pageSize,
        },
      );
      
      final data = response.data;
      
      // Si la réponse est null ou vide, retourner une liste vide
      if (data == null) {
        return [];
      }
      
      // Si c'est une Map avec 'results' (pagination Django REST)
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
      debugPrint('DEBUG: Unexpected delivery data format: ${data.runtimeType}');
      return [];
    } catch (e) {
      debugPrint('DEBUG: Error loading my deliveries: $e');
      rethrow;
    }
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
      return DeliveryModel.fromJson(response.data);
    }

    // Sinon, simple POST
    final response = await _dioClient.post(
      ApiConstants.confirmPickup(id),
      data: data,
    );
    return DeliveryModel.fromJson(response.data);
  }

  /// Confirmer livraison au destinataire (delivery)
  Future<DeliveryModel> confirmDelivery({
    required String id,
    String? deliveryPhoto,
    String? recipientSignature,
    String? notes,
  }) async {
    final data = <String, dynamic>{};
    
    if (notes != null) {
      data['notes'] = notes;
    }

    // Upload photo et signature si fournis
    if (deliveryPhoto != null || recipientSignature != null) {
      final formData = FormData();
      
      if (deliveryPhoto != null) {
        formData.files.add(MapEntry(
          'delivery_photo',
          await MultipartFile.fromFile(deliveryPhoto),
        ));
      }
      
      if (recipientSignature != null) {
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
    return DeliveryModel.fromJson(response.data);
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
