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
		// Nouveau format du backend (depuis calculator.py)
		if (json.containsKey('total_price')) {
			final breakdown = json['breakdown'] as Map<String, dynamic>? ?? {};
			final details = json['details'] as Map<String, dynamic>? ?? {};
			
			return PricingEstimateModel(
				basePrice: (breakdown['base_rate'] ?? 0.0).toDouble(),
				distance: (details['distance_km'] ?? 0.0).toDouble(),
				distancePrice: (breakdown['distance_surcharge'] ?? 0.0).toDouble(),
				weight: (details['billable_weight_kg'] ?? 0.0).toDouble(),
				weightPrice: (breakdown['weight_surcharge'] ?? 0.0).toDouble(),
				total: (json['total_price'] ?? 0.0).toDouble(),
				currency: 'FCFA',
			);
		}
		
		// Ancien format (fallback pour compatibilité)
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
