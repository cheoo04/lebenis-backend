import 'package:flutter/material.dart';

class DeliveryDetailScreen extends StatelessWidget {
  const DeliveryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Récupérer la livraison depuis le provider ou les arguments
    final delivery = {
      'recipient': 'Alice',
      'address': '123 rue A',
      'status': 'En cours',
      'package': 'Petit colis',
      'date': '2025-11-15',
    };
    return Scaffold(
      appBar: AppBar(title: const Text('Détail livraison')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Destinataire : ${delivery['recipient']}', style: Theme.of(context).textTheme.titleMedium),
            Text('Adresse : ${delivery['address']}'),
            Text('Statut : ${delivery['status']}'),
            Text('Colis : ${delivery['package']}'),
            Text('Date : ${delivery['date']}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Action de suivi ou autre
              },
              child: const Text('Suivre la livraison'),
            ),
          ],
        ),
      ),
    );
  }
}
