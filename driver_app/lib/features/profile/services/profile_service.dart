import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../data/providers/driver_cni_upload_provider.dart';
import '../../../../data/providers/driver_provider.dart';

class ProfileService {

  /// Delete a vehicle document and update UI state via callback
  static Future<void> deleteVehicleDocument({
    required BuildContext context,
    required WidgetRef ref,
    required String type,
    required void Function(String? url, dynamic photo, Uint8List? bytes) onStateUpdate,
  }) async {
    try {
      // Call the provider to delete the document
      final success = await ref.read(driverCniUploadProvider).deleteDocument(documentType: type);
      if (!context.mounted) return;
      if (success) {
        // Update UI state: clear the document's url, photo, and bytes
        onStateUpdate(null, null, null);
        Helpers.showSuccessSnackBar(context, 'Document supprimé avec succès');
      } else {
        Helpers.showErrorSnackBar(context, 'Échec de la suppression du document');
      }
    } catch (e) {
      Helpers.showErrorSnackBar(context, 'Erreur lors de la suppression: $e');
    }
  }
  static Future<String?> uploadDocument({
    required WidgetRef ref,
    required dynamic file,
    required Uint8List? bytes,
    required String documentType,
    bool isFront = false,
    String? fallbackUrl,
    BuildContext? context,
  }) async {
    if (file != null && bytes != null) {
      try {
        return await ref.read(driverCniUploadProvider).uploadCni(
          file: file,
          isFront: isFront,
          documentType: documentType,
        );
      } catch (e) {
        if (context != null) {
          Helpers.showErrorSnackBar(context, 'Erreur upload $documentType: $e');
        }
        return fallbackUrl;
      }
    }
    return fallbackUrl;
  }

  static Future<bool> deleteDocument({
    required WidgetRef ref,
    required String documentType,
    BuildContext? context,
  }) async {
    try {
      final success = await ref.read(driverCniUploadProvider).deleteDocument(documentType: documentType);
      if (!success && context != null && context.mounted) {
        Helpers.showErrorSnackBar(context, 'Échec de la suppression du document');
      }
      return success;
    } catch (e) {
      if (context != null && context.mounted) {
        Helpers.showErrorSnackBar(context, 'Erreur: $e');
      }
      return false;
    }
  }

  static Future<String?> uploadProfilePhoto({
    required WidgetRef ref,
    required dynamic file,
    required Uint8List? bytes,
    String? fallbackUrl,
    BuildContext? context,
    bool delete = false,
    String? initialUrl,
  }) async {
    if (delete && initialUrl != null && initialUrl.isNotEmpty) {
      final success = await ref.read(driverProvider.notifier).deleteProfilePhoto();
      if (context != null && context.mounted && !success) {
        Helpers.showErrorSnackBar(context, 'Erreur lors de la suppression de la photo');
      }
      return null;
    }
    if (file != null && bytes != null) {
      try {
        if (file is XFile || file is File) {
          return await ref.read(driverProvider.notifier).uploadProfilePhoto(file);
        } else {
          throw Exception('Type de fichier non supporté: ${file.runtimeType}');
        }
      } catch (e) {
        if (context != null && context.mounted) {
          Helpers.showErrorSnackBar(context, 'Erreur upload photo: $e');
        }
        return fallbackUrl;
      }
    }
    return null;
  }
}
