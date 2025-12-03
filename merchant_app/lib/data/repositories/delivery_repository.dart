import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/delivery_model.dart';

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

  Future<DeliveryModel> getDeliveryDetail(int id) async {
    final response = await dioClient.get('${ApiConstants.deliveries}/$id');
    return DeliveryModel.fromJson(response.data);
  }

  Future<DeliveryModel> createDelivery(Map<String, dynamic> data) async {
    final response = await dioClient.post(ApiConstants.deliveries, data: data);
    return DeliveryModel.fromJson(response.data);
  }

  Future<bool> deleteDelivery(int id) async {
    await dioClient.delete('${ApiConstants.deliveries}/$id');
    return true;
  }

  Future<DeliveryModel> cancelDelivery(int id) async {
    final response = await dioClient.patch(
      '${ApiConstants.deliveries}/$id/cancel',
    );
    return DeliveryModel.fromJson(response.data);
  }

  Future<DeliveryModel> updateDelivery(int id, Map<String, dynamic> data) async {
    final response = await dioClient.patch(
      '${ApiConstants.deliveries}/$id',
      data: data,
    );
    return DeliveryModel.fromJson(response.data);
  }
}
