class DriverModel {
  final String id; // UUID
  final String name;
  final String phone;
  final String? photo;
  final double? currentLatitude;
  final double? currentLongitude;

  DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    this.photo,
    this.currentLatitude,
    this.currentLongitude,
  });

  // Aliases pour compatibilité
  String get firstName => name;
  String get phoneNumber => phone;

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    double? _parseDoubleOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return DriverModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['user']?['first_name'] ?? 'Chauffeur',
      phone: json['phone'] ?? json['user']?['phone_number'] ?? '',
      photo: json['photo'],
      currentLatitude: _parseDoubleOrNull(json['current_latitude']),
      currentLongitude: _parseDoubleOrNull(json['current_longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'photo': photo,
      if (currentLatitude != null) 'current_latitude': currentLatitude,
      if (currentLongitude != null) 'current_longitude': currentLongitude,
    };
  }
}
