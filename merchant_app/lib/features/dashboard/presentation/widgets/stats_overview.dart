import 'package:flutter/material.dart';


// Widget réutilisable pour afficher une statistique avec icône, titre, valeur, couleur et action
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? Theme.of(context).cardColor,
      child: ListTile(
        leading: Icon(icon, color: color ?? Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(value, style: Theme.of(context).textTheme.titleLarge),
        onTap: onTap,
      ),
    );
  }
}

class StatsOverview extends StatelessWidget {
  final int deliveries;
  final double revenue;
  final int invoicesPaid;
  final int invoicesTotal;
  const StatsOverview({
    required this.deliveries,
    required this.revenue,
    required this.invoicesPaid,
    required this.invoicesTotal,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistiques', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(label: 'Livraisons', value: deliveries.toString()),
                _StatItem(label: 'Revenus', value: '${revenue.toStringAsFixed(0)} FCFA'),
                _StatItem(label: 'Factures', value: '$invoicesPaid/$invoicesTotal'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
