// lib/data/models/user_model.dart

/// Modèle représentant un utilisateur (User)
/// Correspond à la réponse de l'API backend pour l'authentification
class UserModel {
  final String id; // UUID from backend
  final String email;
  final String userType; // 'driver', 'merchant', 'admin'
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? profilePhoto;
  final bool isActive;
  final bool isVerified;
  final bool isStaff;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.userType,
    this.firstName,
    this.lastName,
    this.phone,
    this.profilePhoto,
    this.isActive = true,
    this.isVerified = false,
    this.isStaff = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Créer un UserModel depuis JSON (API response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      userType: json['user_type']?.toString() ?? 'driver',
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      phone: json['phone']?.toString(),
      profilePhoto: json['profile_photo']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 'true',
      isVerified: json['is_verified'] == true || json['is_verified'] == 'true',
      isStaff: json['is_staff'] == true || json['is_staff'] == 'true',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
    );
  }

  /// Convertir en JSON (pour envoi à l'API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_type': userType,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'profile_photo': profilePhoto,
      'is_active': isActive,
      'is_verified': isVerified,
      'is_staff': isStaff,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Obtenir le nom complet
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName'.trim();
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return email; // Fallback sur l'email
  }

  /// Obtenir les initiales (pour avatar)
  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    } else if (firstName != null) {
      return firstName!.substring(0, 1).toUpperCase();
    }
    return email.substring(0, 1).toUpperCase();
  }

  /// Copier avec modifications
  UserModel copyWith({
    String? id,
    String? email,
    String? userType,
    String? firstName,
    String? lastName,
    String? phone,
    String? profilePhoto,
    bool? isActive,
    bool? isVerified,
    bool? isStaff,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      isStaff: isStaff ?? this.isStaff,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}
