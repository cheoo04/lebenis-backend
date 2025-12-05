class MerchantStatsModel {
  final String id; // UUID
  final String businessName;
  final String verificationStatus;
  final int periodDays;
  
  // Livraisons
  final int totalDeliveries;
  final int periodDeliveries;
  final int delivered;
  final int inProgress;
  final int pending;
  final int cancelled;
  final double successRate;
  
  // Revenus
  final double periodRevenue;
  final double totalRevenue;
  final double totalBilled;
  final double paid;
  final double pendingPayment;
  
  // Factures
  final int invoicesTotal;
  final int invoicesPaid;
  final int invoicesPending;
  
  // Livraisons actives
  final int activeDeliveries;

  MerchantStatsModel({
    required this.id,
    required this.businessName,
    required this.verificationStatus,
    required this.periodDays,
    required this.totalDeliveries,
    required this.periodDeliveries,
    required this.delivered,
    required this.inProgress,
    required this.pending,
    required this.cancelled,
    required this.successRate,
    required this.periodRevenue,
    required this.totalRevenue,
    required this.totalBilled,
    required this.paid,
    required this.pendingPayment,
    required this.invoicesTotal,
    required this.invoicesPaid,
    required this.invoicesPending,
    required this.activeDeliveries,
  });

  factory MerchantStatsModel.fromJson(Map<String, dynamic> json) {
    final merchant = json['merchant'] ?? {};
    final deliveries = json['deliveries'] ?? {};
    final revenue = json['revenue'] ?? {};
    final invoices = json['invoices'] ?? {};
    
    return MerchantStatsModel(
      id: merchant['id']?.toString() ?? '',
      businessName: merchant['business_name'] ?? '',
      verificationStatus: merchant['verification_status'] ?? 'pending',
      periodDays: json['period_days'] ?? 30,
      totalDeliveries: deliveries['total_all_time'] ?? 0,
      periodDeliveries: deliveries['period_total'] ?? 0,
      delivered: deliveries['delivered'] ?? 0,
      inProgress: deliveries['in_progress'] ?? 0,
      pending: deliveries['pending'] ?? 0,
      cancelled: deliveries['cancelled'] ?? 0,
      successRate: _parseDouble(deliveries['success_rate']),
      periodRevenue: _parseDouble(revenue['period_revenue']),
      totalRevenue: _parseDouble(revenue['total_revenue']) ?? _parseDouble(revenue['total_billed']),
      totalBilled: _parseDouble(revenue['total_billed']),
      paid: _parseDouble(revenue['paid']),
      pendingPayment: _parseDouble(revenue['pending_payment']),
      invoicesTotal: invoices['total'] ?? 0,
      invoicesPaid: invoices['paid'] ?? 0,
      invoicesPending: invoices['pending'] ?? 0,
      activeDeliveries: (deliveries['in_progress'] ?? 0) + (deliveries['pending'] ?? 0),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String get formattedRevenue => '${periodRevenue.toStringAsFixed(0)} FCFA';
}