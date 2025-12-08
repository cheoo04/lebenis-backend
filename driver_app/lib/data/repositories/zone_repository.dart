import '../models/zone_model.dart';
import '../../core/network/dio_client.dart';

class ZoneRepository {
  final DioClient dioClient;
  ZoneRepository(this.dioClient);

  Future<List<ZoneModel>> fetchZones() async {
    // Request communes aggregated view to display simple commune names instead of detailed zones
    final response = await dioClient.get('/api/v1/pricing/zones/with-selection/', queryParameters: {'group_by': 'commune'});
    final data = response.data;
    if (data is Map && data['communes'] is List) {
      final List communes = data['communes'];
      return communes.map<ZoneModel>((json) {
        final String commune = json['commune'] as String;
        final String display = (json['commune_display'] as String?) ?? commune;
        final bool selected = json['selected'] ?? false;
        return ZoneModel(id: commune, name: display, selected: selected);
      }).toList();
    } else {
      throw Exception('Réponse inattendue du backend pour les zones: $data');
    }
  }

  Future<void> saveSelectedZones(List<String> zoneIds) async {
    // Send communes (zoneIds are communes when using grouped view)
    await dioClient.post(
      '/api/v1/pricing/zones/assign/',
      data: {'communes': zoneIds},
    );
  }
}
