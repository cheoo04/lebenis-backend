import 'package:flutter/material.dart';

class DeliveryListScreen extends StatelessWidget {
  const DeliveryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Remplacer par une vraie liste depuis le provider
    final deliveries = [
      {'recipient': 'Alice', 'address': '123 rue A', 'status': 'En cours'},
      {'recipient': 'Bob', 'address': '456 rue B', 'status': 'Livrée'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Mes livraisons')),
      body: ListView.separated(
        itemCount: deliveries.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, i) {
          final d = deliveries[i];
          return ListTile(
            leading: const Icon(Icons.local_shipping),
            title: Text(d['recipient']!),
            subtitle: Text(d['address']!),
            trailing: Text(d['status']!),
            onTap: () {
              // TODO: Naviguer vers le détail
            },
          );
        },
      ),
    );
  }
}
