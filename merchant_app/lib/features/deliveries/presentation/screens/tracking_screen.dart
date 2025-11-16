import 'package:flutter/material.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Afficher une vraie carte avec la position du livreur
    return Scaffold(
      appBar: AppBar(title: const Text('Suivi de livraison')),
      body: const Center(
        child: Text('Carte de suivi ici (Google Maps, etc.)'),
      ),
    );
  }
}
