// lib/core/utils/formatters.dart

import 'package:intl/intl.dart';

/// Classe utilitaire pour formater les données (dates, prix, distances, etc.)
class Formatters {
  // ========== DATES ==========

  /// Formater une date en français (ex: "3 novembre 2025")
  static String formatDate(DateTime date) {
    // Utilisation sans locale pour éviter les erreurs d'initialisation
    return DateFormat('d MMMM yyyy').format(date);
  }

  /// Formater une date courte (ex: "03/11/2025")
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Formater l'heure (ex: "14:30")
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Formater date et heure (ex: "3 nov 2025 à 14:30")
  static String formatDateTime(DateTime date) {
    // Utilisation sans locale pour éviter les erreurs d'initialisation
    return DateFormat('d MMM yyyy à HH:mm').format(date);
  }

  /// Formater date et heure courte (ex: "03/11/2025 14:30")
  static String formatDateTimeShort(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  /// Temps relatif (ex: "Il y a 5 minutes", "Dans 2 heures")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.isNegative) {
      // Date future
      final futureDiff = date.difference(now);
      if (futureDiff.inSeconds < 60) {
        return 'Dans ${futureDiff.inSeconds} secondes';
      } else if (futureDiff.inMinutes < 60) {
        return 'Dans ${futureDiff.inMinutes} minute${futureDiff.inMinutes > 1 ? 's' : ''}';
      } else if (futureDiff.inHours < 24) {
        return 'Dans ${futureDiff.inHours} heure${futureDiff.inHours > 1 ? 's' : ''}';
      } else if (futureDiff.inDays < 7) {
        return 'Dans ${futureDiff.inDays} jour${futureDiff.inDays > 1 ? 's' : ''}';
      } else {
        return formatDate(date);
      }
    } else {
      // Date passée
      if (difference.inSeconds < 60) {
        return 'Il y a ${difference.inSeconds} secondes';
      } else if (difference.inMinutes < 60) {
        return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
      } else if (difference.inHours < 24) {
        return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
      } else if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
      } else {
        return formatDate(date);
      }
    }
  }

  /// Jour de la semaine (ex: "Lundi")
  static String formatDayOfWeek(DateTime date) {
    // Utilisation sans locale pour éviter les erreurs d'initialisation
    return DateFormat('EEEE').format(date);
  }

  /// Nom du mois (ex: "Novembre")
  static String formatMonth(DateTime date) {
    // Utilisation sans locale pour éviter les erreurs d'initialisation
    return DateFormat('MMMM').format(date);
  }

  // ========== ARGENT (FCFA) ==========

  /// Formater un prix en FCFA (ex: "15 000 FCFA")
  static String formatPrice(double amount) {
    // Utilisation sans locale pour éviter les erreurs d'initialisation
    final formatter = NumberFormat('#,##0');
    return '${formatter.format(amount)} FCFA';
  }

  /// Formater un prix compact (ex: "15k FCFA")
  static String formatPriceCompact(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M FCFA';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}k FCFA';
    } else {
      return '${amount.toStringAsFixed(0)} FCFA';
    }
  }

  /// Formater un prix avec décimales (ex: "15 000,50 FCFA")
  static String formatPriceWithDecimals(double amount) {
    // Utilisation sans locale pour éviter les erreurs d'initialisation
    final formatter = NumberFormat('#,##0.00');
    return '${formatter.format(amount)} FCFA';
  }

  // ========== DISTANCES ==========

  /// Formater une distance (ex: "12,5 km" ou "850 m")
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      final meters = (distanceInKm * 1000).round();
      return '$meters m';
    } else {
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  /// Formater une distance courte (ex: "12 km")
  static String formatDistanceShort(double distanceInKm) {
    if (distanceInKm < 1) {
      final meters = (distanceInKm * 1000).round();
      return '$meters m';
    } else {
      return '${distanceInKm.toStringAsFixed(0)} km';
    }
  }

  // ========== POIDS ==========

  /// Formater un poids (ex: "2,5 kg" ou "500 g")
  static String formatWeight(double weightInKg) {
    if (weightInKg < 1) {
      final grams = (weightInKg * 1000).round();
      return '$grams g';
    } else {
      return '${weightInKg.toStringAsFixed(1)} kg';
    }
  }

  // ========== TÉLÉPHONE ==========

  /// Formater un numéro de téléphone ivoirien
  /// Format : "+225 07 12 34 56 78" ou "07 12 34 56 78"
  static String formatPhoneNumber(String phone) {
    // Supprimer tous les espaces
    final cleaned = phone.replaceAll(RegExp(r'\s'), '');

    // Format international (+225...)
    if (cleaned.startsWith('+225')) {
      final number = cleaned.substring(4);
      if (number.length == 10) {
        return '+225 ${number.substring(0, 2)} ${number.substring(2, 4)} ${number.substring(4, 6)} ${number.substring(6, 8)} ${number.substring(8)}';
      }
      return cleaned; // Retourner tel quel si format invalide
    }

    // Format local (10 chiffres)
    final digitsOnly = cleaned.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length == 10 && digitsOnly.startsWith('0')) {
      return '${digitsOnly.substring(0, 2)} ${digitsOnly.substring(2, 4)} ${digitsOnly.substring(4, 6)} ${digitsOnly.substring(6, 8)} ${digitsOnly.substring(8)}';
    }

    // Sinon retourner tel quel
    return cleaned;
  }

  /// Formater un numéro sans indicatif (ex: "07 12 34 56 78")
  static String formatPhoneNumberLocal(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length == 10 && cleaned.startsWith('0')) {
      return '${cleaned.substring(0, 2)} ${cleaned.substring(2, 4)} ${cleaned.substring(4, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8)}';
    }
    
    return cleaned;
  }

  // ========== NUMÉROS ==========

  /// Formater un nombre avec séparateurs (ex: "1 234 567")
  static String formatNumber(int number) {
    // Utilisation sans locale pour éviter les erreurs d'initialisation
    final formatter = NumberFormat('#,##0');
    return formatter.format(number);
  }

  /// Formater un pourcentage (ex: "85,5%")
  static String formatPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Formater une note/rating (ex: "4.5/5" ou "4.5 ⭐")
  static String formatRating(double rating, {bool showStars = false}) {
    if (showStars) {
      return '${rating.toStringAsFixed(1)} ⭐';
    } else {
      return '${rating.toStringAsFixed(1)}/5';
    }
  }

  // ========== DURÉE ==========

  /// Formater une durée en minutes (ex: "1h 30min" ou "45min")
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}min';
      }
    }
  }

  /// Formater une durée depuis un DateTime (ex: "2h 15min")
  static String formatDurationFromDateTime(DateTime start, DateTime end) {
    final difference = end.difference(start);
    final minutes = difference.inMinutes;
    return formatDuration(minutes);
  }

  // ========== TRACKING NUMBER ==========

  /// Formater un numéro de suivi (ex: "LBN-2025-00123")
  static String formatTrackingNumber(String trackingNumber) {
    // Ajouter des tirets si nécessaire
    if (trackingNumber.length >= 10 && !trackingNumber.contains('-')) {
      return '${trackingNumber.substring(0, 3)}-${trackingNumber.substring(3, 7)}-${trackingNumber.substring(7)}';
    }
    return trackingNumber.toUpperCase();
  }

  // ========== CAPITALISATION ==========

  /// Capitaliser la première lettre (ex: "bonjour" -> "Bonjour")
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Capitaliser chaque mot (ex: "bonjour monde" -> "Bonjour Monde")
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalize(word)).join(' ');
  }

  // ========== TRUNCATE ==========

  /// Tronquer un texte (ex: "Lorem ipsum dolor..." si > maxLength)
  static String truncate(String text, int maxLength, {String suffix = '...'}) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - suffix.length) + suffix;
  }
}
