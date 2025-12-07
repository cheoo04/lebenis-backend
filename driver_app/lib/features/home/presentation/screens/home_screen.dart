import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_screen.dart';
import 'waiting_verification_screen.dart';
import '../../../deliveries/presentation/screens/delivery_list_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../earnings/presentation/screens/earnings_screen.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../chat/screens/conversations_list_screen.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../data/providers/driver_provider.dart';

/// Écran principal avec navigation moderne par tabs
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Vérifier l'authentification au chargement
    Future.microtask(() async {
      // D'abord, vérifier le statut de connexion
      await ref.read(authProvider.notifier).checkLoginStatus();
      
      final authState = ref.read(authProvider);
      if (!authState.isLoggedIn) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    });
    
    // Écouter les changements d'état d'authentification
    ref.listenManual(authProvider, (previous, next) {
      if (previous?.isLoggedIn == true && next.isLoggedIn == false) {
        // L'utilisateur s'est déconnecté (token invalide, logout, etc.)
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    });
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const DeliveryListScreen();
      case 2:
        return const ConversationsListScreen();
      case 3:
        return const EarningsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final driverState = ref.watch(driverProvider);
    
    // Si le driver n'est pas vérifié, afficher l'écran d'attente
    if (driverState.driver != null && !driverState.driver!.isVerified) {
      return const WaitingVerificationScreen();
    }
    
    return Scaffold(
      body: _buildCurrentScreen(),
    );
  }
}
