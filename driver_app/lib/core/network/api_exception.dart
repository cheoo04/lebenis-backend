// lib/core/network/api_exception.dart

import 'package:dio/dio.dart';

/// Classe d'exception personnalisée pour gérer toutes les erreurs API
/// Transforme les erreurs Dio en messages compréhensibles en français
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final DioExceptionType? type;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
    this.type,
  });

  /// Factory pour créer une ApiException depuis une DioException
  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connexion trop lente. Vérifiez votre réseau.',
          statusCode: null,
          type: error.type,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Pas de connexion internet. Vérifiez votre connexion.',
          statusCode: null,
          type: error.type,
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Requête annulée',
          statusCode: null,
          type: error.type,
        );

      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'Certificat SSL invalide',
          statusCode: null,
          type: error.type,
        );

      case DioExceptionType.unknown:
        return ApiException(
          message: 'Erreur réseau inattendue. Réessayez.',
          statusCode: null,
          type: error.type,
        );
    }
  }

  /// Gère les réponses HTTP avec erreur (4xx, 5xx)
  static ApiException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    // Extraction du message d'erreur depuis le backend
    String errorMessage = 'Erreur inconnue';
    
    if (data is Map<String, dynamic>) {
      // Cas spécial: erreurs de validation Django (status 400)
      if (statusCode == 400 && !data.containsKey('message') && !data.containsKey('detail')) {
        // C'est probablement un objet de validation errors de Django
        final errors = <String>[];
        data.forEach((field, value) {
          if (value is List && value.isNotEmpty) {
            // Messages personnalisés pour les champs courants
            if (field == 'email') {
              errors.add('Email existe déjà');
            } else if (field == 'phone') {
              errors.add('Numéro de téléphone existe déjà');
            } else if (field == 'password' || field == 'password2') {
              for (var err in value) {
                errors.add(err.toString());
              }
            } else if (field == 'non_field_errors') {
              for (var err in value) {
                errors.add(err.toString());
              }
            } else {
              for (var err in value) {
                errors.add(err.toString());
              }
            }
          } else if (value is String) {
            errors.add(value);
          }
        });
        if (errors.isNotEmpty) {
          errorMessage = errors.join('\n');
        }
      } else {
        // Essayer différentes clés possibles pour le message
        final rawMessage = data['message'] ?? 
                           data['error'] ?? 
                           data['detail'];
        
        if (rawMessage is String) {
          errorMessage = rawMessage;
        } else if (rawMessage is Map) {
          // Si c'est un objet de validation errors
          final firstKey = (rawMessage as Map<String, dynamic>).keys.first;
          final firstError = rawMessage[firstKey];
          
          if (firstError is List) {
            errorMessage = firstError.isNotEmpty ? firstError[0].toString() : errorMessage;
          } else {
            errorMessage = firstError.toString();
          }
        } else if (rawMessage is List && rawMessage.isNotEmpty) {
          errorMessage = rawMessage[0].toString();
        }
      }
    } else if (data is String) {
      errorMessage = data;
    }

    switch (statusCode) {
      case 400:
        return ApiException(
          message: errorMessage,
          statusCode: 400,
          data: data,
        );

      case 401:
        return ApiException(
          message: errorMessage.isNotEmpty && errorMessage != 'Erreur inconnue' 
              ? errorMessage 
              : 'Email ou mot de passe incorrect.',
          statusCode: 401,
          data: data,
        );

      case 403:
        return ApiException(
          message: 'Accès refusé. Vous n\'avez pas les permissions.',
          statusCode: 403,
          data: data,
        );

      case 404:
        return ApiException(
          message: 'Ressource introuvable',
          statusCode: 404,
          data: data,
        );

      case 422:
        return ApiException(
          message: 'Erreur de validation: $errorMessage',
          statusCode: 422,
          data: data,
        );

      case 429:
        return ApiException(
          message: 'Trop de requêtes. Patientez un moment.',
          statusCode: 429,
          data: data,
        );

      case 500:
        return ApiException(
          message: 'Erreur serveur. Réessayez plus tard.',
          statusCode: 500,
          data: data,
        );

      case 502:
      case 503:
      case 504:
        return ApiException(
          message: 'Service temporairement indisponible',
          statusCode: statusCode,
          data: data,
        );

      default:
        return ApiException(
          message: errorMessage.isNotEmpty 
              ? errorMessage 
              : 'Erreur HTTP ${statusCode ?? "inconnue"}',
          statusCode: statusCode,
          data: data,
        );
    }
  }

  /// Vérifie si l'erreur est liée à l'authentification
  bool get isAuthError => statusCode == 401 || statusCode == 403;

  /// Vérifie si l'erreur est liée au réseau
  bool get isNetworkError => type == DioExceptionType.connectionError ||
                             type == DioExceptionType.connectionTimeout;

  /// Vérifie si l'erreur est du côté serveur
  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  String toString() => message;
}
