class MerchantModel {
  final int id;
  final String businessName;
  final String email;
  final String phone;
  final String address;
  final String verificationStatus; // "approved", "pending", "rejected"
  final String? registreCommerce; // URL du document
  final String? profilePhoto;
  final DateTime createdAt;

  MerchantModel({
    required this.id,
    required this.businessName,
    required this.email,
    required this.phone,
    required this.address,
    required this.verificationStatus,
    this.registreCommerce,
    this.profilePhoto,
    required this.createdAt,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      id: json['id'],
      businessName: json['business_name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      verificationStatus: json['verification_status'] ?? 'pending',
      registreCommerce: json['registre_commerce'],
      profilePhoto: json['profile_photo'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'email': email,
      'phone': phone,
      'address': address,
      'verification_status': verificationStatus,
    };
  }

  // Alias pour compatibilité
  String get phoneNumber => phone;
  
  // Vérifier si le compte est vérifié
  bool get isVerified => verificationStatus == 'approved';
  
  bool get isPending => verificationStatus == 'pending';
  
  bool get isRejected => verificationStatus == 'rejected';

  String get statusLabel {
    switch (verificationStatus) {
      case 'approved':
        return 'Approuvé';
      case 'pending':
        return 'En attente';
      case 'rejected':
        return 'Rejeté';
      default:
        return verificationStatus;
    }
  }
}