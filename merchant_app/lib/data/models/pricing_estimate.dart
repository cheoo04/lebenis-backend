class PricingEstimateModel {
	final double basePrice;
	final double distance;
	final double distancePrice;
	final double weight;
	final double weightPrice;
	final double total;
	final String currency;

	PricingEstimateModel({
		required this.basePrice,
		required this.distance,
		required this.distancePrice,
		required this.weight,
		required this.weightPrice,
		required this.total,
		required this.currency,
	});

	factory PricingEstimateModel.fromJson(Map<String, dynamic> json) {
		return PricingEstimateModel(
			basePrice: (json['base_price'] ?? 0.0).toDouble(),
			distance: (json['distance'] ?? 0.0).toDouble(),
			distancePrice: (json['distance_price'] ?? 0.0).toDouble(),
			weight: (json['weight'] ?? 0.0).toDouble(),
			weightPrice: (json['weight_price'] ?? 0.0).toDouble(),
			total: (json['total'] ?? 0.0).toDouble(),
			currency: json['currency'] ?? 'FCFA',
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'base_price': basePrice,
			'distance': distance,
			'distance_price': distancePrice,
			'weight': weight,
			'weight_price': weightPrice,
			'total': total,
			'currency': currency,
		};
	}
}
