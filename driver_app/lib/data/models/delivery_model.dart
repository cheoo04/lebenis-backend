// lib/data/models/delivery_model.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

/// Modèle représentant une livraison (Delivery)
class DeliveryModel {
  final String id; // Changed from int to String for UUID support
  final String trackingNumber;
  final String status;
  
  // Adresses
  final String pickupAddress;
  final String pickupCommune;
  final String pickupQuartier;
  final String pickupPrecision;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final String deliveryAddress;
  final String deliveryCommune;
  final String deliveryQuartier;
  final String deliveryPrecision;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  
  // Destinataire
  final String recipientName;
  final String recipientPhone;
  
  // Colis
  final String packageDescription;
  final double weight;
  final double price;
  final double distanceKm;
  final String? notes;
  
  // Relations
  final Map<String, dynamic>? merchant;
  final Map<String, dynamic>? driver;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime? assignedAt;
  final DateTime? pickupTime;
  final DateTime? deliveryTime;
  final DateTime? cancelledAt;
  
  // Autres
  final String? pickupPhoto;
  final String? deliveryPhoto;
  final String? recipientSignature;
  final String? cancellationReason;
  
  // Payment fields
  final String? paymentMethod;
  final double? codAmount;
  
  // Delivery proof (aliases for compatibility)
  String? get photoUrl => deliveryPhoto;
  String? get signatureUrl => recipientSignature;
  String? get deliveryNotes => notes;

  DeliveryModel({
    required this.id,
    required this.trackingNumber,
    required this.status,
    required this.pickupAddress,
    required this.pickupCommune,
    required this.pickupQuartier,
    required this.pickupPrecision,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.deliveryAddress,
    required this.deliveryCommune,
    required this.deliveryQuartier,
    required this.deliveryPrecision,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.recipientName,
    required this.recipientPhone,
    required this.packageDescription,
    required this.weight,
    required this.price,
    required this.distanceKm,
    this.notes,
    this.merchant,
    this.driver,
    required this.createdAt,
    this.assignedAt,
    this.pickupTime,
    this.deliveryTime,
    this.cancelledAt,
    this.pickupPhoto,
    this.deliveryPhoto,
    this.recipientSignature,
    this.cancellationReason,
    this.paymentMethod,
    this.codAmount,
  });

  /// Créer depuis JSON
  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id']?.toString() ?? '',
      trackingNumber: json['tracking_number']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      // Pickup (fallback si vide)
        pickupAddress: json['pickup_address']?.toString() ?? json['pickup_commune']?.toString() ?? '',
        pickupCommune: json['pickup_commune']?.toString() ?? '',
        pickupQuartier: json['pickup_quartier']?.toString() ?? '',
        pickupPrecision: json['pickup_precision']?.toString() ?? json['pickup_address_details']?.toString() ?? '',
        pickupLatitude: json['pickup_latitude'] != null
          ? double.tryParse(json['pickup_latitude'].toString())
          : null,
      pickupLongitude: json['pickup_longitude'] != null
          ? double.tryParse(json['pickup_longitude'].toString())
          : null,
      // Delivery
        deliveryAddress: json['delivery_address']?.toString() ?? '',
        deliveryCommune: json['delivery_commune']?.toString() ?? '',
        deliveryQuartier: json['delivery_quartier']?.toString() ?? '',
        deliveryPrecision: json['delivery_precision']?.toString() ?? json['delivery_address']?.toString() ?? '',
        deliveryLatitude: json['delivery_latitude'] != null
          ? double.tryParse(json['delivery_latitude'].toString())
          : null,
      deliveryLongitude: json['delivery_longitude'] != null
          ? double.tryParse(json['delivery_longitude'].toString())
          : null,
      // Recipient
      recipientName: json['recipient_name']?.toString() ?? '',
      recipientPhone: json['recipient_phone']?.toString() ?? '',
      // Package
      packageDescription: json['package_description']?.toString() ?? '',
      weight: json['package_weight_kg'] != null
          ? double.tryParse(json['package_weight_kg'].toString()) ?? 0.0
          : 0.0,
      price: json['calculated_price'] != null
          ? double.tryParse(json['calculated_price'].toString()) ?? 0.0
          : json['actual_price'] != null
              ? double.tryParse(json['actual_price'].toString()) ?? 0.0
              : 0.0,
      distanceKm: json['distance_km'] != null
          ? double.tryParse(json['distance_km'].toString()) ?? 0.0
          : 0.0,
      notes: json['delivery_notes']?.toString(),
      // Relations
      merchant: json['merchant'] as Map<String, dynamic>?,
      driver: json['driver'] as Map<String, dynamic>?,
      // Timestamps
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      assignedAt: json['assigned_at'] != null 
          ? DateTime.parse(json['assigned_at']) 
          : null,
      pickupTime: json['picked_up_at'] != null 
          ? DateTime.parse(json['picked_up_at']) 
          : null,
      deliveryTime: json['delivered_at'] != null 
          ? DateTime.parse(json['delivered_at']) 
          : null,
      cancelledAt: json['cancelled_at'] != null 
          ? DateTime.parse(json['cancelled_at']) 
          : null,
      // Proof of delivery
      pickupPhoto: json['pickup_photo']?.toString(),
      deliveryPhoto: json['photo_url']?.toString(),
      recipientSignature: json['signature_url']?.toString(),
      cancellationReason: json['cancellation_reason']?.toString(),
      // Payment
      paymentMethod: json['payment_method']?.toString(),
      codAmount: json['cod_amount'] != null
          ? double.tryParse(json['cod_amount'].toString())
          : null,
    );
  }

  // ========== GETTERS UTILITAIRES ==========

  /// Obtenir le label du statut en français
  String get statusLabel => AppStrings.deliveryStatus[status] ?? status;

  /// Obtenir la couleur du statut
  Color get statusColor {
    switch (status) {
      case 'pending':
      case 'assigned':
        return AppColors.statusAssigned;
      case 'accepted':
        return AppColors.statusAccepted;
      case 'picked_up':
      case 'pickup_in_progress':
        return AppColors.statusPickedUp;
      case 'in_transit':
        return AppColors.statusInTransit;
      case 'delivered':
        return AppColors.statusDelivered;
      case 'cancelled':
      case 'failed':
        return AppColors.statusCancelled;
      default:
        return Colors.grey;
    }
  }

  /// Vérifie si la livraison est en cours
  bool get isActive {
    return status == 'in_progress' || status == 'pending';
  }

  /// Vérifie si la livraison est terminée
  bool get isCompleted => status == 'delivered';

  /// Vérifie si la livraison est annulée
  bool get isCancelled => status == 'cancelled' || status == 'failed';

  /// Obtenir le nom du commerçant
  String? get merchantName => merchant?['business_name'] as String?;

  /// Obtenir le nom du driver
  String? get driverName => driver?['full_name'] as String?;

  /// Formater le prix
  String get formattedPrice => '${price.toStringAsFixed(0)} FCFA';

  /// Formater la distance
  String get formattedDistance => '${distanceKm.toStringAsFixed(1)} km';

  /// Formater le poids
  String get formattedWeight => '${weight.toStringAsFixed(1)} kg';

  /// Copier avec modifications
  DeliveryModel copyWith({
    String? status,
    DateTime? assignedAt,
    DateTime? pickupTime,
    DateTime? deliveryTime,
    String? pickupPhoto,
    String? deliveryPhoto,
    String? recipientSignature,
    Map<String, dynamic>? driver,
  }) {
    return DeliveryModel(
      id: id,
      trackingNumber: trackingNumber,
      status: status ?? this.status,
      pickupAddress: pickupAddress,
      pickupCommune: pickupCommune,
      pickupQuartier: pickupQuartier,
      pickupPrecision: pickupPrecision,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      deliveryAddress: deliveryAddress,
      deliveryCommune: deliveryCommune,
      deliveryQuartier: deliveryQuartier,
      deliveryPrecision: deliveryPrecision,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      packageDescription: packageDescription,
      weight: weight,
      price: price,
      distanceKm: distanceKm,
      notes: notes,
      merchant: merchant,
      driver: driver ?? this.driver,
      createdAt: createdAt,
      assignedAt: assignedAt ?? this.assignedAt,
      pickupTime: pickupTime ?? this.pickupTime,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      cancelledAt: cancelledAt,
      pickupPhoto: pickupPhoto ?? this.pickupPhoto,
      deliveryPhoto: deliveryPhoto ?? this.deliveryPhoto,
      recipientSignature: recipientSignature ?? this.recipientSignature,
      cancellationReason: cancellationReason,
      paymentMethod: paymentMethod,
      codAmount: codAmount,
    );
  }

  @override
  String toString() {
    return 'DeliveryModel(id: $id, tracking: $trackingNumber, status: $status)';
  }
}
