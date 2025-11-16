import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/delivery_model.dart';

class DeliveryRepository {
  final DioClient dioClient;

  DeliveryRepository(this.dioClient);

  Future<List<DeliveryModel>> getDeliveries() async {
    final response = await dioClient.get(ApiConstants.deliveries);
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

  // Ajoutez ici d'autres méthodes (update, tracking, etc.) selon vos besoins
}
