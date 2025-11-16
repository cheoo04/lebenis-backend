import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/providers/merchant_provider.dart';
import '../widgets/verification_status.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final merchantAsync = ref.watch(merchantProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: merchantAsync.when(
        data: (merchant) {
          if (merchant == null) {
            return const Center(child: Text('Aucun profil trouvé'));
          }
          // Cast explicite si nécessaire
          final m = merchant as dynamic;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // En-tête profil : avatar, nom, email, bouton éditer
                CircleAvatar(
                  radius: 60,
                  backgroundImage: m.profilePhoto != null ? NetworkImage(m.profilePhoto!) : null,
                  child: m.profilePhoto == null ? const Icon(Icons.store, size: 60) : null,
                ),
                const SizedBox(height: 16),
                Text(
                  m.businessName ?? '-',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  m.email ?? '-',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Naviguer vers l'édition du profil
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Modifier'),
                ),
                const SizedBox(height: 8),
                VerificationStatus(isVerified: m.isVerified == true),
                _buildInfoCard(context, icon: Icons.phone, title: 'Téléphone', value: m.phone ?? '-'),
                _buildInfoCard(context, icon: Icons.location_on, title: 'Adresse', value: m.address ?? '-'),
                _buildInfoCard(context, icon: Icons.category, title: 'Type de commerce', value: m.businessType ?? '-'),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Naviguer vers l'édition du profil
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Modifier le profil'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur: $error')),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String title, required String value}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}
