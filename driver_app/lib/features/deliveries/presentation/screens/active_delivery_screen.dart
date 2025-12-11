import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/backend_constants.dart';
import '../../../../core/providers/delivery_provider.dart';
import '../../../../core/providers/location_provider.dart';
import '../../../../data/models/delivery_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../shared/widgets/modern_button.dart';
import '../../../../shared/utils/formatters.dart';
import '../../../../shared/utils/helpers.dart';
import '../widgets/delivery_route_map.dart';
import '../widgets/step_indicator.dart';
import '../widgets/delivery_card.dart';
import '../widgets/info_card.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/navigation_utils.dart';

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
    // Ensure deliveryProvider has the active delivery set so UI reads from a single source of truth
    try {
      final notifier = ref.read(deliveryProvider.notifier);
      final currentActive = ref.read(deliveryProvider).activeDelivery;
      if (currentActive == null) {
        notifier.setActiveDelivery(widget.delivery);
      }
    } catch (_) {}
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
      final locNotifier = ref.read(locationProvider.notifier);
      final deliveryNotifier = ref.read(deliveryProvider.notifier);

      // Actualiser la position juste avant la confirmation
      final currentPos = await locNotifier.getCurrentPosition();

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

  Future<void> _startDelivery() async {
    // Ne fait plus d'appel backend ni de changement de statut
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    Helpers.showSuccessSnackBar(context, 'Vous pouvez commencer votre trajet vers le point de récupération.');
    setState(() {
      _currentStep = DeliveryStep.goingToPickup;
      _isProcessing = false;
    });
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
                  // Real Map with Route (only when coords are available)
                  if (delivery.pickupLatitude != null &&
                      delivery.pickupLongitude != null &&
                      delivery.deliveryLatitude != null &&
                      delivery.deliveryLongitude != null)
                    DeliveryRouteMap(
                      pickupLocation: LatLng(
                        delivery.pickupLatitude!,
                        delivery.pickupLongitude!,
                      ),
                      deliveryLocation: LatLng(
                        delivery.deliveryLatitude!,
                        delivery.deliveryLongitude!,
                      ),
                      currentLocation: locationState.currentPosition != null
                          ? LatLng(
                              locationState.currentPosition!.latitude,
                              locationState.currentPosition!.longitude,
                            )
                          : null,
                      showRouteInfo: false,
                      height: double.infinity,
                    )
                  else
                    // Fallback when coordinates are missing: show a lightweight placeholder
                    Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.location_off, size: 36, color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                'Coordonnées non disponibles',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Actualisez la position ou contactez le support.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
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
                    StepIndicator(currentStep: _currentStep),

                    const SizedBox(height: AppSpacing.xl),

                    // Current Destination Card
                    DeliveryCard(
                      delivery: delivery,
                      onTap: () => _callContact(delivery.recipientPhone),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Delivery Info
                    InfoCard(
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
                          value: delivery.distanceKm < 1
                              ? '${(delivery.distanceKm * 1000).round()} m'
                              : '${delivery.distanceKm.toStringAsFixed(1)} km',
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
                            if (delivery.status == 'assigned') ...[
                              ModernButton(
                                text: 'Démarrer la livraison',
                                onPressed: _isProcessing ? null : _startDelivery,
                                isLoading: _isProcessing,
                                icon: Icons.play_arrow,
                                type: ModernButtonType.success,
                              ),
                            ] else if (_currentStep == DeliveryStep.goingToPickup) ...[
                              ModernButton(
                                text: 'Confirmer la récupération',
                                onPressed: _isProcessing ? null : _confirmPickup,
                                isLoading: _isProcessing,
                                icon: Icons.check_circle,
                                type: ModernButtonType.success,
                              ),
                            ] else if (_currentStep == DeliveryStep.goingToDelivery && delivery.status == BackendConstants.deliveryStatusInProgress) ...[
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
                  final messenger = ScaffoldMessenger.of(context);
                  final pos = await locNotifier.getCurrentPosition();
                  if (!mounted) return;
                  if (pos != null) {
                    messenger.showSnackBar(const SnackBar(content: Text('Position actualisée'), backgroundColor: Colors.green));
                  } else {
                    messenger.showSnackBar(const SnackBar(content: Text('Impossible d\'obtenir la position. Activez le GPS et réessayez.'), backgroundColor: Colors.red));
                  }
                } catch (e) {
                  if (!mounted) return;
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.showSnackBar(SnackBar(content: Text('Erreur lors de l\'actualisation de la position: $e'), backgroundColor: Colors.red));
                }
              },
              child: const Text('Actualiser la position'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() => _isProcessing = true);
                final messenger = ScaffoldMessenger.of(context);
                try {
                  final success = await deliveryNotifier.confirmPickup(id: widget.delivery.id);
                  if (!mounted) return;
                  if (success) {
                    messenger.showSnackBar(const SnackBar(content: Text('Colis récupéré avec succès!'), backgroundColor: Colors.green));
                    if (mounted) {
                      setState(() {
                        _currentStep = DeliveryStep.goingToDelivery;
                      });
                    }
                  } else {
                    final err = ref.read(deliveryProvider).error ?? 'Échec lors de la confirmation';
                    messenger.showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
                  }
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
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
              onTap: () async {
                Navigator.pop(context);
                // Choose target based on current step
                final delivery = ref.read(deliveryProvider).activeDelivery ?? widget.delivery;
                final target = (_currentStep == DeliveryStep.goingToDelivery)
                    ? delivery.deliveryLatitude != null && delivery.deliveryLongitude != null
                        ? [delivery.deliveryLatitude, delivery.deliveryLongitude]
                        : null
                    : delivery.pickupLatitude != null && delivery.pickupLongitude != null
                        ? [delivery.pickupLatitude, delivery.pickupLongitude]
                        : null;

                if (target == null || target.length != 2) {
                  Helpers.showSnackBar(context, 'Coordonnées GPS indisponibles');
                  return;
                }

                try {
                  await openNavigationApp(latitude: target[0] as double, longitude: target[1] as double, label: delivery.trackingNumber);
                } catch (e) {
                  Helpers.showErrorSnackBar(context, 'Impossible d\'ouvrir une application de navigation: $e');
                }
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
