class MerchantStatsModel {
  final int id;
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
  final double totalBilled;
  final double paid;
  final double pendingPayment;
  
  // Factures
  final int invoicesTotal;
  final int invoicesPaid;
  final int invoicesPending;

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
    required this.totalBilled,
    required this.paid,
    required this.pendingPayment,
    required this.invoicesTotal,
    required this.invoicesPaid,
    required this.invoicesPending,
  });

  factory MerchantStatsModel.fromJson(Map<String, dynamic> json) {
    return MerchantStatsModel(
      id: json['id'],
      businessName: json['business_name'],
      verificationStatus: json['verification_status'],
      periodDays: json['period_days'] ?? 30,
      totalDeliveries: json['deliveries']['total_all_time'] ?? 0,
      periodDeliveries: json['deliveries']['period_total'] ?? 0,
      delivered: json['deliveries']['delivered'] ?? 0,
      inProgress: json['deliveries']['in_progress'] ?? 0,
      pending: json['deliveries']['pending'] ?? 0,
      cancelled: json['deliveries']['cancelled'] ?? 0,
      successRate: (json['deliveries']['success_rate'] ?? 0.0).toDouble(),
      periodRevenue: (json['revenue']['period_revenue'] ?? 0.0).toDouble(),
      totalBilled: (json['revenue']['total_billed'] ?? 0.0).toDouble(),
      paid: (json['revenue']['paid'] ?? 0.0).toDouble(),
      pendingPayment: (json['revenue']['pending_payment'] ?? 0.0).toDouble(),
      invoicesTotal: json['invoices']['total'] ?? 0,
      invoicesPaid: json['invoices']['paid'] ?? 0,
      invoicesPending: json['invoices']['pending'] ?? 0,
    );
  }

  String get formattedRevenue => '${periodRevenue.toStringAsFixed(0)} FCFA';
}