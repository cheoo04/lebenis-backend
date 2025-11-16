import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/pricing_estimate.dart';

class PricingRepository {
  final DioClient dioClient;
  PricingRepository(this.dioClient);

  Future<PricingEstimateModel> estimatePrice(Map<String, dynamic> data) async {
    final response = await dioClient.post(ApiConstants.pricingEstimate, data: data);
    return PricingEstimateModel.fromJson(response.data);
  }
}
