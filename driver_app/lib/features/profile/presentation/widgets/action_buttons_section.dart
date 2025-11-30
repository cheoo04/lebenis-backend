import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_button.dart';

class ActionButtonsSection extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const ActionButtonsSection({
    super.key,
    required this.isSubmitting,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: 'Enregistrer les modifications',
          onPressed: isSubmitting ? null : onSave,
          isLoading: isSubmitting,
          icon: Icons.save,
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          icon: const Icon(Icons.close),
          label: const Text('Annuler'),
          onPressed: isSubmitting ? null : onCancel,
        ),
      ],
    );
  }
}
