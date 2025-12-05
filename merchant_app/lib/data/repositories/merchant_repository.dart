import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/merchant_model.dart';
import '../models/merchant_stats_model.dart';

class MerchantRepository {
  final DioClient dioClient;

  MerchantRepository(this.dioClient);

  // Récupérer le profil du marchand connecté
  Future<MerchantModel> getProfile() async {
    final response = await dioClient.get(ApiConstants.merchantProfile);
    // Backend retourne une liste avec un seul élément (le merchant connecté)
    final results = response.data['results'] ?? response.data;
    if (results is List && results.isNotEmpty) {
      return MerchantModel.fromJson(results[0]);
    }
    // Fallback si réponse directe (pour compatibilité)
    return MerchantModel.fromJson(response.data);
  }

  // Mettre à jour le profil
  Future<MerchantModel> updateProfile({
    String? businessName,
    String? phone,
    String? address,
  }) async {
    final data = <String, dynamic>{};
    if (businessName != null) data['business_name'] = businessName;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;

    final response = await dioClient.patch(
      ApiConstants.merchantProfile,
      data: data,
    );

    return MerchantModel.fromJson(response.data);
  }

  // Récupérer les statistiques du marchand
  Future<MerchantStatsModel> getStats({int periodDays = 30}) async {
    final response = await dioClient.get(
      ApiConstants.merchantStats,
      queryParameters: {'period': periodDays},
    );
    return MerchantStatsModel.fromJson(response.data);
  }

  // Mettre à jour les documents (RCCM, pièce d'identité)
  Future<MerchantModel> updateDocuments({
    dynamic rccmDocument,
    dynamic idDocument,
  }) async {
    // 1. Uploader les fichiers vers Cloudinary
    String? rccmUrl;
    String? idUrl;

    if (rccmDocument != null) {
      final rccmResponse = await dioClient.uploadFile(
        ApiConstants.cloudinaryUpload,
        rccmDocument,
        fileKey: 'file',
      );
      rccmUrl = rccmResponse.data['url'];
    }

    if (idDocument != null) {
      final idResponse = await dioClient.uploadFile(
        ApiConstants.cloudinaryUpload,
        idDocument,
        fileKey: 'file',
      );
      idUrl = idResponse.data['url'];
    }

    // 2. Mettre à jour les URLs dans le backend
    final data = <String, dynamic>{};
    if (rccmUrl != null) data['rccm_document'] = rccmUrl;
    if (idUrl != null) data['id_document'] = idUrl;

    final response = await dioClient.patch(
      '${ApiConstants.merchantProfile}update-documents/',
      data: data,
    );

    return MerchantModel.fromJson(response.data['merchant']);
  }
}