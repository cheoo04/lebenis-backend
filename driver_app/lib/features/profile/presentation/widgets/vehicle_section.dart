import 'package:flutter/material.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../shared/widgets/modern_text_field.dart';
import '../../../../shared/widgets/custom_textfield.dart';

class VehicleSection extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController vehicleTypeController;
  final TextEditingController vehiclePlateController;
  final TextEditingController vehicleCapacityController;
  final bool isSubmitting;
  final VoidCallback onSelectVehicleType;

  const VehicleSection({
    super.key,
    required this.phoneController,
    required this.vehicleTypeController,
    required this.vehiclePlateController,
    required this.vehicleCapacityController,
    required this.isSubmitting,
    required this.onSelectVehicleType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informations du véhicule', style: AppTypography.h4),
        const SizedBox(height: AppSpacing.md),
        ModernTextField(
          label: 'Téléphone',
          controller: phoneController,
          prefixIcon: Icons.phone_outlined,
          enabled: !isSubmitting,
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Téléphone requis' : null,
        ),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: isSubmitting ? null : onSelectVehicleType,
          child: AbsorbPointer(
            child: CustomTextField(
              label: 'Type de véhicule',
              controller: vehicleTypeController,
              prefixIcon: Icons.directions_car_outlined,
              enabled: !isSubmitting,
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Type de véhicule requis'
                      : null,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        CustomTextField(
          label: 'Matricule (plaque d\'immatriculation)',
          controller: vehiclePlateController,
          prefixIcon: Icons.confirmation_number_outlined,
          enabled: !isSubmitting,
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Matricule requis' : null,
        ),
        const SizedBox(height: AppSpacing.md),
        CustomTextField(
          label: 'Capacité de charge (kg)',
          controller: vehicleCapacityController,
          prefixIcon: Icons.scale,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Capacité requise';
            }
            final capacity = double.tryParse(value.trim());
            if (capacity == null) {
              return 'Valeur numérique requise';
            }
            // TODO: BackendValidators.validateVehicleCapacity(value)
            return null;
          },
          enabled: !isSubmitting,
        ),
      ],
    );
  }
}
