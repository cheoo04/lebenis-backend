import 'package:flutter/material.dart';

class WaitingApprovalScreen extends StatelessWidget {
  const WaitingApprovalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compte en attente'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.hourglass_empty, size: 64, color: Colors.orange),
              SizedBox(height: 24),
              Text(
                'Votre compte marchand est en cours de vérification.\nVous recevrez une notification dès validation.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
