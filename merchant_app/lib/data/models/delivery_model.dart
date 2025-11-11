class DeliveryModel {
	final int id;
	final String trackingNumber;
	final String status; // e.g. "pending", "in_progress", "delivered", "cancelled"
	final String recipientName;
	final String recipientPhone;
	final String pickupAddress;
	final String deliveryAddress;
	final DateTime createdAt;
	final DateTime? deliveredAt;
	final double price;
	final String? notes;

	DeliveryModel({
		required this.id,
		required this.trackingNumber,
		required this.status,
		required this.recipientName,
		required this.recipientPhone,
		required this.pickupAddress,
		required this.deliveryAddress,
		required this.createdAt,
		this.deliveredAt,
		required this.price,
		this.notes,
	});

	factory DeliveryModel.fromJson(Map<String, dynamic> json) {
		return DeliveryModel(
			id: json['id'],
			trackingNumber: json['tracking_number'],
			status: json['status'],
			recipientName: json['recipient_name'],
			recipientPhone: json['recipient_phone'],
			pickupAddress: json['pickup_address'],
			deliveryAddress: json['delivery_address'],
			createdAt: DateTime.parse(json['created_at']),
			deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null,
			price: (json['price'] ?? 0.0).toDouble(),
			notes: json['notes'],
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
			'delivery_address': deliveryAddress,
			'created_at': createdAt.toIso8601String(),
			'delivered_at': deliveredAt?.toIso8601String(),
			'price': price,
			'notes': notes,
		};
	}
}
