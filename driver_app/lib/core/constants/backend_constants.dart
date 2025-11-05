// lib/core/constants/backend_constants.dart

import 'package:flutter/material.dart';

/// Constantes qui reflètent exactement les choix du backend Django
/// 
/// Ces constantes doivent TOUJOURS rester synchronisées avec le backend
class BackendConstants {
  // ========== DELIVERY STATUS ==========
  
  static const String deliveryStatusPendingAssignment = 'pending_assignment';
  static const String deliveryStatusAssigned = 'assigned';
  static const String deliveryStatusPickupInProgress = 'pickup_in_progress';
  static const String deliveryStatusPickedUp = 'picked_up';
  static const String deliveryStatusInTransit = 'in_transit';
  static const String deliveryStatusDelivered = 'delivered';
  static const String deliveryStatusCancelled = 'cancelled';

  static const List<String> deliveryStatusChoices = [
    deliveryStatusPendingAssignment,
    deliveryStatusAssigned,
    deliveryStatusPickupInProgress,
    deliveryStatusPickedUp,
    deliveryStatusInTransit,
    deliveryStatusDelivered,
    deliveryStatusCancelled,
  ];

  static const Map<String, String> deliveryStatusLabels = {
    deliveryStatusPendingAssignment: 'En attente d\'assignation',
    deliveryStatusAssigned: 'Assigné',
    deliveryStatusPickupInProgress: 'Enlèvement en cours',
    deliveryStatusPickedUp: 'Colis récupéré',
    deliveryStatusInTransit: 'En livraison',
    deliveryStatusDelivered: 'Livré',
    deliveryStatusCancelled: 'Annulé',
  };

  // ========== PAYMENT METHODS ==========
  
  static const String paymentMethodPrepaid = 'prepaid';
  static const String paymentMethodCod = 'cod';

  static const List<String> paymentMethodChoices = [
    paymentMethodPrepaid,
    paymentMethodCod,
  ];

  static const Map<String, String> paymentMethodLabels = {
    paymentMethodPrepaid: 'Prépayé',
    paymentMethodCod: 'Paiement à la livraison',
  };

  // ========== SCHEDULING TYPES ==========
  
  static const String schedulingTypeImmediate = 'immediate';
  static const String schedulingTypeScheduled = 'scheduled';

  static const List<String> schedulingTypeChoices = [
    schedulingTypeImmediate,
    schedulingTypeScheduled,
  ];

  static const Map<String, String> schedulingTypeLabels = {
    schedulingTypeImmediate: 'Immédiat',
    schedulingTypeScheduled: 'Planifié',
  };

  // ========== VEHICLE TYPES ==========
  
  static const String vehicleTypeMoto = 'moto';
  static const String vehicleTypeVoiture = 'voiture';
  static const String vehicleTypeTricycle = 'tricycle';
  static const String vehicleTypeCamionnette = 'camionnette';

  static const List<String> vehicleTypeChoices = [
    vehicleTypeMoto,
    vehicleTypeTricycle,
    vehicleTypeVoiture,
    vehicleTypeCamionnette,
  ];

  static const Map<String, String> vehicleTypeLabels = {
    vehicleTypeMoto: 'Moto',
    vehicleTypeTricycle: 'Tricycle',
    vehicleTypeVoiture: 'Voiture',
    vehicleTypeCamionnette: 'Camionnette',
  };

  // ========== COMMUNES D'ABIDJAN ==========
  
  static const String communeAbobo = 'abobo';
  static const String communeAdjame = 'adjamé';
  static const String communeAttecoube = 'attécoubé';
  static const String communeCocody = 'cocody';
  static const String communeKoumassi = 'koumassi';
  static const String communeMarcory = 'marcory';
  static const String communePlateau = 'plateau';
  static const String communePortBouet = 'port-bouët';
  static const String communeTreichville = 'treichville';
  static const String communeYopougon = 'yopougon';
  static const String communeAnyama = 'anyama';
  static const String communeBingerville = 'bingerville';
  static const String communeSongon = 'songon';

  static const List<String> communeChoices = [
    communeAbobo,
    communeAdjame,
    communeAttecoube,
    communeCocody,
    communeKoumassi,
    communeMarcory,
    communePlateau,
    communePortBouet,
    communeTreichville,
    communeYopougon,
    communeAnyama,
    communeBingerville,
    communeSongon,
  ];

  static const Map<String, String> communeLabels = {
    communeAbobo: 'Abobo',
    communeAdjame: 'Adjamé',
    communeAttecoube: 'Attécoubé',
    communeCocody: 'Cocody',
    communeKoumassi: 'Koumassi',
    communeMarcory: 'Marcory',
    communePlateau: 'Plateau',
    communePortBouet: 'Port-Bouët',
    communeTreichville: 'Treichville',
    communeYopougon: 'Yopougon',
    communeAnyama: 'Anyama',
    communeBingerville: 'Bingerville',
    communeSongon: 'Songon',
  };

  // ========== VERIFICATION STATUS ==========
  
  static const String verificationStatusPending = 'pending';
  static const String verificationStatusApproved = 'approved';
  static const String verificationStatusRejected = 'rejected';

  static const List<String> verificationStatusChoices = [
    verificationStatusPending,
    verificationStatusApproved,
    verificationStatusRejected,
  ];

  static const Map<String, String> verificationStatusLabels = {
    verificationStatusPending: 'En attente',
    verificationStatusApproved: 'Approuvé',
    verificationStatusRejected: 'Rejeté',
  };

  // ========== PAYMENT STATUS ==========
  
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusCompleted = 'completed';
  static const String paymentStatusFailed = 'failed';

  static const List<String> paymentStatusChoices = [
    paymentStatusPending,
    paymentStatusCompleted,
    paymentStatusFailed,
  ];

  static const Map<String, String> paymentStatusLabels = {
    paymentStatusPending: 'En attente',
    paymentStatusCompleted: 'Complété',
    paymentStatusFailed: 'Échoué',
  };

  // ========== FIELD CONSTRAINTS ==========
  
  // Limites de caractères (basées sur les modèles Django)
  static const int maxLengthAddress = 255;
  static const int maxLengthCommune = 100;
  static const int maxLengthQuartier = 100;
  static const int maxLengthRecipientName = 200;
  static const int maxLengthRecipientPhone = 20;
  static const int maxLengthDriverLicense = 50;
  static const int maxLengthVehicleRegistration = 20;
  static const int maxLengthConfirmationCode = 10;
  static const int maxLengthTrackingNumber = 50;

  // Limites numériques
  static const double maxPackageWeight = 999.99;
  static const double maxPackageDimension = 999.99;
  static const double maxPackageValue = 99999999.99;
  static const double maxVehicleCapacity = 9999.99;
  static const double maxCodAmount = 99999999.99;

  // Coordonnées GPS
  static const double minLatitude = -90.0;
  static const double maxLatitude = 90.0;
  static const double minLongitude = -180.0;
  static const double maxLongitude = 180.0;

  // Téléphone
  static const int phoneLength10Digits = 10; // Format local: 0712345678
  static const int phoneLength13Chars = 13;  // Format international: +2250712345678
  static const int maxPhoneLength = 20;      // Max stocké en DB
  static const List<String> validPhonePrefixes = ['01', '05', '07'];
  static const String phoneCountryCode = '+225';

  // Email
  static const int minEmailLength = 5;
  static const int maxEmailLength = 254;

  // Mot de passe
  static const int minPasswordLength = 8;

  // Date
  static const int maxSchedulingDaysAhead = 30;

  // ========== HELPER METHODS ==========
  
  /// Obtenir le label d'un statut de livraison
  static String getDeliveryStatusLabel(String status) {
    return deliveryStatusLabels[status] ?? status;
  }

  /// Obtenir le label d'une méthode de paiement
  static String getPaymentMethodLabel(String method) {
    return paymentMethodLabels[method] ?? method;
  }

  /// Obtenir le label d'un type de véhicule
  static String getVehicleTypeLabel(String type) {
    return vehicleTypeLabels[type] ?? type;
  }

  /// Obtenir l'icône pour un type de véhicule
  static IconData getVehicleTypeIcon(String type) {
    switch (type) {
      case vehicleTypeMoto:
        return Icons.two_wheeler;
      case vehicleTypeTricycle:
        return Icons.electric_rickshaw;
      case vehicleTypeVoiture:
        return Icons.directions_car;
      case vehicleTypeCamionnette:
        return Icons.local_shipping;
      default:
        return Icons.local_shipping;
    }
  }

  /// Obtenir le label d'une commune
  static String getCommuneLabel(String commune) {
    return communeLabels[commune] ?? commune;
  }

  /// Vérifier si un statut est valide
  static bool isValidDeliveryStatus(String status) {
    return deliveryStatusChoices.contains(status);
  }

  /// Vérifier si une méthode de paiement est valide
  static bool isValidPaymentMethod(String method) {
    return paymentMethodChoices.contains(method);
  }

  /// Vérifier si un type de véhicule est valide
  static bool isValidVehicleType(String type) {
    return vehicleTypeChoices.contains(type);
  }

  /// Vérifier si une commune est valide
  static bool isValidCommune(String commune) {
    return communeChoices.contains(commune.toLowerCase());
  }
}
