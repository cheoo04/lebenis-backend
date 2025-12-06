import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../../../../data/providers/user_profile_provider.dart';
import '../../../../data/providers/individual_provider.dart';
import '../../../../data/models/individual_model.dart';
import '../../../../shared/widgets/modern_text_field.dart';
import '../../../../shared/widgets/modern_button.dart';

class EditIndividualProfileScreen extends ConsumerStatefulWidget {
  final IndividualModel individual;

  const EditIndividualProfileScreen({
    required this.individual,
    super.key,
  });

  @override
  ConsumerState<EditIndividualProfileScreen> createState() =>
      _EditIndividualProfileScreenState();
}

class _EditIndividualProfileScreenState
    extends ConsumerState<EditIndividualProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: _getFirstName(widget.individual.fullName),
    );
    _lastNameController = TextEditingController(
      text: _getLastName(widget.individual.fullName),
    );
    _emailController = TextEditingController(text: widget.individual.email);
    _phoneController =
        TextEditingController(text: widget.individual.phone ?? '');
    _addressController =
        TextEditingController(text: widget.individual.address ?? '');
  }

  String _getFirstName(String fullName) {
    final parts = fullName.split(' ');
    return parts.isNotEmpty ? parts[0] : '';
  }

  String _getLastName(String fullName) {
    final parts = fullName.split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final phone = _phoneController.text.trim();
      final address = _addressController.text.trim();

      // Appeler l'API pour mettre à jour le profil du particulier via le provider
      await ref.read(individualProfileProvider.notifier).updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        address: address,
      );

      // Recharger le profil général pour mettre à jour l'UI
      await ref.read(userProfileProvider.notifier).loadProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Avatar section
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.individual.fullName.isNotEmpty
                        ? widget.individual.fullName[0].toUpperCase()
                        : 'P',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // First name
            ModernTextField(
              controller: _firstNameController,
              label: 'Prénom',
              hint: 'Ex: Jean',
              prefixIcon: Icons.person,
              validator: (v) => v == null || v.isEmpty ? 'Prénom requis' : null,
            ),
            const SizedBox(height: 20),

            // Last name
            ModernTextField(
              controller: _lastNameController,
              label: 'Nom',
              hint: 'Ex: Dupont',
              prefixIcon: Icons.person_outline,
              validator: (v) => v == null || v.isEmpty ? 'Nom requis' : null,
            ),
            const SizedBox(height: 20),

            // Email
            ModernTextField(
              controller: _emailController,
              label: 'Email',
              hint: 'contact@example.com',
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              readOnly: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email requis';
                if (!v.contains('@')) return 'Email invalide';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Phone
            ModernTextField(
              controller: _phoneController,
              label: 'Téléphone',
              hint: '+225 07 XX XX XX XX',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Téléphone requis';
                if (v.length < 10) return 'Numéro invalide';
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Address
            ModernTextField(
              controller: _addressController,
              label: 'Adresse',
              hint: 'Commune, rue, immeuble...',
              prefixIcon: Icons.location_on,
              maxLines: 3,
              validator: (v) => v == null || v.isEmpty ? 'Adresse requise' : null,
            ),
            const SizedBox(height: 40),

            // Save button
            ModernButton(
              text: 'Enregistrer les modifications',
              icon: Icons.save,
              onPressed: _saveProfile,
              isLoading: _isSaving,
              backgroundColor: AppTheme.primaryColor,
            ),
            const SizedBox(height: 20),

            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Les modifications seront visibles après validation',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[900],
                      ),
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
