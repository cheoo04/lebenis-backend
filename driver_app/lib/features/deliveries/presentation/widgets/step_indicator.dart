import 'package:flutter/material.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../core/constants/app_colors.dart';

enum DeliveryStep {
  goingToPickup,
  goingToDelivery,
}

class StepIndicator extends StatelessWidget {
  final DeliveryStep currentStep;
  const StepIndicator({required this.currentStep, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StepItem(
            icon: Icons.store,
            label: 'Récupération',
            isActive: currentStep == DeliveryStep.goingToPickup,
            isCompleted: currentStep == DeliveryStep.goingToDelivery,
          ),
        ),
        Container(
          width: 40,
          height: 2,
          color: currentStep == DeliveryStep.goingToDelivery
              ? AppColors.success
              : AppColors.border,
        ),
        Expanded(
          child: StepItem(
            icon: Icons.home,
            label: 'Livraison',
            isActive: currentStep == DeliveryStep.goingToDelivery,
            isCompleted: false,
          ),
        ),
      ],
    );
  }
}

class StepItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCompleted;
  const StepItem({required this.icon, required this.label, required this.isActive, required this.isCompleted, super.key});

  @override
  Widget build(BuildContext context) {
    final color = isCompleted
        ? AppColors.success
        : isActive
            ? AppColors.primary
            : AppColors.textSecondary;
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isCompleted || isActive ? color : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isCompleted || isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
