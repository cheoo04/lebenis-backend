// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

/// Palette de couleurs de l'application LeBeni's Driver
class AppColors {
  // ========== COULEURS PRINCIPALES ==========
  static const Color primary = Color(0xFF1E88E5); // Bleu LeBeni's
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);
  
  static const Color secondary = Color(0xFFFF9800); // Orange (pour accents)
  static const Color secondaryDark = Color(0xFFF57C00);
  static const Color secondaryLight = Color(0xFFFFB74D);
  
  // ========== COULEURS DE FOND ==========
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // ========== TEXTES ==========
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textDisabled = Color(0xFF9E9E9E);
  
  // ========== STATUS COLORS ==========
  static const Color success = Color(0xFF4CAF50); // Vert
  static const Color error = Color(0xFFF44336); // Rouge
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color info = Color(0xFF2196F3); // Bleu info
  
  // ========== DELIVERY STATUS COLORS ==========
  static const Color statusAssigned = Color(0xFF2196F3); // Bleu
  static const Color statusAccepted = Color(0xFF9C27B0); // Violet
  static const Color statusPickedUp = Color(0xFFFF9800); // Orange
  static const Color statusInTransit = Color(0xFFFF5722); // Orange foncé
  static const Color statusDelivered = Color(0xFF4CAF50); // Vert
  static const Color statusCancelled = Color(0xFF9E9E9E); // Gris
  
  // ========== AVAILABILITY STATUS COLORS ==========
  static const Color availableGreen = Color(0xFF4CAF50);
  static const Color busyOrange = Color(0xFFFF9800);
  static const Color offlineGrey = Color(0xFF9E9E9E);
  
  // ========== BORDERS ==========
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
  
  // ========== SHADOWS ==========
  static const Color shadow = Color(0x1A000000);
  
  // ========== GRADIENTS ==========
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
  );
}
