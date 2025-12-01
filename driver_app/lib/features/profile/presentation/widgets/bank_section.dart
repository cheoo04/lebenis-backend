import 'package:flutter/material.dart';

class BankSection extends StatelessWidget {
  final TextEditingController bankAccountNameController;
  final TextEditingController bankAccountNumberController;
  final TextEditingController bankNameController;
  final bool isSubmitting;
  const BankSection({
    super.key,
    required this.bankAccountNameController,
    required this.bankAccountNumberController,
    required this.bankNameController,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Informations bancaires', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: bankAccountNameController,
          decoration: const InputDecoration(labelText: 'Nom du titulaire du compte'),
          enabled: !isSubmitting,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: bankAccountNumberController,
          decoration: const InputDecoration(labelText: 'Numéro de compte'),
          enabled: !isSubmitting,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: bankNameController,
          decoration: const InputDecoration(labelText: 'Banque'),
          enabled: !isSubmitting,
        ),
      ],
    );
  }
}
