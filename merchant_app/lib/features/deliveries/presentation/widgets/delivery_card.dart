import 'package:flutter/material.dart';

class DeliveryCard extends StatelessWidget {
  final String recipient;
  final String address;
  final String status;
  final VoidCallback? onTap;

  const DeliveryCard({
    super.key,
    required this.recipient,
    required this.address,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_shipping),
        title: Text(recipient),
        subtitle: Text(address),
        trailing: Text(status),
        onTap: onTap,
      ),
    );
  }
}
