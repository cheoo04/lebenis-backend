import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'network/dio_client.dart';
import 'services/auth_service.dart';
import '../data/providers/auth_provider.dart';
import 'services/upload_service.dart';
import 'services/pdf_report_service.dart';
import 'services/notification_service.dart';
import 'constants/api_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  return dio;
});

final dioClientProvider = Provider<DioClient>((ref) {
  final authService = ref.watch(authServiceProvider);
  final dio = ref.watch(dioProvider);
  
  // Ajouter un intercepteur pour inclure le token JWT automatiquement
  dio.interceptors.clear(); // Nettoyer les anciens intercepteurs
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Ne pas ajouter le token pour les endpoints publics
        final publicEndpoints = ['/auth/register/', '/auth/login/', '/auth/refresh/'];
        final isPublicEndpoint = publicEndpoints.any((endpoint) => options.path.contains(endpoint));
        
        if (!isPublicEndpoint) {
          final token = await authService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Si erreur 401, essayer de rafraîchir le token
        if (error.response?.statusCode == 401) {
          try {
            final newToken = await authService.refreshAccessToken();
            if (newToken != null && newToken.isNotEmpty) {
              // Réessayer la requête avec le nouveau token
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              final response = await dio.fetch(error.requestOptions);
              return handler.resolve(response);
            }
          } catch (e) {
            // Si le refresh échoue, déconnecter l'utilisateur via le provider
            try {
              await ref.read(authStateProvider.notifier).logout();
            } catch (_) {
              // Fallback: clear tokens directly
              await authService.logout();
            }
          }
        }
        return handler.next(error);
      },
    ),
  );
  
  return DioClient(dio);
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final uploadServiceProvider = Provider<UploadService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return UploadService(dioClient);
});

final pdfReportServiceProvider = Provider<PDFReportService>((ref) {
  return PDFReportService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return NotificationService(dioClient);
});
