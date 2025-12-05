import 'package:flutter/material.dart';
// ...existing code imports for your screens...
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/deliveries/presentation/screens/delivery_list_screen.dart';
import '../../features/deliveries/presentation/screens/create_delivery_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/waiting_approval_screen.dart';
import '../../features/auth/presentation/screens/rejected_screen.dart';
import '../../features/profile/presentation/screens/upload_documents_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
      switch (settings.name) {
        case '/':
          return MaterialPageRoute(builder: (_) => const SplashScreen());
        case '/login':
          return MaterialPageRoute(builder: (_) => const LoginScreen());
        case '/register':
          return MaterialPageRoute(builder: (_) => const RegisterScreen());
        case '/dashboard':
          return MaterialPageRoute(builder: (_) => const DashboardScreen());
        case '/profile':
          return MaterialPageRoute(builder: (_) => const ProfileScreen());
        case '/upload-documents':
          return MaterialPageRoute(builder: (_) => const UploadDocumentsScreen());
        case '/deliveries':
          return MaterialPageRoute(builder: (_) => const DeliveryListScreen());
        case '/create-delivery':
          return MaterialPageRoute(builder: (_) => const CreateDeliveryScreen());
        case '/waiting-approval':
          return MaterialPageRoute(builder: (_) => const WaitingApprovalScreen());
        case '/rejected':
          return MaterialPageRoute(builder: (_) => const RejectedScreen());
        default:
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              body: Center(
                child: Text('Route ${settings.name} non trouvée'),
              ),
            ),
          );
      }
  }
}
