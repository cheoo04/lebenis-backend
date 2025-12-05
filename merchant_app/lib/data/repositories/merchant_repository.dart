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
      queryParameters: {'period_days': periodDays},
    );
    return MerchantStatsModel.fromJson(response.data);
  }
}