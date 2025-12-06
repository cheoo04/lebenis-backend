import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../theme/app_theme.dart';
import '../../../../data/providers/merchant_provider.dart';
import '../../../../shared/widgets/modern_text_field.dart';
import '../../../../shared/widgets/modern_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;
  bool _isSaving = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Charger les données dans un Future microtask pour éviter l'erreur de provider
    Future.microtask(() => _loadProfile());
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de l\'image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choisir une photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Prendre une photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choisir depuis la galerie'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      // Charger le profil
      await ref.read(merchantProfileProvider.notifier).loadProfile();
      
      // Attendre un frame pour que le provider soit mis à jour
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (!mounted) return;
      
      // Lire les données du profil
      final merchantAsync = ref.read(merchantProfileProvider);
      
      merchantAsync.whenData((merchant) {
        if (merchant != null && mounted) {
          _businessNameController.text = merchant.businessName;
          if (merchant.user != null) {
            _emailController.text = merchant.user!['email'] ?? '';
            _phoneController.text = merchant.user!['phone'] ?? '';
          }
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Récupérer l'ID du merchant depuis le profil
      final merchantAsync = ref.read(merchantProfileProvider);
      String? merchantId;
      merchantAsync.whenData((merchant) {
        merchantId = merchant?.id;
      });
      
      if (merchantId == null) {
        throw Exception('Impossible de récupérer l\'ID du merchant');
      }
      
      await ref.read(merchantRepositoryProvider).updateProfile(
        merchantId: merchantId!,
        businessName: _businessNameController.text.trim(),
        phone: _phoneController.text.trim(),
        businessAddress: _addressController.text.trim(),
      );

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Avatar section
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryColor,
                              width: 3,
                            ),
                            image: _selectedImage != null
                                ? DecorationImage(
                                    image: FileImage(_selectedImage!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _selectedImage == null
                              ? const Icon(
                                  Icons.store,
                                  size: 50,
                                  color: AppTheme.primaryColor,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showImageSourceDialog,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Business name / Nom du commerce
                  ModernTextField(
                    controller: _businessNameController,
                    label: 'Nom du commerce / Entreprise',
                    hint: 'Ex: Boutique Centrale, Shop Plus...',
                    prefixIcon: Icons.store,
                    validator: (v) => v == null || v.isEmpty ? 'Nom requis' : null,
                  ),

                  const SizedBox(height: 20),

                  // Email
                  ModernTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'contact@business.com',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
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
