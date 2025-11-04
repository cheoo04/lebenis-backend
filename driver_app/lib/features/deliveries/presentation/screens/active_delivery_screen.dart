import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/backend_constants.dart';
import '../../../../core/providers/delivery_provider.dart';
import '../../../../core/providers/location_provider.dart';
import '../../../../data/models/delivery_model.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/utils/formatters.dart';
import '../../../../shared/utils/helpers.dart';

class ActiveDeliveryScreen extends ConsumerStatefulWidget {
  final DeliveryModel delivery;

  const ActiveDeliveryScreen({
    super.key,
    required this.delivery,
  });

  @override
  ConsumerState<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends ConsumerState<ActiveDeliveryScreen> {
  bool _isProcessing = false;
  DeliveryStep _currentStep = DeliveryStep.goingToPickup;

  @override
  void initState() {
    super.initState();
    _initializeDelivery();
    _determineCurrentStep();
  }

  void _initializeDelivery() {
    // Start GPS tracking
    ref.read(locationProvider.notifier).startTracking();
  }

  void _determineCurrentStep() {
    switch (widget.delivery.status) {
      case BackendConstants.deliveryStatusAssigned:
      case BackendConstants.deliveryStatusPickupInProgress:
        _currentStep = DeliveryStep.goingToPickup;
        break;
      case BackendConstants.deliveryStatusPickedUp:
      case BackendConstants.deliveryStatusInTransit:
        _currentStep = DeliveryStep.goingToDelivery;
        break;
      default:
        _currentStep = DeliveryStep.goingToPickup;
    }
  }

  @override
  void dispose() {
    // Stop GPS tracking when leaving screen
    ref.read(locationProvider.notifier).stopTracking();
    super.dispose();
  }

  Future<void> _confirmPickup() async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Confirmer la récupération',
      message: 'Avez-vous récupéré le colis?',
      confirmText: 'Confirmer',
      cancelText: 'Annuler',
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
      await ref.read(deliveryProvider.notifier).confirmPickup(id: widget.delivery.id);
      
      if (!mounted) return;
      
      Helpers.showSuccessSnackBar(context, 'Colis récupéré avec succès!');
      setState(() {
        _currentStep = DeliveryStep.goingToDelivery;
      });
    } catch (e) {
      if (!mounted) return;
      Helpers.showErrorSnackBar(context, 'Erreur: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _goToConfirmDelivery() async {
    Navigator.of(context).pushReplacementNamed(
      '/confirm-delivery',
      arguments: widget.delivery,
    );
  }

  Future<void> _cancelDelivery() async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Annuler la livraison',
      message: 'Êtes-vous sûr de vouloir annuler cette livraison? Cette action est irréversible.',
      confirmText: 'Annuler la livraison',
      cancelText: 'Retour',
      confirmColor: AppColors.error,
    );

    if (confirmed != true) return;

    setState(() => _isProcessing = true);

    try {
  await ref.read(deliveryProvider.notifier).cancelDelivery(widget.delivery.id, 'Annulé par le livreur');
      
      if (!mounted) return;
      
      Helpers.showSuccessSnackBar(context, 'Livraison annulée');
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

  Future<void> _callContact(String? phone) async {
    if (phone == null || phone.isEmpty) {
      Helpers.showSnackBar(context, 'Numéro de téléphone non disponible');
      return;
    }
    
    // Lancer l'appel téléphonique
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      Helpers.showErrorSnackBar(context, 'Impossible de lancer l\'appel');
    }
  }

  @override
  Widget build(BuildContext context) {
    final delivery = widget.delivery;
    final locationState = ref.watch(locationProvider);
    final isGpsReady = ref.watch(isGpsReadyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Livraison #${delivery.trackingNumber}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Map Section
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[300],
              child: Stack(
                children: [
                  // Map Placeholder
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: Dimensions.spacingM),
                        Text(
                          'Carte Google Maps avec suivi GPS',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  
                  // GPS Status Indicator
                  Positioned(
                    top: Dimensions.spacingM,
                    right: Dimensions.spacingM,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.spacingM,
                        vertical: Dimensions.spacingS,
                      ),
                      decoration: BoxDecoration(
                        color: isGpsReady ? AppColors.success : AppColors.warning,
                        borderRadius: BorderRadius.circular(Dimensions.radiusL),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            locationState.isTracking ? Icons.gps_fixed : Icons.gps_off,
                            color: Colors.white,
                            size: Dimensions.iconS,
                          ),
                          const SizedBox(width: Dimensions.spacingXS),
                          Text(
                            locationState.isTracking ? 'GPS Actif' : 'GPS Inactif',
                            style: TextStyles.labelSmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Delivery Info Section
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step Indicator
                  _StepIndicator(currentStep: _currentStep),

                  const SizedBox(height: Dimensions.spacingXL),

                  // Current Destination Card
                  _DestinationCard(
                    step: _currentStep,
                    delivery: delivery,
                    onCall: _callContact,
                  ),

                  const SizedBox(height: Dimensions.spacingXL),

                  // Delivery Info
                  _InfoCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Informations',
                    items: [
                      if (delivery.packageDescription.isNotEmpty)
                        InfoItem(
                          label: 'Description',
                          value: delivery.packageDescription,
                        ),
                      InfoItem(
                        label: 'Montant',
                        value: Formatters.formatPrice(delivery.price),
                      ),
                      InfoItem(
                        label: 'Distance',
                        value: Formatters.formatDistance(delivery.distanceKm),
                      ),
                    ],
                  ),

                  const SizedBox(height: Dimensions.spacingXL),

                  // Action Buttons
                  if (_currentStep == DeliveryStep.goingToPickup) ...[
                    CustomButton(
                      text: 'Confirmer la récupération',
                      onPressed: _isProcessing ? null : _confirmPickup,
                      isLoading: _isProcessing,
                      icon: Icons.check_circle,
                      type: ButtonType.success,
                    ),
                  ] else if (_currentStep == DeliveryStep.goingToDelivery) ...[
                    CustomButton(
                      text: 'Confirmer la livraison',
                      onPressed: _isProcessing ? null : _goToConfirmDelivery,
                      isLoading: _isProcessing,
                      icon: Icons.check_circle,
                      type: ButtonType.success,
                    ),
                  ],

                  const SizedBox(height: Dimensions.spacingM),

                  OutlineButton(
                    text: 'Annuler la livraison',
                    onPressed: _isProcessing ? null : _cancelDelivery,
                    icon: Icons.cancel,
                  ),

                  const SizedBox(height: Dimensions.spacingL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.navigation),
              title: const Text('Ouvrir dans Google Maps'),
              onTap: () {
                Navigator.pop(context);
                Helpers.showSnackBar(context, 'Ouverture de Google Maps...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Actualiser la position'),
              onTap: () {
                Navigator.pop(context);
                ref.read(locationProvider.notifier).getCurrentPosition();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Détails de la livraison'),
              onTap: () {
                Navigator.pop(context);
                // Show delivery details
              },
            ),
          ],
        ),
      ),
    );
  }
}

enum DeliveryStep {
  goingToPickup,
  goingToDelivery,
}

class _StepIndicator extends StatelessWidget {
  final DeliveryStep currentStep;

  const _StepIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StepItem(
            icon: Icons.store,
            label: 'Récupération',
            isActive: currentStep == DeliveryStep.goingToPickup,
            isCompleted: currentStep == DeliveryStep.goingToDelivery,
          ),
        ),
        Container(
          width: 40,
          height: 2,
          color: currentStep == DeliveryStep.goingToDelivery
              ? AppColors.success
              : AppColors.border,
        ),
        Expanded(
          child: _StepItem(
            icon: Icons.home,
            label: 'Livraison',
            isActive: currentStep == DeliveryStep.goingToDelivery,
            isCompleted: false,
          ),
        ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted
        ? AppColors.success
        : isActive
            ? AppColors.primary
            : AppColors.textSecondary;

    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isCompleted || isActive ? color : Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isCompleted || isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: Dimensions.spacingS),
        Text(
          label,
          style: TextStyles.labelSmall.copyWith(
            color: color,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DestinationCard extends StatelessWidget {
  final DeliveryStep step;
  final DeliveryModel delivery;
  final Function(String?) onCall;

  const _DestinationCard({
    required this.step,
    required this.delivery,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final isPickup = step == DeliveryStep.goingToPickup;
    final address = isPickup ? delivery.pickupAddress : delivery.deliveryAddress;
    final name = isPickup ? delivery.merchantName : delivery.recipientName;
    final phone = isPickup ? null : delivery.recipientPhone;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isPickup ? Icons.circle_outlined : Icons.location_on,
                  color: isPickup ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: Dimensions.spacingS),
                Text(
                  isPickup ? 'Aller récupérer' : 'Livrer à',
                  style: TextStyles.h3,
                ),
              ],
            ),
            const SizedBox(height: Dimensions.spacingM),
            Text(
              address,
              style: TextStyles.bodyLarge,
            ),
            const SizedBox(height: Dimensions.spacingM),
            const Divider(),
            const SizedBox(height: Dimensions.spacingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (name != null) ...[
                      Text(
                        name,
                        style: TextStyles.labelLarge,
                      ),
                      const SizedBox(height: Dimensions.spacingXS),
                    ],
                    if (phone != null)
                      Text(
                        Formatters.formatPhoneNumber(phone),
                        style: TextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    IconCircleButton(
                      icon: Icons.phone,
                      onPressed: () => onCall(phone),
                      backgroundColor: AppColors.success,
                    ),
                    const SizedBox(width: Dimensions.spacingS),
                    IconCircleButton(
                      icon: Icons.navigation,
                      onPressed: () {
                        Helpers.showSnackBar(context, 'Ouverture de Google Maps...');
                      },
                      backgroundColor: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<InfoItem> items;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.items,
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
                Icon(icon, size: Dimensions.iconM),
                const SizedBox(width: Dimensions.spacingS),
                Text(title, style: TextStyles.labelLarge),
              ],
            ),
            const SizedBox(height: Dimensions.spacingM),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.spacingS),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.label,
                        style: TextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        item.value,
                        style: TextStyles.bodyMedium,
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class InfoItem {
  final String label;
  final String value;

  InfoItem({required this.label, required this.value});
}
