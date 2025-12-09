// lib/shared/widgets/modern_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';

/// TextField moderne avec design arrondi et label au-dessus
class ModernTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Function(String)? onFieldSubmitted;
  final TextCapitalization textCapitalization;
  final bool isCompact;

  const ModernTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.onChanged,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine effective compact mode: explicit or inferred from label
    final effectiveCompact = isCompact || ((label ?? '').toLowerCase().contains('commune')) || ((label ?? '').toLowerCase().contains('quartier'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label au-dessus du champ
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.label,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        
        // Champ de saisie
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          onChanged: onChanged,
          validator: validator,
          inputFormatters: inputFormatters,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          textCapitalization: textCapitalization,
          style: AppTypography.bodyMedium.copyWith(fontSize: effectiveCompact ? 14 : null),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            filled: true,
            fillColor: enabled ? AppColors.surface : AppColors.background,
              isDense: effectiveCompact,
              contentPadding: effectiveCompact
                  ? const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8)
                  : const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
            
            // Bordures arrondies
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
            disabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.inputRadius,
              borderSide: const BorderSide(color: AppColors.borderLight, width: 1),
            ),
            
            // Icônes
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textSecondary)
                : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon, color: AppColors.textSecondary),
                    onPressed: onSuffixIconTap,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

/// TextField de recherche avec icône
class SearchTextField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final VoidCallback? onClear;

  const SearchTextField({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.inputRadius,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTypography.bodyMedium,
        decoration: InputDecoration(
          hintText: hint ?? 'Rechercher...',
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textHint,
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.inputRadius,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.inputRadius,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.inputRadius,
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          suffixIcon: controller?.text.isNotEmpty ?? false
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: onClear,
                )
              : null,
        ),
      ),
    );
  }
}
