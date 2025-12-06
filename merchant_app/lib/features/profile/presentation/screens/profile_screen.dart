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
          
          // Extraire les informations de l'utilisateur
          final userName = merchant.user?['first_name'] ?? '';
          final userLastName = merchant.user?['last_name'] ?? '';
          final userEmail = merchant.user?['email'] ?? '';
          final fullName = '$userName $userLastName'.trim();
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // En-tête profil : avatar, nom, email, bouton éditer
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.orange.shade100,
                  child: Text(
                    merchant.businessName.isNotEmpty ? merchant.businessName[0].toUpperCase() : 'M',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  merchant.businessName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  userEmail,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                VerificationStatus(isVerified: merchant.isVerified),
                const SizedBox(height: 16),
                _buildInfoCard(context, icon: Icons.person, title: 'Nom complet', value: fullName.isNotEmpty ? fullName : '-'),
                _buildInfoCard(context, icon: Icons.phone, title: 'Téléphone', value: merchant.user?['phone'] ?? '-'),
                _buildInfoCard(context, icon: Icons.category, title: 'Type de commerce', value: merchant.businessType ?? '-'),
                _buildInfoCard(context, icon: Icons.numbers, title: 'Numéro RCCM', value: merchant.registrationNumber ?? '-'),
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
