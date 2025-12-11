// driver_app/lib/features/profile/presentation/screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../zones/presentation/screens/zone_selection_screen.dart';
import '../../../../core/constants/backend_constants.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../data/providers/driver_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../shared/widgets/modern_button.dart';
import '../../../../shared/widgets/modern_card.dart';
import '../../../../shared/widgets/modern_list_tile.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/utils/formatters.dart';
import '../../../../shared/utils/helpers.dart';
import '../widgets/availability_toggle.dart';
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
      // ignore: unused_result
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

    // Gérer le cas où le driver est null après chargement (erreur/token expiré)
    // Rediriger automatiquement vers la page de connexion
    if (!driverState.isLoading && driver == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authProvider.notifier).logout();
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      });
      
      return const Scaffold(
        body: LoadingWidget(message: 'Session expirée, redirection...'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mon Profil'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
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
          padding: const EdgeInsets.all(AppSpacing.screenPaddingHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              
              // Photo de profil
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        child: ClipOval(
                          child: driver?.profilePhoto != null
                              ? (driver!.profilePhoto!.startsWith('http://') || driver.profilePhoto!.startsWith('https://'))
                                  ? Image.network(
                                      '${driver.profilePhoto!}?cb=${DateTime.now().millisecondsSinceEpoch}',
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.person_outline,
                                          size: 60,
                                          color: AppColors.primary,
                                        );
                                      },
                                    )
                                  : driver.profilePhoto!.startsWith('file://')
                                      ? Image.file(
                                          File(Uri.parse(driver.profilePhoto!).toFilePath()),
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(Icons.person_outline, size: 60, color: AppColors.primary)
                              : Icon(Icons.person_outline, size: 60, color: AppColors.primary),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.textWhite,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Nom
              Text(
                driver?.user.fullName ?? 'Nom non disponible',
                style: AppTypography.h2,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.sm),

              // Email & Phone
              Text(
                driver?.user.email ?? '',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                Formatters.formatPhoneNumber(driver?.phone ?? ''),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Toggle de disponibilité
              const AvailabilityToggle(),

              const SizedBox(height: AppSpacing.xl),

              // Statistiques
              ModernSectionHeader(title: 'Statistiques'),

              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: ModernStatCard(
                      icon: Icons.star_outline,
                      label: 'Note',
                      value: (driver?.rating ?? 0.0).toStringAsFixed(1),
                      color: AppColors.yellow,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ModernStatCard(
                      icon: Icons.local_shipping_outlined,
                      label: 'Livraisons',
                      value: '${stats?['total_deliveries'] ?? 0}',
                      color: AppColors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: ModernStatCard(
                      icon: Icons.check_circle_outline,
                      label: 'Complétées',
                      value: '${stats?['completed_deliveries'] ?? 0}',
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ModernStatCard(
                      icon: Icons.attach_money,
                      label: 'Gains',
                      value: Formatters.formatPrice((stats?['total_earnings'] ?? 0).toDouble()),
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Informations du véhicule
              ModernSectionHeader(title: 'Véhicule'),

              const SizedBox(height: AppSpacing.md),

              ModernCard(
                child: Column(
                  children: [
                    ModernInfoRow(
                      icon: driver?.vehicleType != null 
                        ? BackendConstants.getVehicleTypeIcon(driver!.vehicleType)
                        : Icons.local_shipping_outlined,
                      label: 'Type',
                      value: driver?.vehicleTypeLabel ?? 'Non défini',
                    ),
                    if (driver?.vehicleRegistration != null) ...[
                      Divider(height: AppSpacing.lg, color: AppColors.border),
                      ModernInfoRow(
                        icon: Icons.confirmation_number_outlined,
                        label: 'Immatriculation',
                        value: driver?.vehicleRegistration ?? '',
                      ),
                    ],
                    Divider(height: AppSpacing.lg, color: AppColors.border),
                    ModernInfoRow(
                      icon: Icons.scale_outlined,
                      label: 'Capacité de charge',
                      value: '${driver?.vehicleCapacityKg ?? 0} kg',
                    ),
                  ],
                ),
              ),
              
              // Capacités du véhicule (info visuelle)
              if (driver?.vehicleType != null) ...[
                const SizedBox(height: AppSpacing.md),
                VehicleCapacityCard(vehicleType: driver!.vehicleType),
              ],

              const SizedBox(height: AppSpacing.xl),

              // Bouton gestion des zones de travail
              ModernButton(
                text: 'Mes zones de travail',
                onPressed: _goToZones,
                icon: Icons.map_outlined,
                type: ModernButtonType.secondary,
                size: ModernButtonSize.large,
                fullWidth: true,
              ),

              // Actions
              const SizedBox(height: AppSpacing.lg),
              ModernButton(
                text: 'Déconnexion',
                icon: Icons.logout,
                type: ModernButtonType.danger,
                size: ModernButtonSize.large,
                fullWidth: true,
                onPressed: _logout,
              ),
              
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
