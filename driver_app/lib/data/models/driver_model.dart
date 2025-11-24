// lib/data/models/driver_model.dart

import 'user_model.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Modèle représentant un livreur (Driver)
class DriverModel {
  final String id; // UUID du backend
  final UserModel user;
  final String phone;
  final String vehicleType; // 'moto', 'voiture', 'tricycle', 'camionnette'
  final String vehicleRegistration;
  final double vehicleCapacityKg; // Capacité de charge en kg
  final String verificationStatus; // 'pending', 'verified', 'rejected'
  final String availabilityStatus; // 'available', 'busy', 'offline'
  final double? currentLatitude;
  final double? currentLongitude;
  final double rating;
  final int totalDeliveries;
  final int? successfulDeliveries;
  final String? profilePhoto;
  final String? driversLicense;
  final DateTime? licenseExpiry;
  final String? vehicleRegistrationDocument;
  final String? vehicleInsurance;
  final DateTime? vehicleInsuranceExpiry;
  final String? vehicleTechnicalInspection;
  final DateTime? vehicleInspectionExpiry;
  final String? vehicleGrayCard;
  final String? vehicleVignette;
  final DateTime? vehicleVignetteExpiry;
  final String? identityCardNumber;
  final String? identityCardFront;
  final String? identityCardBack;
  final DateTime? dateOfBirth;
  final String? bankAccountName;
  final String? bankAccountNumber;
  final String? bankName;
  final String? mobileMoneyNumber;
  final String? mobileMoneyProvider;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelationship;
  final int? yearsOfExperience;
  final String? previousEmployer;
  final List<String>? languagesSpoken;
  final bool? isOnBreak;
  final DateTime? breakStartedAt;
  final Duration? totalBreakDurationToday;
  final DateTime? lastBreakReset;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DriverModel({
    required this.id,
    required this.user,
    required this.phone,
    required this.vehicleType,
    required this.vehicleRegistration,
    this.vehicleCapacityKg = 30.0, // Valeur par défaut
    required this.verificationStatus,
    required this.availabilityStatus,
    this.currentLatitude,
    this.currentLongitude,
    this.rating = 0.0,
    this.totalDeliveries = 0,
    this.successfulDeliveries,
    this.profilePhoto,
    this.driversLicense,
    this.licenseExpiry,
    this.vehicleRegistrationDocument,
    this.vehicleInsurance,
    this.vehicleInsuranceExpiry,
    this.vehicleTechnicalInspection,
    this.vehicleInspectionExpiry,
    this.vehicleGrayCard,
    this.vehicleVignette,
    this.vehicleVignetteExpiry,
    this.identityCardNumber,
    this.identityCardFront,
    this.identityCardBack,
    this.dateOfBirth,
    this.bankAccountName,
    this.bankAccountNumber,
    this.bankName,
    this.mobileMoneyNumber,
    this.mobileMoneyProvider,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelationship,
    this.yearsOfExperience,
    this.previousEmployer,
    this.languagesSpoken,
    this.isOnBreak,
    this.breakStartedAt,
    this.totalBreakDurationToday,
    this.lastBreakReset,
    required this.createdAt,
    this.updatedAt,
  });
  /// Créer depuis JSON
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'].toString(),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      phone: json['phone'] as String? ?? json['user']?['phone'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String? ?? 'moto',
      vehicleRegistration: json['vehicle_registration'] as String? ?? '',
      vehicleCapacityKg: json['vehicle_capacity_kg'] != null
        ? double.tryParse(json['vehicle_capacity_kg'].toString()) ?? 30.0
        : 30.0,
      verificationStatus: json['verification_status'] as String? ?? 'pending',
      availabilityStatus: json['availability_status'] as String? ?? 'offline',
      currentLatitude: json['current_latitude'] != null
        ? double.tryParse(json['current_latitude'].toString())
        : null,
      currentLongitude: json['current_longitude'] != null
        ? double.tryParse(json['current_longitude'].toString())
        : null,
      rating: json['rating'] != null
        ? double.tryParse(json['rating'].toString()) ?? 0.0
        : 0.0,
      totalDeliveries: json['total_deliveries'] as int? ?? 0,
      successfulDeliveries: json['successful_deliveries'] as int?,
      profilePhoto: json['profile_photo'] as String?,
      driversLicense: json['driver_license'] as String?,
      licenseExpiry: json['license_expiry'] != null && (json['license_expiry'] as String).isNotEmpty
        ? DateTime.tryParse(json['license_expiry'])
        : null,
      vehicleRegistrationDocument: json['vehicle_registration_document'] as String?,
      vehicleInsurance: json['vehicle_insurance'] as String?,
      vehicleInsuranceExpiry: json['vehicle_insurance_expiry'] != null && (json['vehicle_insurance_expiry'] as String).isNotEmpty
        ? DateTime.tryParse(json['vehicle_insurance_expiry'])
        : null,
      vehicleTechnicalInspection: json['vehicle_technical_inspection'] as String?,
      vehicleInspectionExpiry: json['vehicle_inspection_expiry'] != null && (json['vehicle_inspection_expiry'] as String).isNotEmpty
        ? DateTime.tryParse(json['vehicle_inspection_expiry'])
        : null,
      vehicleGrayCard: json['vehicle_gray_card'] as String?,
      vehicleVignette: json['vehicle_vignette'] as String?,
      vehicleVignetteExpiry: json['vehicle_vignette_expiry'] != null && (json['vehicle_vignette_expiry'] as String).isNotEmpty
        ? DateTime.tryParse(json['vehicle_vignette_expiry'])
        : null,
      identityCardNumber: json['identity_card_number'] as String?,
      identityCardFront: _parseStringField(json['identity_card_front']),
      identityCardBack: _parseStringField(json['identity_card_back']),
      dateOfBirth: json['date_of_birth'] != null && (json['date_of_birth'] as String).isNotEmpty
        ? DateTime.tryParse(json['date_of_birth'])
        : null,
      bankAccountName: json['bank_account_name'] as String?,
      bankAccountNumber: json['bank_account_number'] as String?,
      bankName: json['bank_name'] as String?,
      mobileMoneyNumber: json['mobile_money_number'] as String?,
      mobileMoneyProvider: json['mobile_money_provider'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      emergencyContactRelationship: json['emergency_contact_relationship'] as String?,
      yearsOfExperience: json['years_of_experience'] as int?,
      previousEmployer: json['previous_employer'] as String?,
      languagesSpoken: json['languages_spoken'] != null
        ? (json['languages_spoken'] is List)
          ? (json['languages_spoken'] as List)
              .where((e) => e != null)
              .map((e) => e.toString())
              .toList()
          : null
        : null,
      isOnBreak: json['is_on_break'] as bool?,
      breakStartedAt: json['break_started_at'] != null && (json['break_started_at'] as String).isNotEmpty
        ? DateTime.tryParse(json['break_started_at'])
        : null,
      totalBreakDurationToday: json['total_break_duration_today'] != null
        ? Duration(seconds: json['total_break_duration_today'] as int)
        : null,
      lastBreakReset: json['last_break_reset'] != null && (json['last_break_reset'] as String).isNotEmpty
        ? DateTime.tryParse(json['last_break_reset'])
        : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null && (json['updated_at'] as String).isNotEmpty
        ? DateTime.tryParse(json['updated_at'])
        : null,
    );
  }

  /// Helper to safely parse a string field, even if backend sends wrong type
  static String? _parseStringField(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is List && value.isNotEmpty && value.first is String) return value.first;
    if (value is Map && value['url'] is String) return value['url'];
    return value.toString();
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'phone': phone,
      'vehicle_type': vehicleType,
      'vehicle_registration': vehicleRegistration,
      'vehicle_capacity_kg': vehicleCapacityKg,
      'verification_status': verificationStatus,
      'availability_status': availabilityStatus,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'rating': rating,
      'total_deliveries': totalDeliveries,
      'successful_deliveries': successfulDeliveries,
      'profile_photo': profilePhoto,
      'drivers_license': driversLicense,
      'license_expiry': licenseExpiry?.toIso8601String(),
      'vehicle_registration_document': vehicleRegistrationDocument,
      'vehicle_insurance': vehicleInsurance,
      'vehicle_insurance_expiry': vehicleInsuranceExpiry?.toIso8601String(),
      'vehicle_technical_inspection': vehicleTechnicalInspection,
      'vehicle_inspection_expiry': vehicleInspectionExpiry?.toIso8601String(),
      'vehicle_gray_card': vehicleGrayCard,
      'vehicle_vignette': vehicleVignette,
      'vehicle_vignette_expiry': vehicleVignetteExpiry?.toIso8601String(),
      'identity_card_number': identityCardNumber,
      'identity_card_front': identityCardFront,
      'identity_card_back': identityCardBack,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'bank_account_name': bankAccountName,
      'bank_account_number': bankAccountNumber,
      'bank_name': bankName,
      'mobile_money_number': mobileMoneyNumber,
      'mobile_money_provider': mobileMoneyProvider,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'emergency_contact_relationship': emergencyContactRelationship,
      'years_of_experience': yearsOfExperience,
      'previous_employer': previousEmployer,
      'languages_spoken': languagesSpoken,
      'is_on_break': isOnBreak,
      'break_started_at': breakStartedAt?.toIso8601String(),
      'total_break_duration_today': totalBreakDurationToday?.inSeconds,
      'last_break_reset': lastBreakReset?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
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
    String? id,
    UserModel? user,
    String? phone,
    String? vehicleType,
    String? vehicleRegistration,
    double? vehicleCapacityKg,
    String? verificationStatus,
    String? availabilityStatus,
    double? currentLatitude,
    double? currentLongitude,
    double? rating,
    int? totalDeliveries,
    String? profilePhoto,
    String? driversLicense,
    String? vehicleRegistrationDocument,
    String? identityCardNumber,
    String? identityCardFront,
    String? identityCardBack,
    DateTime? dateOfBirth,
    String? vehicleVignette,
    DateTime? vehicleVignetteExpiry,
    DateTime? createdAt,
  }) {
    return DriverModel(
      id: id ?? this.id,
      user: user ?? this.user,
      phone: phone ?? this.phone,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      vehicleCapacityKg: vehicleCapacityKg ?? this.vehicleCapacityKg,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      driversLicense: driversLicense ?? this.driversLicense,
      vehicleRegistrationDocument: vehicleRegistrationDocument ?? this.vehicleRegistrationDocument,
      identityCardNumber: identityCardNumber ?? this.identityCardNumber,
      identityCardFront: identityCardFront ?? this.identityCardFront,
      identityCardBack: identityCardBack ?? this.identityCardBack,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      vehicleVignette: vehicleVignette ?? this.vehicleVignette,
      vehicleVignetteExpiry: vehicleVignetteExpiry ?? this.vehicleVignetteExpiry,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'DriverModel(id: $id, name: ${user.fullName}, status: $availabilityStatus)';
  }
}
