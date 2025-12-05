class MerchantModel {
  final String id; // UUID
  final Map<String, dynamic>? user; // Objet User du backend
  final String businessName;
  final String? businessType;
  final String? registrationNumber;
  final String? taxId;
  final String verificationStatus; // "pending", "verified", "rejected"
  final String? rejectionReason;
  final String? documentsUrl;
  final String? rccmDocument;
  final String? idDocument;
  final double commissionRate;
  final double currentBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  MerchantModel({
    required this.id,
    this.user,
    required this.businessName,
    this.businessType,
    this.registrationNumber,
    this.taxId,
    required this.verificationStatus,
    this.rejectionReason,
    this.documentsUrl,
    this.rccmDocument,
    this.idDocument,
    required this.commissionRate,
    required this.currentBalance,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    // Le backend peut retourner 'user' comme un ID ou un objet
    Map<String, dynamic>? userData;
    if (json['user'] != null) {
      if (json['user'] is Map<String, dynamic>) {
        userData = json['user'] as Map<String, dynamic>;
      } else if (json['user'] is int || json['user'] is String) {
        // Si c'est juste un ID, on ne peut pas extraire les infos
        userData = null;
      }
    }
    
    return MerchantModel(
      id: json['id']?.toString() ?? '',
      user: userData,
      businessName: json['business_name'] ?? '',
      businessType: json['business_type'],
      registrationNumber: json['registration_number'],
      taxId: json['tax_id'],
      verificationStatus: json['verification_status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      documentsUrl: json['documents_url'],
      rccmDocument: json['rccm_document'],
      idDocument: json['id_document'],
      commissionRate: _parseDouble(json['commission_rate']),
      currentBalance: _parseDouble(json['current_balance']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_name': businessName,
      'business_type': businessType,
      'verification_status': verificationStatus,
      'commission_rate': commissionRate,
      'current_balance': currentBalance,
    };
  }

  // Getters pour compatibilité et accès facile
  String get email => user?['email'] ?? '';
  String get phone => user?['phone'] ?? '';
  String get firstName => user?['first_name'] ?? '';
  String get lastName => user?['last_name'] ?? '';
  String get address => user?['address'] ?? ''; // Adresse de l'utilisateur
  
  // Alias pour compatibilité
  String get phoneNumber => phone;
  
  // Vérifier si le compte est vérifié (backend utilise "approved" ou "verified")
  bool get isVerified => verificationStatus == 'approved' || verificationStatus == 'verified';
  
  bool get isPending => verificationStatus == 'pending';
  
  bool get isRejected => verificationStatus == 'rejected';

  String get statusLabel {
    switch (verificationStatus) {
      case 'approved':
      case 'verified':
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