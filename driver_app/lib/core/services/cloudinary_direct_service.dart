import 'package:dio/dio.dart';

/// Service factorisé pour upload direct Cloudinary de tous les documents driver
class CloudinaryDirectService {
  final String cloudName;
  final String uploadPreset;

  CloudinaryDirectService({required this.cloudName, required this.uploadPreset});

  /// Upload un fichier sur Cloudinary et retourne l'URL sécurisée
  /// [filePath] : chemin local du fichier
  /// [folder] : dossier Cloudinary (ex: 'lebenis/cni', 'lebenis/assurance')
  Future<String> uploadDocument(String filePath, {required String folder}) async {
    final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'upload_preset': uploadPreset,
      'folder': folder,
    });
    final response = await Dio().post(url, data: formData);
    if (response.statusCode == 200 && response.data['secure_url'] != null) {
      return response.data['secure_url'];
    } else {
      throw Exception('Erreur Cloudinary: ${response.data}');
    }
  }
}
