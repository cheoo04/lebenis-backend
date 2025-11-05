// lib/core/routes/app_router.dart

import 'package:flutter/material.dart';

// Import des écrans
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/deliveries/presentation/screens/delivery_list_screen.dart';
import '../../features/deliveries/presentation/screens/delivery_details_screen.dart';
import '../../features/deliveries/presentation/screens/active_delivery_screen.dart';
import '../../features/deliveries/presentation/screens/confirm_delivery_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/earnings/presentation/screens/earnings_screen.dart';
import '../../features/scanner/presentation/screens/qr_scanner_screen.dart';
import '../../data/models/delivery_model.dart';

/// Gestion des routes de l'application
class AppRouter {
  // ========== ROUTES NOMMÉES ==========
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String deliveryList = '/deliveries';
  static const String deliveryDetails = '/delivery-details';
  static const String activeDelivery = '/active-delivery';
  static const String confirmDelivery = '/confirm-delivery';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String earnings = '/earnings';
  static const String qrScanner = '/qr-scanner';
  static const String settings = '/settings';

  // ========== GÉNÉRATEUR DE ROUTES ==========
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      case deliveryList:
        return MaterialPageRoute(
          builder: (_) => const DeliveryListScreen(),
        );

      case deliveryDetails:
        final delivery = settings.arguments as DeliveryModel?;
        if (delivery == null) {
          return MaterialPageRoute(
            builder: (_) => const PlaceholderScreen(title: 'Erreur: Livraison non trouvée'),
          );
        }
        return MaterialPageRoute(
          builder: (_) => DeliveryDetailsScreen(delivery: delivery),
        );

      case activeDelivery:
        final delivery = settings.arguments as DeliveryModel?;
        if (delivery == null) {
          return MaterialPageRoute(
            builder: (_) => const PlaceholderScreen(title: 'Erreur: Livraison non trouvée'),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ActiveDeliveryScreen(delivery: delivery),
        );

      case confirmDelivery:
        final delivery = settings.arguments as DeliveryModel?;
        if (delivery == null) {
          return MaterialPageRoute(
            builder: (_) => const PlaceholderScreen(title: 'Erreur: Livraison non trouvée'),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ConfirmDeliveryScreen(delivery: delivery),
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );

      case editProfile:
        return MaterialPageRoute(
          builder: (_) => const EditProfileScreen(),
        );

      case earnings:
        return MaterialPageRoute(
          builder: (_) => const EarningsScreen(),
        );

      case qrScanner:
        final callback = settings.arguments as Function(String)?;
        return MaterialPageRoute(
          builder: (_) => QRScannerScreen(
            onCodeScanned: callback ?? (code) {},
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const PlaceholderScreen(title: '404 Not Found'),
        );
    }
  }

  // ========== NAVIGATION HELPERS ==========

  /// Naviguer vers une route
  static Future<T?> push<T>(BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Remplacer la route actuelle
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      arguments: arguments,
      result: result,
    );
  }

  /// Retourner à l'accueil (supprime tout le stack)
  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Retour arrière
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }
}

// ========== ÉCRAN TEMPORAIRE (SPLASH) ==========

class TemporarySplashScreen extends StatefulWidget {
  const TemporarySplashScreen({super.key});

  @override
  State<TemporarySplashScreen> createState() => _TemporarySplashScreenState();
}

class _TemporarySplashScreenState extends State<TemporarySplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      // La vraie vérification se fait dans SplashScreen avec AuthService
      AppRouter.pushReplacement(context, AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E88E5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.delivery_dining,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'LeBeni\'s Driver',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Livraison Rapide & Sécurisée',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== ÉCRAN PLACEHOLDER ==========

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Écran en cours de développement',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
