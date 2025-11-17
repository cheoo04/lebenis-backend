import '../models/zone_model.dart';
import '../../core/network/dio_client.dart';

class ZoneRepository {
  final DioClient dioClient;
  ZoneRepository(this.dioClient);

  Future<List<ZoneModel>> fetchZones() async {
    final response = await dioClient.get('/api/v1/zones/with-selection/');
    final data = response.data as List;
    return data.map((json) => ZoneModel.fromJson(json)).toList();
  }

  Future<void> saveSelectedZones(List<String> zoneIds) async {
    await dioClient.post(
      '/api/v1/zones/assign/',
      data: {'zone_ids': zoneIds},
    );
  }
}
