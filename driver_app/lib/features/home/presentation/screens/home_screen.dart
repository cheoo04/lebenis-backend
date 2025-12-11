import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_screen.dart';
import 'waiting_verification_screen.dart';
import '../../../deliveries/presentation/screens/delivery_list_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../earnings/presentation/screens/earnings_screen.dart';
import '../../../chat/screens/conversations_list_screen.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../data/providers/driver_provider.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Écran principal avec navigation moderne par tabs
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final int _currentIndex = 0;
  bool _hasAttemptedLoad = false; // Track if we've tried to load the profile

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
        return; // Don't continue if not logged in
      }
      // Charger le profil du driver dès l'ouverture pour éviter un affichage
      // temporaire du dashboard avant que le provider soit initialisé.
      try {
        await ref.read(driverProvider.notifier).loadProfile();
        await ref.read(driverProvider.notifier).loadStats();
      } catch (_) {
        // Ignorer les erreurs ici; l'écran gérera l'état d'erreur via le provider
      }
      
      // Mark that we've attempted to load
      if (mounted) {
        setState(() {
          _hasAttemptedLoad = true;
        });
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

    // Si on est en train de charger le profil et qu'il n'existe pas encore,
    // afficher un écran de chargement pour éviter le "flash" du profil.
    if (driverState.isLoading && driverState.driver == null) {
      return const Scaffold(
        body: LoadingWidget(message: 'Chargement du profil...'),
      );
    }
    
    // Si on n'a pas encore tenté de charger le profil, attendre
    if (!_hasAttemptedLoad && driverState.driver == null) {
      return const Scaffold(
        body: LoadingWidget(message: 'Chargement du profil...'),
      );
    }

    // Si le chargement est terminé ET on a tenté de charger ET le driver est null,
    // c'est une vraie erreur (token expiré, compte supprimé, etc.)
    if (_hasAttemptedLoad && !driverState.isLoading && driverState.driver == null) {
      // Utiliser addPostFrameCallback pour éviter les erreurs de navigation pendant le build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authProvider.notifier).logout();
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      });
      
      return const Scaffold(
        body: LoadingWidget(message: 'Session expirée, redirection...'),
      );
    }

    // Si le driver existe mais n'est pas vérifié, afficher l'écran d'attente
    if (driverState.driver != null && !driverState.driver!.isVerified) {
      return const WaitingVerificationScreen();
    }
    
    return Scaffold(
      body: _buildCurrentScreen(),
    );
  }
}
