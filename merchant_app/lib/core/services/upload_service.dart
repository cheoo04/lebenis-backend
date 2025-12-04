import 'dart:io';
import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../constants/api_constants.dart';

class UploadService {
  final DioClient _dioClient;

  UploadService(this._dioClient);

  /// Upload un document vers Cloudinary (RCCM, ID, etc.)
  Future<String> uploadDocument({
    required File file,
    required String documentType, // 'rccm', 'id_card', 'license', etc.
  }) async {
    try {
      // Créer FormData pour l'upload multipart
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'upload_type': 'document',
        'document_type': documentType,
      });

      final response = await _dioClient.post(
        ApiConstants.cloudinaryUpload,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      // Le backend retourne: {"url": "https://...", "upload_type": "document"}
      return response.data['url'] as String;
    } catch (e) {
      throw Exception('Erreur upload document: $e');
    }
  }

  /// Upload une photo de profil
  Future<String> uploadProfilePhoto({
    required File file,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'upload_type': 'profile_photo',
      });

      final response = await _dioClient.post(
        ApiConstants.cloudinaryUpload,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      return response.data['url'] as String;
    } catch (e) {
      throw Exception('Erreur upload photo: $e');
    }
  }

  /// Upload une image pour le chat
  Future<String> uploadChatImage({
    required File file,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'upload_type': 'chat_image',
      });

      final response = await _dioClient.post(
        ApiConstants.cloudinaryUpload,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      return response.data['url'] as String;
    } catch (e) {
      throw Exception('Erreur upload image: $e');
    }
  }
}
