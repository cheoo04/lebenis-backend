import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../models/invoice_model.dart';
import '../repositories/invoice_repository.dart';

// Provider du repository
final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return InvoiceRepository(dioClient);
});

// State pour la liste des factures
class InvoicesState {
  final List<InvoiceModel> invoices;
  final bool isLoading;
  final String? error;

  InvoicesState({
    this.invoices = const [],
    this.isLoading = false,
    this.error,
  });

  InvoicesState copyWith({
    List<InvoiceModel>? invoices,
    bool? isLoading,
    String? error,
  }) {
    return InvoicesState(
      invoices: invoices ?? this.invoices,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier pour gérer les factures
class InvoicesNotifier extends Notifier<InvoicesState> {
  @override
  InvoicesState build() {
    loadInvoices();
    return InvoicesState();
  }

  Future<void> loadInvoices({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final repository = ref.read(invoiceRepositoryProvider);
      final invoices = await repository.getMyInvoices(status: status);

      state = InvoicesState(
        invoices: invoices,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>?> payInvoice({
    required String invoiceId, // UUID
    required String paymentMethod,
    required String phoneNumber,
  }) async {
    try {
      final repository = ref.read(invoiceRepositoryProvider);
      final result = await repository.payInvoice(
        invoiceId: invoiceId,
        paymentMethod: paymentMethod,
        phoneNumber: phoneNumber,
      );

      // Recharger la liste après paiement
      await loadInvoices();

      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<String?> downloadInvoicePDF(String invoiceId, String savePath) async {
    try {
      final repository = ref.read(invoiceRepositoryProvider);
      final path = await repository.downloadInvoicePDF(invoiceId, savePath);
      return path;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}

// Provider principal des factures
final invoicesProvider = NotifierProvider<InvoicesNotifier, InvoicesState>(() {
  return InvoicesNotifier();
});

// Provider pour le détail d'une facture
final invoiceDetailProvider = FutureProvider.family<InvoiceModel, String>((ref, invoiceId) async {
  final repository = ref.watch(invoiceRepositoryProvider);
  return repository.getInvoiceDetail(invoiceId);
});
