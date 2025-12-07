// lib/data/repositories/payment_repository.dart

import 'package:flutter/foundation.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/payment_model.dart';

/// Repository pour gérer les paiements (Phase 2)
class PaymentRepository {

    /// POST /api/v1/payments/wave-session/
    /// Crée une session de paiement Wave et retourne l'URL de paiement.
    ///
    /// Params:
    /// - amount: montant à payer (double ou String)
    /// - currency: "XOF"
    /// - errorUrl: URL de retour en cas d'échec
    /// - successUrl: URL de retour en cas de succès
    ///
    /// Returns:
    ///   { "payment_url": "https://checkout.wave.com/session/abc123" }
    Future<String> createWaveSession({
      required double amount,
      required String currency,
      required String errorUrl,
      required String successUrl,
    }) async {
      try {
        final response = await _dioClient.post(
          ApiConstants.paymentWaveSession,
          data: {
            'amount': amount,
            'currency': currency,
            'error_url': errorUrl,
            'success_url': successUrl,
          },
        );
        final data = response.data as Map<String, dynamic>;
        final url = data['payment_url'] as String?;
        if (url == null || url.isEmpty) {
          throw Exception('Aucune URL de paiement Wave reçue.');
        }
        return url;
      } catch (e) {
        rethrow;
      }
    }
  final DioClient _dioClient;

  PaymentRepository(this._dioClient);

  /// GET /api/v1/payments/payments/my-earnings/
  /// Récupère les gains du driver par période
  /// 
  /// Params:
  /// - period: 'today', 'week', 'month'
  /// 
  /// Returns:
  /// ```json
  /// {
  ///   "period": "week",
  ///   "total_earnings": 45000,
  ///   "total_driver_amount": 36000,
  ///   "total_commission": 9000,
  ///   "payment_count": 8,
  ///   "payments": [...]
  /// }
  /// ```
  Future<Map<String, dynamic>> getMyEarnings({String period = 'week'}) async {
    try {
      
      final response = await _dioClient.get(
        ApiConstants.paymentMyEarnings,
        queryParameters: {'period': period},
      );

      
    // Parse les payments dans la réponse
    final data = response.data as Map<String, dynamic>;
    final payments = data['payments'] ?? [];
    data['payments'] = (payments as List)
      .map((p) => PaymentModel.fromJson(p as Map<String, dynamic>))
      .toList();
    return data;
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/v1/payments/payments/my-payouts/
  /// Récupère l'historique des versements quotidiens automatiques (23:59)
  /// 
  /// Returns:
  /// ```json
  /// {
  ///   "count": 12,
  ///   "results": [...]
  /// }
  /// ```
  Future<List<DailyPayoutModel>> getMyPayouts({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      
      final response = await _dioClient.get(
        ApiConstants.paymentMyPayouts,
        queryParameters: {
          'page': page,
          'page_size': pageSize,
        },
      );

      
    final results = response.data['results'] ?? [];
    return (results as List)
      .map((p) => DailyPayoutModel.fromJson(p as Map<String, dynamic>))
      .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/v1/payments/payments/stats/
  /// Statistiques globales (lifetime + ce mois)
  /// 
  /// Returns:
  /// ```json
  /// {
  ///   "lifetime": {
  ///     "total_earned": 450000,
  ///     "total_payments": 85,
  ///     "average_per_payment": 5294.12
  ///   },
  ///   "this_month": {
  ///     "total_earned": 120000,
  ///     "total_payments": 22
  ///   },
  ///   "payment_methods": {
  ///     "orange_money": 12,
  ///     "mtn_momo": 10
  ///   }
  /// }
  /// ```
  Future<Map<String, dynamic>> getStats() async {
    try {
      
      final response = await _dioClient.get(ApiConstants.paymentStats);

      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/v1/payments/payments/transactions/
  /// Historique complet des transactions (collection, disbursement, refund)
  /// 
  /// Params:
  /// - transaction_type: 'collection', 'disbursement', 'refund' (optionnel)
  /// - status: 'success', 'failed', 'pending' (optionnel)
  /// - start_date: YYYY-MM-DD (optionnel)
  /// - end_date: YYYY-MM-DD (optionnel)
  Future<List<TransactionHistoryModel>> getTransactions({
    int page = 1,
    int pageSize = 20,
    String? transactionType,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    try {
      
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      
      if (transactionType != null) queryParams['transaction_type'] = transactionType;
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      
      final response = await _dioClient.get(
        ApiConstants.paymentTransactions,
        queryParameters: queryParams,
      );

      
    final results = response.data['results'] ?? [];
    return (results as List)
      .map((t) => TransactionHistoryModel.fromJson(t as Map<String, dynamic>))
      .toList();
    } catch (e) {
      rethrow;
    }
  }
}
