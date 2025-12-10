import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/backend_constants.dart';
import '../../../../core/providers/delivery_provider.dart';
import '../../../../core/providers/location_provider.dart';
import '../../../../data/providers/driver_provider.dart';
import '../../../../data/models/delivery_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../shared/widgets/modern_button.dart';
import '../../../../shared/utils/formatters.dart';
import '../../../../shared/utils/helpers.dart';
import '../widgets/delivery_route_map.dart';

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
  Map<String, dynamic>? _lastPickupError;

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
      case BackendConstants.deliveryStatusInProgress:
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
      // Capture les notifiers/état AVANT les opérations asynchrones
      final locNotifier = ref.read(locationProvider.notifier);
      final deliveryNotifier = ref.read(deliveryProvider.notifier);
      var currentPos = ref.read(currentPositionProvider);

      // Demander une position si nécessaire
      currentPos ??= await locNotifier.getCurrentPosition();

      // Si le widget a été démonté pendant l'attente, quitter sans utiliser `ref`
      if (!mounted) return;

      if (currentPos == null) {
        Helpers.showErrorSnackBar(context, 'Position GPS introuvable. Activez le GPS ou actualisez la position avant de confirmer.');
        return;
      }

      final success = await deliveryNotifier.confirmPickup(id: widget.delivery.id);

      if (!mounted) return;

      if (success) {
        Helpers.showSuccessSnackBar(context, 'Colis récupéré avec succès!');
        setState(() {
          _currentStep = DeliveryStep.goingToDelivery;
        });
      } else {
        final err = ref.read(deliveryProvider).error ?? 'Erreur inconnue lors de la confirmation';
        Helpers.showErrorSnackBar(context, 'Échec: $err');
      }
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
    final delivery = ref.watch(deliveryProvider).activeDelivery ?? widget.delivery;
    final locationState = ref.watch(locationProvider);
    final isGpsReady = ref.watch(isGpsReadyProvider);
    final pickupError = ref.watch(deliveryProvider).pickupError;

    // Show the pickup error dialog once per distinct error payload
    if (pickupError != null && pickupError != _lastPickupError) {
      _lastPickupError = pickupError;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showPickupErrorDialog(pickupError);
        }
      });
    } else if (pickupError == null && _lastPickupError != null) {
      _lastPickupError = null;
    }

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
      body: SafeArea(
        child: Column(
          children: [
            // Map Section with real route - fixed proportional height to avoid overflow
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.36,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Real Map with Route
                  DeliveryRouteMap(
                    pickupLocation: LatLng(
                      delivery.pickupLatitude,
                      delivery.pickupLongitude,
                    ),
                    deliveryLocation: LatLng(
                      delivery.deliveryLatitude,
                      delivery.deliveryLongitude,
                    ),
                    currentLocation: locationState.currentPosition != null
                        ? LatLng(
                            locationState.currentPosition!.latitude,
                            locationState.currentPosition!.longitude,
                          )
                        : null,
                    showRouteInfo: false,
                    height: double.infinity,
                  ),

                  // GPS Status Indicator (smaller, constrained)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isGpsReady ? AppColors.success : AppColors.warning,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            locationState.isTracking ? Icons.gps_fixed : Icons.gps_off,
                            color: Colors.white,
                            size: 16.0,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            locationState.isTracking ? 'GPS Actif' : 'GPS Inactif',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Delivery Info Section (flexible, scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Step Indicator
                    _StepIndicator(currentStep: _currentStep),

                    const SizedBox(height: AppSpacing.xl),

                    // Current Destination Card
                    _DestinationCard(
                      step: _currentStep,
                      delivery: delivery,
                      onCall: _callContact,
                    ),

                    const SizedBox(height: AppSpacing.xl),

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

                    const SizedBox(height: AppSpacing.xl),

                    // Action Buttons
                    Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_currentStep == DeliveryStep.goingToPickup) ...[
                              ModernButton(
                                text: 'Confirmer la récupération',
                                onPressed: _isProcessing ? null : _confirmPickup,
                                isLoading: _isProcessing,
                                icon: Icons.check_circle,
                                type: ModernButtonType.success,
                              ),
                            ] else if (_currentStep == DeliveryStep.goingToDelivery) ...[
                              ModernButton(
                                text: 'Confirmer la livraison',
                                onPressed: _isProcessing ? null : _goToConfirmDelivery,
                                isLoading: _isProcessing,
                                icon: Icons.check_circle,
                                type: ModernButtonType.success,
                              ),
                            ],

                            const SizedBox(height: AppSpacing.md),

                            ModernButton(
                              text: 'Annuler la livraison',
                              onPressed: _isProcessing ? null : _cancelDelivery,
                              icon: Icons.cancel,
                              type: ModernButtonType.outlined,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),
                    // Bottom safe spacing
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPickupErrorDialog(Map<String, dynamic> error) async {
    final locNotifier = ref.read(locationProvider.notifier);
    final deliveryNotifier = ref.read(deliveryProvider.notifier);

    final message = error['error'] ?? 'La confirmation a échoué car la position GPS est requise.';
    final driverCoords = error['driver_coords'];
    final pickupCommune = error['pickup_commune'];
    final pickupSource = error['pickup_source'];
    final driverLastUpdate = error['driver_last_update'];

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Position GPS requise'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              if (pickupCommune != null) ...[
                const SizedBox(height: 8),
                Text('Commune de fallback: $pickupCommune', style: Theme.of(context).textTheme.bodySmall),
              ],
              if (pickupSource != null) ...[
                const SizedBox(height: 6),
                Text('Source des coordonnées: $pickupSource', style: Theme.of(context).textTheme.bodySmall),
              ],
              if (driverCoords != null) ...[
                const SizedBox(height: 8),
                Text('Position serveur: $driverCoords', style: Theme.of(context).textTheme.bodySmall),
              ],
              if (driverLastUpdate != null) ...[
                const SizedBox(height: 6),
                Text('Dernière mise à jour GPS: $driverLastUpdate', style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  final pos = await locNotifier.getCurrentPosition();
                  if (!mounted) return;
                  if (pos != null) {
                    Helpers.showSuccessSnackBar(context, 'Position actualisée');
                  } else {
                    Helpers.showErrorSnackBar(context, 'Impossible d\'obtenir la position. Activez le GPS et réessayez.');
                  }
                } catch (e) {
                  if (!mounted) return;
                  Helpers.showErrorSnackBar(context, 'Erreur lors de l\'actualisation de la position: $e');
                }
              },
              child: const Text('Actualiser la position'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() => _isProcessing = true);
                try {
                  final success = await deliveryNotifier.confirmPickup(id: widget.delivery.id);
                  if (!mounted) return;
                  if (success) {
                    Helpers.showSuccessSnackBar(context, 'Colis récupéré avec succès!');
                    setState(() {
                      _currentStep = DeliveryStep.goingToDelivery;
                    });
                  } else {
                    final err = ref.read(deliveryProvider).error ?? 'Échec lors de la confirmation';
                    Helpers.showErrorSnackBar(context, err);
                  }
                } catch (e) {
                  if (!mounted) return;
                  Helpers.showErrorSnackBar(context, 'Erreur: $e');
                } finally {
                  if (mounted) setState(() => _isProcessing = false);
                }
              },
              child: const Text('Réessayer'),
            ),
          ],
        );
      },
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
        const SizedBox(height: AppSpacing.sm),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
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
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (isPickup ? AppColors.success : AppColors.error).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPickup ? Icons.storefront : Icons.home,
                    color: isPickup ? AppColors.success : AppColors.error,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPickup ? 'Aller récupérer' : 'Livrer à',
                        style: AppTypography.h3,
                      ),
                      const SizedBox(height: 4),
                      if (name != null)
                        Text(
                          name,
                          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Address - allow up to 3 lines and selectable for copy
            SelectableText(
              address,
              maxLines: 3,
              style: AppTypography.bodyLarge,
            ),

            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left: contact info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (phone != null) ...[
                        Text(
                          Formatters.formatPhoneNumber(phone),
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                      Text(
                        delivery.pickupCommune ?? '',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

                // Right: action buttons (bigger, accessible) - use Wrap to avoid infinite width during layout
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  alignment: WrapAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: phone != null ? () => onCall(phone) : null,
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text('Appeler'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Helpers.showSnackBar(context, 'Ouverture de Google Maps...');
                      },
                      icon: const Icon(Icons.navigation, size: 18),
                      label: const Text('Itinéraire'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20.0, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(title, style: AppTypography.labelLarge),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Items: make label secondary and value wrap if long
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          item.label,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        flex: 6,
                        child: Text(
                          item.value,
                          textAlign: TextAlign.right,
                          style: AppTypography.bodyMedium,
                        ),
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
