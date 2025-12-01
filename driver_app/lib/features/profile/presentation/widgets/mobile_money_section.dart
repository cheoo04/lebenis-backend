import 'package:flutter/material.dart';

class MobileMoneySection extends StatelessWidget {
  final TextEditingController mobileMoneyNumberController;
  final String? selectedProvider;
  final void Function(String?) onProviderChanged;
  final bool isSubmitting;
  const MobileMoneySection({
    super.key,
    required this.mobileMoneyNumberController,
    required this.selectedProvider,
    required this.onProviderChanged,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mobile Money', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: mobileMoneyNumberController,
          decoration: const InputDecoration(labelText: 'Numéro Mobile Money'),
          enabled: !isSubmitting,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedProvider,
          items: const [
            DropdownMenuItem(value: 'orange', child: Text('Orange Money')),
            DropdownMenuItem(value: 'mtn', child: Text('MTN Money')),
            DropdownMenuItem(value: 'wave', child: Text('Wave')),
          ],
          onChanged: isSubmitting ? null : onProviderChanged,
          decoration: const InputDecoration(labelText: 'Opérateur'),
        ),
      ],
    );
  }
}
