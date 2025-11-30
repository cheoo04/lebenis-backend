import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/backend_validators.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import 'language_selector.dart';

class IdentitySection extends StatelessWidget {
  final TextEditingController cniController;
  final DateTime? dateOfBirth;
  final bool isSubmitting;
  final ValueChanged<DateTime?> onDateChanged;
  final List<String> allLanguages;
  final List<String> selectedLanguages;
  final ValueChanged<List<String>> onLanguagesChanged;
  final Widget cniFrontWidget;
  final Widget cniBackWidget;
  final VoidCallback onPickCniFront;
  final VoidCallback onPickCniBack;

  const IdentitySection({
    super.key,
    required this.cniController,
    required this.dateOfBirth,
    required this.isSubmitting,
    required this.onDateChanged,
    required this.allLanguages,
    required this.selectedLanguages,
    required this.onLanguagesChanged,
    required this.cniFrontWidget,
    required this.cniBackWidget,
    required this.onPickCniFront,
    required this.onPickCniBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informations d\'identité', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: Dimensions.spacingM),
        CustomTextField(
          label: 'Numéro de CNI',
          controller: cniController,
          prefixIcon: Icons.credit_card,
          enabled: !isSubmitting,
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Numéro de CNI requis' : null,
        ),
        const SizedBox(height: Dimensions.spacingM),
        ListTile(
          leading: const Icon(Icons.cake),
          title: Text(dateOfBirth != null
              ? DateFormat('dd/MM/yyyy').format(dateOfBirth!)
              : 'Date de naissance'),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: isSubmitting
                ? null
                : () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dateOfBirth ?? DateTime(1990, 1, 1),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      onDateChanged(picked);
                    }
                  },
            ),
        ),
        const SizedBox(height: Dimensions.spacingM),
        LanguageSelector(
          allLanguages: allLanguages,
          selectedLanguages: selectedLanguages,
          isSubmitting: isSubmitting,
          onChanged: onLanguagesChanged,
        ),
        const SizedBox(height: Dimensions.spacingM),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text('Photo recto CNI'),
                  const SizedBox(height: 8),
                  cniFrontWidget,
                  TextButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Uploader recto'),
                    onPressed: isSubmitting ? null : onPickCniFront,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Text('Photo verso CNI'),
                  const SizedBox(height: 8),
                  cniBackWidget,
                  TextButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Uploader verso'),
                    onPressed: isSubmitting ? null : onPickCniBack,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
