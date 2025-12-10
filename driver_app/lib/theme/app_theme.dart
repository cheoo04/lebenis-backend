// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import 'app_typography.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

/// Configuration du thème moderne de l'application
class AppTheme {
  // ========== LIGHT THEME ==========
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTypography.fontFamily,
      
      // ========== COLORS ==========
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.textWhite,
        onSecondary: AppColors.textWhite,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textWhite,
      ),
      
      scaffoldBackgroundColor: AppColors.background,
      
      // ========== APP BAR THEME ==========
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      
      // ========== CARD THEME ==========
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
        ),
        color: AppColors.cardBackground,
        margin: const EdgeInsets.all(AppSpacing.elementSpacingMedium),
      ),
      
      // ========== ELEVATED BUTTON THEME ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          // Use 0 width here so the theme doesn't force an infinite width
          // which would break layout inside unbounded parents (Wrap/Row).
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          textStyle: AppTypography.button,
        ),
      ),
      
      // ========== TEXT BUTTON THEME ==========
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.button,
        ),
      ),
      
      // ========== OUTLINED BUTTON THEME ==========
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          // Use 0 width to avoid forcing infinite width from the theme.
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonPaddingHorizontal,
            vertical: AppSpacing.buttonPaddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          textStyle: AppTypography.button,
        ),
      ),
      
      // ========== INPUT DECORATION THEME ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.inputRadius,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTypography.label,
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textHint,
        ),
        errorStyle: AppTypography.caption.copyWith(
          color: AppColors.error,
        ),
      ),
      
      // ========== BOTTOM NAVIGATION BAR THEME ==========
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // ========== CHIP THEME ==========
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        labelStyle: AppTypography.labelSmall.copyWith(
          color: AppColors.primary,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.chipRadius,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      
      // ========== FLOATING ACTION BUTTON THEME ==========
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 4,
      ),
      
      // ========== DIVIDER THEME ==========
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      
      // ========== TEXT THEME ==========
      textTheme: const TextTheme(
        displayLarge: AppTypography.h1,
        displayMedium: AppTypography.h2,
        displaySmall: AppTypography.h3,
        headlineLarge: AppTypography.h3,
        headlineMedium: AppTypography.h4,
        headlineSmall: AppTypography.h5,
        titleLarge: AppTypography.h4,
        titleMedium: AppTypography.h5,
        titleSmall: AppTypography.label,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.button,
        labelMedium: AppTypography.label,
        labelSmall: AppTypography.labelSmall,
      ),
      
      // ========== ICON THEME ==========
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
    );
  }
  
  // ========== DARK THEME ==========
  static ThemeData get darkTheme {
    // Pour l'instant, on garde le light theme
    // Le dark theme peut être implémenté plus tard si nécessaire
    return lightTheme;
  }
}
