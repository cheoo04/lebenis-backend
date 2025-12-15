class DriverModel {
  final String id; // UUID du profil Driver
  final String? userId; // UUID du User (pour le chat)
  final String name;
  final String phone;
  final String? photo;
  final double? currentLatitude;
  final double? currentLongitude;

  DriverModel({
    required this.id,
    this.userId,
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
    double? parseDoubleOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return DriverModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['user']?['id']?.toString(),
      name: json['name'] ?? json['user']?['first_name'] ?? 'Chauffeur',
      phone: json['phone'] ?? json['user']?['phone_number'] ?? '',
      photo: json['photo'],
      currentLatitude: parseDoubleOrNull(json['current_latitude']),
      currentLongitude: parseDoubleOrNull(json['current_longitude']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'user_id': userId,
      'name': name,
      'phone': phone,
      'photo': photo,
      if (currentLatitude != null) 'current_latitude': currentLatitude,
      if (currentLongitude != null) 'current_longitude': currentLongitude,
    };
  }
}
