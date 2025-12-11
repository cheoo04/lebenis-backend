import 'package:hive/hive.dart';

part 'driver_profile_cache.g.dart';

/// Collection pour cacher le profil du driver
/// 
/// Permet d'afficher les informations même hors-ligne
@HiveType(typeId: 2)
class DriverProfileCache extends HiveObject {
  /// ID serveur du driver
  @HiveField(0)
  late String serverId;
  
  /// ID utilisateur
  @HiveField(1)
  late String userId;
  
  // === Informations personnelles ===
  @HiveField(2)
  late String firstName;
  
  @HiveField(3)
  late String lastName;
  
  @HiveField(4)
  late String email;
  
  @HiveField(5)
  late String phone;
  
  @HiveField(6)
  String? profilePhoto;
  
  // === Informations driver ===
  @HiveField(7)
  late String vehicleType;
  
  @HiveField(8)
  String? licensePlate;
  
  @HiveField(9)
  late bool isVerified;
  
  @HiveField(10)
  late bool isAvailable;
  
  @HiveField(11)
  late double rating;
  
  @HiveField(12)
  late int totalDeliveries;
  
  // === Zone de couverture ===
  @HiveField(13)
  String? currentCommune;
  
  @HiveField(14)
  String? currentQuartier;
  
  @HiveField(15)
  double? currentLatitude;
  
  @HiveField(16)
  double? currentLongitude;
  
  // === Earnings ===
  @HiveField(17)
  late double todayEarnings;
  
  @HiveField(18)
  late double weekEarnings;
  
  @HiveField(19)
  late double monthEarnings;
  
  @HiveField(20)
  late double totalEarnings;
  
  // === Timestamps ===
  @HiveField(21)
  late DateTime cachedAt;
  
  @HiveField(22)
  DateTime? lastOnlineAt;
  
  DriverProfileCache();
  
  /// Factory depuis JSON API
  factory DriverProfileCache.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    
    return DriverProfileCache()
      ..serverId = json['id']?.toString() ?? ''
      ..userId = user['id']?.toString() ?? ''
      ..firstName = user['first_name']?.toString() ?? ''
      ..lastName = user['last_name']?.toString() ?? ''
      ..email = user['email']?.toString() ?? ''
      ..phone = user['phone']?.toString() ?? json['phone']?.toString() ?? ''
      ..profilePhoto = user['profile_photo']?.toString() ?? json['photo']?.toString()
      ..vehicleType = json['vehicle_type']?.toString() ?? 'moto'
      ..licensePlate = json['license_plate']?.toString()
      ..isVerified = json['is_verified'] == true
      ..isAvailable = json['is_available'] == true
      ..rating = double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0
      ..totalDeliveries = int.tryParse(json['total_deliveries']?.toString() ?? '0') ?? 0
      ..currentCommune = json['current_commune']?.toString()
      ..currentQuartier = json['current_quartier']?.toString()
      ..currentLatitude = double.tryParse(json['current_latitude']?.toString() ?? '')
      ..currentLongitude = double.tryParse(json['current_longitude']?.toString() ?? '')
      ..todayEarnings = double.tryParse(json['today_earnings']?.toString() ?? '0') ?? 0.0
      ..weekEarnings = double.tryParse(json['week_earnings']?.toString() ?? '0') ?? 0.0
      ..monthEarnings = double.tryParse(json['month_earnings']?.toString() ?? '0') ?? 0.0
      ..totalEarnings = double.tryParse(json['total_earnings']?.toString() ?? '0') ?? 0.0
      ..cachedAt = DateTime.now()
      ..lastOnlineAt = json['last_location_update'] != null
          ? DateTime.tryParse(json['last_location_update'].toString())
          : null;
  }
  
  /// Nom complet
  String get fullName => '$firstName $lastName'.trim();
  
  /// Convertir en Map
  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'user': {
        'id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'profile_photo': profilePhoto,
      },
      'vehicle_type': vehicleType,
      'license_plate': licensePlate,
      'is_verified': isVerified,
      'is_available': isAvailable,
      'rating': rating,
      'total_deliveries': totalDeliveries,
      'current_commune': currentCommune,
      'current_quartier': currentQuartier,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'today_earnings': todayEarnings,
      'week_earnings': weekEarnings,
      'month_earnings': monthEarnings,
      'total_earnings': totalEarnings,
    };
  }
}
