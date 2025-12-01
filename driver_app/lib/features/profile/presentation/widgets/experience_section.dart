import 'package:flutter/material.dart';

class ExperienceSection extends StatelessWidget {
  final TextEditingController yearsOfExperienceController;
  final TextEditingController previousEmployerController;
  final bool isSubmitting;
  const ExperienceSection({
    super.key,
    required this.yearsOfExperienceController,
    required this.previousEmployerController,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Expérience professionnelle", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: yearsOfExperienceController,
          decoration: const InputDecoration(labelText: "Années d'expérience en livraison"),
          keyboardType: TextInputType.number,
          enabled: !isSubmitting,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: previousEmployerController,
          decoration: const InputDecoration(labelText: 'Dernier employeur'),
          enabled: !isSubmitting,
        ),
      ],
    );
  }
}
