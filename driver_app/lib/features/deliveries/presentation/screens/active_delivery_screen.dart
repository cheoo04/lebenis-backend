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
      case 'assigned':
        // Livreur assigné - doit aller récupérer le colis
        _currentStep = DeliveryStep.goingToPickup;
        break;
      case 'picked_up':
      case BackendConstants.deliveryStatusInProgress:
        // Colis récupéré - en route vers la livraison
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

      if (!mounted) {
        setState(() => _isProcessing = false);
        return;
      }

      if (currentPos == null) {
        setState(() => _isProcessing = false);
        Helpers.showErrorSnackBar(context, 'Position GPS introuvable. Activez le GPS ou actualisez la position avant de confirmer.');
        return;
      }

      final success = await deliveryNotifier.confirmPickup(id: widget.delivery.id);

      if (!mounted) {
        setState(() => _isProcessing = false);
        return;
      }

      if (success) {
        Helpers.showSuccessSnackBar(context, 'Colis récupéré avec succès!');
        setState(() {
          _currentStep = DeliveryStep.goingToDelivery;
          _isProcessing = false;
        });
      } else {
        setState(() => _isProcessing = false);
        // L'erreur sera affichée via le dialogue pickupError si c'est une erreur de distance/GPS
        // Sinon afficher un message générique
        final pickupError = ref.read(deliveryProvider).pickupError;
        if (pickupError == null) {
          final err = ref.read(deliveryProvider).error ?? 'Erreur inconnue lors de la confirmation';
          Helpers.showErrorSnackBar(context, 'Échec: $err');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        Helpers.showErrorSnackBar(context, 'Erreur: $e');
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

  /// Ouvre Google Maps pour naviguer vers le point d'enlèvement
  Future<void> _openNavigationToPickup() async {
    final delivery = ref.read(deliveryProvider).activeDelivery ?? widget.delivery;
    
    if (delivery.pickupLatitude == null || delivery.pickupLongitude == null) {
      Helpers.showErrorSnackBar(context, 'Coordonnées du point d\'enlèvement non disponibles');
      return;
    }
    
    try {
      await openNavigationApp(
        latitude: delivery.pickupLatitude!,
        longitude: delivery.pickupLongitude!,
        label: delivery.trackingNumber,
      );
    } catch (e) {
      if (!mounted) return;
      Helpers.showErrorSnackBar(context, 'Impossible d\'ouvrir la navigation: $e');
    }
  }

  /// Calcule la distance entre la position actuelle et le point de récupération
  double? _calculateDistanceToPickup(DeliveryModel delivery, dynamic locationState) {
    if (delivery.pickupLatitude == null || delivery.pickupLongitude == null) {
      return null;
    }
    if (locationState.currentPosition == null) {
      return null;
    }
    
    final Distance distance = const Distance();
    final currentPos = LatLng(
      locationState.currentPosition!.latitude,
      locationState.currentPosition!.longitude,
    );
    final pickupPos = LatLng(
      delivery.pickupLatitude!,
      delivery.pickupLongitude!,
    );
    
    // Retourne la distance en km
    return distance.as(LengthUnit.Kilometer, currentPos, pickupPos);
  }

  /// Construit le widget affichant la distance au point de récupération
  Widget _buildDistanceToPickupCard(DeliveryModel delivery, dynamic locationState) {
    final distanceKm = _calculateDistanceToPickup(delivery, locationState);
    
    if (distanceKm == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.gps_off, color: Colors.grey[600]),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Position GPS en cours de récupération...',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }
    
    // Déterminer la couleur et l'icône selon la distance
    final bool isClose = distanceKm <= 1.0; // Seuil de 1 km
    final bool isVeryClose = distanceKm <= 0.2; // Moins de 200m
    
    Color bgColor;
    Color borderColor;
    Color iconColor;
    IconData icon;
    String message;
    
    if (isVeryClose) {
      bgColor = AppColors.success.withValues(alpha: 0.1);
      borderColor = AppColors.success.withValues(alpha: 0.3);
      iconColor = AppColors.success;
      icon = Icons.check_circle;
      message = 'Vous êtes au point de récupération';
    } else if (isClose) {
      bgColor = AppColors.success.withValues(alpha: 0.1);
      borderColor = AppColors.success.withValues(alpha: 0.3);
      iconColor = AppColors.success;
      icon = Icons.near_me;
      message = 'Vous pouvez confirmer la récupération';
    } else {
      bgColor = AppColors.warning.withValues(alpha: 0.1);
      borderColor = AppColors.warning.withValues(alpha: 0.3);
      iconColor = AppColors.warning;
      icon = Icons.directions_walk;
      message = 'Rapprochez-vous du point de récupération';
    }
    
    // Formater la distance
    String distanceText;
    if (distanceKm < 1) {
      distanceText = '${(distanceKm * 1000).round()} m';
    } else {
      distanceText = '${distanceKm.toStringAsFixed(1)} km';
    }
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distance au point de récupération',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      distanceText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isClose)
                TextButton.icon(
                  onPressed: _openNavigationToPickup,
                  icon: const Icon(Icons.navigation, size: 18),
                  label: const Text('Naviguer'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: iconColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
                      // Masquer la distance totale pendant la phase de récupération
                      hideDistance: delivery.status == 'assigned' && _currentStep == DeliveryStep.goingToPickup,
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Delivery Info
                    // Afficher les informations détaillées uniquement en phase de livraison
                    // (En phase de récupération, le montant est déjà visible dans la DeliveryCard)
                    if (delivery.status != 'assigned' || _currentStep != DeliveryStep.goingToPickup)
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
                            // Afficher la distance au point de récupération si on est en phase de pickup
                            if (delivery.status == 'assigned' && _currentStep == DeliveryStep.goingToPickup) ...[
                              _buildDistanceToPickupCard(delivery, locationState),
                              const SizedBox(height: AppSpacing.md),
                            ],
                            
                            // Statut 'assigned' - Afficher "Confirmer la récupération"
                            // Désactiver le bouton si la distance au point de récupération est > 1 km
                            if (delivery.status == 'assigned' && _currentStep == DeliveryStep.goingToPickup) ...[
                              Builder(
                                builder: (context) {
                                  final distanceToPickup = _calculateDistanceToPickup(delivery, locationState);
                                  final bool canConfirm = distanceToPickup != null && distanceToPickup <= 1.0;
                                  
                                  return ModernButton(
                                    text: 'Confirmer la récupération',
                                    onPressed: (_isProcessing || !canConfirm) ? null : _confirmPickup,
                                    isLoading: _isProcessing,
                                    icon: Icons.inventory_2,
                                    type: canConfirm ? ModernButtonType.success : ModernButtonType.secondary,
                                  );
                                },
                              ),
                            // Statut 'picked_up' ou 'in_progress' - Afficher "Confirmer la livraison"
                            ] else if (delivery.status == 'picked_up' || 
                                       delivery.status == BackendConstants.deliveryStatusInProgress) ...[
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

    final message = error['error'] ?? 'La confirmation a échoué.';
    final driverCoords = error['driver_coords'];
    final pickupCommune = error['pickup_commune'];
    final driverLastUpdate = error['driver_last_update'];
    final distanceKm = error['distance_km'];
    final requireGps = error['require_gps'] == true;

    // Déterminer le type d'erreur
    final bool isTooFarError = distanceKm != null;
    final String title = isTooFarError 
        ? 'Vous êtes trop loin' 
        : 'Position GPS requise';
    final IconData icon = isTooFarError 
        ? Icons.location_off 
        : Icons.gps_off;
    final Color iconColor = isTooFarError 
        ? AppColors.warning 
        : AppColors.error;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 12),
              Expanded(child: Text(title)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(fontSize: 15),
                ),
                if (isTooFarError) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_walk, color: AppColors.warning),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Distance actuelle: ${(distanceKm as num).toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Rendez-vous au point d\'enlèvement indiqué sur la carte pour confirmer la récupération du colis.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
                if (!isTooFarError && requireGps) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Activez votre GPS et actualisez votre position avant de confirmer.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
                if (pickupCommune != null) ...[
                  const SizedBox(height: 12),
                  Text('📍 Point d\'enlèvement: $pickupCommune', style: Theme.of(context).textTheme.bodySmall),
                ],
                if (driverCoords != null && !isTooFarError) ...[
                  const SizedBox(height: 6),
                  Text('Position serveur: $driverCoords', style: Theme.of(context).textTheme.bodySmall),
                ],
                if (driverLastUpdate != null && !isTooFarError) ...[
                  const SizedBox(height: 6),
                  Text('Dernière mise à jour: $driverLastUpdate', style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Réinitialiser l'erreur
                ref.read(deliveryProvider.notifier).clearPickupError();
              },
              child: const Text('Fermer'),
            ),
            if (!isTooFarError)
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
                    messenger.showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
                  }
                },
                child: const Text('Actualiser la position'),
              ),
            if (isTooFarError)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Ouvrir la navigation vers le point d'enlèvement
                  _openNavigationToPickup();
                },
                icon: const Icon(Icons.navigation),
                label: const Text('Naviguer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              )
            else
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
