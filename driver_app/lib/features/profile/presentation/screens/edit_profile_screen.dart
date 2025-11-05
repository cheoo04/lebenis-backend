import 'dart:io';
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
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  
  File? _newProfilePhoto;
  bool _isSubmitting = false;
  String? _selectedVehicleType;

  @override
  void initState() {
    super.initState();
    // Charger le profil d'abord
    Future.microtask(() async {
      await ref.read(driverProvider.notifier).loadProfile();
      _loadCurrentData();
    });
  }

  void _loadCurrentData() {
    final driver = ref.read(driverProvider).driver;
    if (driver != null) {
      _phoneController.text = driver.phone;
      _selectedVehicleType = driver.vehicleType;
      _vehicleTypeController.text = driver.vehicleType;
      _vehiclePlateController.text = driver.vehicleRegistration;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _vehicleTypeController.dispose();
    _vehiclePlateController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePhoto() async {
    final file = await Helpers.pickImageWithDialog(context);
    
    if (file != null) {
      setState(() {
        _newProfilePhoto = file;
      });
    }
  }

  Future<void> _selectVehicleType() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Type de véhicule'),
        content: Column(
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
                isSelected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              onTap: () {
                Navigator.of(context).pop(type);
              },
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedVehicleType = selected;
        _vehicleTypeController.text = selected;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Enregistrer les modifications',
      message: 'Voulez-vous vraiment modifier votre profil?',
      confirmText: 'Enregistrer',
      cancelText: 'Annuler',
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);

    try {
      // Préparer les données de mise à jour
      final updateData = <String, dynamic>{
        'phone': _phoneController.text.trim(),
        'vehicle_type': _selectedVehicleType,
        'vehicle_plate': _vehiclePlateController.text.trim(),
      };

      // Upload de la photo de profil si changée
      if (_newProfilePhoto != null) {
        try {
          final photoUrl = await ref.read(driverProvider.notifier).uploadProfilePhoto(_newProfilePhoto!);
          updateData['profile_photo'] = photoUrl;
        } catch (e) {
          if (mounted) {
            Helpers.showErrorSnackBar(context, 'Erreur upload photo: $e');
          }
          // Continue même si l'upload échoue
        }
      }

      // Appel API pour mettre à jour le profil
      await ref.read(driverProvider.notifier).updateProfile(updateData);

      if (!mounted) return;
      Helpers.showSuccessSnackBar(context, 'Profil mis à jour avec succès!');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      Helpers.showErrorSnackBar(context, 'Erreur: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverState = ref.watch(driverProvider);
    final driver = driverState.driver;

    if (driverState.isLoading && driver == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Modifier le profil'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (driver == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Modifier le profil'),
        ),
        body: const Center(
          child: Text('Aucune donnée de profil'),
        ),
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
                            child: Image.file(
                              _newProfilePhoto!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
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
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
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

            // Name (read-only)
            Text(
              'Informations personnelles',
              style: TextStyles.h3,
            ),
            const SizedBox(height: Dimensions.spacingM),

            CustomTextField(
              label: 'Nom complet',
              initialValue: driver.user.fullName,
              enabled: false,
              prefixIcon: Icons.person_outline,
            ),

            const SizedBox(height: Dimensions.spacingM),

            // Email (read-only)
            CustomTextField(
              label: 'Email',
              initialValue: driver.user.email,
              enabled: false,
              prefixIcon: Icons.email_outlined,
            ),

            const SizedBox(height: Dimensions.spacingM),

            // Phone (editable)
            CustomTextField(
              label: 'Téléphone',
              controller: _phoneController,
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) => Validators.validatePhone(value ?? ''),
              enabled: !_isSubmitting,
            ),

            const SizedBox(height: Dimensions.spacingXL),

            // Vehicle Information
            Text(
              'Informations du véhicule',
              style: TextStyles.h3,
            ),
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
              validator: (value) => BackendValidators.validateVehicleRegistration(value),
              enabled: !_isSubmitting,
            ),

            const SizedBox(height: Dimensions.spacingXXL),

            // Save Button
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
