class IndividualModel {
  final String id;
  final String userId;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? address;
  final DateTime createdAt;
  final DateTime updatedAt;

  IndividualModel({
    required this.id,
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IndividualModel.fromJson(Map<String, dynamic> json) {
    return IndividualModel(
      id: json['id']?.toString() ?? '',
      userId: json['user']?.toString() ?? json['user_id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['phone'],
      address: json['address'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName'.trim();

  IndividualModel copyWith({
    String? id,
    String? userId,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IndividualModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
