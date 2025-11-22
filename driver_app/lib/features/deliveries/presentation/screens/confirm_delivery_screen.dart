import 'dart:io';
// import 'dart:typed_data'; // ← AJOUT pour Uint8List
import 'package:flutter/foundation.dart'; // ← AJOUT pour kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/providers/delivery_provider.dart';
import '../../../../core/utils/backend_validators.dart';
import '../../../../data/models/delivery_model.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../../../../shared/utils/helpers.dart';

class ConfirmDeliveryScreen extends ConsumerStatefulWidget {
  final DeliveryModel delivery;

  const ConfirmDeliveryScreen({
    super.key,
    required this.delivery,
  });

  @override
  ConsumerState<ConfirmDeliveryScreen> createState() => _ConfirmDeliveryScreenState();
}

class _ConfirmDeliveryScreenState extends ConsumerState<ConfirmDeliveryScreen> {
  final TextEditingController _pinController = TextEditingController();
  final _notesController = TextEditingController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  
  // ← MODIFICATION: Support web et mobile
  File? _photoFile;
  Uint8List? _photoBytes; // Pour le web
  
  File? _signatureFile;
  Uint8List? _signatureBytes; // Pour le web
  
  bool _isProcessing = false;

  @override
  void dispose() {
    _notesController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _showPhotoOptions() async {
    final file = await Helpers.pickImageWithDialog(context);
    if (file != null) {
      // ← MODIFICATION: Lire les bytes pour le web
      if (kIsWeb) {
        final bytes = await file.readAsBytes();
        setState(() {
          _photoBytes = bytes;
          _photoFile = file; // Garde la référence pour le path
        });
      } else {
        setState(() {
          _photoFile = file;
        });
      }
    }
  }

  Future<void> _captureSignature() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _SignatureDialog(controller: _signatureController),
    );

    if (!mounted) return;

    if (result == true && _signatureController.isNotEmpty) {
      final signature = await _signatureController.toPngBytes();
      if (signature != null) {
        // ← MODIFICATION: Support web et mobile
        if (kIsWeb) {
          setState(() {
            _signatureBytes = signature;
          });
        } else {
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png');
          await file.writeAsBytes(signature);
          setState(() {
            _signatureFile = file;
            _signatureBytes = signature; // Garde les bytes aussi
          });
        }
        Helpers.showSuccessSnackBar(context, 'Signature capturée avec succès');
      }
    }
  }

  Future<void> _confirmDelivery() async {
    // Validate requirements
    if (_photoFile == null && _photoBytes == null) {
      Helpers.showErrorSnackBar(context, 'Veuillez prendre une photo de la livraison');
      return;
    }

    if (_signatureFile == null && _signatureBytes == null) {
      Helpers.showErrorSnackBar(context, 'Veuillez capturer la signature du destinataire');
      return;
    }

    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Confirmer la livraison',
      message: 'Êtes-vous sûr que la livraison a été effectuée avec succès?',
      confirmText: 'Confirmer',
      cancelText: 'Vérifier',
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      setState(() => _isProcessing = false);
      Future.microtask(() {
        if (mounted) {
          Helpers.showErrorSnackBar(context, 'Le code PIN doit contenir 4 chiffres.');
        }
      });
      return;
    }
    
    try {
      await ref.read(deliveryProvider.notifier).confirmDelivery(
        id: widget.delivery.id,
        confirmationCode: pin,
        deliveryPhoto: _photoFile?.path,
        deliveryPhotoBytes: _photoBytes,
        recipientSignature: _signatureFile?.path,
        recipientSignatureBytes: _signatureBytes,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      if (!mounted) return;

      Helpers.showSuccessSnackBar(context, 'Livraison confirmée avec succès!');
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      Helpers.showErrorSnackBar(context, 'Erreur: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmer la livraison'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Delivery Info Header
            Card(
              color: AppColors.success.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.cardPadding),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: Dimensions.spacingM),
                    Text(
                      'Livraison effectuée!',
                      style: TextStyles.h2.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: Dimensions.spacingS),
                    Text(
                      'Livraison #${widget.delivery.trackingNumber}',
                      style: TextStyles.trackingNumber,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: Dimensions.spacingXL),

            // Instructions
            Text(
              'Informations requises',
              style: TextStyles.h3,
            ),
            const SizedBox(height: Dimensions.spacingS),
            Text(
              'Pour finaliser la livraison, veuillez fournir:',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: Dimensions.spacingL),

            // Champ de saisie du code PIN (4 chiffres)
            Padding(
              padding: const EdgeInsets.only(bottom: Dimensions.spacingL),
              child: TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(
                  labelText: 'Code PIN de confirmation',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                enabled: !_isProcessing,
              ),
            ),
            // Photo Section ← MODIFICATION ICI
            _RequirementCard(
              icon: Icons.photo_camera,
              title: 'Photo de la livraison',
              subtitle: 'Prenez une photo du colis livré',
              isCompleted: _photoFile != null || _photoBytes != null,
              child: Column(
                children: [
                  if (_photoFile != null || _photoBytes != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusM),
                      child: kIsWeb && _photoBytes != null
                          ? Image.memory(
                              _photoBytes!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              _photoFile!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(height: Dimensions.spacingM),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlineButton(
                          text: _photoFile == null && _photoBytes == null ? 'Prendre une photo' : 'Changer',
                          onPressed: _isProcessing ? null : _showPhotoOptions,
                          icon: Icons.camera_alt,
                        ),
                      ),
                      if (_photoFile != null || _photoBytes != null) ...[
                        const SizedBox(width: Dimensions.spacingS),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: _isProcessing
                              ? null
                              : () {
                                  setState(() {
                                    _photoFile = null;
                                    _photoBytes = null;
                                  });
                                },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: Dimensions.spacingL),

            // Signature Section ← MODIFICATION ICI
            _RequirementCard(
              icon: Icons.draw,
              title: 'Signature du destinataire',
              subtitle: 'Faites signer le destinataire',
              isCompleted: _signatureFile != null || _signatureBytes != null,
              child: Column(
                children: [
                  if (_signatureFile != null || _signatureBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.radiusM),
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.success, width: 2),
                          borderRadius: BorderRadius.circular(Dimensions.radiusM),
                        ),
                        child: kIsWeb && _signatureBytes != null
                            ? Image.memory(
                                _signatureBytes!,
                                fit: BoxFit.contain,
                              )
                            : Image.file(
                                _signatureFile!,
                                fit: BoxFit.contain,
                              ),
                      ),
                    )
                  else
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(Dimensions.radiusM),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.gesture,
                              color: AppColors.textSecondary,
                              size: 48,
                            ),
                            SizedBox(height: Dimensions.spacingS),
                            Text(
                              'Zone de signature',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: Dimensions.spacingM),
                  Row(
                    children: [
                      Expanded(
                        child: OutlineButton(
                          text: (_signatureFile != null || _signatureBytes != null) ? 'Capturer à nouveau' : 'Capturer signature',
                          onPressed: _isProcessing ? null : _captureSignature,
                          icon: Icons.edit,
                        ),
                      ),
                      if (_signatureFile != null || _signatureBytes != null) ...[
                        const SizedBox(width: Dimensions.spacingS),
                        IconButton(
                          icon: const Icon(Icons.delete, color: AppColors.error),
                          onPressed: _isProcessing
                              ? null
                              : () {
                                  setState(() {
                                    _signatureFile = null;
                                    _signatureBytes = null;
                                  });
                                },
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: Dimensions.spacingL),

            // Notes Section
            _RequirementCard(
              icon: Icons.note_outlined,
              title: 'Notes (optionnel)',
              subtitle: 'Ajoutez des notes sur la livraison',
              isCompleted: false,
              isOptional: true,
              child: TextArea(
                controller: _notesController,
                hint: 'Ex: Colis remis au gardien, sonnette défectueuse, etc.',
                maxLines: 3,
                maxLength: 1000,
                enabled: !_isProcessing,
                validator: (value) => BackendValidators.validateDeliveryNotes(value),
              ),
            ),

            const SizedBox(height: Dimensions.spacingXXL),

            // Confirm Button
            CustomButton(
              text: 'Confirmer la livraison',
              onPressed: _isProcessing ? null : _confirmDelivery,
              isLoading: _isProcessing,
              icon: Icons.check_circle,
              type: ButtonType.success,
            ),

            const SizedBox(height: Dimensions.spacingM),

            OutlineButton(
              text: 'Annuler',
              onPressed: _isProcessing
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

// Les autres classes (_RequirementCard et _SignatureDialog) restent identiques

class _RequirementCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isOptional;
  final Widget child;

  const _RequirementCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    this.isOptional = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : icon,
                    color: isCompleted ? AppColors.success : AppColors.primary,
                    size: Dimensions.iconM,
                  ),
                ),
                const SizedBox(width: Dimensions.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: TextStyles.labelLarge,
                          ),
                          if (isOptional) ...[
                            const SizedBox(width: Dimensions.spacingXS),
                            Text(
                              '(optionnel)',
                              style: TextStyles.caption,
                            ),
                          ],
                        ],
                      ),
                      Text(
                        subtitle,
                        style: TextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.spacingM),
            child,
          ],
        ),
      ),
    );
  }
}

// Dialog widget pour la capture de signature
class _SignatureDialog extends StatelessWidget {
  final SignatureController controller;

  const _SignatureDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.dialogPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Signature du destinataire',
                  style: TextStyles.h3,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.spacingM),

            // Instructions
            Text(
              'Demandez au destinataire de signer ci-dessous',
              style: TextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Dimensions.spacingL),

            // Signature Canvas
            Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 2),
                borderRadius: BorderRadius.circular(Dimensions.radiusM),
                color: Colors.white,
              ),
              child: Signature(
                controller: controller,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: Dimensions.spacingM),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlineButton(
                    text: 'Effacer',
                    onPressed: () {
                      controller.clear();
                    },
                    icon: Icons.clear,
                  ),
                ),
                const SizedBox(width: Dimensions.spacingM),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: 'Valider',
                    onPressed: () {
                      if (controller.isEmpty) {
                        Helpers.showErrorSnackBar(
                          context,
                          'Veuillez d\'abord signer',
                        );
                        return;
                      }
                      Navigator.of(context).pop(true);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
