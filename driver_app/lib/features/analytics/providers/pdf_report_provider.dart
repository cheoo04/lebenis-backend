import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/pdf_report_service.dart';
import '../../../data/providers/auth_provider.dart';

// PDF Report Service Provider
final pdfReportServiceProvider = Provider<PDFReportService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PDFReportService(dioClient);
});

// PDF Download State
class PDFDownloadState {
  final bool isDownloading;
  final double progress;
  final String? error;
  final String? filePath;

  PDFDownloadState({
    this.isDownloading = false,
    this.progress = 0.0,
    this.error,
    this.filePath,
  });

  PDFDownloadState copyWith({
    bool? isDownloading,
    double? progress,
    String? error,
    String? filePath,
  }) {
    return PDFDownloadState(
      isDownloading: isDownloading ?? this.isDownloading,
      progress: progress ?? this.progress,
      error: error,
      filePath: filePath ?? this.filePath,
    );
  }
}

// PDF Download Notifier
class PDFDownloadNotifier extends StateNotifier<PDFDownloadState> {
  final PDFReportService _pdfService;

  PDFDownloadNotifier(this._pdfService) : super(PDFDownloadState());

  Future<void> downloadReport({
    required String period,
    String? startDate,
    String? endDate,
  }) async {
    state = PDFDownloadState(isDownloading: true, progress: 0.0);

    try {
      final filePath = await _pdfService.downloadAnalyticsPDF(
        period: period,
        startDate: startDate,
        endDate: endDate,
        onProgress: (progress) {
          state = state.copyWith(progress: progress);
        },
      );

      state = PDFDownloadState(
        isDownloading: false,
        progress: 1.0,
        filePath: filePath,
      );
    } catch (e) {
      state = PDFDownloadState(
        isDownloading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> downloadTestReport() async {
    state = PDFDownloadState(isDownloading: true, progress: 0.0);

    try {
      final filePath = await _pdfService.downloadTestPDF(
        onProgress: (progress) {
          state = state.copyWith(progress: progress);
        },
      );

      state = PDFDownloadState(
        isDownloading: false,
        progress: 1.0,
        filePath: filePath,
      );
    } catch (e) {
      state = PDFDownloadState(
        isDownloading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> shareReport(String filePath) async {
    try {
      await _pdfService.sharePDF(filePath);
    } catch (e) {
      state = state.copyWith(error: 'Failed to share PDF: ${e.toString()}');
    }
  }

  Future<void> openReport(String filePath) async {
    try {
      await _pdfService.openPDF(filePath);
    } catch (e) {
      state = state.copyWith(error: 'Failed to open PDF: ${e.toString()}');
    }
  }

  void resetState() {
    state = PDFDownloadState();
  }
}

final pdfDownloadProvider =
    StateNotifierProvider<PDFDownloadNotifier, PDFDownloadState>((ref) {
  final pdfService = ref.watch(pdfReportServiceProvider);
  return PDFDownloadNotifier(pdfService);
});
