import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../../data/providers/invoice_provider.dart';
import '../../../../data/models/invoice_model.dart';
import '../../../../shared/widgets/modern_button.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final String invoiceId; // UUID

  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  bool _isProcessing = false;
  String? _selectedPaymentMethod;
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _showPaymentDialog(InvoiceModel invoice) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payer la facture'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Montant: ${invoice.totalAmount.toStringAsFixed(0)} FCFA',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Méthode de paiement'),
              RadioListTile<String>(
                title: const Text('Orange Money'),
                value: 'orange_money',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() => _selectedPaymentMethod = value);
                },
              ),
              RadioListTile<String>(
                title: const Text('MTN Mobile Money'),
                value: 'mtn_momo',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() => _selectedPaymentMethod = value);
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Numéro de téléphone',
                  hintText: '77 123 45 67',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: _selectedPaymentMethod != null && _phoneController.text.isNotEmpty
                ? () {
                    Navigator.pop(context);
                    _processPayment(invoice);
                  }
                : null,
            child: const Text('Payer'),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment(InvoiceModel invoice) async {
    if (_selectedPaymentMethod == null || _phoneController.text.isEmpty) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final result = await ref.read(invoicesProvider.notifier).payInvoice(
            invoiceId: invoice.id,
            paymentMethod: _selectedPaymentMethod!,
            phoneNumber: _phoneController.text,
          );

      if (mounted) {
        setState(() => _isProcessing = false);

        if (result != null && result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Paiement initié avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          // Recharger le détail
          ref.invalidate(invoiceDetailProvider(widget.invoiceId));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors du paiement'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _downloadPDF(InvoiceModel invoice) async {
    setState(() => _isProcessing = true);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${directory.path}/Invoices');
      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }

      final savePath = '${pdfDir.path}/invoice_${invoice.invoiceNumber}.pdf';
      final path = await ref.read(invoicesProvider.notifier).downloadInvoicePDF(
            invoice.id,
            savePath,
          );

      if (mounted && path != null) {
        setState(() => _isProcessing = false);

        final action = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('PDF téléchargé'),
            content: const Text('Le PDF de la facture a été téléchargé avec succès.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'close'),
                child: const Text('Fermer'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, 'open'),
                child: const Text('Ouvrir'),
              ),
            ],
          ),
        );

        if (action == 'open') {
          await OpenFile.open(path);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceAsync = ref.watch(invoiceDetailProvider(widget.invoiceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la facture'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: invoiceAsync.when(
        data: (invoice) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(invoice),
              const SizedBox(height: 24),
              _buildPeriodCard(invoice),
              const SizedBox(height: 16),
              _buildAmountBreakdown(invoice),
              const SizedBox(height: 16),
              _buildItems(invoice),
              const SizedBox(height: 32),
              if (!invoice.isPaid) ...[
                ModernButton(
                  text: _isProcessing ? 'Traitement...' : 'Payer maintenant',
                  icon: Icons.payment,
                  onPressed: _isProcessing ? null : () => _showPaymentDialog(invoice),
                  backgroundColor: Colors.green,
                  isLoading: _isProcessing,
                ),
                const SizedBox(height: 12),
              ],
              ModernButton(
                text: _isProcessing ? 'Téléchargement...' : 'Télécharger le PDF',
                icon: Icons.picture_as_pdf,
                onPressed: _isProcessing ? null : () => _downloadPDF(invoice),
                backgroundColor: Colors.deepPurple,
                isLoading: _isProcessing,
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text('Erreur: ${error.toString()}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(invoiceDetailProvider(widget.invoiceId)),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(InvoiceModel invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Facture N°',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        invoice.invoiceNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(invoice.status),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Date de création', DateFormat('dd MMM yyyy').format(invoice.createdAt)),
            _buildInfoRow('Date d\'échéance', DateFormat('dd MMM yyyy').format(invoice.dueDate)),
            if (invoice.paidAt != null)
              _buildInfoRow('Date de paiement', DateFormat('dd MMM yyyy').format(invoice.paidAt!)),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodCard(InvoiceModel invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  'Période facturée',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Du',
              DateFormat('dd MMM yyyy').format(invoice.periodStart),
            ),
            _buildInfoRow(
              'Au',
              DateFormat('dd MMM yyyy').format(invoice.periodEnd),
            ),
            _buildInfoRow(
              'Livraisons',
              '${invoice.totalDeliveries}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountBreakdown(InvoiceModel invoice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.receipt, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  'Détail des montants',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Sous-total', '${invoice.subtotal.toStringAsFixed(0)} FCFA'),
            _buildInfoRow(
              'Commission (${invoice.commissionRate}%)',
              '${invoice.commissionAmount.toStringAsFixed(0)} FCFA',
            ),
            _buildInfoRow(
              'TVA (${invoice.taxRate}%)',
              '${invoice.taxAmount.toStringAsFixed(0)} FCFA',
            ),
            if (invoice.discountAmount > 0)
              _buildInfoRow(
                'Réduction',
                '-${invoice.discountAmount.toStringAsFixed(0)} FCFA',
              ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL À PAYER',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${invoice.totalAmount.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItems(InvoiceModel invoice) {
    if (invoice.items.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.list, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text(
                  'Détail des livraisons',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...invoice.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.description,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      Text(
                        '${item.amount.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'paid':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'overdue':
        color = Colors.red;
        icon = Icons.warning;
        break;
      case 'cancelled':
        color = Colors.grey;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.orange;
        icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            _getStatusLabel(status),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
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
