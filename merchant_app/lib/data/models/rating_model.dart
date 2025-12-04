class DeliveryRatingModel {
  final int id;
  final int deliveryId;
  final int driverId;
  final double rating; // 1-5
  final String? comment;
  final double? punctualityRating;
  final double? professionalismRating;
  final double? careRating;
  final DateTime createdAt;

  DeliveryRatingModel({
    required this.id,
    required this.deliveryId,
    required this.driverId,
    required this.rating,
    this.comment,
    this.punctualityRating,
    this.professionalismRating,
    this.careRating,
    required this.createdAt,
  });

  factory DeliveryRatingModel.fromJson(Map<String, dynamic> json) {
    return DeliveryRatingModel(
      id: json['id'],
      deliveryId: json['delivery'],
      driverId: json['driver'],
      rating: double.parse(json['rating'].toString()),
      comment: json['comment'],
      punctualityRating: json['punctuality_rating'] != null
          ? double.parse(json['punctuality_rating'].toString())
          : null,
      professionalismRating: json['professionalism_rating'] != null
          ? double.parse(json['professionalism_rating'].toString())
          : null,
      careRating: json['care_rating'] != null
          ? double.parse(json['care_rating'].toString())
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      if (comment != null) 'comment': comment,
      if (punctualityRating != null) 'punctuality_rating': punctualityRating,
      if (professionalismRating != null)
        'professionalism_rating': professionalismRating,
      if (careRating != null) 'care_rating': careRating,
    };
  }
}
