// Widget pour sélectionner une adresse de livraison
import 'package:flutter/material.dart';

class AddressPicker extends StatelessWidget {
  final String? selectedAddress;
  final VoidCallback? onTap;
  const AddressPicker({super.key, this.selectedAddress, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.location_on, color: Colors.blue),
      title: Text(selectedAddress ?? 'Sélectionner une adresse'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
