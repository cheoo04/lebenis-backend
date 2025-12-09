// driver_app/lib/features/profile/presentation/screens/edit_profile_screen.dart
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/backend_constants.dart';
import '../../../../core/services/cloudinary_direct_service.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../data/models/driver_model.dart';
import '../../../../data/providers/driver_provider.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../shared/utils/helpers.dart';
import '../widgets/identity_section.dart';
import '../widgets/vehicle_section.dart';
import '../widgets/vehicle_documents_section.dart';
import '../widgets/profile_photo_section.dart';
import '../widgets/action_buttons_section.dart';
import '../widgets/bank_section.dart';
import '../widgets/mobile_money_section.dart';
import '../widgets/emergency_contact_section.dart';
import '../widgets/experience_section.dart';
import '../../services/photo_mixin.dart';
import '../../services/profile_service.dart';

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

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> with PhotoMixin<EditProfileScreen> {

  /// Suppression effective d'un document véhicule (via service)
  Future<void> _deleteVehicleDocument(String type) async {
    setState(() => _isSubmitting = true);
    final result = await ProfileService.deleteVehicleDocument(
      context: context,
      ref: ref,
      type: type,
      onStateUpdate: (String? url, dynamic photo, Uint8List? bytes) {
        setState(() {
          switch (type) {
            case 'insurance':
              _initialInsuranceUrl = url;
              _newInsurancePhoto = photo;
              _newInsurancePhotoBytes = bytes;
              break;
            case 'inspection':
              _initialInspectionUrl = url;
              _newInspectionPhoto = photo;
              _newInspectionPhotoBytes = bytes;
              break;
            case 'gray_card':
              _initialGrayCardUrl = url;
              _newGrayCardPhoto = photo;
              _newGrayCardPhotoBytes = bytes;
              break;
            case 'license':
              _initialLicenseUrl = url;
              _newLicensePhoto = photo;
              _newLicensePhotoBytes = bytes;
              break;
          }
        });
      },
    );
    if (mounted) setState(() => _isSubmitting = false);
    return result;
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
  late TextEditingController _bankAccountNameController;
  late TextEditingController _bankAccountNumberController;
  late TextEditingController _bankNameController;
  late TextEditingController _mobileMoneyNumberController;
  late TextEditingController _emergencyContactNameController;
  late TextEditingController _emergencyContactPhoneController;
  late TextEditingController _emergencyContactRelationshipController;
  late TextEditingController _yearsOfExperienceController;
  late TextEditingController _previousEmployerController;
  
  
  // ========= MOBILE MONEY STATE ==========
  String? _selectedMobileMoneyProvider;

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

  // ========== LANGUAGES STATE ==========
  List<String> _selectedLanguages = [];
  static const List<String> _allLanguages = [
    'Français',
    'Anglais',
    'Bété',
    'Baoulé',
    'Dioula',
    'Malinké',
    'Autre',
  ];

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
    _bankAccountNameController = TextEditingController();
    _bankAccountNumberController = TextEditingController();
    _bankNameController = TextEditingController();
    _mobileMoneyNumberController = TextEditingController();
    _emergencyContactNameController = TextEditingController();
    _emergencyContactPhoneController = TextEditingController();
    _emergencyContactRelationshipController = TextEditingController();
    _yearsOfExperienceController = TextEditingController();
    _previousEmployerController = TextEditingController();
  }

  void _disposeControllers() {
    _phoneController.dispose();
    _vehicleTypeController.dispose();
    _vehiclePlateController.dispose();
    _vehicleCapacityController.dispose();
    _cniController.dispose();
    _vignetteExpiryController.dispose();
    _bankAccountNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankNameController.dispose();
    _mobileMoneyNumberController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _emergencyContactRelationshipController.dispose();
    _yearsOfExperienceController.dispose();
    _previousEmployerController.dispose();
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

    // Languages
    _selectedLanguages = List<String>.from(driver.languagesSpoken ?? []);

    // Bank
    _bankAccountNameController.text = driver.bankAccountName ?? '';
    _bankAccountNumberController.text = driver.bankAccountNumber ?? '';
    _bankNameController.text = driver.bankName ?? '';
    // Mobile Money
    _mobileMoneyNumberController.text = driver.mobileMoneyNumber ?? '';
    // Correction : n'accepte que les valeurs valides ou null
    const validProviders = ['orange', 'mtn', 'wave'];
    if (driver.mobileMoneyProvider != null && validProviders.contains(driver.mobileMoneyProvider)) {
      _selectedMobileMoneyProvider = driver.mobileMoneyProvider;
    } else {
      _selectedMobileMoneyProvider = null;
    }
    // Emergency Contact
    _emergencyContactNameController.text = driver.emergencyContactName ?? '';
    _emergencyContactPhoneController.text = driver.emergencyContactPhone ?? '';
    _emergencyContactRelationshipController.text = driver.emergencyContactRelationship ?? '';
    // Experience
    _yearsOfExperienceController.text = driver.yearsOfExperience?.toString() ?? '';
    _previousEmployerController.text = driver.previousEmployer ?? '';
  }

  // ========== PHOTO PICKING METHODS ==========


  Future<void> _pickProfilePhoto() async {
    await pickPhoto(
      context: context,
      onPhotoPicked: (file, bytes) {
        setState(() {
          _newProfilePhoto = file;
          _newProfilePhotoBytes = bytes;
        });
      },
    );
  }

  Future<void> _pickCniPhoto(bool isFront) async {
    await pickPhoto(
      context: context,
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
    await pickPhoto(
      context: context,
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
    return buildPhotoWidget(file, bytes, url);
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
        if (!mounted) return;
        Helpers.showSuccessSnackBar(context, 'Photo de profil supprimée avec succès');
      } else {
        if (!mounted) return;
        Helpers.showErrorSnackBar(context, 'Échec de la suppression de la photo');
      }
    } catch (e) {
      if (!mounted) return;
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


  // Nouvelle méthode centralisée pour upload
  Future<Map<String, String?>> _uploadAllDocuments() async {
    final Map<String, String?> uploads = {};
    final List<String> failed = [];
    // Helper to upload and check
    Future<void> uploadDoc(String key, Future<String?> future, String label) async {
      final url = await future;
      uploads[key] = url;
      if (url == null) failed.add(label);
    }

    // Vérification préalable : n'uploader la photo de profil que si elle a été modifiée ou marquée pour suppression
    if (_newProfilePhoto != null || _photoMarkedForDeletion) {
      await uploadDoc('profile_photo', ProfileService.uploadProfilePhoto(
        ref: ref,
        file: _newProfilePhoto,
        bytes: _newProfilePhotoBytes,
        fallbackUrl: _initialProfilePhotoUrl,
        context: context,
        delete: _photoMarkedForDeletion,
        initialUrl: _initialProfilePhotoUrl,
      ), 'Photo de profil');
    } else {
      uploads['profile_photo'] = _initialProfilePhotoUrl;
    }
    // CNI recto
    if (_newCniFrontPhoto != null) {
      await uploadDoc('identity_card_front', ProfileService.uploadDocument(
        ref: ref,
        file: _newCniFrontPhoto,
        bytes: _newCniFrontPhotoBytes,
        documentType: 'identity_card_front',
        isFront: true,
        fallbackUrl: _initialCniFrontUrl,
        context: context,
      ), 'CNI (recto)');
    } else {
      uploads['identity_card_front'] = _initialCniFrontUrl;
    }

    // CNI verso
    if (_newCniBackPhoto != null) {
      await uploadDoc('identity_card_back', ProfileService.uploadDocument(
        ref: ref,
        file: _newCniBackPhoto,
        bytes: _newCniBackPhotoBytes,
        documentType: 'identity_card_back',
        isFront: false,
        fallbackUrl: _initialCniBackUrl,
        context: context,
      ), 'CNI (verso)');
    } else {
      uploads['identity_card_back'] = _initialCniBackUrl;
    }

    // Assurance
    if (_newInsurancePhoto != null) {
      await uploadDoc('vehicle_insurance', ProfileService.uploadDocument(
        ref: ref,
        file: _newInsurancePhoto,
        bytes: _newInsurancePhotoBytes,
        documentType: 'vehicle_insurance',
        fallbackUrl: _initialInsuranceUrl,
        context: context,
      ), 'Assurance');
    } else {
      uploads['vehicle_insurance'] = _initialInsuranceUrl;
    }

    // Visite technique
    if (_newInspectionPhoto != null) {
      await uploadDoc('vehicle_technical_inspection', ProfileService.uploadDocument(
        ref: ref,
        file: _newInspectionPhoto,
        bytes: _newInspectionPhotoBytes,
        documentType: 'vehicle_technical_inspection',
        fallbackUrl: _initialInspectionUrl,
        context: context,
      ), 'Visite technique');
    } else {
      uploads['vehicle_technical_inspection'] = _initialInspectionUrl;
    }

    // Carte grise
    if (_newGrayCardPhoto != null) {
      await uploadDoc('vehicle_gray_card', ProfileService.uploadDocument(
        ref: ref,
        file: _newGrayCardPhoto,
        bytes: _newGrayCardPhotoBytes,
        documentType: 'vehicle_gray_card',
        fallbackUrl: _initialGrayCardUrl,
        context: context,
      ), 'Carte grise');
    } else {
      uploads['vehicle_gray_card'] = _initialGrayCardUrl;
    }

    // Permis de conduire
    if (_newLicensePhoto != null) {
      await uploadDoc('drivers_license', ProfileService.uploadDocument(
        ref: ref,
        file: _newLicensePhoto,
        bytes: _newLicensePhotoBytes,
        documentType: 'drivers_license',
        fallbackUrl: _initialLicenseUrl,
        context: context,
      ), 'Permis de conduire');
    } else {
      uploads['drivers_license'] = _initialLicenseUrl;
    }

    // Vignette
    if (_newVignettePhoto != null) {
      await uploadDoc('vignette', ProfileService.uploadDocument(
        ref: ref,
        file: _newVignettePhoto,
        bytes: _newVignettePhotoBytes,
        documentType: 'vignette',
        fallbackUrl: _initialVignetteUrl,
        context: context,
      ), 'Vignette');
    } else {
      uploads['vignette'] = _initialVignetteUrl;
    }
    if (failed.isNotEmpty) {
      Helpers.showErrorSnackBar(context, 'Échec de l\'upload pour :\n${failed.join(', ')}');
    }
    return uploads;
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
      // Upload all documents
      final uploads = await _uploadAllDocuments();
      final failedDocs = uploads.entries.where((e) => e.value == null).map((e) => e.key).toList();
      if (failedDocs.isNotEmpty) {
        setState(() => _isSubmitting = false);
        return;
      }

      // Prepare update data
      // Nettoyage/formatage des champs
      String cleanPlate(String plate) {
        // Garde lettres/chiffres/espaces, majuscules
        return plate.replaceAll(RegExp(r'[^A-Za-z0-9 ]'), '').toUpperCase();
      }
      String? formatDate(DateTime? d) => d?.toIso8601String().split('T').first;
      String? truncate(String? s, int max) => (s != null && s.length > max) ? s.substring(0, max) : s;

      final updateData = <String, dynamic>{
        'phone': _phoneController.text.trim(),
        'vehicle_type': _selectedVehicleType,
        'vehicle_plate': cleanPlate(_vehiclePlateController.text.trim()),
        'vehicle_capacity_kg': double.parse(_vehicleCapacityController.text.trim()),
        'identity_card_number': _cniController.text.trim(),
        'date_of_birth': formatDate(_dateOfBirth),
        'languages_spoken': _selectedLanguages,
        'bank_account_name': _bankAccountNameController.text.trim(),
        'bank_account_number': _bankAccountNumberController.text.trim(),
        'bank_name': _bankNameController.text.trim(),
        'mobile_money_number': _mobileMoneyNumberController.text.trim(),
        'mobile_money_provider': _selectedMobileMoneyProvider,
        'emergency_contact_name': _emergencyContactNameController.text.trim(),
        'emergency_contact_phone': _emergencyContactPhoneController.text.trim(),
        'emergency_contact_relationship': _emergencyContactRelationshipController.text.trim(),
        'years_of_experience': int.tryParse(_yearsOfExperienceController.text.trim() == '' ? '0' : _yearsOfExperienceController.text.trim()),
        'previous_employer': _previousEmployerController.text.trim(),
      };

      // Ajout conditionnel des documents
      if (uploads['vignette'] != null && uploads['vignette'] != '') {
        updateData['vehicle_vignette'] = uploads['vignette'];
      }
      if (_vignetteExpiryController.text.isNotEmpty) {
        updateData['vehicle_vignette_expiry'] = _vignetteExpiryController.text;
      }
      if (uploads['identity_card_front'] != null && uploads['identity_card_front'] != '') {
        updateData['identity_card_front'] = uploads['identity_card_front'];
      }
      if (uploads['identity_card_back'] != null && uploads['identity_card_back'] != '') {
        updateData['identity_card_back'] = uploads['identity_card_back'];
      }
      if (uploads['vehicle_insurance'] != null && uploads['vehicle_insurance'] != '') {
        updateData['vehicle_insurance'] = uploads['vehicle_insurance'];
      }
      if (uploads['vehicle_technical_inspection'] != null && uploads['vehicle_technical_inspection'] != '') {
        updateData['vehicle_technical_inspection'] = uploads['vehicle_technical_inspection'];
      }
      if (uploads['vehicle_gray_card'] != null && uploads['vehicle_gray_card'] != '') {
        updateData['vehicle_gray_card'] = uploads['vehicle_gray_card'];
      }
      if (uploads['drivers_license'] != null && uploads['drivers_license'] != '' &&
          (uploads['drivers_license']!.startsWith('http://') || uploads['drivers_license']!.startsWith('https://'))) {
        updateData['driver_license'] = uploads['drivers_license'];
      }
      if (uploads['profile_photo'] != null && uploads['profile_photo'] != '') {
        updateData['profile_photo'] = uploads['profile_photo'];
      }

      // Call API
      final success = await ref.read(driverProvider.notifier).updateProfile(updateData);

      if (!mounted) return;

      if (success) {
        _resetPhotoState();
        await Future.delayed(const Duration(milliseconds: 500));
        ref.refresh(driverProvider);
        _clearImageCache();
        if (!mounted) return;
        Helpers.showSuccessSnackBar(context, 'Profil mis à jour avec succès!');
        Navigator.of(context).pop(true);
      } else {
        // Afficher l'erreur détaillée si présente dans le provider
        final error = ref.read(driverProvider).error;
        if (error != null && error.isNotEmpty) {
          Helpers.showErrorSnackBar(context, 'Erreur backend :\n$error');
        } else {
          Helpers.showErrorSnackBar(context, 'Échec de la mise à jour du profil');
        }
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
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // === PROFILE PHOTO ===
            ProfilePhotoSection(
              newProfilePhoto: _newProfilePhoto,
              newProfilePhotoBytes: _newProfilePhotoBytes,
              initialProfilePhotoUrl: _initialProfilePhotoUrl,
              photoMarkedForDeletion: _photoMarkedForDeletion,
              isSubmitting: _isSubmitting,
              onPickProfilePhoto: _pickProfilePhoto,
            ),
            const SizedBox(height: AppSpacing.xxl),
            // === IDENTITY INFORMATION ===
            IdentitySection(
              cniController: _cniController,
              dateOfBirth: _dateOfBirth,
              isSubmitting: _isSubmitting,
              onDateChanged: (date) => setState(() => _dateOfBirth = date),
              allLanguages: _allLanguages,
              selectedLanguages: _selectedLanguages,
              onLanguagesChanged: (langs) => setState(() => _selectedLanguages = langs),
              cniFrontWidget: _buildPhotoWidget(_newCniFrontPhoto, _newCniFrontPhotoBytes, _initialCniFrontUrl),
              cniBackWidget: _buildPhotoWidget(_newCniBackPhoto, _newCniBackPhotoBytes, _initialCniBackUrl),
              onPickCniFront: () => _pickCniPhoto(true),
              onPickCniBack: () => _pickCniPhoto(false),
            ),
            const SizedBox(height: AppSpacing.xxl),
            // === VEHICLE INFORMATION ===
            VehicleSection(
              phoneController: _phoneController,
              vehicleTypeController: _vehicleTypeController,
              vehiclePlateController: _vehiclePlateController,
              vehicleCapacityController: _vehicleCapacityController,
              isSubmitting: _isSubmitting,
              onSelectVehicleType: _selectVehicleType,
            ),
            const SizedBox(height: AppSpacing.xxl),
            // === VEHICLE DOCUMENTS ===
            VehicleDocumentsSection(
              initialInsuranceUrl: _initialInsuranceUrl,
              insuranceBytes: _newInsurancePhotoBytes,
              initialInspectionUrl: _initialInspectionUrl,
              inspectionBytes: _newInspectionPhotoBytes,
              initialGrayCardUrl: _initialGrayCardUrl,
              grayCardBytes: _newGrayCardPhotoBytes,
              initialLicenseUrl: _initialLicenseUrl,
              licenseBytes: _newLicensePhotoBytes,
              initialVignetteUrl: _initialVignetteUrl,
              vignetteBytes: _newVignettePhotoBytes,
              isSubmitting: _isSubmitting,
              onPickInsurance: () => _pickDocumentPhoto(type: 'insurance'),
              onPickInspection: () => _pickDocumentPhoto(type: 'inspection'),
              onPickGrayCard: () => _pickDocumentPhoto(type: 'gray_card'),
              onPickLicense: () => _pickDocumentPhoto(type: 'license'),
              onPickVignette: () => _pickDocumentPhoto(type: 'vignette'),
            ),
            const SizedBox(height: AppSpacing.xxl),
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
            const SizedBox(height: AppSpacing.xxl),
            // === BANK SECTION ===
            BankSection(
              bankAccountNameController: _bankAccountNameController,
              bankAccountNumberController: _bankAccountNumberController,
              bankNameController: _bankNameController,
              isSubmitting: _isSubmitting,
            ),
            const SizedBox(height: AppSpacing.xxl),
            // === MOBILE MONEY SECTION ===
            MobileMoneySection(
              mobileMoneyNumberController: _mobileMoneyNumberController,
              selectedProvider: _selectedMobileMoneyProvider,
              onProviderChanged: (val) => setState(() => _selectedMobileMoneyProvider = val),
              isSubmitting: _isSubmitting,
            ),
            const SizedBox(height: AppSpacing.xxl),
            // === EMERGENCY CONTACT SECTION ===
            EmergencyContactSection(
              contactNameController: _emergencyContactNameController,
              contactPhoneController: _emergencyContactPhoneController,
              contactRelationshipController: _emergencyContactRelationshipController,
              isSubmitting: _isSubmitting,
            ),
            const SizedBox(height: AppSpacing.xxl),
            // === EXPERIENCE SECTION ===
            ExperienceSection(
              yearsOfExperienceController: _yearsOfExperienceController,
              previousEmployerController: _previousEmployerController,
              isSubmitting: _isSubmitting,
            ),
            const SizedBox(height: AppSpacing.xxl),
            // === BUTTONS ===
            ActionButtonsSection(
              isSubmitting: _isSubmitting,
              onSave: _saveChanges,
              onCancel: () {
                setState(() {
                  _newProfilePhoto = null;
                  _newProfilePhotoBytes = null;
                  _photoMarkedForDeletion = false;
                });
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }


}
