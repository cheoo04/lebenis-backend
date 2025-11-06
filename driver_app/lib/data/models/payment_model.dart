// lib/data/models/payment_model.dart

/// Modèle Payment - Phase 2
/// Représente un paiement individuel pour une livraison
class PaymentModel {
  final String id;
  final String deliveryId;
  final String driverId;
  final double totalAmount;
  final double driverAmount;
  final double platformCommission;
  final double commissionPercentage;
  final String status; // pending, processing, completed, failed
  final String paymentMethod; // orange_money, mtn_momo, wave, moov_money, bank_transfer
  final String? reference;
  final String? transactionId;
  final DateTime createdAt;
  final DateTime? paidAt;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  PaymentModel({
    required this.id,
    required this.deliveryId,
    required this.driverId,
    required this.totalAmount,
    required this.driverAmount,
    required this.platformCommission,
    required this.commissionPercentage,
    required this.status,
    required this.paymentMethod,
    this.reference,
    this.transactionId,
    required this.createdAt,
    this.paidAt,
    this.completedAt,
    this.failedAt,
    this.errorMessage,
    this.metadata,
  });

  /// Factory constructor depuis JSON
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString() ?? '',
      deliveryId: json['delivery']?.toString() ?? json['delivery_id']?.toString() ?? '',
      driverId: json['driver']?.toString() ?? json['driver_id']?.toString() ?? '',
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      driverAmount: double.tryParse(json['driver_amount']?.toString() ?? '0') ?? 0.0,
      platformCommission: double.tryParse(json['platform_commission']?.toString() ?? '0') ?? 0.0,
      commissionPercentage: double.tryParse(json['commission_percentage']?.toString() ?? '20') ?? 20.0,
      status: json['status']?.toString() ?? 'pending',
      paymentMethod: json['payment_method']?.toString() ?? 'orange_money',
      reference: json['reference']?.toString(),
      transactionId: json['transaction_id']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at'].toString()) : null,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'].toString()) : null,
      failedAt: json['failed_at'] != null ? DateTime.tryParse(json['failed_at'].toString()) : null,
      errorMessage: json['error_message']?.toString(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'delivery': deliveryId,
      'driver': driverId,
      'total_amount': totalAmount.toString(),
      'driver_amount': driverAmount.toString(),
      'platform_commission': platformCommission.toString(),
      'commission_percentage': commissionPercentage.toString(),
      'status': status,
      'payment_method': paymentMethod,
      if (reference != null) 'reference': reference,
      if (transactionId != null) 'transaction_id': transactionId,
      'created_at': createdAt.toIso8601String(),
      if (paidAt != null) 'paid_at': paidAt!.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      if (failedAt != null) 'failed_at': failedAt!.toIso8601String(),
      if (errorMessage != null) 'error_message': errorMessage,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Label du statut en français
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'processing':
        return 'En traitement';
      case 'completed':
        return 'Complété';
      case 'failed':
        return 'Échoué';
      default:
        return status;
    }
  }

  /// Label de la méthode de paiement
  String get paymentMethodLabel {
    switch (paymentMethod) {
      case 'orange_money':
        return 'Orange Money';
      case 'mtn_momo':
        return 'MTN Mobile Money';
      case 'wave':
        return 'Wave';
      case 'moov_money':
        return 'Moov Money';
      case 'bank_transfer':
        return 'Virement bancaire';
      default:
        return paymentMethod;
    }
  }

  /// Icône selon la méthode de paiement
  String get paymentMethodIcon {
    switch (paymentMethod) {
      case 'orange_money':
        return '🧡'; // Orange
      case 'mtn_momo':
        return '💛'; // Jaune MTN
      case 'wave':
        return '💙'; // Bleu Wave
      case 'moov_money':
        return '💚'; // Vert Moov
      case 'bank_transfer':
        return '🏦';
      default:
        return '💰';
    }
  }

  @override
  String toString() {
    return 'PaymentModel(id: $id, amount: $driverAmount FCFA, status: $status)';
  }
}

/// Modèle DailyPayout - Phase 2
/// Représente un regroupement quotidien de paiements (versement automatique 23:59)
class DailyPayoutModel {
  final String id;
  final String driverId;
  final DateTime payoutDate;
  final double totalAmount;
  final int paymentCount;
  final String status; // pending, processing, completed, failed
  final String paymentMethod;
  final String? transactionId;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final String? errorMessage;
  final DateTime createdAt;
  final List<PaymentModel> payments; // Liste des paiements inclus

  DailyPayoutModel({
    required this.id,
    required this.driverId,
    required this.payoutDate,
    required this.totalAmount,
    required this.paymentCount,
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    this.completedAt,
    this.failedAt,
    this.errorMessage,
    required this.createdAt,
    this.payments = const [],
  });

  factory DailyPayoutModel.fromJson(Map<String, dynamic> json) {
    return DailyPayoutModel(
      id: json['id']?.toString() ?? '',
      driverId: json['driver']?.toString() ?? json['driver_id']?.toString() ?? '',
      payoutDate: DateTime.tryParse(json['payout_date']?.toString() ?? '') ?? DateTime.now(),
      totalAmount: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      paymentCount: int.tryParse(json['payment_count']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'pending',
      paymentMethod: json['payment_method']?.toString() ?? 'orange_money',
      transactionId: json['transaction_id']?.toString(),
      completedAt: json['completed_at'] != null 
          ? DateTime.tryParse(json['completed_at'].toString()) 
          : null,
      failedAt: json['failed_at'] != null 
          ? DateTime.tryParse(json['failed_at'].toString()) 
          : null,
      errorMessage: json['error_message']?.toString(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      payments: (json['payments'] as List<dynamic>?)
              ?.map((p) => PaymentModel.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driver': driverId,
      'payout_date': payoutDate.toIso8601String(),
      'total_amount': totalAmount.toString(),
      'payment_count': paymentCount,
      'status': status,
      'payment_method': paymentMethod,
      if (transactionId != null) 'transaction_id': transactionId,
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      if (failedAt != null) 'failed_at': failedAt!.toIso8601String(),
      if (errorMessage != null) 'error_message': errorMessage,
      'created_at': createdAt.toIso8601String(),
      'payments': payments.map((p) => p.toJson()).toList(),
    };
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'processing':
        return 'En traitement';
      case 'completed':
        return 'Complété';
      case 'failed':
        return 'Échoué';
      default:
        return status;
    }
  }
}

/// Modèle TransactionHistory - Phase 2
/// Historique complet des transactions (collection, disbursement, refund)
class TransactionHistoryModel {
  final String id;
  final String transactionType; // collection, disbursement, refund
  final double amount;
  final String currency;
  final String driverId;
  final String? paymentId;
  final String? deliveryId;
  final String? externalReference;
  final String provider; // orange_money, mtn_momo, wave, moov_money
  final String status; // success, failed, pending
  final String? errorMessage;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;

  TransactionHistoryModel({
    required this.id,
    required this.transactionType,
    required this.amount,
    required this.currency,
    required this.driverId,
    this.paymentId,
    this.deliveryId,
    this.externalReference,
    required this.provider,
    required this.status,
    this.errorMessage,
    this.metadata,
    required this.createdAt,
    this.completedAt,
  });

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryModel(
      id: json['id']?.toString() ?? '',
      transactionType: json['transaction_type']?.toString() ?? 'collection',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      currency: json['currency']?.toString() ?? 'XOF',
      driverId: json['driver']?.toString() ?? json['driver_id']?.toString() ?? '',
      paymentId: json['payment']?.toString() ?? json['payment_id']?.toString(),
      deliveryId: json['delivery']?.toString() ?? json['delivery_id']?.toString(),
      externalReference: json['external_reference']?.toString(),
      provider: json['provider']?.toString() ?? 'orange_money',
      status: json['status']?.toString() ?? 'pending',
      errorMessage: json['error_message']?.toString(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      completedAt: json['completed_at'] != null 
          ? DateTime.tryParse(json['completed_at'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_type': transactionType,
      'amount': amount.toString(),
      'currency': currency,
      'driver': driverId,
      if (paymentId != null) 'payment': paymentId,
      if (deliveryId != null) 'delivery': deliveryId,
      if (externalReference != null) 'external_reference': externalReference,
      'provider': provider,
      'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
      if (metadata != null) 'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
    };
  }

  String get transactionTypeLabel {
    switch (transactionType) {
      case 'collection':
        return 'Paiement reçu';
      case 'disbursement':
        return 'Versement';
      case 'refund':
        return 'Remboursement';
      default:
        return transactionType;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'success':
        return 'Réussi';
      case 'failed':
        return 'Échoué';
      case 'pending':
        return 'En attente';
      default:
        return status;
    }
  }

  String get providerLabel {
    switch (provider) {
      case 'orange_money':
        return 'Orange Money';
      case 'mtn_momo':
        return 'MTN MoMo';
      case 'wave':
        return 'Wave';
      case 'moov_money':
        return 'Moov Money';
      default:
        return provider;
    }
  }
}
