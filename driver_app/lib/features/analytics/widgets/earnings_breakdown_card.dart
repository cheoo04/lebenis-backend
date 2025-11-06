import 'package:flutter/material.dart';
import '../../../data/models/analytics/earnings_breakdown_model.dart';

class EarningsBreakdownCard extends StatelessWidget {
  final EarningsBreakdownModel breakdown;

  const EarningsBreakdownCard({
    super.key,
    required this.breakdown,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Earnings Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _EarningRow(
              label: 'Delivery Earnings',
              amount: breakdown.deliveryEarnings,
              icon: Icons.delivery_dining,
              color: Colors.blue,
            ),
            const Divider(),
            _EarningRow(
              label: 'Bonus Earnings',
              amount: breakdown.bonusEarnings,
              icon: Icons.star,
              color: Colors.amber,
            ),
            const Divider(),
            _EarningRow(
              label: 'Tip Earnings',
              amount: breakdown.tipEarnings,
              icon: Icons.attach_money,
              color: Colors.green,
            ),
            const Divider(),
            _EarningRow(
              label: 'Adjustments',
              amount: breakdown.adjustmentEarnings,
              icon: Icons.tune,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Earnings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${breakdown.totalEarnings.toStringAsFixed(2)} DA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningRow extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _EarningRow({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} DA',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
