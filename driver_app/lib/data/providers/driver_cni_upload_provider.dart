import 'dart:io';
import 'dart:typed_data';
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

  /// Upload CNI recto/verso (returns Cloudinary URL)
  Future<String> uploadCni({
    required dynamic file,
    required bool isFront,
  }) async {
    String documentType = isFront ? 'cni_recto' : 'cni_verso';
    if (file == null) throw Exception('Aucun fichier sélectionné');
    if (kIsWeb && file is XFile) {
      // Web: save to bytes, write to temp file
      final bytes = await file.readAsBytes();
      final temp = File('/tmp/${file.name}');
      await temp.writeAsBytes(bytes);
      return await _cloudinaryService.uploadDocument(temp.path, documentType);
    } else if (file is XFile) {
      return await _cloudinaryService.uploadDocument(file.path, documentType);
    } else if (file is File) {
      return await _cloudinaryService.uploadDocument(file.path, documentType);
    } else {
      throw Exception('Type de fichier non supporté: ${file.runtimeType}');
    }
  }
}
