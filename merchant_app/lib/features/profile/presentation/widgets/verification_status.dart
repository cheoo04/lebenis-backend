import 'package:flutter/material.dart';

class VerificationStatus extends StatelessWidget {
  final bool isVerified;
  const VerificationStatus({super.key, required this.isVerified});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isVerified ? Icons.verified : Icons.error_outline,
          color: isVerified ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 8),
        Text(
          isVerified ? 'Compte vérifié' : 'Vérification en attente',
          style: TextStyle(
            color: isVerified ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
