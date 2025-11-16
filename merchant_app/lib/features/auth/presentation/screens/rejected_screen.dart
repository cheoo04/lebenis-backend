import 'package:flutter/material.dart';

class RejectedScreen extends StatelessWidget {
  final String? reason;
  const RejectedScreen({Key? key, this.reason}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compte refusé'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cancel, size: 64, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                'Votre compte marchand a été refusé.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              if (reason != null && reason!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Motif :\n$reason',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.redAccent),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // TODO: Ajouter une action de contact support si besoin
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Retour à la connexion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
