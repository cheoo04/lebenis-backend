import 'package:flutter/material.dart';
import '../../../../shared/theme/dimensions.dart';
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
        Text('Informations du véhicule', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: Dimensions.spacingM),
        CustomTextField(
          label: 'Téléphone',
          controller: phoneController,
          prefixIcon: Icons.phone,
          enabled: !isSubmitting,
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Téléphone requis' : null,
        ),
        const SizedBox(height: Dimensions.spacingM),
        GestureDetector(
          onTap: isSubmitting ? null : onSelectVehicleType,
          child: AbsorbPointer(
            child: CustomTextField(
              label: 'Type de véhicule',
              controller: vehicleTypeController,
              prefixIcon: Icons.directions_car,
              enabled: !isSubmitting,
              readOnly: true,
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Type de véhicule requis'
                      : null,
            ),
          ),
        ),
        const SizedBox(height: Dimensions.spacingM),
        CustomTextField(
          label: 'Matricule (plaque d\'immatriculation)',
          controller: vehiclePlateController,
          prefixIcon: Icons.confirmation_number,
          enabled: !isSubmitting,
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Matricule requis' : null,
        ),
        const SizedBox(height: Dimensions.spacingM),
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
