import 'driver_model.dart';

class DeliveryModel {
	final String id; // UUID
	final String trackingNumber;
	final String status; // e.g. "pending", "in_progress", "delivered", "cancelled"
	final String recipientName;
	final String recipientPhone;
	final String pickupAddress;
	final String pickupCommune;
	final double? pickupLatitude;
	final double? pickupLongitude;
	final String deliveryAddress;
	final String deliveryCommune;
	final double? deliveryLatitude;
	final double? deliveryLongitude;
	final String packageDescription;
	final double packageWeightKg;
	final String paymentMethod; // "COD" or "prepaid"
	final double? codAmount;
	final DateTime createdAt;
	final DateTime? deliveredAt;
	final double price;
	final String? notes;
	final DriverModel? driver;

	DeliveryModel({
		required this.id,
		required this.trackingNumber,
		required this.status,
		required this.recipientName,
		required this.recipientPhone,
		required this.pickupAddress,
		required this.pickupCommune,
		this.pickupLatitude,
		this.pickupLongitude,
		required this.deliveryAddress,
		required this.deliveryCommune,
		this.deliveryLatitude,
		this.deliveryLongitude,
		required this.packageDescription,
		required this.packageWeightKg,
		required this.paymentMethod,
		this.codAmount,
		required this.createdAt,
		this.deliveredAt,
		required this.price,
		this.notes,
		this.driver,
	});

	factory DeliveryModel.fromJson(Map<String, dynamic> json) {
		return DeliveryModel(
			id: json['id']?.toString() ?? '',
			trackingNumber: json['tracking_number'],
			status: json['status'],
			recipientName: json['recipient_name'],
			recipientPhone: json['recipient_phone'],
			pickupAddress: json['pickup_address'],
			pickupCommune: json['pickup_commune'] ?? '',
			pickupLatitude: json['pickup_latitude'] != null ? (json['pickup_latitude'] as num).toDouble() : null,
			pickupLongitude: json['pickup_longitude'] != null ? (json['pickup_longitude'] as num).toDouble() : null,
			deliveryAddress: json['delivery_address'],
			deliveryCommune: json['delivery_commune'] ?? '',
			deliveryLatitude: json['delivery_latitude'] != null ? (json['delivery_latitude'] as num).toDouble() : null,
			deliveryLongitude: json['delivery_longitude'] != null ? (json['delivery_longitude'] as num).toDouble() : null,
			packageDescription: json['package_description'] ?? '',
			packageWeightKg: (json['package_weight_kg'] ?? 0.0).toDouble(),
			paymentMethod: json['payment_method'] ?? 'prepaid',
			codAmount: json['cod_amount'] != null ? (json['cod_amount'] as num).toDouble() : null,
			createdAt: DateTime.parse(json['created_at']),
			deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null,
			price: (json['price'] ?? 0.0).toDouble(),
			notes: json['notes'],
			driver: json['driver'] != null ? DriverModel.fromJson(json['driver']) : null,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'tracking_number': trackingNumber,
			'status': status,
			'recipient_name': recipientName,
			'recipient_phone': recipientPhone,
			'pickup_address': pickupAddress,
			'pickup_commune': pickupCommune,
			if (pickupLatitude != null) 'pickup_latitude': pickupLatitude,
			if (pickupLongitude != null) 'pickup_longitude': pickupLongitude,
			'delivery_address': deliveryAddress,
			'delivery_commune': deliveryCommune,
			if (deliveryLatitude != null) 'delivery_latitude': deliveryLatitude,
			if (deliveryLongitude != null) 'delivery_longitude': deliveryLongitude,
			'package_description': packageDescription,
			'package_weight_kg': packageWeightKg,
			'payment_method': paymentMethod,
			if (codAmount != null) 'cod_amount': codAmount,
			'created_at': createdAt.toIso8601String(),
			'delivered_at': deliveredAt?.toIso8601String(),
			'price': price,
			'notes': notes,
			if (driver != null) 'driver': driver!.toJson(),
		};
	}
}
