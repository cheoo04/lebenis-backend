// lib/core/utils/backend_validators.dart

import '../constants/backend_constants.dart';

/// Validateurs conformes aux contraintes du backend Django
/// 
/// Ce fichier contient toutes les validations qui reflètent exactement
/// ce que le backend attend pour chaque champ.
class BackendValidators {
  // ========== DELIVERY VALIDATIONS ==========

  /// Valider une adresse de livraison
  static String? validateDeliveryAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Adresse de livraison requise';
    }

    if (value.trim().length < 10) {
      return 'Adresse trop courte (minimum 10 caractères)';
    }

    if (value.trim().length > 255) {
      return 'Adresse trop longue (maximum 255 caractères)';
    }

    return null;
  }

  /// Valider une commune (max 100 caractères)
  static String? validateCommune(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Commune requise';
    }

    if (value.trim().length > 100) {
      return 'Nom de commune trop long (maximum 100 caractères)';
    }

    // Liste des communes valides de Côte d'Ivoire (Abidjan)
    final validCommunes = [
      'abobo', 'adjamé', 'attécoubé', 'cocody', 'koumassi',
      'marcory', 'plateau', 'port-bouët', 'treichville', 'yopougon',
      'anyama', 'bingerville', 'songon',
    ];

    if (!validCommunes.contains(value.trim().toLowerCase())) {
      return 'Commune invalide. Choisissez parmi: ${validCommunes.join(", ")}';
    }

    return null;
  }

  /// Valider un quartier (max 100 caractères)
  static String? validateQuartier(String? value) {
    // Quartier est optionnel
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (value.trim().length > 100) {
      return 'Nom de quartier trop long (maximum 100 caractères)';
    }

    return null;
  }

  /// Valider une description de colis
  static String? validatePackageDescription(String? value) {
    // Description est optionnelle
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (value.trim().length > 500) {
      return 'Description trop longue (maximum 500 caractères)';
    }

    return null;
  }

  /// Valider le poids du colis (max 5 chiffres, 2 décimales)
  static String? validatePackageWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Poids du colis requis';
    }

    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Poids invalide. Ex: 2.5';
    }

    if (weight <= 0) {
      return 'Le poids doit être supérieur à 0';
    }

    if (weight > 999.99) {
      return 'Poids maximum: 999.99 kg';
    }

    // Vérifier le nombre de décimales
    final parts = value.split('.');
    if (parts.length > 1 && parts[1].length > 2) {
      return 'Maximum 2 décimales (ex: 2.50)';
    }

    return null;
  }

  /// Valider les dimensions du colis (optionnelles)
  static String? validatePackageDimension(String? value) {
    // Dimensions sont optionnelles
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final dimension = double.tryParse(value);
    if (dimension == null) {
      return 'Dimension invalide';
    }

    if (dimension <= 0) {
      return 'La dimension doit être supérieure à 0';
    }

    if (dimension > 999.99) {
      return 'Dimension maximum: 999.99 cm';
    }

    return null;
  }

  /// Valider la valeur du colis (optionnelle)
  static String? validatePackageValue(String? value) {
    // Valeur est optionnelle
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final packageValue = double.tryParse(value);
    if (packageValue == null) {
      return 'Valeur invalide';
    }

    if (packageValue < 0) {
      return 'La valeur ne peut pas être négative';
    }

    if (packageValue > 99999999.99) {
      return 'Valeur maximum: 99 999 999.99 FCFA';
    }

    return null;
  }

  /// Valider le nom du destinataire (max 200 caractères)
  static String? validateRecipientName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nom du destinataire requis';
    }

    if (value.trim().length < 2) {
      return 'Nom trop court (minimum 2 caractères)';
    }

    if (value.trim().length > 200) {
      return 'Nom trop long (maximum 200 caractères)';
    }

    // Vérifier que contient seulement des lettres et espaces
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s\-\.]+$').hasMatch(value)) {
      return 'Nom invalide (lettres uniquement)';
    }

    return null;
  }

  /// Valider le téléphone du destinataire (max 20 caractères)
  /// Formats acceptés :
  /// - Local : 0712345678 (10 chiffres)
  /// - International : +2250712345678 (13 caractères)
  static String? validateRecipientPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Téléphone du destinataire requis';
    }

    // Supprimer espaces uniquement
    final cleaned = value.replaceAll(RegExp(r'\s'), '');

    if (cleaned.length > BackendConstants.maxPhoneLength) {
      return 'Numéro trop long (maximum ${BackendConstants.maxPhoneLength} caractères)';
    }

    // Format international (+225...)
    if (cleaned.startsWith('+225')) {
      final digits = cleaned.substring(4);
      if (digits.length != 10) {
        return 'Format invalide. Ex: +225 07 12 34 56 78';
      }
      // Vérifier préfixe mobile
      final prefix = digits.substring(0, 2);
      if (!BackendConstants.validPhonePrefixes.contains(prefix)) {
        return 'Préfixe invalide. Utilisez 01, 05 ou 07';
      }
      return null;
    }

    // Format local (10 chiffres)
    final digitsOnly = cleaned.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length != 10) {
      return 'Format invalide. Ex: 07 12 34 56 78';
    }

    // Vérifier préfixe mobile
    final prefix = digitsOnly.substring(0, 2);
    if (!BackendConstants.validPhonePrefixes.contains(prefix)) {
      return 'Préfixe invalide. Utilisez 01, 05 ou 07';
    }

    return null;
  }

  /// Valider le montant COD (Cash on Delivery)
  static String? validateCodAmount(String? value, String? paymentMethod) {
    // Si pas de COD, montant non requis
    if (paymentMethod != 'cod') {
      return null;
    }

    if (value == null || value.trim().isEmpty) {
      return 'Montant COD requis pour paiement à la livraison';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Montant invalide';
    }

    if (amount <= 0) {
      return 'Le montant doit être supérieur à 0';
    }

    if (amount > 99999999.99) {
      return 'Montant maximum: 99 999 999.99 FCFA';
    }

    return null;
  }

  /// Valider la latitude
  static String? validateLatitude(double? value) {
    if (value == null) {
      return 'Latitude requise';
    }

    if (value < -90 || value > 90) {
      return 'Latitude invalide (doit être entre -90 et 90)';
    }

    return null;
  }

  /// Valider la longitude
  static String? validateLongitude(double? value) {
    if (value == null) {
      return 'Longitude requise';
    }

    if (value < -180 || value > 180) {
      return 'Longitude invalide (doit être entre -180 et 180)';
    }

    return null;
  }

  // ========== DRIVER VALIDATIONS ==========

  /// Valider le numéro de permis
  static String? validateDriverLicense(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Numéro de permis requis';
    }

    if (value.trim().length < 5) {
      return 'Numéro de permis trop court';
    }

    if (value.trim().length > 50) {
      return 'Numéro de permis trop long (maximum 50 caractères)';
    }

    return null;
  }

  /// Valider la plaque d'immatriculation
  /// Formats acceptés:
  /// - CEDEAO: SN 1234 AB, CI 5678 CD
  /// - Sénégal ancien: DK 1234 A
  /// - Côte d'Ivoire ancien: 01 AA 1234
  static String? validateVehicleRegistration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Immatriculation requise';
    }

    // Normaliser: supprimer espaces multiples et mettre en majuscules
    final plate = value.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
    
    // Vérifier longueur globale
    if (plate.length < 6 || plate.length > 20) {
      return 'Longueur invalide';
    }
    
    // Patterns acceptés
    final cedeaoPattern = RegExp(r'^[A-Z]{2}\s\d{4}\s[A-Z]{2}$');  // SN 1234 AB
    final senegalPattern = RegExp(r'^[A-Z]{2}\s\d{4}\s[A-Z]$');    // DK 1234 A
    final ivoirePattern = RegExp(r'^\d{2}\s[A-Z]{2}\s\d{4}$');     // 01 AA 1234
    
    final isValid = cedeaoPattern.hasMatch(plate) || 
                    senegalPattern.hasMatch(plate) || 
                    ivoirePattern.hasMatch(plate);
    
    if (!isValid) {
      return 'Format invalide. Ex: SN 1234 AB, DK 1234 A ou 01 AA 1234';
    }

    return null;
  }

  /// Normaliser une plaque d'immatriculation pour stockage
  static String normalizePlate(String plate) {
    return plate.trim().toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Valider la capacité du véhicule
  static String? validateVehicleCapacity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Capacité du véhicule requise';
    }

    final capacity = double.tryParse(value);
    if (capacity == null) {
      return 'Capacité invalide';
    }

    if (capacity <= 0) {
      return 'La capacité doit être supérieure à 0';
    }

    if (capacity > 9999.99) {
      return 'Capacité maximum: 9999.99 kg';
    }

    return null;
  }

  /// Valider le type de véhicule
  static String? validateVehicleType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Type de véhicule requis';
    }

    final validTypes = ['moto', 'voiture', 'camionnette'];
    if (!validTypes.contains(value.toLowerCase())) {
      return 'Type invalide. Choisissez: moto, voiture ou camionnette';
    }

    return null;
  }

  // ========== STATUS VALIDATIONS ==========

  /// Valider le statut de livraison
  static String? validateDeliveryStatus(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Statut requis';
    }

    final validStatuses = [
      'pending',
      'in_progress',
      'delivered',
      'cancelled',
    ];

    if (!validStatuses.contains(value)) {
      return 'Statut invalide';
    }

    return null;
  }

  /// Valider le code de confirmation
  static String? validateConfirmationCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Code de confirmation requis';
    }

    if (value.trim().length > 10) {
      return 'Code trop long (maximum 10 caractères)';
    }

    // Généralement composé de chiffres
    if (!RegExp(r'^[0-9A-Z]+$').hasMatch(value)) {
      return 'Code invalide (chiffres et lettres majuscules uniquement)';
    }

    return null;
  }

  /// Valider les notes de livraison
  static String? validateDeliveryNotes(String? value) {
    // Notes sont optionnelles
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (value.trim().length > 1000) {
      return 'Notes trop longues (maximum 1000 caractères)';
    }

    return null;
  }

  // ========== PAYMENT VALIDATIONS ==========

  /// Valider la méthode de paiement
  static String? validatePaymentMethod(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Méthode de paiement requise';
    }

    final validMethods = ['prepaid', 'cod'];
    if (!validMethods.contains(value)) {
      return 'Méthode invalide. Choisissez: prepaid ou cod';
    }

    return null;
  }

  /// Valider le type de planification
  static String? validateSchedulingType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Type de planification requis';
    }

    final validTypes = ['immediate', 'scheduled'];
    if (!validTypes.contains(value)) {
      return 'Type invalide. Choisissez: immediate ou scheduled';
    }

    return null;
  }

  // ========== DATE VALIDATIONS ==========

  /// Valider une date de planification
  static String? validateScheduledDate(DateTime? value, String? schedulingType) {
    // Si immediate, date non requise
    if (schedulingType != 'scheduled') {
      return null;
    }

    if (value == null) {
      return 'Date de planification requise';
    }

    // La date doit être dans le futur
    if (value.isBefore(DateTime.now())) {
      return 'La date doit être dans le futur';
    }

    // Pas plus de 30 jours à l'avance
    final maxDate = DateTime.now().add(const Duration(days: 30));
    if (value.isAfter(maxDate)) {
      return 'Maximum 30 jours à l\'avance';
    }

    return null;
  }

  /// Valider une date d'expiration de permis
  static String? validateLicenseExpiry(DateTime? value) {
    if (value == null) {
      return 'Date d\'expiration requise';
    }

    // La date doit être dans le futur
    if (value.isBefore(DateTime.now())) {
      return 'Le permis est expiré';
    }

    return null;
  }

  // ========== HELPER FUNCTIONS ==========

  /// Nettoyer un numéro de téléphone (supprimer espaces uniquement, garder +)
  /// Convertit format local en international si nécessaire
  static String cleanPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\s'), '');
    
    // Si déjà en format international, retourner tel quel
    if (cleaned.startsWith('+225')) {
      return cleaned;
    }
    
    // Supprimer caractères spéciaux sauf +
    final digitsOnly = cleaned.replaceAll(RegExp(r'[^\d]'), '');
    
    // Si commence par 0 et 10 chiffres, convertir en format international
    if (digitsOnly.length == 10 && digitsOnly.startsWith('0')) {
      return '+225${digitsOnly.substring(1)}'; // Retirer le 0, ajouter +225
    }
    
    return digitsOnly;
  }

  /// Formater un montant pour l'affichage
  static String formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  /// Vérifier si une valeur est dans une liste de choix
  static bool isValidChoice(String? value, List<String> validChoices) {
    if (value == null) return false;
    return validChoices.contains(value);
  }

  /// Valider plusieurs champs en une fois
  static Map<String, String> validateDeliveryData({
    required String deliveryAddress,
    required String deliveryCommune,
    String? deliveryQuartier,
    required String packageWeight,
    required String recipientName,
    required String recipientPhone,
    required String paymentMethod,
    String? codAmount,
  }) {
    final errors = <String, String>{};

    final addressError = validateDeliveryAddress(deliveryAddress);
    if (addressError != null) errors['delivery_address'] = addressError;

    final communeError = validateCommune(deliveryCommune);
    if (communeError != null) errors['delivery_commune'] = communeError;

    final quartierError = validateQuartier(deliveryQuartier);
    if (quartierError != null) errors['delivery_quartier'] = quartierError;

    final weightError = validatePackageWeight(packageWeight);
    if (weightError != null) errors['package_weight'] = weightError;

    final nameError = validateRecipientName(recipientName);
    if (nameError != null) errors['recipient_name'] = nameError;

    final phoneError = validateRecipientPhone(recipientPhone);
    if (phoneError != null) errors['recipient_phone'] = phoneError;

    final paymentError = validatePaymentMethod(paymentMethod);
    if (paymentError != null) errors['payment_method'] = paymentError;

    final codError = validateCodAmount(codAmount, paymentMethod);
    if (codError != null) errors['cod_amount'] = codError;

    return errors;
  }
}
