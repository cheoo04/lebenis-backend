import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';
import 'shared/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/services/notification_service.dart';
import 'core/routes/app_router.dart';

/// Handler pour les messages Firebase en arrière-plan
/// DOIT être une fonction top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    if (kDebugMode) {
      debugPrint('📩 Message reçu en arrière-plan: ${message.notification?.title}');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('⚠️ Erreur handler Firebase background: $e');
    }
  }
}

void main() async {
  // Initialisation Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Capturer toutes les erreurs Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('🔴 Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  // Initialisation Firebase (optionnel - nécessaire configuration par plateforme)
  // Firebase n'est pas supporté sur Linux/Desktop en développement
  bool firebaseInitialized = false;
  
  // Vérifier si la plateforme supporte Firebase
  final isFirebaseSupported = !kIsWeb && 
      (defaultTargetPlatform == TargetPlatform.android || 
       defaultTargetPlatform == TargetPlatform.iOS);
  
  if (isFirebaseSupported) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      firebaseInitialized = true;
      if (kDebugMode) {
        debugPrint('✅ Firebase initialisé');
      }

      // Handler notifications en arrière-plan
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Erreur Firebase: $e');
        debugPrint('💡 L\'application fonctionnera sans Firebase (notifications désactivées)');
      }
    }
  } else {
    if (kDebugMode) {
      debugPrint('⚠️ Firebase désactivé sur cette plateforme (${defaultTargetPlatform.name})');
      debugPrint('💡 L\'application fonctionnera sans notifications push');
    }
  }

  // Lancer l'app avec Riverpod
  runApp(
    ProviderScope(
      overrides: [
        // Passer l'état Firebase aux providers
        firebaseEnabledProvider.overrideWithValue(firebaseInitialized),
      ],
      child: const LeBenisDriverApp(),
    ),
  );
}

// Provider pour vérifier si Firebase est activé
final firebaseEnabledProvider = Provider<bool>((ref) => false);

class LeBenisDriverApp extends ConsumerStatefulWidget {
  const LeBenisDriverApp({super.key});

  @override
  ConsumerState<LeBenisDriverApp> createState() => _LeBenisDriverAppState();
}

class _LeBenisDriverAppState extends ConsumerState<LeBenisDriverApp> {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  /// Initialiser les notifications
  Future<void> _initializeNotifications() async {
    // Vérifier si Firebase est activé
    final firebaseEnabled = ref.read(firebaseEnabledProvider);
    if (!firebaseEnabled) {
      if (kDebugMode) {
        debugPrint('⚠️ Notifications désactivées (Firebase non configuré)');
      }
      return;
    }

    try {
      await _notificationService.initialize();
      if (kDebugMode) {
        debugPrint('✅ Notifications initialisées');
      }

      // Handler pour navigation après tap sur notification
      _notificationService.onNotificationTap = (data) {
        if (kDebugMode) {
          debugPrint('📩 Notification tappée: $data');
        }
        
        // Navigation selon le type de notification
        if (data.containsKey('type')) {
          switch (data['type']) {
            case 'new_delivery':
              // Naviguer vers la liste des livraisons
              Navigator.of(context).pushNamed('/deliveries');
              break;
            case 'delivery_update':
              // Naviguer vers le détail de la livraison
              if (data.containsKey('delivery_id')) {
                Navigator.of(context).pushNamed(
                  '/delivery-details',
                  arguments: data['delivery_id'],
                );
              }
              break;
            case 'earnings':
              // Naviguer vers les gains
              Navigator.of(context).pushNamed('/earnings');
              break;
            default:
              // Notification générique - rester sur l'écran actuel
              break;
          }
        }
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur init notifications: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // Thème personnalisé
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Routes
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
