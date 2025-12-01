// lib/shared/widgets/quantity_controls.dart

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../theme/app_radius.dart';

/// Contrôles de quantité (+/-) avec design moderne
class QuantityControls extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int? maxQuantity;
  final int minQuantity;

  const QuantityControls({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.maxQuantity,
    this.minQuantity = 0,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrement = quantity > minQuantity;
    final canIncrement = maxQuantity == null || quantity < maxQuantity!;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton -
          _QuantityButton(
            icon: Icons.remove,
            onTap: canDecrement ? onDecrement : null,
          ),
          
          // Quantité
          Container(
            constraints: const BoxConstraints(minWidth: 40),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              quantity.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          
          // Bouton +
          _QuantityButton(
            icon: Icons.add,
            onTap: canIncrement ? onIncrement : null,
          ),
        ],
      ),
    );
  }
}

/// Bouton individuel pour les contrôles de quantité
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: isEnabled ? AppColors.primary : AppColors.textDisabled,
          ),
        ),
      ),
    );
  }
}
