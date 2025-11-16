import 'package:dio/dio.dart';

class ZoneRepository {
  final Dio dio;
  ZoneRepository({required this.dio});

  Future<List<ZoneModel>> fetchZones() async {
    final response = await dio.get('/api/v1/zones/with-selection/');
    final data = response.data as List;
    return data.map((json) => ZoneModel.fromJson(json)).toList();
  }

  Future<void> saveSelectedZones(List<String> zoneIds) async {
    await dio.post(
      '/api/v1/zones/assign/',
      data: {'zone_ids': zoneIds},
    );
  }
}
