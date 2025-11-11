import 'dart:io';
import 'dart:typed_data';
import '../../../../core/utils/helpers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  // ========== CONTROLLERS & STATE ==========
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _vehicleCapacityController = TextEditingController();

  dynamic _newProfilePhoto; // File (mobile) ou WebPickedFile (web)
  Uint8List? _newProfilePhotoBytes;
  bool _isSubmitting = false;
  String? _selectedVehicleType;

  // ========== LIFECYCLE ==========
  @override
  void initState() {
    super.initState();
    // Charger le profil d'abord
    Future.microtask(() async {
      if (mounted) {
        await ref.read(driverProvider.notifier).loadProfile();
        _loadCurrentData();
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _vehicleTypeController.dispose();
    _vehiclePlateController.dispose();
    _vehicleCapacityController.dispose();
    super.dispose();
  }

  // ========== PRIVATE METHODS ==========
  void _loadCurrentData() {
    final driver = ref.read(driverProvider).driver;
    if (driver != null) {
      _phoneController.text = driver.phone;
      _selectedVehicleType = driver.vehicleType;
      _vehicleTypeController.text = driver.vehicleType;
      _vehiclePlateController.text = driver.vehicleRegistration;
      _vehicleCapacityController.text = driver.vehicleCapacityKg.toString();
    }
  }

  void _resetPhotoState() {
    debugPrint('[DEBUG] Reset de l\'état local de la photo');
    setState(() {
      _newProfilePhoto = null;
      _newProfilePhotoBytes = null;
    });
  }

  Future<void> _pickProfilePhoto() async {
    try {
      debugPrint('📸 [DEBUG] _pickProfilePhoto lancé');

      final file = await Helpers.pickImageWithDialog(context);

      if (!mounted) return;

      if (file != null) {
        debugPrint('📸 [DEBUG] Fichier reçu: ${file.runtimeType}');

        if (kIsWeb && file is WebPickedFile) {
          final bytes = await file.readAsBytes();
          debugPrint('📸 [DEBUG] Web - taille: ${bytes.length} bytes');

          if (mounted) {
            setState(() {
              _newProfilePhoto = file;
              _newProfilePhotoBytes = bytes;
            });
            Helpers.showSuccessSnackBar(
              context,
              'Image sélectionnée (${bytes.length} bytes)',
            );
          }
        } else if (file is File) {
          debugPrint('📸 [DEBUG] Mobile - path: ${file.path}');

          if (mounted) {
            setState(() {
              _newProfilePhoto = file;
              _newProfilePhotoBytes = null;
            });
            Helpers.showSuccessSnackBar(context, 'Image sélectionnée');
          }
        } else {
          debugPrint('⚠️ [DEBUG] Type inconnu: ${file.runtimeType}');
          if (mounted) {
            Helpers.showErrorSnackBar(context, 'Type de fichier non supporté');
          }
        }
      } else {
        debugPrint('📸 [DEBUG] Aucune image sélectionnée');
        if (mounted) {
          Helpers.showInfoSnackBar(context, 'Sélection annulée');
        }
      }
    } catch (e) {
      debugPrint('❌ [DEBUG] Erreur _pickProfilePhoto: $e');
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Erreur sélection image: $e');
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

      // Upload de la photo de profil si changée
      if (_newProfilePhoto != null && _newProfilePhotoBytes != null) {
        try {
          debugPrint('📤 [DEBUG] Upload photo lancé');

          String photoUrl;
          if (kIsWeb && _newProfilePhoto is WebPickedFile) {
            // Web : passer les bytes et le nom du fichier
            debugPrint(
                '📤 [DEBUG] Web upload - bytes: ${_newProfilePhotoBytes!.length}');
            photoUrl = await ref.read(driverProvider.notifier).uploadProfilePhoto(
              _newProfilePhotoBytes!,
              (_newProfilePhoto as WebPickedFile).name,
            );
          } else if (_newProfilePhoto is File) {
            // Mobile : passer le File
            debugPrint(
                '📤 [DEBUG] Mobile upload - path: ${(_newProfilePhoto as File).path}');
            photoUrl = await ref.read(driverProvider.notifier).uploadProfilePhoto(
              _newProfilePhoto,
            );
          } else {
            throw Exception(
                'Type de fichier non supporté: ${_newProfilePhoto.runtimeType}');
          }

          debugPrint('✅ [DEBUG] Photo uploadée: $photoUrl');
          updateData['profile_photo'] = photoUrl;
        } catch (e) {
          debugPrint('❌ [DEBUG] Erreur upload photo: $e');
          if (mounted) {
            Helpers.showErrorSnackBar(context, 'Erreur upload photo: $e');
          }
          // Continuer sans la photo (elle peut être optionnelle)
        }
      } else {
        debugPrint('⚠️ [DEBUG] Pas de photo à uploader');
      }

      // Appel API pour mettre à jour le profil
      debugPrint('💾 [DEBUG] Mise à jour du profil');
      final success =
          await ref.read(driverProvider.notifier).updateProfile(updateData);

      if (!mounted) return;

      if (success) {
        // Reset de l'état local après succès
        _resetPhotoState();

        debugPrint('✅ [DEBUG] Profil mis à jour avec succès');
        Helpers.showSuccessSnackBar(context, 'Profil mis à jour avec succès!');

        // Attendre un peu avant de fermer pour que le snackbar soit visible
        await Future.delayed(const Duration(milliseconds: 500));

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
                    child: _newProfilePhoto != null
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
                        : driver.profilePhoto != null
                            ? ClipOval(
                                child: CachedNetworkImageWidget(
                                  imageUrl: driver.profilePhoto!,
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
                      _resetPhotoState();
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