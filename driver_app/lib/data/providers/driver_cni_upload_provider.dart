import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/cloudinary_service.dart';
import '../providers/auth_provider.dart';

final driverCniUploadProvider = Provider<DriverCniUploadService>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return DriverCniUploadService(CloudinaryService(dioClient: dioClient));
});

class DriverCniUploadService {
  final CloudinaryService _cloudinaryService;
  DriverCniUploadService(this._cloudinaryService);

  /// Upload document (CNI, assurance, etc.) (returns Cloudinary URL)
  Future<String> uploadCni({
    required dynamic file,
    bool? isFront,
    String? documentType,
  }) async {
    // Si documentType est fourni, on l'utilise, sinon on déduit à partir de isFront (pour la CNI)
    String docType = documentType ?? (isFront == true ? 'cni_recto' : 'cni_verso');
    if (file == null) throw Exception('Aucun fichier sélectionné');
    if (kIsWeb && file is XFile) {
      // Web: save to bytes, write to temp file
      final bytes = await file.readAsBytes();
      final temp = File('/tmp/${file.name}');
      await temp.writeAsBytes(bytes);
      return await _cloudinaryService.uploadDocument(temp.path, docType);
    } else if (file is XFile) {
      return await _cloudinaryService.uploadDocument(file.path, docType);
    } else if (file is File) {
      return await _cloudinaryService.uploadDocument(file.path, docType);
    } else {
      throw Exception('Type de fichier non supporté: ${file.runtimeType}');
    }
  }

  /// Supprimer un document (assurance, carte grise, permis, etc.)
  Future<bool> deleteDocument({required String documentType}) async {
    try {
      // Appel à l'API backend pour supprimer le document
      // L'endpoint doit être implémenté côté backend, ex: /api/v1/cloudinary/delete/
      final response = await _cloudinaryService.deleteDocument(documentType);
      return response;
    } catch (e) {
      // Log ou gestion d'erreur
      return false;
    }
  }
}
