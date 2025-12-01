// lib/shared/widgets/commune_selector.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../core/constants/backend_constants.dart';


/// Widget pour sélectionner une commune
/// Utilise les communes définies dans BackendConstants
class CommuneSelector extends StatelessWidget {
  final String? selectedCommune;
  final Function(String) onCommuneSelected;
  final String label;
  final bool enabled;

  const CommuneSelector({
    super.key,
    required this.selectedCommune,
    required this.onCommuneSelected,
    this.label = 'Commune',
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCommune,
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: Text(
                  'Sélectionnez une commune',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              icon: Icon(
                Icons.arrow_drop_down,
                color: enabled ? AppColors.primary : AppColors.textDisabled,
              ),
              items: BackendConstants.communeChoices.map((commune) {
                return DropdownMenuItem<String>(
                  value: commune,
                  child: Text(
                    BackendConstants.getCommuneLabel(commune),
                    style: AppTypography.bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: enabled
                  ? (value) {
                      if (value != null) {
                        onCommuneSelected(value);
                      }
                    }
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget pour sélectionner une méthode de paiement
class PaymentMethodSelector extends StatelessWidget {
  final String? selectedMethod;
  final Function(String) onMethodSelected;
  final bool enabled;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Méthode de paiement',
          style: AppTypography.labelMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        ...BackendConstants.paymentMethodChoices.map((method) {
          final isSelected = selectedMethod == method;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: InkWell(
              onTap: enabled
                  ? () {
                      onMethodSelected(method);
                    }
                  : null,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            BackendConstants.getPaymentMethodLabel(method),
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            ),
                          ),
                          if (method == BackendConstants.paymentMethodCod)
                            Text(
                              'Le destinataire paiera à la livraison',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Widget pour sélectionner le type de planification
class SchedulingTypeSelector extends StatelessWidget {
  final String? selectedType;
  final Function(String) onTypeSelected;
  final bool enabled;

  const SchedulingTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quand souhaitez-vous cette livraison ?',
          style: AppTypography.labelMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: BackendConstants.schedulingTypeChoices.map((type) {
            final isSelected = selectedType == type;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: InkWell(
                  onTap: enabled
                      ? () {
                          onTypeSelected(type);
                        }
                      : null,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.grey[100],
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          type == BackendConstants.schedulingTypeImmediate
                              ? Icons.flash_on
                              : Icons.schedule,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          size: 32.0,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          BackendConstants.schedulingTypeLabels[type]!,
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
