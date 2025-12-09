// lib/shared/utils/input_decorations.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Returns an [InputDecoration] tailored for compact fields.
///
/// If [isCompact] is null the function will try to infer compact mode from
/// the provided [label] — it becomes compact when the label contains
/// "commune" or "quartier" (case-insensitive).
InputDecoration compactInputDecoration({
  String? label,
  String? hint,
  bool? isCompact,
  IconData? prefixIcon,
  Widget? suffix,
  Widget? suffixIconWidget,
  InputBorder? border,
  String? counterText,
}) {
  final inferred = (label ?? '').toLowerCase().contains('commune') || (label ?? '').toLowerCase().contains('quartier');
  final effectiveCompact = isCompact ?? inferred;

  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    isDense: effectiveCompact,
    contentPadding: effectiveCompact
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
    border: border ?? OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
    enabledBorder: border ?? OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary, width: 2)),
    prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.textSecondary) : null,
    suffix: suffix,
    // allow passing a widget suffixIcon (IconButton) when needed
    suffixIcon: suffixIconWidget,
    counterText: counterText,
  );
}
