// lib/core/utils/validators.dart

/// Classe utilitaire pour valider les champs de formulaire
class Validators {
  // ========== EMAIL ==========

  /// Valider un email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email requis';
    }

    final email = value.trim();

    // Vérifier longueur raisonnable
    if (email.length < 5) {
      return 'Email trop court';
    }

    if (email.length > 254) {
      return 'Email trop long (max 254 caractères)';
    }

    // Regex simple pour email
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Format d\'email invalide. Ex: exemple@email.com';
    }

    // Vérifier qu'il n'y a pas de doubles points
    if (email.contains('..')) {
      return 'Email invalide ';
    }

    // Vérifier que le domaine existe
    final parts = email.split('@');
    if (parts.length != 2) {
      return 'Email invalide ';
    }

    final domain = parts[1];
    if (domain.isEmpty || !domain.contains('.')) {
      return 'Domaine d\'email invalide';
    }

    return null; // Valide
  }

  /// Vérifier si un email est valide (bool)
  static bool isValidEmail(String? value) {
    return validateEmail(value) == null;
  }

  // ========== MOT DE PASSE ==========

  /// Valider un mot de passe (min 8 caractères, conforme aux règles Django)
  static String? validatePassword(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }

    if (value.length < minLength) {
      return 'Mot de passe trop court (min $minLength caractères)';
    }

    // Vérifier si le mot de passe est entièrement numérique
    if (RegExp(r'^\d+$').hasMatch(value)) {
      return 'Le mot de passe ne doit pas être entièrement numérique';
    }

    // Liste des mots de passe trop courants à éviter
    final commonPasswords = [
      'password', 'password123', '12345678', '123456789', '1234567890',
      'qwerty', 'abc123', 'password1', 'admin', 'letmein',
      'welcome', 'monkey', '1234', '12345', '123456', '1234567',
      'password!', 'qwerty123', 'test', 'test123', 'user', 'user123',
    ];

    if (commonPasswords.contains(value.toLowerCase())) {
      return 'Ce mot de passe est trop courant. Choisissez-en un plus unique';
    }

    // Recommander un mélange de lettres et chiffres
    final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(value);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(value);

    if (!hasLetters || !hasNumbers) {
      return 'Utilisez un mélange de lettres et de chiffres';
    }

    return null; // Valide
  }

  /// Valider un mot de passe fort (min 8 caractères, majuscule, minuscule, chiffre)
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }

    if (value.length < 8) {
      return 'Minimum 8 caractères requis';
    }

    // Vérifier majuscule
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Au moins une majuscule requise';
    }

    // Vérifier minuscule
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Au moins une minuscule requise';
    }

    // Vérifier chiffre
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Au moins un chiffre requis';
    }

    return null; // Valide
  }

  /// Confirmer mot de passe
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirmation requise';
    }

    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }

    return null; // Valide
  }

  // ========== TÉLÉPHONE ==========

  /// Valider un numéro de téléphone ivoirien (10 chiffres ou +225...)
  /// Formats acceptés :
  /// - Local : 0712345678 (10 chiffres, commence par 0)
  /// - International : +2250712345678 (13 caractères avec +225)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Numéro de téléphone requis';
    }

    // Supprimer espaces uniquement (garder + pour format international)
    final cleaned = value.replaceAll(RegExp(r'\s'), '');
    
    // Vérifier format international (+225...)
    if (cleaned.startsWith('+225')) {
      final digits = cleaned.substring(4); // Après +225
      if (digits.length != 10) {
        return 'Format invalide. Ex: +225 07 10 20 30 40';
      }
      // Vérifier préfixe mobile (01, 05, 07)
      final prefix = digits.substring(0, 2);
      if (prefix != '01' && prefix != '05' && prefix != '07') {
        return 'Préfixe invalide. Utilisez 01, 05 ou 07';
      }
      return null;
    }

    // Format local (10 chiffres)
    final digitsOnly = cleaned.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length != 10) {
      return 'Numéro invalide (10 chiffres). Ex: 07 12 34 56 78';
    }

    // Vérifier que commence par 0
    if (!digitsOnly.startsWith('0')) {
      return 'Le numéro doit commencer par 0. Ex: 07 12 34 56 78';
    }

    // Vérifier préfixe mobile (01, 05, 07)
    final prefix = digitsOnly.substring(0, 2);
    if (prefix != '01' && prefix != '05' && prefix != '07') {
      return 'Préfixe invalide. Utilisez 01, 05 ou 07';
    }

    return null; // Valide
  }

  /// Valider un numéro international (+221...)
  static String? validateInternationalPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Numéro de téléphone requis';
    }

    // Supprimer espaces
    final cleaned = value.replaceAll(RegExp(r'[^\d+]'), '');

    // Vérifier format international
    if (!cleaned.startsWith('+')) {
      return 'Format international requis (+221...)';
    }

    // Vérifier longueur minimale
    if (cleaned.length < 10) {
      return 'Numéro trop court';
    }

    return null; // Valide
  }

  // ========== NOM ==========

  /// Valider un nom (prénom ou nom de famille)
  static String? validateName(String? value, {String fieldName = 'Nom'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName requis';
    }

    if (value.trim().length < 2) {
      return '$fieldName trop court (min 2 caractères)';
    }

    // Vérifier que contient seulement des lettres et espaces
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s\-]+$').hasMatch(value)) {
      return '$fieldName invalide (lettres uniquement)';
    }

    return null; // Valide
  }

  // ========== CHAMPS REQUIS ==========

  /// Valider un champ texte requis
  static String? validateRequired(String? value, {String fieldName = 'Ce champ'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null; // Valide
  }

  /// Valider avec longueur minimale
  static String? validateMinLength(
    String? value,
    int minLength, {
    String fieldName = 'Ce champ',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }

    if (value.length < minLength) {
      return '$fieldName trop court (min $minLength caractères)';
    }

    return null; // Valide
  }

  /// Valider avec longueur maximale
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String fieldName = 'Ce champ',
  }) {
    if (value == null) return null;

    if (value.length > maxLength) {
      return '$fieldName trop long (max $maxLength caractères)';
    }

    return null; // Valide
  }

  // ========== NUMÉROS ==========

  /// Valider un nombre entier
  static String? validateInteger(String? value, {String fieldName = 'Valeur'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName requise';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return '$fieldName doit être un nombre entier';
    }

    return null; // Valide
  }

  /// Valider un nombre décimal
  static String? validateDecimal(String? value, {String fieldName = 'Valeur'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName requise';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName doit être un nombre';
    }

    return null; // Valide
  }

  /// Valider un nombre positif
  static String? validatePositiveNumber(String? value, {String fieldName = 'Valeur'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName requise';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return '$fieldName doit être un nombre';
    }

    if (number <= 0) {
      return '$fieldName doit être positive';
    }

    return null; // Valide
  }

  /// Valider un montant (prix)
  static String? validateAmount(String? value, {double? minAmount, double? maxAmount}) {
    if (value == null || value.trim().isEmpty) {
      return 'Montant requis';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Montant invalide';
    }

    if (amount <= 0) {
      return 'Montant doit être positif';
    }

    if (minAmount != null && amount < minAmount) {
      return 'Montant minimum: $minAmount FCFA';
    }

    if (maxAmount != null && amount > maxAmount) {
      return 'Montant maximum: $maxAmount FCFA';
    }

    return null; // Valide
  }

  // ========== VÉHICULE ==========

  /// Valider une plaque d'immatriculation
  static String? validateVehicleRegistration(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Numéro d\'immatriculation requis';
    }

    if (value.trim().length < 4) {
      return 'Numéro d\'immatriculation trop court';
    }

    return null; // Valide
  }

  /// Valider un type de véhicule
  static String? validateVehicleType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Type de véhicule requis';
    }

    final validTypes = ['moto', 'voiture', 'velo'];
    if (!validTypes.contains(value.toLowerCase())) {
      return 'Type de véhicule invalide';
    }

    return null; // Valide
  }

  // ========== DATE ==========

  /// Valider une date
  static String? validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date requise';
    }

    try {
      DateTime.parse(value);
      return null; // Valide
    } catch (e) {
      return 'Format de date invalide';
    }
  }

  /// Valider une date de naissance (âge min 18 ans)
  static String? validateBirthDate(String? value, {int minAge = 18}) {
    if (value == null || value.trim().isEmpty) {
      return 'Date de naissance requise';
    }

    try {
      final birthDate = DateTime.parse(value);
      final today = DateTime.now();
      final age = today.year - birthDate.year;

      if (age < minAge) {
        return 'Vous devez avoir au moins $minAge ans';
      }

      return null; // Valide
    } catch (e) {
      return 'Format de date invalide';
    }
  }

  // ========== ADRESSE ==========

  /// Valider une adresse
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Adresse requise';
    }

    if (value.trim().length < 10) {
      return 'Adresse trop courte (min 10 caractères)';
    }

    return null; // Valide
  }

  // ========== COORDONNÉES GPS ==========

  /// Valider une latitude
  static String? validateLatitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Latitude requise';
    }

    final lat = double.tryParse(value);
    if (lat == null) {
      return 'Latitude invalide';
    }

    if (lat < -90 || lat > 90) {
      return 'Latitude hors limites (-90 à 90)';
    }

    return null; // Valide
  }

  /// Valider une longitude
  static String? validateLongitude(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Longitude requise';
    }

    final lng = double.tryParse(value);
    if (lng == null) {
      return 'Longitude invalide';
    }

    if (lng < -180 || lng > 180) {
      return 'Longitude hors limites (-180 à 180)';
    }

    return null; // Valide
  }

  // ========== COMBINAISONS ==========

  /// Valider plusieurs validateurs en chaîne
  static String? validateMultiple(String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null; // Tous valides
  }
}
