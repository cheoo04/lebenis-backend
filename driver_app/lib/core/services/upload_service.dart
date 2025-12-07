// lib/core/services/upload_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import '../network/dio_client.dart';

class UploadService {
  final DioClient _dioClient;
  final ImagePicker _picker = ImagePicker();

  UploadService(this._dioClient);

  /// Sélectionner une image depuis la galerie
  Future<File?> pickImageFromGallery({
    int imageQuality = 85,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      if (kDebugMode) print('Erreur sélection image: $e');
      return null;
    }
  }

  /// Prendre une photo avec la caméra
  Future<File?> takePicture({
    int imageQuality = 85,
    double? maxWidth,
    double? maxHeight,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      if (kDebugMode) print('Erreur capture photo: $e');
      return null;
    }
  }

  /// Afficher un dialog de choix entre caméra et galerie
  Future<File?> pickImageWithDialog({
    required Future<String?> Function() showDialog,
    int imageQuality = 85,
  }) async {
    final choice = await showDialog();
    
    if (choice == null) return null;

    if (choice == 'camera') {
      return await takePicture(imageQuality: imageQuality);
    } else if (choice == 'gallery') {
      return await pickImageFromGallery(imageQuality: imageQuality);
    }

    return null;
  }

  /// Créer un MultipartFile pour l'upload
  Future<MultipartFile> createMultipartFile(
    String filePath, {
    String? filename,
  }) async {
    final fileName = filename ?? path.basename(filePath);
    return await MultipartFile.fromFile(
      filePath,
      filename: fileName,
    );
  }

  /// Upload un fichier unique
  Future<Map<String, dynamic>> uploadSingleFile({
    required String endpoint,
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalData,
    void Function(int sent, int total)? onProgress,
  }) async {
    final response = await _dioClient.post(
      endpoint,
      data: FormData.fromMap({
        fieldName: await createMultipartFile(filePath),
        if (additionalData != null) ...additionalData,
      }),
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );

    return response.data as Map<String, dynamic>;
  }

  /// Upload plusieurs fichiers
  Future<Map<String, dynamic>> uploadMultipleFiles({
    required String endpoint,
    required Map<String, String> files, // fieldName: filePath
    Map<String, dynamic>? additionalData,
    void Function(int sent, int total)? onProgress,
  }) async {
    final Map<String, dynamic> formDataMap = {};

    // Ajouter tous les fichiers
    for (var entry in files.entries) {
      formDataMap[entry.key] = await createMultipartFile(entry.value);
    }

    // Ajouter les données additionnelles
    if (additionalData != null) {
      formDataMap.addAll(additionalData);
    }

    final response = await _dioClient.post(
      endpoint,
      data: FormData.fromMap(formDataMap),
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );

    return response.data as Map<String, dynamic>;
  }

  /// Upload avec retry automatique en cas d'échec
  Future<Map<String, dynamic>> uploadWithRetry({
    required String endpoint,
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalData,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
    void Function(int sent, int total)? onProgress,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        return await uploadSingleFile(
          endpoint: endpoint,
          filePath: filePath,
          fieldName: fieldName,
          additionalData: additionalData,
          onProgress: onProgress,
        );
      } catch (e) {
        lastException = e as Exception;
        attempts++;
        
        if (attempts < maxRetries) {
          if (kDebugMode) {
          }
          await Future.delayed(retryDelay);
        }
      }
    }

    throw lastException ?? Exception('Upload échoué après $maxRetries tentatives');
  }

  /// Vérifier la taille d'un fichier
  bool isFileSizeValid(File file, int maxSizeMB) {
    final fileSizeInBytes = file.lengthSync();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    return fileSizeInMB <= maxSizeMB;
  }

  /// Obtenir la taille d'un fichier en MB
  double getFileSizeInMB(File file) {
    final fileSizeInBytes = file.lengthSync();
    return fileSizeInBytes / (1024 * 1024);
  }

  /// Vérifier si un fichier est une image
  bool isImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(extension);
  }

  /// Vérifier si un fichier est un PDF
  bool isPdfFile(String filePath) {
    return path.extension(filePath).toLowerCase() == '.pdf';
  }
}
