class InvoiceItemModel {
  final String id; // UUID
  final String deliveryId; // UUID
  final String description;
  final double amount;
  final DateTime createdAt;

  InvoiceItemModel({
    required this.id,
    required this.deliveryId,
    required this.description,
    required this.amount,
    required this.createdAt,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id']?.toString() ?? '',
      deliveryId: json['delivery']?['id']?.toString() ?? '',
      description: json['description'] ?? '',
      amount: double.parse(json['amount'].toString()),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class InvoiceModel {
  final String id; // UUID
  final String invoiceNumber;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalDeliveries;
  final double subtotal;
  final double commissionRate;
  final double commissionAmount;
  final double taxRate;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String status; // 'pending', 'paid', 'overdue', 'cancelled'
  final DateTime dueDate;
  final String? paymentMethod;
  final String? paymentReference;
  final DateTime? paidAt;
  final String? notes;
  final DateTime createdAt;
  final List<InvoiceItemModel> items;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.periodStart,
    required this.periodEnd,
    required this.totalDeliveries,
    required this.subtotal,
    required this.commissionRate,
    required this.commissionAmount,
    required this.taxRate,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.status,
    required this.dueDate,
    this.paymentMethod,
    this.paymentReference,
    this.paidAt,
    this.notes,
    required this.createdAt,
    this.items = const [],
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id']?.toString() ?? '',
      invoiceNumber: json['invoice_number'],
      periodStart: DateTime.parse(json['period_start']),
      periodEnd: DateTime.parse(json['period_end']),
      totalDeliveries: json['total_deliveries'] ?? 0,
      subtotal: double.parse(json['subtotal'].toString()),
      commissionRate: double.parse(json['commission_rate'].toString()),
      commissionAmount: double.parse(json['commission_amount'].toString()),
      taxRate: double.parse(json['tax_rate'].toString()),
      taxAmount: double.parse(json['tax_amount'].toString()),
      discountAmount: double.parse(json['discount_amount']?.toString() ?? '0'),
      totalAmount: double.parse(json['total_amount'].toString()),
      status: json['status'],
      dueDate: DateTime.parse(json['due_date']),
      paymentMethod: json['payment_method'],
      paymentReference: json['payment_reference'],
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => InvoiceItemModel.fromJson(item))
              .toList() ??
          [],
    );
  }

  bool get isPaid => status == 'paid';
  bool get isPending => status == 'pending';
  bool get isOverdue => status == 'overdue';

  String get statusLabel {
    switch (status) {
      case 'paid':
        return 'Payée';
      case 'pending':
        return 'En attente';
      case 'overdue':
        return 'En retard';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }
}
