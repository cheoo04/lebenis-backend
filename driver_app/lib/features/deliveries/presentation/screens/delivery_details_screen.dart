import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/backend_constants.dart';
import '../../../../core/providers/delivery_provider.dart';
import '../../../../data/models/delivery_model.dart';
import '../../../../data/providers/driver_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../shared/widgets/modern_button.dart';
import '../../../../shared/widgets/gps_info_card.dart';
import '../../../../shared/utils/formatters.dart';
import '../../../../shared/utils/helpers.dart';
import '../../../../core/utils/navigation_utils.dart';

class DeliveryDetailsScreen extends ConsumerStatefulWidget {
  final DeliveryModel delivery;

  const DeliveryDetailsScreen({
    super.key,
    required this.delivery,
  });

  @override
  ConsumerState<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends ConsumerState<DeliveryDetailsScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isConfirmingDelivery = false;

  Future<void> _confirmDelivery() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      Helpers.showErrorSnackBar(context, 'Le code PIN doit contenir 4 chiffres.');
      return;
    }
    setState(() => _isConfirmingDelivery = true);
      try {
        await ref.read(deliveryProvider.notifier).confirmDelivery(
          id: widget.delivery.id,
          confirmationCode: pin,
        );
        if (!mounted) return;
        Helpers.showSuccessSnackBar(context, 'Livraison confirmée avec succès!');
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        Helpers.showErrorSnackBar(context, 'Erreur: $e');
      } finally {
        if (mounted) setState(() => _isConfirmingDelivery = false);
      }
  }

  Future<void> _openNavigation() async {
    try {
      await openNavigationApp(
        latitude: widget.delivery.deliveryLatitude,
        longitude: widget.delivery.deliveryLongitude,
        label: widget.delivery.deliveryAddress,
      );
    } catch (e) {
      if (!mounted) return;
      Helpers.showErrorSnackBar(context, 'Impossible d\'ouvrir la navigation.');
    }
  }
  bool _isProcessing = false;

  Future<void> _acceptDelivery() async {
    // Récupérer le profil du driver
    final driver = ref.read(currentDriverProvider);
    
    // Vérifications préalables
    if (driver != null && !driver.isVerified) {
      Helpers.showErrorSnackBar(
        context, 
        'Votre compte n\'est pas encore vérifié. Veuillez attendre la validation de votre profil.'
      );
      return;
    }
    
    if (driver != null && !driver.isAvailable) {
      Helpers.showErrorSnackBar(
        context, 
        'Vous devez être en ligne (disponible) pour accepter une livraison. Veuillez passer en mode "Disponible" dans votre profil.'
      );
      return;
    }
    
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Accepter la livraison',
      message: 'Voulez-vous accepter cette livraison?',
      confirmText: 'Accepter',
      cancelText: 'Annuler',
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      await ref.read(deliveryProvider.notifier).acceptDelivery(
        widget.delivery.id,
        driver: driver,
      );
      
      if (!mounted) return;
      
      Helpers.showSuccessSnackBar(context, 'Livraison acceptée avec succès!');
      Navigator.of(context).pop(); // Return to list
    } catch (e) {
      if (!mounted) return;
      Helpers.showErrorSnackBar(context, 'Erreur: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _rejectDelivery() async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Refuser la livraison',
      message: 'Êtes-vous sûr de vouloir refuser cette livraison?',
      confirmText: 'Refuser',
      cancelText: 'Annuler',
      confirmColor: AppColors.error,
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      await ref.read(deliveryProvider.notifier).rejectDelivery(
        widget.delivery.id,
        'Refusé par le livreur',
      );
      
      if (!mounted) return;
      
      Helpers.showSuccessSnackBar(context, 'Livraison refusée');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      Helpers.showErrorSnackBar(context, 'Erreur: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _startDelivery() async {
    // Navigate to active delivery screen
    Navigator.of(context).pushReplacementNamed(
      '/active-delivery',
      arguments: widget.delivery,
    );
  }

  Color _getStatusColor() {
    switch (widget.delivery.status) {
      case BackendConstants.deliveryStatusPendingAssignment:
        return AppColors.warning;
      case BackendConstants.deliveryStatusAssigned:
      case BackendConstants.deliveryStatusPickupInProgress:
      case BackendConstants.deliveryStatusPickedUp:
      case BackendConstants.deliveryStatusInTransit:
        return AppColors.info;
      case BackendConstants.deliveryStatusDelivered:
        return AppColors.success;
      case BackendConstants.deliveryStatusCancelled:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel() {
    return BackendConstants.getDeliveryStatusLabel(widget.delivery.status);
  }

  @override
  Widget build(BuildContext context) {
    final delivery = widget.delivery;

    return Scaffold(
      appBar: AppBar(
        title: Text('Livraison #${delivery.trackingNumber}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              color: _getStatusColor().withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: _getStatusColor(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _getStatusLabel(),
                    style: AppTypography.h3.copyWith(
                      color: _getStatusColor(),
                    ),
                  ),
                ],
              ),
            ),

            // Map Preview (placeholder)
            Container(
              height: 200.0,
              color: Colors.grey[300],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Carte Google Maps',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Addresses Section with GPS Info
                  _SectionTitle(title: 'Itinéraire'),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Point de récupération avec GPS
                  GpsInfoCard(
                    title: 'Point de récupération',
                    address: delivery.pickupAddress,
                    latitude: delivery.pickupLatitude,
                    longitude: delivery.pickupLongitude,
                    color: AppColors.success,
                  ),
                  
                  const SizedBox(height: AppSpacing.md),
                  
                  // Point de livraison avec GPS
                  GpsInfoCard(
                    title: 'Point de livraison',
                    address: delivery.deliveryAddress,
                    latitude: delivery.deliveryLatitude,
                    longitude: delivery.deliveryLongitude,
                    distanceKm: delivery.distanceKm,
                    color: AppColors.error,
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),

                  // Delivery Details Section
                  _SectionTitle(title: 'Détails'),
                  const SizedBox(height: AppSpacing.md),

                  _DetailRow(
                    icon: Icons.qr_code,
                    label: 'Numéro de suivi',
                    value: delivery.trackingNumber,
                  ),
                  
                  _DetailRow(
                    icon: Icons.attach_money,
                    label: 'Montant',
                    value: Formatters.formatPrice(delivery.price),
                    valueStyle: AppTypography.price,
                  ),

                  _DetailRow(
                    icon: Icons.payment,
                    label: 'Mode de paiement',
                    value: delivery.paymentMethod == 'cod' 
                        ? 'Paiement à la livraison' 
                        : 'Prépayé',
                    valueStyle: TextStyle(
                      color: delivery.paymentMethod == 'cod' 
                          ? AppColors.warning 
                          : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  if (delivery.paymentMethod == 'cod' && (delivery.codAmount ?? 0) > 0)
                    _DetailRow(
                      icon: Icons.money,
                      label: 'Montant à collecter',
                      value: Formatters.formatPrice(delivery.codAmount ?? 0),
                      valueStyle: TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                  _DetailRow(
                    icon: Icons.route,
                    label: 'Distance',
                    value: Formatters.formatDistance(delivery.distanceKm),
                  ),

                  if (delivery.packageDescription.isNotEmpty)
                    _DetailRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Description',
                      value: delivery.packageDescription,
                    ),

                  if (delivery.notes != null && delivery.notes!.isNotEmpty)
                    _DetailRow(
                      icon: Icons.note_outlined,
                      label: 'Notes',
                      value: delivery.notes!,
                    ),

                  _DetailRow(
                    icon: Icons.access_time,
                    label: 'Créé le',
                    value: Formatters.formatDateTime(delivery.createdAt),
                  ),

                  if (delivery.assignedAt != null)
                    _DetailRow(
                      icon: Icons.access_time,
                      label: 'Assigné le',
                      value: Formatters.formatDateTime(delivery.assignedAt!),
                    ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Action Buttons
                  if (delivery.status == BackendConstants.deliveryStatusPendingAssignment) ...[
                    ModernButton(
                      text: 'Accepter la livraison',
                      onPressed: _isProcessing ? null : _acceptDelivery,
                      isLoading: _isProcessing,
                      icon: Icons.check_circle,
                      type: ModernButtonType.success,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ModernButton(
                      text: 'Refuser',
                      onPressed: _isProcessing ? null : _rejectDelivery,
                      icon: Icons.cancel,
                      type: ModernButtonType.outlined,
                    ),
                  ] else if (delivery.status == BackendConstants.deliveryStatusAssigned) ...[
                    ModernButton(
                      text: 'Commencer la livraison',
                      onPressed: _isProcessing ? null : _startDelivery,
                      isLoading: _isProcessing,
                      icon: Icons.play_arrow,
                    ),
                  ] else if (delivery.status == BackendConstants.deliveryStatusInTransit || delivery.status == BackendConstants.deliveryStatusPickedUp) ...[
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: const InputDecoration(
                        labelText: 'Code PIN de confirmation',
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ModernButton(
                      text: 'Confirmer la livraison',
                      onPressed: _isConfirmingDelivery ? null : _confirmDelivery,
                      isLoading: _isConfirmingDelivery,
                      icon: Icons.verified,
                      type: ModernButtonType.success,
                    ),
                  ] else if (delivery.status == BackendConstants.deliveryStatusDelivered) ...[
                    // Afficher photo et signature si disponibles
                    const SizedBox(height: AppSpacing.xl),
                    _SectionTitle(title: 'Preuves de livraison'),
                    const SizedBox(height: AppSpacing.md),
                    
                    if (delivery.photoUrl != null && delivery.photoUrl!.isNotEmpty) ...[
                      const Text('Photo de livraison', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          delivery.photoUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Icon(Icons.error, size: 50),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    
                    if (delivery.signatureUrl != null && delivery.signatureUrl!.isNotEmpty) ...[
                      const Text('Signature du destinataire', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          delivery.signatureUrl!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 150,
                              color: Colors.grey[200],
                              child: const Icon(Icons.error, size: 50),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    
                    if (delivery.deliveryNotes != null && delivery.deliveryNotes!.isNotEmpty) ...[
                      _DetailRow(
                        icon: Icons.note_outlined,
                        label: 'Notes de livraison',
                        value: delivery.deliveryNotes!,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.h3,
    );
  }
}

class _AddressCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String address;
  final String? contactName;
  final String? contactPhone;

  const _AddressCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.address,
    this.contactName,
    this.contactPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24.0),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: AppTypography.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              address,
              style: AppTypography.bodyMedium,
            ),
            if (contactName != null || contactPhone != null) ...[
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              if (contactName != null)
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 20.0,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      contactName!,
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              if (contactPhone != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 20.0,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      Formatters.formatPhoneNumber(contactPhone!),
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20.0,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: valueStyle ?? AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
