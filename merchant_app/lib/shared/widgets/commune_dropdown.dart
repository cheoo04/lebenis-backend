import 'package:flutter/material.dart';

class CommuneDropdown extends StatelessWidget {
  final List<String> communes;
  final String? value;
  final void Function(String?)? onChanged;
  final String label;

  const CommuneDropdown({
    super.key,
    required this.communes,
    this.value,
    this.onChanged,
    this.label = 'Commune',
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: communes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
    );
  }
}
