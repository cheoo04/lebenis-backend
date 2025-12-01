import 'package:flutter/material.dart';

class EmergencyContactSection extends StatelessWidget {
  final TextEditingController contactNameController;
  final TextEditingController contactPhoneController;
  final TextEditingController contactRelationshipController;
  final bool isSubmitting;
  const EmergencyContactSection({
    super.key,
    required this.contactNameController,
    required this.contactPhoneController,
    required this.contactRelationshipController,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Contact d'urgence", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: contactNameController,
          decoration: const InputDecoration(labelText: 'Nom du contact'),
          enabled: !isSubmitting,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: contactPhoneController,
          decoration: const InputDecoration(labelText: 'Téléphone'),
          keyboardType: TextInputType.phone,
          enabled: !isSubmitting,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: contactRelationshipController,
          decoration: const InputDecoration(labelText: 'Lien de parenté'),
          enabled: !isSubmitting,
        ),
      ],
    );
  }
}
