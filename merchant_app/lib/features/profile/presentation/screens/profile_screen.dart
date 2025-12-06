import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/providers/user_profile_provider.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/models/merchant_model.dart';
import '../../../../data/models/individual_model.dart';
import '../widgets/verification_status.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final isMerchant = ref.watch(isMerchantProvider);

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
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Aucun profil trouvé'));
          }
          
          // Affichage selon le type d'utilisateur
          if (profile is MerchantModel) {
            return _buildMerchantProfile(context, ref, profile);
          } else if (profile is IndividualModel) {
            return _buildIndividualProfile(context, ref, profile);
          } else if (profile is Map) {
            // Fallback pour profil individual en Map
            return _buildIndividualProfileFromMap(context, ref, profile);
          }
          
          return const Center(child: Text('Type de profil inconnu'));
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Erreur: $error')),
      ),
    );
  }

  Widget _buildMerchantProfile(BuildContext context, WidgetRef ref, MerchantModel merchant) {
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
          const SizedBox(height: 24),
          _buildLogoutButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildIndividualProfile(BuildContext context, WidgetRef ref, IndividualModel individual) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // En-tête profil : avatar, nom, email
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              individual.fullName.isNotEmpty ? individual.fullName[0].toUpperCase() : 'P',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            individual.fullName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            individual.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              'Particulier',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(context, icon: Icons.person, title: 'Nom complet', value: individual.fullName),
          _buildInfoCard(context, icon: Icons.phone, title: 'Téléphone', value: individual.phone.isNotEmpty ? individual.phone : '-'),
          _buildInfoCard(context, icon: Icons.location_on, title: 'Adresse', value: individual.address.isNotEmpty ? individual.address : '-'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Naviguer vers l'édition du profil
            },
            icon: const Icon(Icons.edit),
            label: const Text('Modifier le profil'),
          ),
          const SizedBox(height: 24),
          _buildLogoutButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildIndividualProfileFromMap(BuildContext context, WidgetRef ref, Map profile) {
    final fullName = '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}'.trim();
    final email = profile['email'] ?? '';
    final phone = profile['phone'] ?? '';
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // En-tête profil : avatar, nom, email
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              fullName.isNotEmpty ? fullName[0].toUpperCase() : 'P',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName.isNotEmpty ? fullName : 'Utilisateur',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              'Particulier',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(context, icon: Icons.person, title: 'Nom complet', value: fullName.isNotEmpty ? fullName : '-'),
          _buildInfoCard(context, icon: Icons.phone, title: 'Téléphone', value: phone.isNotEmpty ? phone : '-'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Naviguer vers l'édition du profil
            },
            icon: const Icon(Icons.edit),
            label: const Text('Modifier le profil'),
          ),
          const SizedBox(height: 24),
          _buildLogoutButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Afficher un dialogue de confirmation
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Déconnexion'),
              content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Déconnecter'),
                ),
              ],
            ),
          );
          
          if (confirm == true && context.mounted) {
            await ref.read(authStateProvider.notifier).logout();
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          }
        },
        icon: const Icon(Icons.logout),
        label: const Text('Déconnexion'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
        ),
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
