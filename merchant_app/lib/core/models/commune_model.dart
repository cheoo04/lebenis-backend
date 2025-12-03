// lib/core/models/commune_model.dart

class CommuneModel {
  final String commune;
  final double latitude;
  final double longitude;
  final String zoneName;

  CommuneModel({
    required this.commune,
    required this.latitude,
    required this.longitude,
    required this.zoneName,
  });

  factory CommuneModel.fromJson(Map<String, dynamic> json) {
    return CommuneModel(
      commune: json['commune'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      zoneName: json['zone_name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commune': commune,
      'latitude': latitude,
      'longitude': longitude,
      'zone_name': zoneName,
    };
  }

  @override
  String toString() => '$commune ($zoneName)';
}
