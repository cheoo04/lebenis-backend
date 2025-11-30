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
import '../widgets/stat_card.dart';
import '../widgets/info_row.dart';
import '../widgets/vehicle_capacity_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}



class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
                    child: StatCard(
                      icon: Icons.star,
                      iconColor: AppColors.warning,
                      label: 'Note',
                      value: (driver?.rating ?? 0.0).toStringAsFixed(1),
                    ),
                  ),
                  const SizedBox(width: Dimensions.spacingM),
                  Expanded(
                    child: StatCard(
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
                    child: StatCard(
                      icon: Icons.check_circle,
                      iconColor: AppColors.success,
                      label: 'Complétées',
                      value: '${stats?['completed_deliveries'] ?? 0}',
                    ),
                  ),
                  const SizedBox(width: Dimensions.spacingM),
                  Expanded(
                    child: StatCard(
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
                      InfoRow(
                        icon: driver?.vehicleType != null 
                          ? BackendConstants.getVehicleTypeIcon(driver!.vehicleType)
                          : Icons.local_shipping,
                        label: 'Type',
                        value: driver?.vehicleTypeLabel ?? 'Non défini',
                      ),
                      if (driver?.vehicleRegistration != null) ...[
                        const Divider(),
                        InfoRow(
                          icon: Icons.confirmation_number,
                          label: 'Immatriculation',
                          value: driver?.vehicleRegistration ?? '',
                        ),
                      ],
                      const Divider(),
                      InfoRow(
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
                VehicleCapacityCard(vehicleType: driver!.vehicleType),
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
              const SizedBox(height: Dimensions.spacingXL),
              CustomButton(
                text: 'Déconnexion',
                icon: Icons.logout,
                type: ButtonType.danger,
                onPressed: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
