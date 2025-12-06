import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/pricing_estimate.dart';

class PricingRepository {
  final DioClient dioClient;
  PricingRepository(this.dioClient);

  Future<PricingEstimateModel> estimatePrice(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(ApiConstants.pricingEstimate, data: data);
      
      // Vérifier si la réponse contient une erreur
      if (response.data is Map && response.data.containsKey('error')) {
        throw Exception(response.data['error'] ?? 'Erreur de calcul de prix');
      }
      
      return PricingEstimateModel.fromJson(response.data);
    } catch (e) {
      print('Erreur estimatePrice: $e');
      rethrow;
    }
  }
}
