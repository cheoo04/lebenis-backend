import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/backend_constants.dart';
import '../../../../core/providers/delivery_provider.dart';
import '../../../../data/models/delivery_model.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
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
      await ref.read(deliveryProvider.notifier).acceptDelivery(widget.delivery.id);
      
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
              padding: const EdgeInsets.all(Dimensions.spacingL),
              color: _getStatusColor().withValues(alpha: 0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: _getStatusColor(),
                  ),
                  const SizedBox(width: Dimensions.spacingS),
                  Text(
                    _getStatusLabel(),
                    style: TextStyles.h3.copyWith(
                      color: _getStatusColor(),
                    ),
                  ),
                ],
              ),
            ),

            // Map Preview (placeholder)
            Container(
              height: Dimensions.mapPreviewHeight,
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
                    SizedBox(height: Dimensions.spacingS),
                    Text(
                      'Carte Google Maps',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(Dimensions.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Addresses Section
                  _SectionTitle(title: 'Itinéraire'),
                  const SizedBox(height: Dimensions.spacingM),
                  _AddressCard(
                    icon: Icons.circle_outlined,
                    iconColor: AppColors.success,
                    title: 'Point de récupération',
                    address: delivery.pickupAddress,
                    contactName: delivery.merchantName,
                    contactPhone: null,
                  ),
                  const SizedBox(height: Dimensions.spacingM),
                  _AddressCard(
                    icon: Icons.location_on,
                    iconColor: AppColors.error,
                    title: 'Point de livraison',
                    address: delivery.deliveryAddress,
                    contactName: delivery.recipientName,
                    contactPhone: delivery.recipientPhone,
                  ),
                  const SizedBox(height: Dimensions.spacingM),
                  CustomButton(
                    text: 'Naviguer',
                    icon: Icons.navigation,
                    onPressed: _openNavigation,
                  ),
                  const SizedBox(height: Dimensions.spacingXL),

                  // Delivery Details Section
                  _SectionTitle(title: 'Détails'),
                  const SizedBox(height: Dimensions.spacingM),

                  _DetailRow(
                    icon: Icons.qr_code,
                    label: 'Numéro de suivi',
                    value: delivery.trackingNumber,
                  ),
                  
                  _DetailRow(
                    icon: Icons.attach_money,
                    label: 'Montant',
                    value: Formatters.formatPrice(delivery.price),
                    valueStyle: TextStyles.priceSmall,
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

                  const SizedBox(height: Dimensions.spacingXXL),

                  // Action Buttons
                  if (delivery.status == BackendConstants.deliveryStatusPendingAssignment) ...[
                    CustomButton(
                      text: 'Accepter la livraison',
                      onPressed: _isProcessing ? null : _acceptDelivery,
                      isLoading: _isProcessing,
                      icon: Icons.check_circle,
                      type: ButtonType.success,
                    ),
                    const SizedBox(height: Dimensions.spacingM),
                    OutlineButton(
                      text: 'Refuser',
                      onPressed: _isProcessing ? null : _rejectDelivery,
                      icon: Icons.cancel,
                    ),
                  ] else if (delivery.status == BackendConstants.deliveryStatusAssigned) ...[
                    CustomButton(
                      text: 'Commencer la livraison',
                      onPressed: _isProcessing ? null : _startDelivery,
                      isLoading: _isProcessing,
                      icon: Icons.play_arrow,
                    ),
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
      style: TextStyles.h3,
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
        padding: const EdgeInsets.all(Dimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: Dimensions.iconM),
                const SizedBox(width: Dimensions.spacingS),
                Text(
                  title,
                  style: TextStyles.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: Dimensions.spacingM),
            Text(
              address,
              style: TextStyles.bodyMedium,
            ),
            if (contactName != null || contactPhone != null) ...[
              const SizedBox(height: Dimensions.spacingM),
              const Divider(),
              const SizedBox(height: Dimensions.spacingS),
              if (contactName != null)
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: Dimensions.iconS,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: Dimensions.spacingS),
                    Text(
                      contactName!,
                      style: TextStyles.bodyMedium,
                    ),
                  ],
                ),
              if (contactPhone != null) ...[
                const SizedBox(height: Dimensions.spacingS),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: Dimensions.iconS,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: Dimensions.spacingS),
                    Text(
                      Formatters.formatPhoneNumber(contactPhone!),
                      style: TextStyles.bodyMedium.copyWith(
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
      padding: const EdgeInsets.only(bottom: Dimensions.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: Dimensions.iconS,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: Dimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: valueStyle ?? TextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
