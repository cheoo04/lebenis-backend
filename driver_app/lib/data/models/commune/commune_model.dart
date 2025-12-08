// lib/data/models/commune/commune_model.dart

import '../../../core/utils/json_utils.dart';

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
      commune: json['commune']?.toString() ?? '',
      latitude: safeDouble(json['latitude']),
      longitude: safeDouble(json['longitude']),
      zoneName: json['zone_name']?.toString() ?? '',
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
  String toString() => '$commune ($latitude, $longitude)';
}
