import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/delivery_model.dart';
import '../models/rating_model.dart';

class DeliveryRepository {
  final DioClient dioClient;

  DeliveryRepository(this.dioClient);

  Future<List<DeliveryModel>> getDeliveries({String? status}) async {
    final queryParams = status != null ? {'status': status} : null;
    final response = await dioClient.get(
      ApiConstants.deliveries,
      queryParameters: queryParams,
    );
    final list = response.data as List;
    return list.map((e) => DeliveryModel.fromJson(e)).toList();
  }

  Future<DeliveryModel> getDeliveryDetail(String id) async {
    final response = await dioClient.get('${ApiConstants.deliveries}$id/');
    return DeliveryModel.fromJson(response.data);
  }

  Future<DeliveryModel> createDelivery(Map<String, dynamic> data) async {
    final response = await dioClient.post(ApiConstants.deliveries, data: data);
    return DeliveryModel.fromJson(response.data);
  }

  Future<bool> deleteDelivery(String id) async {
    await dioClient.delete('${ApiConstants.deliveries}$id/');
    return true;
  }

  Future<DeliveryModel> cancelDelivery(String id) async {
    final response = await dioClient.patch(
      '${ApiConstants.deliveries}/$id/cancel',
    );
    return DeliveryModel.fromJson(response.data);
  }

  Future<DeliveryModel> updateDelivery(String id, Map<String, dynamic> data) async {
    final response = await dioClient.patch(
      '${ApiConstants.deliveries}$id/',
      data: data,
    );
    return DeliveryModel.fromJson(response.data);
  }

  /// POST /api/v1/deliveries/{id}/rate-driver/
  Future<DeliveryRatingModel> rateDriver({
    required String deliveryId,
    required double rating,
    String? comment,
    double? punctualityRating,
    double? professionalismRating,
    double? careRating,
  }) async {
    final response = await dioClient.post(
      '${ApiConstants.deliveries}$deliveryId/rate-driver/',
      data: {
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
        if (punctualityRating != null) 'punctuality_rating': punctualityRating,
        if (professionalismRating != null) 'professionalism_rating': professionalismRating,
        if (careRating != null) 'care_rating': careRating,
      },
    );

    // L'API retourne { success: true, message: '...', rating: {...} }
    return DeliveryRatingModel.fromJson(response.data['rating']);
  }
}
