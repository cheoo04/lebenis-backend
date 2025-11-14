// driver_app/lib/features/profile/presentation/screens/edit_profile_screen.dart
import 'dart:io';
import 'dart:typed_data';
import '../../../../core/utils/helpers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/models/driver_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../data/providers/driver_provider.dart';
import '../../../../core/utils/backend_validators.dart';
import '../../../../core/constants/backend_constants.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../../../../shared/widgets/network_image_cached.dart';
import '../../../../shared/utils/helpers.dart';
import '../../../../shared/utils/validators.dart';


class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}


class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
    Future<void> _deleteProfilePhoto() async {
      final confirmed = await Helpers.showConfirmDialog(
        context,
        title: 'Supprimer la photo de profil',
        message: 'Voulez-vous vraiment supprimer votre photo de profil ? Cette action est irréversible.',
        confirmText: 'Supprimer',
        cancelText: 'Annuler',
      );
      if (confirmed != true) return;
      setState(() => _isSubmitting = true);
      try {
        final success = await ref.read(driverProvider.notifier).deleteProfilePhoto();
        if (success) {
          _resetPhotoState();
          imageCache.clear();
          imageCache.clearLiveImages();
          final driver = ref.read(driverProvider).driver;
          if (driver?.profilePhoto != null) {
            await CachedNetworkImageProvider(driver!.profilePhoto!).evict();
          }
          Helpers.showSuccessSnackBar(context, 'Photo de profil supprimée avec succès');
        } else {
          Helpers.showErrorSnackBar(context, 'Échec de la suppression de la photo');
        }
      } catch (e) {
        Helpers.showErrorSnackBar(context, 'Erreur: $e');
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  // ========== CONTROLLERS & STATE ==========
  late GlobalKey<FormState> _formKey;
  late TextEditingController _phoneController;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _vehiclePlateController;
  late TextEditingController _vehicleCapacityController;

  late String _selectedVehicleType;
  dynamic _newProfilePhoto;
  Uint8List? _newProfilePhotoBytes;
  bool _isSubmitting = false;
  String? _initialProfilePhotoUrl;
  bool _photoMarkedForDeletion = false;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _phoneController = TextEditingController();
    _vehicleTypeController = TextEditingController();
    _vehiclePlateController = TextEditingController();
    _vehicleCapacityController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _vehicleTypeController.dispose();
    _vehiclePlateController.dispose();
    _vehicleCapacityController.dispose();
    super.dispose();
  }

  void _initializeForm(DriverModel driver) {
    _phoneController.text = driver.phone;
    _selectedVehicleType = driver.vehicleType;
    _vehicleTypeController.text = driver.vehicleTypeLabel;
    _vehiclePlateController.text = driver.vehicleRegistration ?? '';
    _vehicleCapacityController.text = driver.vehicleCapacityKg.toString();
    _initialProfilePhotoUrl = driver.profilePhoto;
    _photoMarkedForDeletion = false;
    _newProfilePhoto = null;
    _newProfilePhotoBytes = null;
  }

Future<void> _pickProfilePhoto() async {
  try {
    final ImagePicker picker = ImagePicker();
    // Sur web : galerie, sur mobile : choix
    final ImageSource source = kIsWeb
        ? ImageSource.gallery
        : (await showDialog<ImageSource>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Sélectionner une photo'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Galerie'),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('Caméra'),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                ],
              ),
            ),
          )) ?? ImageSource.gallery;

    final XFile? pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (pickedFile == null) {
      debugPrint('⚠️ [DEBUG] Aucune photo sélectionnée');
      return;
    }
    if (!mounted) return;
    final bytes = await pickedFile.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Fichier trop volumineux (max 5MB)');
      }
      return;
    }
    setState(() {
      _newProfilePhoto = pickedFile;
      _newProfilePhotoBytes = bytes;
    });
    debugPrint('✅ [DEBUG] Photo sélectionnée:');
    debugPrint('   - Nom: \\${pickedFile.name}');
    debugPrint('   - Taille: \\${(bytes.length / 1024 / 1024).toStringAsFixed(2)} MB');
    debugPrint('   - Path: \\${pickedFile.path}');
    if (mounted) {
      Helpers.showSuccessSnackBar(context, 'Photo sélectionnée');
    }
  } catch (e) {
    debugPrint('❌ [DEBUG] Erreur sélection photo: $e');
    if (mounted) {
      Helpers.showErrorSnackBar(context, 'Erreur: $e');
    }
  }
}

  void _resetPhotoState() {
    setState(() {
      _newProfilePhoto = null;
      _newProfilePhotoBytes = null;
      _photoMarkedForDeletion = false;
    });
  }

  // 🔥 UNE SEULE MÉTHODE _saveChanges (DUPLICATION SUPPRIMÉE)
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      Helpers.showErrorSnackBar(context, 'Veuillez corriger les erreurs');
      return;
    }

    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Enregistrer les modifications',
      message: 'Voulez-vous vraiment modifier votre profil?',
      confirmText: 'Enregistrer',
      cancelText: 'Annuler',
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _isSubmitting = true);

    try {
      debugPrint('💾 [DEBUG] _saveChanges lancé');

      // Préparer les données de mise à jour
      final updateData = <String, dynamic>{
        'phone': _phoneController.text.trim(),
        'vehicle_type': _selectedVehicleType,
        'vehicle_plate': _vehiclePlateController.text.trim(),
        'vehicle_capacity_kg': double.parse(_vehicleCapacityController.text.trim()),
      };

      String? photoUrl;
      bool photoChanged = false;

      // 1. Suppression demandée
      if (_photoMarkedForDeletion && _initialProfilePhotoUrl != null && _initialProfilePhotoUrl!.isNotEmpty) {
        debugPrint('🗑 [DEBUG] Suppression de la photo demandée');
        final success = await ref.read(driverProvider.notifier).deleteProfilePhoto();
        if (success) {
          photoUrl = null;
          photoChanged = true;
        } else {
          Helpers.showErrorSnackBar(context, 'Erreur lors de la suppression de la photo');
          setState(() => _isSubmitting = false);
          return;
        }
      }

      // 2. Nouvelle photo sélectionnée (remplace l’ancienne ou ajout)
      if (_newProfilePhoto != null && _newProfilePhotoBytes != null) {
        try {
          debugPrint('📤 [DEBUG] Upload photo lancé');
          if (_newProfilePhoto is XFile) {
            debugPrint('📤 [DEBUG] Upload XFile - path: \\${(_newProfilePhoto as XFile).path}');
            photoUrl = await ref.read(driverProvider.notifier).uploadProfilePhoto(_newProfilePhoto);
          } else if (_newProfilePhoto is File) {
            debugPrint('📤 [DEBUG] Upload File - path: \\${(_newProfilePhoto as File).path}');
            photoUrl = await ref.read(driverProvider.notifier).uploadProfilePhoto(_newProfilePhoto);
          } else {
            throw Exception('Type de fichier non supporté: \\${_newProfilePhoto.runtimeType}');
          }
          debugPrint('✅ [DEBUG] Photo uploadée: \\${photoUrl}');
          photoChanged = true;
        } catch (e) {
          debugPrint('❌ [DEBUG] Erreur upload photo: \\${e}');
          if (mounted) {
            Helpers.showErrorSnackBar(context, 'Erreur upload photo: \\${e}');
          }
          setState(() => _isSubmitting = false);
          return;
        }
      }

      // Si la photo a changé (supprimée ou ajoutée), mettre à jour le champ profile_photo
      if (photoChanged) {
        updateData['profile_photo'] = photoUrl ?? '';
      }

      // Appel API pour mettre à jour le profil
      debugPrint('💾 [DEBUG] Mise à jour du profil');
      final success = await ref.read(driverProvider.notifier).updateProfile(updateData);

      if (!mounted) return;

      if (success) {
        debugPrint('✅ [DEBUG] Profil mis à jour - refresh du provider');
        _resetPhotoState();
        await Future.delayed(const Duration(milliseconds: 500));
        // Force refresh du provider
        await ref.refresh(driverProvider);
        // Vider le cache Flutter
        imageCache.clear();
        imageCache.clearLiveImages();
        // Évict l’ancienne image du cache réseau
        final driver = ref.read(driverProvider).driver;
        if (driver?.profilePhoto != null) {
          await CachedNetworkImageProvider(driver!.profilePhoto!).evict();
        }
        debugPrint('✅ [DEBUG] Profil mis à jour avec succès');
        Helpers.showSuccessSnackBar(context, 'Profil mis à jour avec succès!');
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        debugPrint('❌ [DEBUG] Echec de la mise à jour');
        Helpers.showErrorSnackBar(context, 'Échec de la mise à jour du profil');
      }
    } catch (e) {
      debugPrint('❌ [DEBUG] Erreur _saveChanges: $e');
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Erreur: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _selectVehicleType() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Type de véhicule'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: BackendConstants.vehicleTypeChoices.map((type) {
              final isSelected = _selectedVehicleType == type;
              return ListTile(
                leading: Icon(
                  BackendConstants.getVehicleTypeIcon(type),
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 28,
                ),
                title: Text(
                  BackendConstants.getVehicleTypeLabel(type),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : null,
                  ),
                ),
                trailing: Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                onTap: () => Navigator.of(context).pop(type),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (selected != null && selected != _selectedVehicleType) {
      if (!mounted) return;

      final confirmed = await Helpers.showConfirmDialog(
        context,
        title: 'Changer de véhicule',
        message:
            'Le changement de type de véhicule ajustera automatiquement la capacité. Continuer ?',
        confirmText: 'Confirmer',
        cancelText: 'Annuler',
      );

      if (confirmed && mounted) {
        setState(() {
          _selectedVehicleType = selected;
          _vehicleTypeController.text = selected;
          final defaultCapacity = _getDefaultCapacity(selected);
          _vehicleCapacityController.text = defaultCapacity.toString();
        });

        Helpers.showSuccessSnackBar(
          context,
          'Capacité ajustée à ${_getDefaultCapacity(selected)} kg',
        );
      }
    }
  }

  double _getDefaultCapacity(String vehicleType) {
    switch (vehicleType) {
      case 'moto':
        return 15.0;
      case 'tricycle':
        return 100.0;
      case 'voiture':
        return 200.0;
      case 'camionnette':
        return 500.0;
      default:
        return 30.0;
    }
  }

  // ========== BUILD ==========
  @override
  Widget build(BuildContext context) {
    final driverState = ref.watch(driverProvider);
    final driver = driverState.driver;

    if (driverState.isLoading && driver == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Modifier le profil')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (driver == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Modifier le profil')),
        body: const Center(child: Text('Aucune donnée de profil')),
      );
    }

    // Initialize form si pas déjà fait
    if (_phoneController.text.isEmpty) {
      _initializeForm(driver);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(Dimensions.pagePadding),
          children: [
            // Profile Photo
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: _photoMarkedForDeletion
                        ? const Icon(Icons.person, size: 60)
                        : _newProfilePhoto != null
                            ? ClipOval(
                                child: kIsWeb && _newProfilePhotoBytes != null
                                    ? Image.memory(
                                        _newProfilePhotoBytes!,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                    : (_newProfilePhoto is File)
                                        ? Image.file(
                                            _newProfilePhoto as File,
                                            width: 120,
                                            height: 120,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(Icons.person, size: 60),
                              )
                            : (_initialProfilePhotoUrl != null && _initialProfilePhotoUrl!.isNotEmpty)
                                ? ClipOval(
                                    child: CachedNetworkImageWidget(
                                      imageUrl: _initialProfilePhotoUrl!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.primary,
                                  ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _isSubmitting ? null : _pickProfilePhoto,
                      ),
                    ),
                  ),
                  if (!_photoMarkedForDeletion && _initialProfilePhotoUrl != null && _initialProfilePhotoUrl!.isNotEmpty && _newProfilePhoto == null)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 20,
                          ),
                          tooltip: 'Supprimer la photo de profil',
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    _photoMarkedForDeletion = true;
                                    _newProfilePhoto = null;
                                    _newProfilePhotoBytes = null;
                                  });
                                },
                        ),
                      ),
                    ),
                  if (_photoMarkedForDeletion)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.undo,
                            color: Colors.white,
                            size: 20,
                          ),
                          tooltip: 'Annuler la suppression',
                          onPressed: _isSubmitting
                              ? null
                              : () {
                                  setState(() {
                                    _photoMarkedForDeletion = false;
                                  });
                                },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Dimensions.spacingXL),

            // Informations personnelles
            Text('Informations personnelles', style: TextStyles.h3),
            const SizedBox(height: Dimensions.spacingM),

            CustomTextField(
              label: 'Nom complet',
              initialValue: driver.user.fullName,
              enabled: false,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: Dimensions.spacingM),

            CustomTextField(
              label: 'Email',
              initialValue: driver.user.email,
              enabled: false,
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: Dimensions.spacingM),

            CustomTextField(
              label: 'Téléphone',
              controller: _phoneController,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) => Validators.validatePhone(value ?? ''),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: Dimensions.spacingXL),

            // Informations du véhicule
            Text('Informations du véhicule', style: TextStyles.h3),
            const SizedBox(height: Dimensions.spacingM),

            CustomTextField(
              label: 'Type de véhicule',
              controller: _vehicleTypeController,
              prefixIcon: Icons.delivery_dining,
              readOnly: true,
              onTap: _isSubmitting ? null : _selectVehicleType,
              suffixIcon: Icons.arrow_drop_down,
              validator: (value) => BackendValidators.validateVehicleType(value),
            ),
            const SizedBox(height: Dimensions.spacingM),

            CustomTextField(
              label: 'Plaque d\'immatriculation',
              controller: _vehiclePlateController,
              prefixIcon: Icons.confirmation_number_outlined,
              validator: (value) =>
                  BackendValidators.validateVehicleRegistration(value),
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: Dimensions.spacingM),

            CustomTextField(
              label: 'Capacité de charge (kg)',
              controller: _vehicleCapacityController,
              prefixIcon: Icons.scale,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Capacité requise';
                }
                final capacity = double.tryParse(value.trim());
                if (capacity == null) {
                  return 'Valeur numérique requise';
                }
                return BackendValidators.validateVehicleCapacity(value);
              },
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: Dimensions.spacingXXL),

            // Buttons
            CustomButton(
              text: 'Enregistrer les modifications',
              onPressed: _isSubmitting ? null : _saveChanges,
              isLoading: _isSubmitting,
              icon: Icons.save,
            ),
            const SizedBox(height: Dimensions.spacingM),

            OutlineButton(
              text: 'Annuler',
              onPressed: _isSubmitting
                  ? null
                  : () {
                      setState(() {
                        _newProfilePhoto = null;
                        _newProfilePhotoBytes = null;
                        _photoMarkedForDeletion = false;
                        // Restaurer l’UI à la photo d’origine
                      });
                      Navigator.of(context).pop();
                    },
              icon: Icons.close,
            ),
            const SizedBox(height: Dimensions.spacingL),
          ],
        ),
      ),
    );
  }
}