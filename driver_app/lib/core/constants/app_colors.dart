// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

/// Palette de couleurs moderne de l'application LeBeni's Driver
/// Inspirée des maquettes UI avec un design minimaliste et coloré
class AppColors {
  // ========== COULEURS PRINCIPALES MODERNES ==========
  static const Color primary = Color(0xFF5B7FFF); // Bleu vibrant moderne
  static const Color primaryDark = Color(0xFF4A66E5);
  static const Color primaryLight = Color(0xFF7B9AFF);
  
  static const Color secondary = Color(0xFFFFA726); // Orange joyeux
  static const Color secondaryDark = Color(0xFFF57C00);
  static const Color secondaryLight = Color(0xFFFFB74D);
  
  // ========== COULEURS VIVES ET JOYEUSES ==========
  static const Color green = Color(0xFF4CAF50); // Vert succès
  static const Color greenLight = Color(0xFF81C784);
  static const Color greenDark = Color(0xFF388E3C);
  
  static const Color red = Color(0xFFEF5350); // Rouge vibrant
  static const Color redLight = Color(0xFFE57373);
  static const Color redDark = Color(0xFFD32F2F);
  
  static const Color yellow = Color(0xFFFFCA28); // Jaune joyeux
  static const Color yellowLight = Color(0xFFFFD54F);
  static const Color yellowDark = Color(0xFFFFA000);
  
  static const Color orange = Color(0xFFFFA726); // Orange
  static const Color purple = Color(0xFF9C27B0); // Violet
  static const Color blue = Color(0xFF42A5F5); // Bleu clair
  
  // ========== COULEURS DE FOND ==========
  static const Color background = Color(0xFFFAFAFA); // Fond très clair
  static const Color surface = Color(0xFFFFFFFF); // Blanc pur
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // ========== TEXTES ==========
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFF9E9E9E);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // ========== STATUS COLORS ==========
  static const Color success = green;
  static const Color error = red;
  static const Color warning = orange;
  static const Color info = blue;
  
  // ========== DELIVERY STATUS COLORS ==========
  static const Color statusAssigned = blue; // Bleu
  static const Color statusAccepted = purple; // Violet
  static const Color statusPickedUp = orange; // Orange
  static const Color statusInTransit = Color(0xFFFF5722); // Orange foncé
  static const Color statusDelivered = green; // Vert
  static const Color statusCancelled = Color(0xFF9E9E9E); // Gris
  
  // ========== AVAILABILITY STATUS COLORS ==========
  static const Color availableGreen = green;
  static const Color busyOrange = orange;
  static const Color offlineGrey = Color(0xFF9E9E9E);
  
  // ========== BORDERS ==========
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color divider = Color(0xFFEEEEEE);
  
  // ========== SHADOWS ==========
  static const Color shadow = Color(0x0A000000); // Ombre très légère
  static const Color shadowMedium = Color(0x14000000);
  
  // ========== GRADIENTS MODERNES ==========
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
  );
  
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFA726), Color(0xFFF57C00)],
  );
  
  static const LinearGradient redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [red, redDark],
  );
  
  // ========== COULEURS DES CARTES DASHBOARD ==========
  static const Color cardBlue = Color(0xFF5B7FFF);
  static const Color cardGreen = Color(0xFF4CAF50);
  static const Color cardOrange = Color(0xFFFFA726);
  static const Color cardRed = Color(0xFFEF5350);
  static const Color cardYellow = Color(0xFFFFCA28);
  static const Color cardPurple = Color(0xFF9C27B0);
}
