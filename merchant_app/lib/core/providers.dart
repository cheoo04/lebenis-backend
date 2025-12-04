import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'network/dio_client.dart';
import 'services/auth_service.dart';
import 'services/upload_service.dart';
import 'services/pdf_report_service.dart';
import 'services/notification_service.dart';
import 'constants/api_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
  return dio;
});

final dioClientProvider = Provider<DioClient>((ref) {
  final dio = ref.watch(dioProvider);
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
  final dioClient = ref.watch(dioClientProvider);
  return PDFReportService(dioClient);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return NotificationService(dioClient);
});
