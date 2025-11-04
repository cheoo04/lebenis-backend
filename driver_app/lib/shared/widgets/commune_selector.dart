// lib/shared/widgets/commune_selector.dart

import 'package:flutter/material.dart';
import '../../core/constants/backend_constants.dart';
import '../theme/app_colors.dart';
import '../theme/dimensions.dart';
import '../theme/text_styles.dart';

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
          style: TextStyles.labelMedium,
        ),
        const SizedBox(height: Dimensions.spacingS),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(Dimensions.radiusM),
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
                  horizontal: Dimensions.spacingM,
                ),
                child: Text(
                  'Sélectionnez une commune',
                  style: TextStyles.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.spacingM,
                vertical: Dimensions.spacingS,
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
                    style: TextStyles.bodyMedium,
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
          style: TextStyles.labelMedium,
        ),
        const SizedBox(height: Dimensions.spacingM),
        ...BackendConstants.paymentMethodChoices.map((method) {
          final isSelected = selectedMethod == method;
          return Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.spacingS),
            child: InkWell(
              onTap: enabled
                  ? () {
                      onMethodSelected(method);
                    }
                  : null,
              borderRadius: BorderRadius.circular(Dimensions.radiusM),
              child: Container(
                padding: const EdgeInsets.all(Dimensions.spacingM),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(Dimensions.radiusM),
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
                    const SizedBox(width: Dimensions.spacingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            BackendConstants.getPaymentMethodLabel(method),
                            style: TextStyles.bodyMedium.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            ),
                          ),
                          if (method == BackendConstants.paymentMethodCod)
                            Text(
                              'Le destinataire paiera à la livraison',
                              style: TextStyles.caption.copyWith(
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
          style: TextStyles.labelMedium,
        ),
        const SizedBox(height: Dimensions.spacingM),
        Row(
          children: BackendConstants.schedulingTypeChoices.map((type) {
            final isSelected = selectedType == type;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: Dimensions.spacingS),
                child: InkWell(
                  onTap: enabled
                      ? () {
                          onTypeSelected(type);
                        }
                      : null,
                  borderRadius: BorderRadius.circular(Dimensions.radiusM),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.spacingM,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.grey[100],
                      borderRadius: BorderRadius.circular(Dimensions.radiusM),
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
                          size: Dimensions.iconL,
                        ),
                        const SizedBox(height: Dimensions.spacingXS),
                        Text(
                          BackendConstants.schedulingTypeLabels[type]!,
                          style: TextStyles.labelSmall.copyWith(
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
