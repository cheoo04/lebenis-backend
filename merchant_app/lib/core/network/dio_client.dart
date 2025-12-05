import 'package:dio/dio.dart';
import 'api_exception.dart';

class DioClient {
  final Dio dio;

  DioClient(this.dio);

  String _formatErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Le serveur ne répond pas. Vérifiez votre connexion internet.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        
        // Gérer les erreurs de validation Django
        if (data is Map<String, dynamic>) {
          final errors = <String>[];
          data.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              if (key == 'email') {
                errors.add('Email déjà utilisé');
              } else if (key == 'phone') {
                errors.add('Numéro de téléphone déjà utilisé');
              } else if (key == 'password' || key == 'password2') {
                errors.add(value[0].toString());
              } else if (key == 'detail' || key == 'non_field_errors') {
                errors.add(value[0].toString());
              } else {
                errors.add('${key}: ${value[0]}');
              }
            } else if (value is String) {
              if (key == 'detail') {
                errors.add(value);
              } else {
                errors.add('${key}: $value');
              }
            }
          });
          if (errors.isNotEmpty) {
            return errors.join('\n');
          }
        } else if (data is String) {
          return data;
        }
        
        // Messages par défaut selon le code HTTP
        if (statusCode == 400) return 'Données invalides. Vérifiez vos informations.';
        if (statusCode == 401) return 'Email ou mot de passe incorrect.';
        if (statusCode == 403) return 'Accès refusé.';
        if (statusCode == 404) return 'Service non trouvé.';
        if (statusCode == 500) return 'Erreur serveur. Réessayez plus tard.';
        return 'Erreur serveur (code $statusCode)';
      case DioExceptionType.cancel:
        return 'Requête annulée';
      case DioExceptionType.connectionError:
        return 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
      case DioExceptionType.badCertificate:
        return 'Erreur de certificat de sécurité';
      case DioExceptionType.unknown:
      default:
        if (e.error?.toString().contains('SocketException') ?? false) {
          return 'Pas de connexion internet';
        }
        return e.message ?? 'Erreur de connexion au serveur';
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw ApiException(
        _formatErrorMessage(e),
        code: e.response?.statusCode ?? 0,
        details: e.response?.data,
      );
    }
  }

  Future<Response> post(String path, {dynamic data, Options? options}) async {
    try {
      return await dio.post(path, data: data, options: options);
    } on DioException catch (e) {
      throw ApiException(
        _formatErrorMessage(e),
        code: e.response?.statusCode ?? 0,
        details: e.response?.data,
      );
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await dio.patch(path, data: data);
    } on DioException catch (e) {
      throw ApiException(
        _formatErrorMessage(e),
        code: e.response?.statusCode ?? 0,
        details: e.response?.data,
      );
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await dio.delete(path);
    } on DioException catch (e) {
      throw ApiException(
        _formatErrorMessage(e),
        code: e.response?.statusCode ?? 0,
        details: e.response?.data,
      );
    }
  }

  Future<Response> upload(String path, {required FormData data}) async {
    try {
      return await dio.post(path, data: data);
    } on DioException catch (e) {
      throw ApiException(
        _formatErrorMessage(e),
        code: e.response?.statusCode ?? 0,
        details: e.response?.data,
      );
    }
  }

  /// Download a file to local storage
  Future<Response> download(
    String path,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await dio.download(
        path,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException(
        _formatErrorMessage(e),
        code: e.response?.statusCode ?? 0,
        details: e.response?.data,
      );
    }
  }
}
