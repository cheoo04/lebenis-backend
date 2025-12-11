import 'package:hive/hive.dart';

part 'delivery_cache.g.dart';

/// Collection Hive pour stocker les livraisons en mode offline
/// 
/// Cette collection permet de:
/// - Cacher les livraisons actives du driver
/// - Stocker les livraisons en cours même sans connexion
/// - Synchroniser automatiquement à la reconnexion
@HiveType(typeId: 0)
class DeliveryCache extends HiveObject {
  /// ID serveur de la livraison (UUID)
  @HiveField(0)
  late String serverId;
  
  /// Numéro de tracking
  @HiveField(1)
  late String trackingNumber;
  
  /// Status de la livraison
  @HiveField(2)
  late String status;
  
  // === Adresse de ramassage ===
  @HiveField(3)
  late String pickupAddress;
  
  @HiveField(4)
  late String pickupCommune;
  
  @HiveField(5)
  late String pickupQuartier;
  
  @HiveField(6)
  late String pickupPrecision;
  
  @HiveField(7)
  double? pickupLatitude;
  
  @HiveField(8)
  double? pickupLongitude;
  
  // === Adresse de livraison ===
  @HiveField(9)
  late String deliveryAddress;
  
  @HiveField(10)
  late String deliveryCommune;
  
  @HiveField(11)
  late String deliveryQuartier;
  
  @HiveField(12)
  late String deliveryPrecision;
  
  @HiveField(13)
  double? deliveryLatitude;
  
  @HiveField(14)
  double? deliveryLongitude;
  
  // === Destinataire ===
  @HiveField(15)
  late String recipientName;
  
  @HiveField(16)
  late String recipientPhone;
  
  // === Colis ===
  @HiveField(17)
  late String packageDescription;
  
  @HiveField(18)
  late double weight;
  
  @HiveField(19)
  late double price;
  
  @HiveField(20)
  late double distanceKm;
  
  @HiveField(21)
  String? notes;
  
  // === Paiement ===
  @HiveField(22)
  String? paymentMethod;
  
  @HiveField(23)
  double? codAmount;
  
  // === Merchant info (JSON stocké) ===
  @HiveField(24)
  String? merchantJson;
  
  // === Photos & Signature ===
  @HiveField(25)
  String? pickupPhoto;
  
  @HiveField(26)
  String? deliveryPhoto;
  
  @HiveField(27)
  String? recipientSignature;
  
  @HiveField(28)
  String? cancellationReason;
  
  // === Timestamps ===
  @HiveField(29)
  late DateTime createdAt;
  
  @HiveField(30)
  DateTime? assignedAt;
  
  @HiveField(31)
  DateTime? pickupTime;
  
  @HiveField(32)
  DateTime? deliveryTime;
  
  @HiveField(33)
  DateTime? cancelledAt;
  
  /// Timestamp de la dernière synchronisation
  @HiveField(34)
  late DateTime cachedAt;
  
  /// Indique si des modifications locales doivent être synchronisées
  @HiveField(35)
  late bool needsSync;
  
  // === Constructeur ===
  DeliveryCache();
  
  // === Factory depuis le modèle API ===
  factory DeliveryCache.fromJson(Map<String, dynamic> json) {
    final cache = DeliveryCache()
      ..serverId = json['id']?.toString() ?? ''
      ..trackingNumber = json['tracking_number']?.toString() ?? ''
      ..status = json['status']?.toString() ?? 'pending'
      ..pickupAddress = json['pickup_address']?.toString() ?? ''
      ..pickupCommune = json['pickup_commune']?.toString() ?? ''
      ..pickupQuartier = json['pickup_quartier']?.toString() ?? ''
      ..pickupPrecision = json['pickup_precision']?.toString() ?? ''
      ..pickupLatitude = json['pickup_latitude'] != null
          ? double.tryParse(json['pickup_latitude'].toString())
          : null
      ..pickupLongitude = json['pickup_longitude'] != null
          ? double.tryParse(json['pickup_longitude'].toString())
          : null
      ..deliveryAddress = json['delivery_address']?.toString() ?? ''
      ..deliveryCommune = json['delivery_commune']?.toString() ?? ''
      ..deliveryQuartier = json['delivery_quartier']?.toString() ?? ''
      ..deliveryPrecision = json['delivery_precision']?.toString() ?? ''
      ..deliveryLatitude = json['delivery_latitude'] != null
          ? double.tryParse(json['delivery_latitude'].toString())
          : null
      ..deliveryLongitude = json['delivery_longitude'] != null
          ? double.tryParse(json['delivery_longitude'].toString())
          : null
      ..recipientName = json['recipient_name']?.toString() ?? ''
      ..recipientPhone = json['recipient_phone']?.toString() ?? ''
      ..packageDescription = json['package_description']?.toString() ?? ''
      ..weight = json['package_weight_kg'] != null
          ? double.tryParse(json['package_weight_kg'].toString()) ?? 0.0
          : 0.0
      ..price = json['calculated_price'] != null
          ? double.tryParse(json['calculated_price'].toString()) ?? 0.0
          : 0.0
      ..distanceKm = json['distance_km'] != null
          ? double.tryParse(json['distance_km'].toString()) ?? 0.0
          : 0.0
      ..notes = json['delivery_notes']?.toString()
      ..paymentMethod = json['payment_method']?.toString()
      ..codAmount = json['cod_amount'] != null
          ? double.tryParse(json['cod_amount'].toString())
          : null
      ..pickupPhoto = json['pickup_photo']?.toString()
      ..deliveryPhoto = json['delivery_photo']?.toString()
      ..recipientSignature = json['recipient_signature']?.toString()
      ..cancellationReason = json['cancellation_reason']?.toString()
      ..createdAt = json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now()
      ..assignedAt = json['assigned_at'] != null
          ? DateTime.tryParse(json['assigned_at'].toString())
          : null
      ..pickupTime = json['pickup_time'] != null
          ? DateTime.tryParse(json['pickup_time'].toString())
          : null
      ..deliveryTime = json['delivery_time'] != null
          ? DateTime.tryParse(json['delivery_time'].toString())
          : null
      ..cancelledAt = json['cancelled_at'] != null
          ? DateTime.tryParse(json['cancelled_at'].toString())
          : null
      ..cachedAt = DateTime.now()
      ..needsSync = false;
    
    // Stocker merchant comme JSON string
    if (json['merchant'] != null) {
      try {
        cache.merchantJson = json['merchant'].toString();
      } catch (_) {}
    }
    
    return cache;
  }
  
  /// Convertir en Map pour l'API
  Map<String, dynamic> toJson() {
    return {
      'id': serverId,
      'tracking_number': trackingNumber,
      'status': status,
      'pickup_address': pickupAddress,
      'pickup_commune': pickupCommune,
      'pickup_quartier': pickupQuartier,
      'pickup_precision': pickupPrecision,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'delivery_address': deliveryAddress,
      'delivery_commune': deliveryCommune,
      'delivery_quartier': deliveryQuartier,
      'delivery_precision': deliveryPrecision,
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
      'recipient_name': recipientName,
      'recipient_phone': recipientPhone,
      'package_description': packageDescription,
      'package_weight_kg': weight,
      'calculated_price': price,
      'distance_km': distanceKm,
      'delivery_notes': notes,
      'payment_method': paymentMethod,
      'cod_amount': codAmount,
      'pickup_photo': pickupPhoto,
      'delivery_photo': deliveryPhoto,
      'recipient_signature': recipientSignature,
      'cancellation_reason': cancellationReason,
      'created_at': createdAt.toIso8601String(),
      'assigned_at': assignedAt?.toIso8601String(),
      'pickup_time': pickupTime?.toIso8601String(),
      'delivery_time': deliveryTime?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
    };
  }
}
