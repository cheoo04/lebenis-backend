// lib/shared/widgets/modern_button.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// Énumération des types de boutons modernes
enum ModernButtonType {
  primary,
  secondary,
  success,
  danger,
  outlined,
  text,
}

/// Énumération des tailles de boutons
enum ModernButtonSize {
  small,
  medium,
  large,
}

/// Bouton moderne avec design arrondi et coloré
class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ModernButtonType type;
  final ModernButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final double? customRadius;

  const ModernButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ModernButtonType.primary,
    this.size = ModernButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.customRadius,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColors = _getColors();
    final buttonSize = _getSize();
    final buttonTextStyle = _getTextStyle();
    // Use LayoutBuilder to avoid forcing infinite width inside unbounded parents
    return LayoutBuilder(builder: (context, constraints) {
      final canUseFullWidth = fullWidth && constraints.maxWidth.isFinite;
      return SizedBox(
        width: canUseFullWidth ? double.infinity : null,
        height: buttonSize.height,
        child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColors.background,
          foregroundColor: buttonColors.foreground,
          elevation: type == ModernButtonType.outlined || type == ModernButtonType.text ? 0 : 2,
          shadowColor: AppColors.shadow,
          padding: EdgeInsets.symmetric(
            horizontal: buttonSize.paddingHorizontal,
            vertical: buttonSize.paddingVertical,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(customRadius ?? buttonSize.radius),
            side: type == ModernButtonType.outlined
                ? BorderSide(color: buttonColors.background, width: 1.5)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(buttonColors.foreground),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: buttonSize.iconSize),
                    SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    text,
                    style: buttonTextStyle,
                  ),
                ],
              ),
      );
    });
  }

  /// Retourne les couleurs selon le type de bouton
  _ButtonColors _getColors() {
    switch (type) {
      case ModernButtonType.primary:
        return const _ButtonColors(
          background: AppColors.primary,
          foreground: AppColors.textWhite,
        );
      case ModernButtonType.secondary:
        return const _ButtonColors(
          background: AppColors.secondary,
          foreground: AppColors.textWhite,
        );
      case ModernButtonType.success:
        return const _ButtonColors(
          background: AppColors.green,
          foreground: AppColors.textWhite,
        );
      case ModernButtonType.danger:
        return const _ButtonColors(
          background: AppColors.red,
          foreground: AppColors.textWhite,
        );
      case ModernButtonType.outlined:
        return const _ButtonColors(
          background: AppColors.primary,
          foreground: AppColors.primary,
        );
      case ModernButtonType.text:
        return const _ButtonColors(
          background: Colors.transparent,
          foreground: AppColors.primary,
        );
    }
  }

  /// Retourne la taille selon l'énumération
  _ButtonSize _getSize() {
    switch (size) {
      case ModernButtonSize.small:
        return const _ButtonSize(
          height: 40,
          paddingHorizontal: 16,
          paddingVertical: 8,
          radius: AppRadius.button,
          iconSize: 18,
        );
      case ModernButtonSize.medium:
        return const _ButtonSize(
          height: 48,
          paddingHorizontal: 24,
          paddingVertical: 12,
          radius: AppRadius.button,
          iconSize: 20,
        );
      case ModernButtonSize.large:
        return const _ButtonSize(
          height: 56,
          paddingHorizontal: 32,
          paddingVertical: 16,
          radius: AppRadius.buttonLarge,
          iconSize: 24,
        );
    }
  }

  /// Retourne le style de texte selon la taille
  TextStyle _getTextStyle() {
    switch (size) {
      case ModernButtonSize.small:
        return AppTypography.buttonSmall;
      case ModernButtonSize.medium:
      case ModernButtonSize.large:
        return AppTypography.button;
    }
  }
}

/// Classe privée pour les couleurs du bouton
class _ButtonColors {
  final Color background;
  final Color foreground;

  const _ButtonColors({
    required this.background,
    required this.foreground,
  });
}

/// Classe privée pour les dimensions du bouton
class _ButtonSize {
  final double height;
  final double paddingHorizontal;
  final double paddingVertical;
  final double radius;
  final double iconSize;

  const _ButtonSize({
    required this.height,
    required this.paddingHorizontal,
    required this.paddingVertical,
    required this.radius,
    required this.iconSize,
  });
}
