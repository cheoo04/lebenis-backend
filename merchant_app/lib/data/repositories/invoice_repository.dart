import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/invoice_model.dart';

class InvoiceRepository {
  final DioClient dioClient;

  InvoiceRepository(this.dioClient);

  /// GET /api/v1/payments/invoices/my-invoices/
  Future<List<InvoiceModel>> getMyInvoices({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await dioClient.get(
        '${ApiConstants.invoices}my-invoices/',
        queryParameters: queryParams,
      );

      final results = response.data['results'] as List<dynamic>?;
      if (results != null) {
        return results.map((json) => InvoiceModel.fromJson(json)).toList();
      }

      // Si pas de pagination, directement une liste
      if (response.data is List) {
        return (response.data as List)
            .map((json) => InvoiceModel.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Erreur lors du chargement des factures: ${e.toString()}');
    }
  }

  /// GET /api/v1/payments/invoices/{id}/
  Future<InvoiceModel> getInvoiceDetail(String invoiceId) async {
    try {
      final response = await dioClient.get('${ApiConstants.invoices}$invoiceId/');
      return InvoiceModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Erreur lors du chargement de la facture: ${e.toString()}');
    }
  }

  /// POST /api/v1/payments/invoices/{id}/pay/
  /// Payer une facture via Mobile Money
  Future<Map<String, dynamic>> payInvoice({
    required String invoiceId, // UUID
    required String paymentMethod, // 'orange_money' ou 'mtn_momo'
    required String phoneNumber,
  }) async {
    try {
      final response = await dioClient.post(
        '${ApiConstants.invoices}$invoiceId/pay/',
        data: {
          'payment_method': paymentMethod,
          'phone_number': phoneNumber,
        },
      );

      return {
        'success': response.data['success'] ?? true,
        'payment_reference': response.data['payment_reference'],
        'message': response.data['message'],
      };
    } catch (e) {
      throw Exception('Erreur lors du paiement: ${e.toString()}');
    }
  }

  /// GET /api/v1/payments/invoices/{id}/download-pdf/
  Future<String> downloadInvoicePDF(String invoiceId, String savePath) async {
    try {
      await dioClient.download(
        '${ApiConstants.invoices}$invoiceId/download-pdf/',
        savePath,
      );
      return savePath;
    } catch (e) {
      throw Exception('Erreur lors du téléchargement du PDF: ${e.toString()}');
    }
  }
}
