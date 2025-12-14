import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/user_profile_provider.dart';
import '../../../../data/models/merchant_model.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/text_styles.dart';

class SplashScreen extends ConsumerStatefulWidget {
	const SplashScreen({super.key});

	@override
	ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

	@override
	void initState() {
		super.initState();
    _setupAnimations();
		WidgetsBinding.instance.addPostFrameCallback((_) {
			_checkAuthAndRedirect();
		});
	}

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

	Future<void> _checkAuthAndRedirect() async {
    // Attendre que l'animation soit visible
    await Future.delayed(const Duration(milliseconds: 2500));
    
		try {
			final auth = ref.read(authStateProvider);
			
			// Si pas connecté, aller sur login
			if (auth.value == null) {
				if (mounted) Navigator.pushReplacementNamed(context, '/login');
				return;
			}
			
		// Charger le profil utilisateur (merchant ou individual)
		await ref.read(userProfileProvider.notifier).loadProfile();
		
		// Attendre un peu plus pour que le provider soit mis à jour
		await Future.delayed(const Duration(milliseconds: 300));
		
		final profileState = ref.read(userProfileProvider);
		
		// Gérer les erreurs de chargement du profil
		if (profileState.hasError) {
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(
						content: Text('Erreur: ${profileState.error}'),
						backgroundColor: Colors.red,
						duration: const Duration(seconds: 3),
					),
				);
				await Future.delayed(const Duration(seconds: 1));
				Navigator.pushReplacementNamed(context, '/login');
			}
			return;
		}
		
		if (profileState.value == null) {
				if (mounted) Navigator.pushReplacementNamed(context, '/login');
				return;
			}
			
			final profile = profileState.value!;
			
			// Cas merchant: vérifier le statut de vérification
			if (profile is MerchantModel) {
				
				if (profile.verificationStatus == 'approved' || profile.verificationStatus == 'verified') {
					if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
				} else if (profile.verificationStatus == 'pending') {
					if (mounted) Navigator.pushReplacementNamed(context, '/waiting-approval');
				} else if (profile.verificationStatus == 'rejected') {
					if (mounted) Navigator.pushReplacementNamed(context, '/rejected');
				} else {
					if (mounted) Navigator.pushReplacementNamed(context, '/login');
				}
			} else {
				// Cas particulier: aller directement au dashboard
				if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
			}
		} catch (e) {
			if (mounted) Navigator.pushReplacementNamed(context, '/login');
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
      backgroundColor: AppColors.background,
			body: SafeArea(
				child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Logo en haut
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        margin: const EdgeInsets.only(top: 24),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/logo_lebeni_business2.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.store,
                                size: 40,
                                color: AppColors.primary,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Illustration centrale
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icône boutique moderne
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.storefront_outlined,
                                    size: 64,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Décorations stylisées
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildDecoIcon(Icons.inventory_2_outlined, AppColors.success),
                                    const SizedBox(width: 32),
                                    _buildDecoIcon(Icons.local_shipping_outlined, AppColors.accent),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Texte et loader
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          // Titre
                          Text(
                            'LeBenis Business',
                            style: TextStyles.title.copyWith(
                              color: AppColors.primary,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),

                          // Sous-titre
                          Text(
                            'Gérez vos livraisons en toute simplicité',
                            style: TextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),

                          // Loading indicator
                          const SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
			),
		);
	}

  /// Icône décorative
  Widget _buildDecoIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        size: 24,
        color: color,
      ),
    );
  }
}
