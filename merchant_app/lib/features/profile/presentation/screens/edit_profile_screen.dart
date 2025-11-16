import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Charger et éditer les infos du profil marchand
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Champs d'édition (nom, email, téléphone, etc.)
            TextFormField(
              decoration: const InputDecoration(labelText: 'Nom du commerce'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Téléphone'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Sauvegarder les modifications
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}
