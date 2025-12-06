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
		// Helper pour convertir String ou num en double
		double? parseDouble(dynamic value) {
			if (value == null) return null;
			if (value is num) return value.toDouble();
			if (value is String) return double.tryParse(value);
			return null;
		}
		
		return DeliveryModel(
			id: json['id']?.toString() ?? '',
			trackingNumber: json['tracking_number']?.toString() ?? '',
			status: json['status']?.toString() ?? 'pending',
			recipientName: json['recipient_name']?.toString() ?? '',
			recipientPhone: json['recipient_phone']?.toString() ?? '',
			pickupAddress: json['pickup_address']?.toString() ?? json['pickup_address_details']?.toString() ?? '',
			pickupCommune: json['pickup_commune']?.toString() ?? '',
			pickupLatitude: parseDouble(json['pickup_latitude']),
			pickupLongitude: parseDouble(json['pickup_longitude']),
			deliveryAddress: json['delivery_address']?.toString() ?? '',
			deliveryCommune: json['delivery_commune']?.toString() ?? '',
			deliveryLatitude: parseDouble(json['delivery_latitude']),
			deliveryLongitude: parseDouble(json['delivery_longitude']),
			packageDescription: json['package_description']?.toString() ?? '',
			packageWeightKg: parseDouble(json['package_weight_kg']) ?? 0.0,
			paymentMethod: json['payment_method']?.toString() ?? 'prepaid',
			codAmount: parseDouble(json['cod_amount']),
			createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
			deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null,
			price: parseDouble(json['calculated_price']) ?? parseDouble(json['actual_price']) ?? parseDouble(json['price']) ?? 0.0,
			notes: json['notes']?.toString(),
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
