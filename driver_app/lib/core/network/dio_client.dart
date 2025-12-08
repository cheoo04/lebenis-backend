// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../services/auth_service.dart';
import 'api_exception.dart';

class DioClient {
  late final Dio _dio;
  final AuthService _authService;
  final Future<void> Function()? onLogout;

  DioClient(this._authService, {this.onLogout}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Intercepteur pour JWT
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Ne pas envoyer le token pour les endpoints publics
    final publicEndpoints = [
      ApiConstants.login,
      ApiConstants.register,
      ApiConstants.refreshToken,
    ];
    
    final isPublicEndpoint = publicEndpoints.any((endpoint) => 
      options.path.contains(endpoint)
    );
    
    if (!isPublicEndpoint) {
      final token = await _authService.getAccessToken();
        // Ajout debug : debugPrint du token à chaque requête privée
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      } else {
      }
    }
    if (kDebugMode) {
      debugPrint('DioClient _onRequest: ${options.method} ${options.path} Authorization: ${options.headers['Authorization'] ?? 'none'}');
    }
    return handler.next(options);
  }

  Future<void> _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    // Vérifier si la réponse contient une erreur d'authentification
    if (response.data is Map) {
      final data = response.data as Map;
      final code = data['code'];
      
      // Si le token est invalide ou expiré
        if (code == 'token_not_valid' || code == 'token_expired') {
        if (onLogout != null) {
          await onLogout!();
        } else {
          await _authService.logout();
        }
        
        // Créer une DioException pour que l'app puisse la gérer
        return handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: 'Token invalide ou expiré',
          ),
        );
      }
    }
    
    return handler.next(response);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401) {
      try {
        // Récupérer le refresh token depuis le service d'auth
        final refreshToken = await _authService.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          await _authService.logout();
          return handler.reject(error);
        }

        // Appeler l'endpoint de refresh pour obtenir un nouvel access token
        final refreshResp = await _dio.post(
          ApiConstants.refreshToken,
          data: {'refresh': refreshToken},
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          }),
        );

        if (refreshResp.statusCode == 200 && refreshResp.data != null) {
          final data = refreshResp.data;
          final newAccess = data['access'] ?? data['access_token'] ?? data['tokens']?['access'];
          if (newAccess != null && newAccess.toString().isNotEmpty) {
            // Mettre à jour le token en local
            await _authService.updateAccessToken(newAccess.toString());

            // Réessayer la requête originale avec le nouveau token
            error.requestOptions.headers['Authorization'] = 'Bearer ${newAccess.toString()}';
            final clonedRequest = error.requestOptions.copyWith(
              headers: error.requestOptions.headers,
            );
            final response = await _dio.fetch(clonedRequest);
            return handler.resolve(response);
          }
        }

        // Si refresh échoue
        if (onLogout != null) {
          await onLogout!();
        } else {
          await _authService.logout();
        }
        return handler.reject(error);
      } catch (e) {
        if (onLogout != null) {
          await onLogout!();
        } else {
          await _authService.logout();
        }
        return handler.reject(error);
      }
    }
    return handler.next(error);
  }

  // HTTP Methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.patch(path, data: data, options: options);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
  }) async {
    try {
      return await _dio.delete(path, data: data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> uploadFile(
    String path, {
    String? filePath,
    Uint8List? fileBytes,
    String? filename,
    required String fieldName,
    Map<String, dynamic>? additionalData,
    ProgressCallback? onSendProgress,
    String method = 'POST', // Méthode HTTP (POST, PUT, PATCH)
  }) async {
    try {
      MultipartFile multipartFile;
      if (fileBytes != null) {
        multipartFile = MultipartFile.fromBytes(
          fileBytes,
          filename: filename ?? 'upload_file.png',
        );
      } else if (filePath != null) {
        multipartFile = await MultipartFile.fromFile(filePath);
      } else {
        throw Exception('No file data provided for uploadFile');
      }

      final formData = FormData.fromMap({
        fieldName: multipartFile,
        if (additionalData != null) ...additionalData,
      });
      
      // Utiliser la méthode HTTP spécifiée
      switch (method.toUpperCase()) {
        case 'PATCH':
          return await _dio.patch(path, data: formData, onSendProgress: onSendProgress);
        case 'PUT':
          return await _dio.put(path, data: formData, onSendProgress: onSendProgress);
        case 'POST':
        default:
          return await _dio.post(path, data: formData, onSendProgress: onSendProgress);
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Response> download(
    String urlPath,
    String savePath, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
