import '../models/zone_model.dart';
import '../../core/network/dio_client.dart';

class ZoneRepository {
  final DioClient dioClient;
  ZoneRepository(this.dioClient);

  Future<List<ZoneModel>> fetchZones() async {
    final response = await dioClient.get('/api/v1/pricing/zones/with-selection/');
    final data = response.data;
    if (data is List) {
      return data.map((json) => ZoneModel.fromJson(json)).toList();
    } else {
      throw Exception('Réponse inattendue du backend pour les zones: $data');
    }
  }

  Future<void> saveSelectedZones(List<String> zoneIds) async {
    await dioClient.post(
      '/api/v1/pricing/zones/assign/',
      data: {'zone_ids': zoneIds},
    );
  }
}
