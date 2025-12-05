class UserModel {
  final String id;
  final String email;
  final String userType; // "merchant"
  final String firstName;
  final String lastName;

  UserModel({
    required this.id,
    required this.email,
    required this.userType,
    required this.firstName,
    required this.lastName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      userType: json['user_type'] ?? 'merchant',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'user_type': userType,
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}