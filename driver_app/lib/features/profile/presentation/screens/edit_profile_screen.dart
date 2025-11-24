// driver_app/lib/features/profile/presentation/screens/edit_profile_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/backend_constants.dart';
import '../../../../core/services/cloudinary_direct_service.dart';
import '../../../../core/utils/backend_validators.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../data/models/driver_model.dart';
import '../../../../data/providers/driver_cni_upload_provider.dart';
import '../../../../data/providers/driver_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';
import '../../../../shared/utils/helpers.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../../../../shared/widgets/network_image_cached.dart';
import '../widgets/document_card.dart';

// ============================================================================
// SCREEN
// ============================================================================

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

// ============================================================================
// STATE
// ============================================================================

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {

      /// Suppression effective d'un document véhicule
      Future<void> _deleteVehicleDocument(String type) async {
        String title;
        String? currentUrl;
        switch (type) {
          case 'insurance':
            title = 'Assurance';
            currentUrl = _initialInsuranceUrl;
            break;
          case 'inspection':
            title = 'Visite technique';
            currentUrl = _initialInspectionUrl;
            break;
          case 'gray_card':
            title = 'Carte grise';
            currentUrl = _initialGrayCardUrl;
            break;
          case 'license':
            title = 'Permis de conduire';
            currentUrl = _initialLicenseUrl;
            break;
          default:
            return;
        }

        if (currentUrl == null || currentUrl.isEmpty) {
          Helpers.showErrorSnackBar(context, 'Aucun document à supprimer');
          return;
        }

        final confirmed = await Helpers.showConfirmDialog(
          context,
          title: 'Supprimer $title',
          message: 'Voulez-vous vraiment supprimer ce document ? Cette action est irréversible.',
          confirmText: 'Supprimer',
          cancelText: 'Annuler',
        );
        if (confirmed != true) return;

        setState(() => _isSubmitting = true);
        try {
          final success = await ref.read(driverCniUploadProvider).deleteDocument(documentType: type);
          if (success) {
            setState(() {
              switch (type) {
                case 'insurance':
                  _initialInsuranceUrl = null;
                  _newInsurancePhoto = null;
                  _newInsurancePhotoBytes = null;
                  break;
                case 'inspection':
                  _initialInspectionUrl = null;
                  _newInspectionPhoto = null;
                  _newInspectionPhotoBytes = null;
                  break;
                case 'gray_card':
                  _initialGrayCardUrl = null;
                  _newGrayCardPhoto = null;
                  _newGrayCardPhotoBytes = null;
                  break;
                case 'license':
                  _initialLicenseUrl = null;
                  _newLicensePhoto = null;
                  _newLicensePhotoBytes = null;
                  break;
              }
            });
            Helpers.showSuccessSnackBar(context, 'Document supprimé avec succès');
          } else {
            Helpers.showErrorSnackBar(context, 'Échec de la suppression du document');
          }
        } catch (e) {
          Helpers.showErrorSnackBar(context, 'Erreur: $e');
        } finally {
          if (mounted) setState(() => _isSubmitting = false);
        }
      }
    // ========== PERMIS & VIGNETTE STATE ==========
    dynamic _newLicensePhoto;
    Uint8List? _newLicensePhotoBytes;
    String? _initialLicenseUrl;

    dynamic _newVignettePhoto;
    Uint8List? _newVignettePhotoBytes;
    String? _initialVignetteUrl;
    DateTime? _vignetteExpiry;
    late TextEditingController _vignetteExpiryController;
  // ========== FORM & SUBMISSION STATE ==========
  late GlobalKey<FormState> _formKey;
  bool _isSubmitting = false;

  // ========== CONTROLLERS ==========
  late TextEditingController _phoneController;
  late TextEditingController _vehicleTypeController;
  late TextEditingController _vehiclePlateController;
  late TextEditingController _vehicleCapacityController;
  late TextEditingController _cniController;

  // ========== PROFILE PHOTO STATE ==========
  dynamic _newProfilePhoto;
  Uint8List? _newProfilePhotoBytes;
  String? _initialProfilePhotoUrl;
  bool _photoMarkedForDeletion = false;

  // ========== CNI PHOTOS STATE ==========
  dynamic _newCniFrontPhoto;
  Uint8List? _newCniFrontPhotoBytes;
  String? _initialCniFrontUrl;
  
  dynamic _newCniBackPhoto;
  Uint8List? _newCniBackPhotoBytes;
  String? _initialCniBackUrl;

  // ========== VEHICLE DOCUMENTS STATE ==========
  dynamic _newInsurancePhoto;
  Uint8List? _newInsurancePhotoBytes;
  String? _initialInsuranceUrl;
  
  dynamic _newInspectionPhoto;
  Uint8List? _newInspectionPhotoBytes;
  String? _initialInspectionUrl;
  
  dynamic _newGrayCardPhoto;
  Uint8List? _newGrayCardPhotoBytes;
  String? _initialGrayCardUrl;

  // ========== VEHICLE & OTHER FIELDS STATE ==========
  late String _selectedVehicleType;
  DateTime? _dateOfBirth;

  // ========== SERVICES ==========
  late final CloudinaryDirectService _cloudinaryDirectService;

  // ========== LIFECYCLE ==========
  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeControllers();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  // ========== INITIALIZATION METHODS ==========

  void _initializeServices() {
    _cloudinaryDirectService = CloudinaryDirectService(
      cloudName: 'dp8lng1aj', // Remplace par ton cloud name
      uploadPreset: 'TON_UPLOAD_PRESET', // Remplace par ton upload preset
    );
  }

  void _initializeControllers() {
    _formKey = GlobalKey<FormState>();
    _phoneController = TextEditingController();
    _vehicleTypeController = TextEditingController();
    _vehiclePlateController = TextEditingController();
    _vehicleCapacityController = TextEditingController();
    
    _cniController = TextEditingController();
    _vignetteExpiryController = TextEditingController();
  }

  void _disposeControllers() {
    _phoneController.dispose();
    _vehicleTypeController.dispose();
    _vehiclePlateController.dispose();
    _vehicleCapacityController.dispose();
    _cniController.dispose();
    _vignetteExpiryController.dispose();
  }

  void _initializeForm(DriverModel driver) {
    // Profile Photo
    _initialProfilePhotoUrl = driver.profilePhoto;
    _photoMarkedForDeletion = false;
    _newProfilePhoto = null;
    _newProfilePhotoBytes = null;

    // Identity Fields
    _cniController.text = driver.identityCardNumber ?? '';
    _dateOfBirth = driver.dateOfBirth;
    _initialCniFrontUrl = driver.identityCardFront;
    _initialCniBackUrl = driver.identityCardBack;
    _newCniFrontPhoto = null;
    _newCniFrontPhotoBytes = null;
    _newCniBackPhoto = null;
    _newCniBackPhotoBytes = null;

    // Vehicle Fields
    _phoneController.text = driver.phone;
    _selectedVehicleType = driver.vehicleType;
    _vehicleTypeController.text = driver.vehicleTypeLabel;
    _vehiclePlateController.text = driver.vehicleRegistration ?? '';
    _vehicleCapacityController.text = driver.vehicleCapacityKg.toString();
    // Vehicle Documents
    _initialInsuranceUrl = driver.vehicleInsurance;
    _newInsurancePhoto = null;
    _newInsurancePhotoBytes = null;
    _initialInspectionUrl = driver.vehicleTechnicalInspection;
    _newInspectionPhoto = null;
    _newInspectionPhotoBytes = null;
    _initialGrayCardUrl = driver.vehicleGrayCard;
    _newGrayCardPhoto = null;
    _newGrayCardPhotoBytes = null;

    // Permis & Vignette
    _initialLicenseUrl = driver.driversLicense;
    _newLicensePhoto = null;
    _newLicensePhotoBytes = null;
    _initialVignetteUrl = driver.vehicleVignette;
    _vignetteExpiry = driver.vehicleVignetteExpiry;
    _vignetteExpiryController.text = driver.vehicleVignetteExpiry != null
      ? driver.vehicleVignetteExpiry!.toIso8601String().split('T').first
      : '';
    _newVignettePhoto = null;
    _newVignettePhotoBytes = null;
  }

  // ========== PHOTO PICKING METHODS ==========

  Future<void> _pickProfilePhoto() async {
    await _pickPhoto(
      onPhotoPicked: (file, bytes) {
        setState(() {
          _newProfilePhoto = file;
          _newProfilePhotoBytes = bytes;
        });
      },
    );
  }

  Future<void> _pickCniPhoto(bool isFront) async {
    await _pickPhoto(
      onPhotoPicked: (file, bytes) {
        setState(() {
          if (isFront) {
            _newCniFrontPhoto = file;
            _newCniFrontPhotoBytes = bytes;
          } else {
            _newCniBackPhoto = file;
            _newCniBackPhotoBytes = bytes;
          }
        });
      },
    );
  }

  Future<void> _pickDocumentPhoto({required String type}) async {
    await _pickPhoto(
      onPhotoPicked: (file, bytes) {
        setState(() {
          if (type == 'insurance') {
            _newInsurancePhoto = file;
            _newInsurancePhotoBytes = bytes;
          } else if (type == 'inspection') {
            _newInspectionPhoto = file;
            _newInspectionPhotoBytes = bytes;
          } else if (type == 'gray_card') {
            _newGrayCardPhoto = file;
            _newGrayCardPhotoBytes = bytes;
          } else if (type == 'license') {
            _newLicensePhoto = file;
            _newLicensePhotoBytes = bytes;
          } else if (type == 'vignette') {
            _newVignettePhoto = file;
            _newVignettePhotoBytes = bytes;
          }
        });
      },
    );
  }

  /// Generic photo picker method (refactored)
  Future<void> _pickPhoto({
    required Function(dynamic file, Uint8List bytes) onPhotoPicked,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final ImageSource source = kIsWeb || !(Theme.of(context).platform == TargetPlatform.android || Theme.of(context).platform == TargetPlatform.iOS)
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
                      if (Theme.of(context).platform == TargetPlatform.android || Theme.of(context).platform == TargetPlatform.iOS)
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

      if (pickedFile == null) return;
      if (!mounted) return;

      final bytes = await pickedFile.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        if (mounted) {
          Helpers.showErrorSnackBar(context, 'Fichier trop volumineux (max 5MB)');
        }
        return;
      }

      onPhotoPicked(pickedFile, bytes);

      if (mounted) {
        Helpers.showSuccessSnackBar(context, 'Photo sélectionnée');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Erreur: $e');
      }
    }
  }

  // ========== PHOTO DISPLAY METHODS ==========

  Widget _buildPhotoWidget(dynamic file, Uint8List? bytes, dynamic url) {
    if (file != null && bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: kIsWeb
            ? Image.memory(bytes, width: 90, height: 60, fit: BoxFit.cover)
            : (file is File)
                ? Image.file(file, width: 90, height: 60, fit: BoxFit.cover)
                : (file is XFile)
                    ? Image.file(File(file.path), width: 90, height: 60, fit: BoxFit.cover)
                    : Image.memory(bytes, width: 90, height: 60, fit: BoxFit.cover),
      );
    } else if (url != null && url is String && url.isNotEmpty) {
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImageWidget(
            imageUrl: url,
            width: 90,
            height: 60,
            fit: BoxFit.cover,
          ),
        );
      } else if (url.startsWith('file://')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(Uri.parse(url).toFilePath()),
            width: 90,
            height: 60,
            fit: BoxFit.cover,
          ),
        );
      }
    }
    // Par défaut, retourne un placeholder
    return Container(
      width: 90,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, size: 32, color: Colors.grey),
    );
  }

  // ========== PROFILE PHOTO DELETION ==========

  Future<void> _deleteProfilePhoto() async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Supprimer la photo de profil',
      message:
          'Voulez-vous vraiment supprimer votre photo de profil ? Cette action est irréversible.',
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
    );
    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      final success = await ref.read(driverProvider.notifier).deleteProfilePhoto();
      if (success) {
        _resetPhotoState();
        _clearImageCache();
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

  void _resetPhotoState() {
    setState(() {
      _newProfilePhoto = null;
      _newProfilePhotoBytes = null;
      _photoMarkedForDeletion = false;
    });
  }

  void _clearImageCache() {
    imageCache.clear();
    imageCache.clearLiveImages();
    final driver = ref.read(driverProvider).driver;
    if (driver?.profilePhoto != null) {
      CachedNetworkImageProvider(driver!.profilePhoto!).evict();
    }
  }

  // ========== VEHICLE TYPE SELECTION ==========

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

  // ========== UPLOAD & SAVE METHODS ==========

  /// Upload permis de conduire
  Future<String?> _uploadDriverLicense() async {
    if (_newLicensePhoto != null && _newLicensePhotoBytes != null) {
      try {
        return await ref.read(driverCniUploadProvider).uploadCni(
          file: _newLicensePhoto,
          isFront: false,
          documentType: 'drivers_license',
        );
      } catch (e) {
        if (mounted) {
          Helpers.showErrorSnackBar(context, 'Erreur upload permis: $e');
        }
        return _initialLicenseUrl;
      }
    }
    return _initialLicenseUrl;
  }

  /// Upload vignette
  Future<String?> _uploadVignette() async {
    if (_newVignettePhoto != null && _newVignettePhotoBytes != null) {
      try {
        return await ref.read(driverCniUploadProvider).uploadCni(
          file: _newVignettePhoto,
          isFront: false,
          documentType: 'vignette',
        );
      } catch (e) {
        if (mounted) {
          Helpers.showErrorSnackBar(context, 'Erreur upload vignette: $e');
        }
        return _initialVignetteUrl;
      }
    }
    return _initialVignetteUrl;
  }

  /// Upload profile photo
  Future<String?> _uploadProfilePhoto() async {
    if (_photoMarkedForDeletion && _initialProfilePhotoUrl != null &&
        _initialProfilePhotoUrl!.isNotEmpty) {
      final success = await ref.read(driverProvider.notifier).deleteProfilePhoto();
      if (!success) {
        Helpers.showErrorSnackBar(context, 'Erreur lors de la suppression de la photo');
        return _initialProfilePhotoUrl;
      }
      return null;
    }
    if (_newProfilePhoto != null && _newProfilePhotoBytes != null) {
      try {
        if (_newProfilePhoto is XFile || _newProfilePhoto is File) {
          return await ref.read(driverProvider.notifier).uploadProfilePhoto(_newProfilePhoto);
        } else {
          throw Exception('Type de fichier non supporté: \\${_newProfilePhoto.runtimeType}');
        }
      } catch (e) {
        if (mounted) {
          Helpers.showErrorSnackBar(context, 'Erreur upload photo: $e');
        }
        return _initialProfilePhotoUrl;
      }
    }
    return _initialProfilePhotoUrl;
  }

  /// Upload CNI front
  Future<String?> _uploadCniFront() async {
    if (_newCniFrontPhoto != null && _newCniFrontPhotoBytes != null) {
      try {
        return await ref.read(driverCniUploadProvider).uploadCni(
          file: _newCniFrontPhoto,
          isFront: true,
        );
      } catch (e) {
        if (mounted) {
          Helpers.showErrorSnackBar(context, 'Erreur upload CNI recto: $e');
        }
        return _initialCniFrontUrl;
      }
    }
    return _initialCniFrontUrl;
  }

  /// Upload CNI back
  Future<String?> _uploadCniBack() async {
    if (_newCniBackPhoto != null && _newCniBackPhotoBytes != null) {
      try {
        return await ref.read(driverCniUploadProvider).uploadCni(
          file: _newCniBackPhoto,
          isFront: false,
        );
      } catch (e) {
        if (mounted) {
          Helpers.showErrorSnackBar(context, 'Erreur upload CNI verso: $e');
        }
        return _initialCniBackUrl;
      }
    }
    return _initialCniBackUrl;
  }

  /// Upload vehicle insurance
  Future<String?> _uploadVehicleInsurance() async {
    if (_newInsurancePhoto != null && _newInsurancePhotoBytes != null) {
      try {
        return await ref.read(driverCniUploadProvider).uploadCni(
          file: _newInsurancePhoto,
          isFront: false,
          documentType: 'vehicle_insurance',
        );
      } catch (e) {
        if (mounted) {
          Helpers.showErrorSnackBar(context, 'Erreur upload assurance: $e');
        }
        return _initialInsuranceUrl;
      }
    }
    return _initialInsuranceUrl;
  }

  /// Upload vehicle inspection
  Future<String?> _uploadVehicleInspection() async {
    if (_newInspectionPhoto != null && _newInspectionPhotoBytes != null) {
      try {
        return await ref.read(driverCniUploadProvider).uploadCni(
          file: _newInspectionPhoto,
          isFront: false,
          documentType: 'vehicle_technical_inspection',
        );
      } catch (e) {
        if (mounted) {
          Helpers.showErrorSnackBar(context, 'Erreur upload visite technique: $e');
        }
        return _initialInspectionUrl;
      }
    }
    return _initialInspectionUrl;
  }

  /// Upload vehicle gray card
  Future<String?> _uploadVehicleGrayCard() async {
    if (_newGrayCardPhoto != null && _newGrayCardPhotoBytes != null) {
      try {
        return await ref.read(driverCniUploadProvider).uploadCni(
          file: _newGrayCardPhoto,
          isFront: false,
          documentType: 'vehicle_gray_card',
        );
      } catch (e) {
        if (mounted) {
          Helpers.showErrorSnackBar(context, 'Erreur upload carte grise: $e');
        }
        return _initialGrayCardUrl;
      }
    }
    return _initialGrayCardUrl;
  }

  /// Main save changes method
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
      // Upload all documents in parallel
      final profilePhotoUrl = await _uploadProfilePhoto();
      final cniFrontUrl = await _uploadCniFront();
      final cniBackUrl = await _uploadCniBack();
      final insuranceUrl = await _uploadVehicleInsurance();
      final inspectionUrl = await _uploadVehicleInspection();
      final grayCardUrl = await _uploadVehicleGrayCard();
      final licenseUrl = await _uploadDriverLicense();
      final vignetteUrl = await _uploadVignette();

        if (cniFrontUrl == null || cniBackUrl == null || insuranceUrl == null ||
          inspectionUrl == null || grayCardUrl == null || licenseUrl == null || vignetteUrl == null) {
        setState(() => _isSubmitting = false);
        return;
      }

      // Prepare update data
      final updateData = <String, dynamic>{
        'phone': _phoneController.text.trim(),
        'vehicle_type': _selectedVehicleType,
        'vehicle_plate': _vehiclePlateController.text.trim(),
        'vehicle_capacity_kg': double.parse(_vehicleCapacityController.text.trim()),
        'vehicle_vignette': vignetteUrl,
        'vehicle_vignette_expiry': _vignetteExpiryController.text.isNotEmpty ? _vignetteExpiryController.text : null,
        'identity_card_number': _cniController.text.trim(),
        'date_of_birth': _dateOfBirth != null ? _dateOfBirth!.toIso8601String() : null,
        'identity_card_front': cniFrontUrl,
        'identity_card_back': cniBackUrl,
        'vehicle_insurance': insuranceUrl,
        'vehicle_technical_inspection': inspectionUrl,
        'vehicle_gray_card': grayCardUrl,
        'driver_license': licenseUrl,
        'vehicle_vignette': vignetteUrl,
        'profile_photo': profilePhotoUrl ?? '',
      };

      // Call API
      final success = await ref.read(driverProvider.notifier).updateProfile(updateData);

      if (!mounted) return;

      if (success) {
        _resetPhotoState();
        await Future.delayed(const Duration(milliseconds: 500));
        ref.refresh(driverProvider);
        _clearImageCache();
        Helpers.showSuccessSnackBar(context, 'Profil mis à jour avec succès!');
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        Helpers.showErrorSnackBar(context, 'Échec de la mise à jour du profil');
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackBar(context, 'Erreur: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // ========== BUILD METHODS ==========

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
            // === PROFILE PHOTO ===
            _buildProfilePhotoSection(),
            const SizedBox(height: Dimensions.spacingXXL),
            // === IDENTITY INFORMATION ===
            _buildIdentitySection(),
            const SizedBox(height: Dimensions.spacingXXL),
            // === VEHICLE INFORMATION ===
            _buildVehicleSection(),
            const SizedBox(height: Dimensions.spacingXXL),
            // === VEHICLE DOCUMENTS ===
            _buildVehicleDocumentsSection(),
            const SizedBox(height: Dimensions.spacingXXL),
            // === DATE EXPIRATION VIGNETTE ===
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                controller: _vignetteExpiryController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date d\'expiration de la vignette',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _vignetteExpiry ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _vignetteExpiry = picked;
                      _vignetteExpiryController.text = picked.toIso8601String().split('T').first;
                    });
                  }
                },
                validator: (value) {
                  // Optionnel : validation
                  return null;
                },
              ),
            ),
            // === BUTTONS ===
            _buildActionButtons(),
            const SizedBox(height: Dimensions.spacingM),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Center(
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
                            ? Image.memory(_newProfilePhotoBytes!,
                                width: 120, height: 120, fit: BoxFit.cover)
                            : (_newProfilePhoto is File)
                                ? Image.file(_newProfilePhoto as File,
                                    width: 120, height: 120, fit: BoxFit.cover)
                                : (_newProfilePhoto is XFile)
                                    ? Image.file(File((_newProfilePhoto as XFile).path),
                                        width: 120, height: 120, fit: BoxFit.cover)
                                    : const Icon(Icons.person, size: 60),
                      )
                    : (_initialProfilePhotoUrl != null &&
                            _initialProfilePhotoUrl!.isNotEmpty &&
                            (_initialProfilePhotoUrl!.startsWith('http://') || _initialProfilePhotoUrl!.startsWith('https://')))
                        ? ClipOval(
                            child: CachedNetworkImageWidget(
                              imageUrl: _initialProfilePhotoUrl!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (_initialProfilePhotoUrl != null &&
                            _initialProfilePhotoUrl!.isNotEmpty &&
                            _initialProfilePhotoUrl!.startsWith('file://'))
                        ? ClipOval(
                            child: Image.file(
                              File(Uri.parse(_initialProfilePhotoUrl!).toFilePath()),
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Icon(Icons.person, size: 60, color: AppColors.primary),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _isSubmitting ? null : _pickProfilePhoto,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1), // Remplacer par .withValues si besoin
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informations d\'identité', style: TextStyles.h3),
        const SizedBox(height: Dimensions.spacingM),
        CustomTextField(
          label: 'Numéro de CNI',
          controller: _cniController,
          prefixIcon: Icons.credit_card,
          enabled: !_isSubmitting,
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Numéro de CNI requis' : null,
        ),
        const SizedBox(height: Dimensions.spacingM),
        ListTile(
          leading: const Icon(Icons.cake),
          title: Text(_dateOfBirth != null
              ? DateFormat('dd/MM/yyyy').format(_dateOfBirth!)
              : 'Date de naissance'),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _isSubmitting
                ? null
                : () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dateOfBirth ?? DateTime(1990, 1, 1),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _dateOfBirth = picked);
                    }
                  },
            ),
        ),
        const SizedBox(height: Dimensions.spacingM),
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text('Photo recto CNI'),
                  const SizedBox(height: 8),
                  _buildPhotoWidget(
                      _newCniFrontPhoto, _newCniFrontPhotoBytes, _initialCniFrontUrl),
                  TextButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Uploader recto'),
                    onPressed: _isSubmitting ? null : () => _pickCniPhoto(true),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Text('Photo verso CNI'),
                  const SizedBox(height: 8),
                  _buildPhotoWidget(
                      _newCniBackPhoto, _newCniBackPhotoBytes, _initialCniBackUrl),
                  TextButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Uploader verso'),
                    onPressed: _isSubmitting ? null : () => _pickCniPhoto(false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Informations du véhicule', style: TextStyles.h3),
        const SizedBox(height: Dimensions.spacingM),
        CustomTextField(
          label: 'Téléphone',
          controller: _phoneController,
          prefixIcon: Icons.phone,
          enabled: !_isSubmitting,
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Téléphone requis' : null,
        ),
        const SizedBox(height: Dimensions.spacingM),
        GestureDetector(
          onTap: _isSubmitting ? null : _selectVehicleType,
          child: AbsorbPointer(
            child: CustomTextField(
              label: 'Type de véhicule',
              controller: _vehicleTypeController,
              prefixIcon: Icons.directions_car,
              enabled: !_isSubmitting,
              readOnly: true,
              validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Type de véhicule requis'
                      : null,
            ),
          ),
        ),
        const SizedBox(height: Dimensions.spacingM),
        CustomTextField(
          label: 'Matricule (plaque d\'immatriculation)',
          controller: _vehiclePlateController,
          prefixIcon: Icons.confirmation_number,
          enabled: !_isSubmitting,
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Matricule requis' : null,
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
      ],
    );
  }

  Widget _buildVehicleDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Documents véhicule', style: TextStyles.h3),
        const SizedBox(height: Dimensions.spacingM),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            DocumentCard(
              title: 'Assurance',
              url: _initialInsuranceUrl,
              onUpload: _isSubmitting ? (){} : () => _pickDocumentPhoto(type: 'insurance'),
              onDelete: _isSubmitting ? (){} : () => _deleteVehicleDocument('insurance'),
            ),
            DocumentCard(
              title: 'Visite technique',
              url: _initialInspectionUrl,
              onUpload: _isSubmitting ? (){} : () => _pickDocumentPhoto(type: 'inspection'),
              onDelete: _isSubmitting ? (){} : () => _deleteVehicleDocument('inspection'),
            ),
            DocumentCard(
              title: 'Carte grise',
              url: _initialGrayCardUrl,
              onUpload: _isSubmitting ? (){} : () => _pickDocumentPhoto(type: 'gray_card'),
              onDelete: _isSubmitting ? (){} : () => _deleteVehicleDocument('gray_card'),
            ),
            DocumentCard(
              title: 'Permis de conduire',
              url: _initialLicenseUrl,
              onUpload: _isSubmitting ? (){} : () => _pickDocumentPhoto(type: 'license'),
              onDelete: _isSubmitting ? (){} : () => _deleteVehicleDocument('license'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
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
                  });
                  Navigator.of(context).pop();
                },
          icon: Icons.close,
        ),
      ],
    );
  }
}
