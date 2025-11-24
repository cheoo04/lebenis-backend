// driver_app/lib/features/profile/presentation/screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../zones/presentation/screens/zone_selection_screen.dart';
import '../../../../core/constants/backend_constants.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/driver_provider.dart';
import '../../../../data/models/driver_model.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/utils/formatters.dart';
import '../../../../shared/utils/helpers.dart';
import '../widgets/availability_toggle.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _showFullInfoDialog(DriverModel? driver) {
    if (driver == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Informations supplémentaires'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nom: ${driver.user.fullName}'),
              Text('Email: ${driver.user.email}'),
              Text('Téléphone: ${driver.phone}'),
              Text('Date de naissance: ${driver.dateOfBirth != null ? DateFormat('dd/MM/yyyy').format(driver.dateOfBirth!) : '-'}'),
              Text('Numéro de CNI: ${driver.identityCardNumber ?? '-'}'),
              Text('CNI Recto: ${driver.identityCardFront ?? '-'}'),
              Text('CNI Verso: ${driver.identityCardBack ?? '-'}'),
              Text('Type véhicule: ${driver.vehicleTypeLabel}'),
              Text('Immatriculation: ${driver.vehicleRegistration}'),
              Text('Capacité: ${driver.vehicleCapacityKg} kg'),
              Text('Statut: ${driver.verificationStatus}'),
              Text('Banque: ${driver.bankName ?? '-'}'),
              Text('Compte bancaire: ${driver.bankAccountNumber ?? '-'}'),
              Text('Mobile Money: ${driver.mobileMoneyNumber ?? '-'}'),
              Text('Contact urgence: ${driver.emergencyContactName ?? '-'} (${driver.emergencyContactPhone ?? '-'})'),
              // Ajoutez d'autres champs si besoin
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

    void _goToZones() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ZoneSelectionScreen()),
      );
    }
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(driverProvider.notifier).loadProfile();
      ref.read(driverProvider.notifier).loadStats();
    });
  }

  Future<void> _goToEditProfile() async {
    final result = await Navigator.of(context).pushNamed('/edit-profile');
    if (result == true && mounted) {
      ref.refresh(driverProvider);
      await Future.wait([
        ref.read(driverProvider.notifier).loadProfile(),
        ref.read(driverProvider.notifier).loadStats(),
      ]);
      if (mounted) setState(() {});
    }
  }

  Future<void> _logout() async {
    final confirmed = await Helpers.showConfirmDialog(
      context,
      title: 'Déconnexion',
      message: 'Voulez-vous vraiment vous déconnecter?',
      confirmText: 'Déconnexion',
      cancelText: 'Annuler',
      confirmColor: AppColors.error,
    );

    if (confirmed != true) return;

    try {
      await ref.read(authProvider.notifier).logout();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      Helpers.showErrorSnackBar(context, 'Erreur lors de la déconnexion: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverState = ref.watch(driverProvider);
    final driver = driverState.driver;
    final stats = driverState.stats;

    if (driverState.isLoading && driver == null) {
      return const Scaffold(
        body: LoadingWidget(message: 'Chargement du profil...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _goToEditProfile,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Informations supplémentaires',
            onPressed: () => _showFullInfoDialog(driver),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait<void>([
            ref.read(driverProvider.notifier).loadProfile(),
            ref.read(driverProvider.notifier).loadStats(),
          ]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo de profil
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      child: ClipOval(
                        child: driver?.profilePhoto != null
                            ? (driver!.profilePhoto!.startsWith('http://') || driver!.profilePhoto!.startsWith('https://'))
                                ? Image.network(
                                    // Use string interpolation for cache-busting query param
                                    '${driver!.profilePhoto!}?cb=${DateTime.now().millisecondsSinceEpoch}',
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppColors.primary,
                                      );
                                    },
                                  )
                                : driver!.profilePhoto!.startsWith('file://')
                                    ? Image.file(
                                        File(Uri.parse(driver!.profilePhoto!).toFilePath()),
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(Icons.person, size: 60, color: AppColors.primary)
                            : Icon(Icons.person, size: 60, color: AppColors.primary),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.spacingXS),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: Dimensions.iconS,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: Dimensions.spacingL),

              // Nom
              Text(
                driver?.user.fullName ?? 'Nom non disponible',
                style: TextStyles.h2,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: Dimensions.spacingS),

              // Email & Phone
              Text(
                driver?.user.email ?? '',
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: Dimensions.spacingXS),

              Text(
                Formatters.formatPhoneNumber(driver?.phone ?? ''),
                style: TextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: Dimensions.spacingXL),

              // Toggle de disponibilité
              const AvailabilityToggle(),

              const SizedBox(height: Dimensions.spacingXL),

              // Statistiques
              Text(
                'Statistiques',
                style: TextStyles.h3,
              ),

              const SizedBox(height: Dimensions.spacingM),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.star,
                      iconColor: AppColors.warning,
                      label: 'Note',
                      value: (driver?.rating ?? 0.0).toStringAsFixed(1),
                    ),
                  ),
                  const SizedBox(width: Dimensions.spacingM),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_shipping,
                      iconColor: AppColors.info,
                      label: 'Livraisons',
                      value: '${stats?['total_deliveries'] ?? 0}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Dimensions.spacingM),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.check_circle,
                      iconColor: AppColors.success,
                      label: 'Complétées',
                      value: '${stats?['completed_deliveries'] ?? 0}',
                    ),
                  ),
                  const SizedBox(width: Dimensions.spacingM),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.attach_money,
                      iconColor: AppColors.primary,
                      label: 'Gains Total',
                      value: Formatters.formatPrice((stats?['total_earnings'] ?? 0).toDouble()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: Dimensions.spacingXL),

              // Informations du véhicule
              Text(
                'Véhicule',
                style: TextStyles.h3,
              ),

              const SizedBox(height: Dimensions.spacingM),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.cardPadding),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: driver?.vehicleType != null 
                          ? BackendConstants.getVehicleTypeIcon(driver!.vehicleType)
                          : Icons.local_shipping,
                        label: 'Type',
                        value: driver?.vehicleTypeLabel ?? 'Non défini',
                      ),
                      if (driver?.vehicleRegistration != null) ...[
                        const Divider(),
                        _InfoRow(
                          icon: Icons.confirmation_number,
                          label: 'Immatriculation',
                          value: driver?.vehicleRegistration ?? '',
                        ),
                      ],
                      const Divider(),
                      _InfoRow(
                        icon: Icons.scale,
                        label: 'Capacité de charge',
                        value: '${driver?.vehicleCapacityKg ?? 0} kg',
                      ),
                    ],
                  ),
                ),
              ),
              
              // Capacités du véhicule (info visuelle)
              if (driver?.vehicleType != null) ...[
                const SizedBox(height: Dimensions.spacingM),
                _VehicleCapacityCard(vehicleType: driver!.vehicleType),
              ],

              const SizedBox(height: Dimensions.spacingXL),

              // Bouton gestion des zones de travail
              CustomButton(
                text: 'Mes zones de travail',
                onPressed: _goToZones,
                icon: Icons.map,
                type: ButtonType.secondary,
              ),

              // Actions
              CustomButton(
                text: 'Voir mes gains',
                onPressed: () {
                  Navigator.of(context).pushNamed('/earnings');
                },
                icon: Icons.attach_money,
                type: ButtonType.secondary,
              ),

              const SizedBox(height: Dimensions.spacingM),

              OutlineButton(
                text: 'Déconnexion',
                onPressed: _logout,
                icon: Icons.logout,
              ),

              const SizedBox(height: Dimensions.spacingXL),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.cardPadding),
        child: Column(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: Dimensions.iconL,
            ),
            const SizedBox(height: Dimensions.spacingS),
            Text(
              value,
              style: TextStyles.h3,
            ),
            const SizedBox(height: Dimensions.spacingXS),
            Text(
              label,
              style: TextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: Dimensions.iconM,
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
              Text(
                value,
                style: TextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Widget pour afficher les capacités du véhicule
class _VehicleCapacityCard extends StatelessWidget {
  final String vehicleType;

  const _VehicleCapacityCard({required this.vehicleType});

  Map<String, dynamic> _getCapacityInfo(String type) {
    switch (type) {
      case 'moto':
        return {
          'weight': '15 kg',
          'dimensions': '50 × 40 × 50 cm',
          'description': 'Idéal pour petits colis (sac à dos)',
          'icon': Icons.backpack,
          'color': AppColors.info,
        };
      case 'tricycle':
        return {
          'weight': '100 kg',
          'dimensions': '120 × 80 × 80 cm',
          'description': 'Bon pour colis moyens (caisse arrière)',
          'icon': Icons.shopping_bag,
          'color': AppColors.warning,
        };
      case 'voiture':
        return {
          'weight': '200 kg',
          'dimensions': '150 × 100 × 100 cm',
          'description': 'Colis volumineux (coffre de voiture)',
          'icon': Icons.luggage,
          'color': AppColors.primary,
        };
      case 'camionnette':
        return {
          'weight': '500 kg',
          'dimensions': '300 × 150 × 150 cm',
          'description': 'Gros volumes (benne de camionnette)',
          'icon': Icons.inventory_2,
          'color': AppColors.success,
        };
      default:
        return {
          'weight': '30 kg',
          'dimensions': 'Non spécifié',
          'description': 'Capacité par défaut',
          'icon': Icons.local_shipping,
          'color': AppColors.textSecondary,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _getCapacityInfo(vehicleType);
    
    return Card(
      color: (info['color'] as Color).withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  info['icon'] as IconData,
                  color: info['color'] as Color,
                  size: Dimensions.iconL,
                ),
                const SizedBox(width: Dimensions.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Capacités maximales',
                        style: TextStyles.labelMedium.copyWith(
                          color: info['color'] as Color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: Dimensions.spacingXS),
                      Text(
                        info['description'] as String,
                        style: TextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.spacingM),
            Container(
              padding: const EdgeInsets.all(Dimensions.spacingM),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radiusM),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          Icons.scale,
                          color: info['color'] as Color,
                          size: Dimensions.iconM,
                        ),
                        const SizedBox(height: Dimensions.spacingXS),
                        Text(
                          info['weight'] as String,
                          style: TextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Poids max',
                          style: TextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: AppColors.border,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          Icons.straighten,
                          color: info['color'] as Color,
                          size: Dimensions.iconM,
                        ),
                        const SizedBox(height: Dimensions.spacingXS),
                        Text(
                          info['dimensions'] as String,
                          style: TextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Dimensions max',
                          style: TextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
