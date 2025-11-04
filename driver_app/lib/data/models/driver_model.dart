// lib/data/models/driver_model.dart

import 'user_model.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Modèle représentant un livreur (Driver)
class DriverModel {
  final int id;
  final UserModel user;
  final String phone;
  final String vehicleType; // 'moto', 'voiture', 'velo'
  final String vehicleRegistration;
  final String verificationStatus; // 'pending', 'verified', 'rejected'
  final String availabilityStatus; // 'available', 'busy', 'offline'
  final double? currentLatitude;
  final double? currentLongitude;
  final double rating;
  final int totalDeliveries;
  final String? profilePhoto;
  final String? driversLicense;
  final String? vehicleRegistrationDocument;
  final DateTime createdAt;

  DriverModel({
    required this.id,
    required this.user,
    required this.phone,
    required this.vehicleType,
    required this.vehicleRegistration,
    required this.verificationStatus,
    required this.availabilityStatus,
    this.currentLatitude,
    this.currentLongitude,
    this.rating = 0.0,
    this.totalDeliveries = 0,
    this.profilePhoto,
    this.driversLicense,
    this.vehicleRegistrationDocument,
    required this.createdAt,
  });

  /// Créer depuis JSON
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as int,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      phone: json['phone'] as String,
      vehicleType: json['vehicle_type'] as String,
      vehicleRegistration: json['vehicle_registration'] as String,
      verificationStatus: json['verification_status'] as String? ?? 'pending',
      availabilityStatus: json['availability_status'] as String? ?? 'offline',
      currentLatitude: json['current_latitude']?.toDouble(),
      currentLongitude: json['current_longitude']?.toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalDeliveries: json['total_deliveries'] ?? 0,
      profilePhoto: json['profile_photo'] as String?,
      driversLicense: json['drivers_license'] as String?,
      vehicleRegistrationDocument: json['vehicle_registration_document'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'phone': phone,
      'vehicle_type': vehicleType,
      'vehicle_registration': vehicleRegistration,
      'verification_status': verificationStatus,
      'availability_status': availabilityStatus,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'rating': rating,
      'total_deliveries': totalDeliveries,
      'profile_photo': profilePhoto,
      'drivers_license': driversLicense,
      'vehicle_registration_document': vehicleRegistrationDocument,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ========== GETTERS UTILITAIRES ==========

  /// Vérifie si le driver est disponible
  bool get isAvailable => availabilityStatus == 'available';

  /// Vérifie si le driver est occupé
  bool get isBusy => availabilityStatus == 'busy';

  /// Vérifie si le driver est hors ligne
  bool get isOffline => availabilityStatus == 'offline';

  /// Vérifie si le driver est vérifié
  bool get isVerified => verificationStatus == 'verified';

  /// Vérifie si le driver a une position GPS
  bool get hasLocation => currentLatitude != null && currentLongitude != null;

  /// Obtenir la couleur du statut de disponibilité
  Color get availabilityColor {
    switch (availabilityStatus) {
      case 'available':
        return AppColors.availableGreen;
      case 'busy':
        return AppColors.busyOrange;
      case 'offline':
      default:
        return AppColors.offlineGrey;
    }
  }

  /// Obtenir le label du statut en français
  String get availabilityLabel {
    switch (availabilityStatus) {
      case 'available':
        return 'Disponible';
      case 'busy':
        return 'Occupé';
      case 'offline':
      default:
        return 'Hors ligne';
    }
  }

  /// Obtenir le type de véhicule en français
  String get vehicleTypeLabel {
    switch (vehicleType) {
      case 'moto':
        return 'Moto';
      case 'voiture':
        return 'Voiture';
      case 'velo':
        return 'Vélo';
      default:
        return vehicleType;
    }
  }

  /// Copier avec modifications
  DriverModel copyWith({
    int? id,
    UserModel? user,
    String? phone,
    String? vehicleType,
    String? vehicleRegistration,
    String? verificationStatus,
    String? availabilityStatus,
    double? currentLatitude,
    double? currentLongitude,
    double? rating,
    int? totalDeliveries,
    String? profilePhoto,
    String? driversLicense,
    String? vehicleRegistrationDocument,
    DateTime? createdAt,
  }) {
    return DriverModel(
      id: id ?? this.id,
      user: user ?? this.user,
      phone: phone ?? this.phone,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      driversLicense: driversLicense ?? this.driversLicense,
      vehicleRegistrationDocument: vehicleRegistrationDocument ?? this.vehicleRegistrationDocument,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'DriverModel(id: $id, name: ${user.fullName}, status: $availabilityStatus)';
  }
}
