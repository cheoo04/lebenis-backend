// Widget pour afficher la timeline du statut d'une livraison
import 'package:flutter/material.dart';

class StatusTimeline extends StatelessWidget {
  final List<String> statuses;
  final int currentStep;
  const StatusTimeline({super.key, required this.statuses, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < statuses.length; i++)
          Row(
            children: [
              Icon(
                i < currentStep ? Icons.check_circle : Icons.radio_button_unchecked,
                color: i < currentStep ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(statuses[i]),
            ],
          ),
      ],
    );
  }
}
