import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import '../network/dio_client.dart';

/// Service pour upload d'images vers Cloudinary via le backend
class CloudinaryService {
  final DioClient _dioClient;

  CloudinaryService({required DioClient dioClient}) : _dioClient = dioClient;

  /// Upload une image de chat
  /// 
  /// Args:
  ///   - imagePath: Chemin local de l'image
  ///   - onProgress: Callback pour suivre la progression (0.0 à 1.0)
  /// 
  /// Returns:
  ///   URL Cloudinary de l'image uploadée


  /// Supprimer un document (assurance, carte grise, permis, etc.)
  Future<bool> deleteDocument(String documentType) async {
    try {
      final response = await _dioClient.delete(
        '/api/v1/cloudinary/delete/',
        data: {'document_type': documentType},
      );
      // On attend un booléen ou un champ 'success' dans la réponse
      if (response.data is Map && response.data['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String> uploadChatImage(
    String imagePath, {
    Function(double)? onProgress,
  }) async {
    try {
      final file = File(imagePath);
      
      // Vérifier que le fichier existe
      if (!await file.exists()) {
        throw Exception('Fichier introuvable: $imagePath');
      }

      // Vérifier la taille (max 10MB)
      final fileSize = await file.length();
      const maxSize = 10 * 1024 * 1024; // 10MB
      if (fileSize > maxSize) {
        throw Exception(
          'Image trop volumineuse (${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB). '
          'Taille maximale: 10MB',
        );
      }

      // Préparer FormData
      final fileName = path.basename(imagePath);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: fileName,
        ),
        'upload_type': 'chat_image',
      });

      // Upload avec suivi de progression
      final response = await _dioClient.post(
        '/api/v1/cloudinary/upload/',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
      );

      // Récupérer l'URL
      final imageUrl = response.data['url'] as String?;
      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception('URL de l\'image non retournée par le serveur');
      }

      return imageUrl;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Erreur lors de l\'upload: $e');
    }
  }

  /// Upload une photo de profil
  ///
  /// ⚠️ Le preset/dossier Cloudinary pour la photo de profil est géré côté backend.
  /// Ne pas spécifier de preset côté Flutter pour ce type d'upload.
  Future<String> uploadProfilePhoto(
    String imagePath, {
    Function(double)? onProgress,
  }) async {
    try {
      final file = File(imagePath);
      
      if (!await file.exists()) {
        throw Exception('Fichier introuvable: $imagePath');
      }

      final fileSize = await file.length();
      const maxSize = 5 * 1024 * 1024; // 5MB pour profil
      if (fileSize > maxSize) {
        throw Exception(
          'Image trop volumineuse (${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB). '
          'Taille maximale: 5MB',
        );
      }

      final fileName = path.basename(imagePath);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagePath,
          filename: fileName,
        ),
        'upload_type': 'profile_photo',
      });

      final response = await _dioClient.post(
        '/api/v1/cloudinary/upload/',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
      );

      final imageUrl = response.data['url'] as String?;
      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception('URL de l\'image non retournée par le serveur');
      }

      return imageUrl;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Erreur lors de l\'upload: $e');
    }
  }

  /// Upload un document (permis, carte d'identité, etc.)
  Future<String> uploadDocument(
    String filePath,
    String documentType, {
    Function(double)? onProgress,
  }) async {
    try {
      final file = File(filePath);
      
      if (!await file.exists()) {
        throw Exception('Fichier introuvable: $filePath');
      }

      final fileSize = await file.length();
      const maxSize = 10 * 1024 * 1024; // 10MB
      if (fileSize > maxSize) {
        throw Exception(
          'Fichier trop volumineux (${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB). '
          'Taille maximale: 10MB',
        );
      }

      final fileName = path.basename(filePath);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
        'upload_type': 'document',
        'document_type': documentType,
      });

      final response = await _dioClient.post(
        '/api/v1/cloudinary/upload/',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
      );

      // Correction : robustesse du parsing
      final data = response.data;
      if (data is Map && data['url'] is String) {
        final fileUrl = data['url'] as String;
        if (fileUrl.isEmpty) {
          throw Exception('URL du fichier vide dans la réponse serveur');
        }
        return fileUrl;
      } else {
        // Log de debug pour comprendre la structure inattendue
        throw Exception("Réponse inattendue du serveur lors de l'upload: ${data.toString()}");
      }
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception('Erreur lors de l\'upload: $e');
    }
  }

  /// Gestion des erreurs Dio
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Délai d\'attente dépassé. Vérifiez votre connexion.');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['error'] ?? 
                       error.response?.data?['message'] ??
                       'Erreur serveur';
        
        if (statusCode == 413) {
          return Exception('Fichier trop volumineux');
        } else if (statusCode == 415) {
          return Exception('Type de fichier non supporté');
        }
        return Exception('Erreur $statusCode: $message');

      case DioExceptionType.cancel:
        return Exception('Upload annulé');

      case DioExceptionType.connectionError:
        return Exception('Erreur de connexion. Vérifiez votre réseau.');

      default:
        return Exception('Erreur inattendue: ${error.message}');
    }
  }
}
