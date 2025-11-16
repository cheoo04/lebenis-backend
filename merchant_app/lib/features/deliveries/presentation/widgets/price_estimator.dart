// Widget pour estimer le prix d'une livraison
import 'package:flutter/material.dart';

class PriceEstimator extends StatelessWidget {
  final double? estimatedPrice;
  const PriceEstimator({super.key, this.estimatedPrice});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Estimation du prix', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              estimatedPrice != null ? '${estimatedPrice!.toStringAsFixed(0)} FCFA' : '--',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
