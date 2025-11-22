// lib/data/providers/payment_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/auth_service.dart';
import '../repositories/payment_repository.dart';
import '../models/payment_model.dart';

// ========== REPOSITORY PROVIDER ==========

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final authService = ref.read(authServiceProvider);
  final dioClient = DioClient(authService);
  return PaymentRepository(dioClient);
});

// ========== AUTH SERVICE PROVIDER (réutilisé) ==========

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// ========== PAYMENT STATE ==========

class PaymentState {
  final bool isLoading;
  final String? error;
  
  // My Earnings (période sélectionnée)
  final Map<String, dynamic>? earnings;
  final List<PaymentModel>? earningsPayments;
  
  // My Payouts (historique des versements quotidiens)
  final List<DailyPayoutModel>? payouts;
  final bool isLoadingPayouts;
  
  // Stats (lifetime + ce mois)
  final Map<String, dynamic>? stats;
  
  // Transactions (historique complet)
  final List<TransactionHistoryModel>? transactions;
  final bool isLoadingTransactions;
  
  // Pagination
  final int currentPage;
  final bool hasMore;

  PaymentState({
    this.isLoading = false,
    this.error,
    this.earnings,
    this.earningsPayments,
    this.payouts,
    this.isLoadingPayouts = false,
    this.stats,
    this.transactions,
    this.isLoadingTransactions = false,
    this.currentPage = 1,
    this.hasMore = true,
  });

  PaymentState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? earnings,
    List<PaymentModel>? earningsPayments,
    List<DailyPayoutModel>? payouts,
    bool? isLoadingPayouts,
    Map<String, dynamic>? stats,
    List<TransactionHistoryModel>? transactions,
    bool? isLoadingTransactions,
    int? currentPage,
    bool? hasMore,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      earnings: earnings ?? this.earnings,
      earningsPayments: earningsPayments ?? this.earningsPayments,
      payouts: payouts ?? this.payouts,
      isLoadingPayouts: isLoadingPayouts ?? this.isLoadingPayouts,
      stats: stats ?? this.stats,
      transactions: transactions ?? this.transactions,
      isLoadingTransactions: isLoadingTransactions ?? this.isLoadingTransactions,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// ========== PAYMENT NOTIFIER ==========


class PaymentNotifier extends Notifier<PaymentState> {
  late final PaymentRepository _paymentRepository;

  @override
  PaymentState build() {
    _paymentRepository = ref.read(paymentRepositoryProvider);
    return PaymentState();
  }

  /// Charger les gains par période
  Future<void> loadEarnings({String period = 'week'}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      debugPrint('📊 [PaymentNotifier] loadEarnings(period=$period)');
      
      final data = await _paymentRepository.getMyEarnings(period: period);
      
      state = state.copyWith(
        isLoading: false,
        earnings: data,
        earningsPayments: data['payments'] as List<PaymentModel>?,
      );
      
      debugPrint('✅ [PaymentNotifier] Earnings loaded: ${data['total_earnings']} FCFA');
    } catch (e) {
      debugPrint('❌ [PaymentNotifier] loadEarnings error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Charger les versements quotidiens (payouts)
  Future<void> loadPayouts({int page = 1}) async {
    state = state.copyWith(isLoadingPayouts: true, error: null);
    
    try {
      debugPrint('💰 [PaymentNotifier] loadPayouts(page=$page)');
      
      final newPayouts = await _paymentRepository.getMyPayouts(page: page);
      
      List<DailyPayoutModel> allPayouts;
      if (page == 1) {
        allPayouts = newPayouts;
      } else {
        allPayouts = [...?state.payouts, ...newPayouts];
      }
      
      state = state.copyWith(
        isLoadingPayouts: false,
        payouts: allPayouts,
        currentPage: page,
        hasMore: newPayouts.length >= 20, // Si on a 20 éléments, il y en a peut-être plus
      );
      
      debugPrint('✅ [PaymentNotifier] Payouts loaded: ${allPayouts.length} total');
    } catch (e) {
      debugPrint('❌ [PaymentNotifier] loadPayouts error: $e');
      state = state.copyWith(
        isLoadingPayouts: false,
        error: e.toString(),
      );
    }
  }

  /// Charger les statistiques globales
  Future<void> loadStats() async {
    try {
      debugPrint('📈 [PaymentNotifier] loadStats()');
      
      final stats = await _paymentRepository.getStats();
      
      state = state.copyWith(stats: stats);
      
      debugPrint('✅ [PaymentNotifier] Stats loaded: ${stats['lifetime']?['total_earned']} FCFA lifetime');
    } catch (e) {
      debugPrint('❌ [PaymentNotifier] loadStats error: $e');
      // Ne pas bloquer si stats échouent
    }
  }

  /// Charger l'historique des transactions
  Future<void> loadTransactions({
    int page = 1,
    String? transactionType,
    String? status,
  }) async {
    state = state.copyWith(isLoadingTransactions: true, error: null);
    
    try {
      debugPrint('🧾 [PaymentNotifier] loadTransactions(page=$page, type=$transactionType)');
      
      final newTransactions = await _paymentRepository.getTransactions(
        page: page,
        transactionType: transactionType,
        status: status,
      );
      
      List<TransactionHistoryModel> allTransactions;
      if (page == 1) {
        allTransactions = newTransactions;
      } else {
        allTransactions = [...?state.transactions, ...newTransactions];
      }
      
      state = state.copyWith(
        isLoadingTransactions: false,
        transactions: allTransactions,
        currentPage: page,
        hasMore: newTransactions.length >= 20,
      );
      
      debugPrint('✅ [PaymentNotifier] Transactions loaded: ${allTransactions.length} total');
    } catch (e) {
      debugPrint('❌ [PaymentNotifier] loadTransactions error: $e');
      state = state.copyWith(
        isLoadingTransactions: false,
        error: e.toString(),
      );
    }
  }

  /// Charger toutes les données (earnings + stats + payouts)
  Future<void> loadAll({String period = 'week'}) async {
    await Future.wait([
      loadEarnings(period: period),
      loadStats(),
      loadPayouts(page: 1),
    ]);
  }

  /// Reset de l'état
  void reset() {
    state = PaymentState();
  }
}

// ========== PAYMENT PROVIDER ==========

final paymentProvider = NotifierProvider<PaymentNotifier, PaymentState>(PaymentNotifier.new);
