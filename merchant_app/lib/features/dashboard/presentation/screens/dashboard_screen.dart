import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/merchant_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(merchantProfileProvider);
    final statsAsync = ref.watch(merchantStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(merchantProfileProvider);
              ref.refresh(merchantStatsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(merchantProfileProvider);
          ref.refresh(merchantStatsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profil
                profileAsync.when(
                  data: (profile) => _buildProfileCard(context, profile),
                  loading: () => const _LoadingCard(),
                  error: (err, st) => _ErrorCard(error: err.toString()),
                ),
                const SizedBox(height: 24),
                // Statistiques
                statsAsync.when(
                  data: (stats) => _buildStatsCard(context, stats),
                  loading: () => const _LoadingCard(),
                  error: (err, st) => _ErrorCard(error: err.toString()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, dynamic profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profil Marchand',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Commerce'),
              subtitle: Text(profile.businessName),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(profile.email),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Téléphone'),
              subtitle: Text(profile.phone),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Adresse'),
              subtitle: Text(profile.address),
            ),
            ListTile(
              leading: const Icon(Icons.verified),
              title: const Text('Statut'),
              subtitle: Text(profile.statusLabel),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: profile.verificationStatus == 'approved'
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  profile.statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: profile.verificationStatus == 'approved'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/edit-profile');
              },
              child: const Text('Modifier le profil'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, dynamic stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiques (30 derniers jours)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            // Livraisons
            _StatRow(
              icon: Icons.local_shipping,
              label: 'Livraisons',
              value: '${stats.periodDeliveries}',
              subLabel: 'Taux de succès: ${stats.successRate.toStringAsFixed(1)}%',
            ),
            const SizedBox(height: 12),
            // Revenus
            _StatRow(
              icon: Icons.attach_money,
              label: 'Revenus',
              value: stats.formattedRevenue,
              subLabel: 'Payé: ${stats.paid.toStringAsFixed(0)} FCFA',
            ),
            const SizedBox(height: 12),
            // Factures
            _StatRow(
              icon: Icons.receipt,
              label: 'Factures',
              value: '${stats.invoicesPaid}/${stats.invoicesTotal}',
              subLabel: 'Payées',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subLabel;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.subLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 14)),
              Text(subLabel, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 100,
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;

  const _ErrorCard({required this.error});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error, color: Colors.red.shade700, size: 32),
            const SizedBox(height: 8),
            Text('Erreur: $error', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}