import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import '../../core/network/dio_client.dart';

class PDFReportService {
  final DioClient _dioClient;

  PDFReportService(this._dioClient);

  /// Generate and download analytics PDF report
  /// 
  /// Parameters:
  /// - period: 'today', 'week', 'month', 'year', 'custom'
  /// - startDate: YYYY-MM-DD (required if period='custom')
  /// - endDate: YYYY-MM-DD (required if period='custom')
  /// - onProgress: Optional callback for download progress (0.0 to 1.0)
  /// 
  /// Returns: File path of downloaded PDF
  Future<String> downloadAnalyticsPDF({
    required String period,
    String? startDate,
    String? endDate,
    Function(double)? onProgress,
  }) async {
    try {
      // Prepare request body
      final data = <String, dynamic>{
        'period': period,
      };
      if (startDate != null) data['start_date'] = startDate;
      if (endDate != null) data['end_date'] = endDate;

      // Get downloads directory
      final directory = await _getDownloadsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'analytics_report_$timestamp.pdf';
      final filePath = '${directory.path}/$filename';

      // Download PDF
      await _dioClient.download(
        '/deliveries/reports/analytics-pdf/',
        filePath,
        data: data,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      return filePath;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Download test PDF (last 7 days)
  Future<String> downloadTestPDF({
    Function(double)? onProgress,
  }) async {
    try {
      final directory = await _getDownloadsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'test_report_$timestamp.pdf';
      final filePath = '${directory.path}/$filename';

      await _dioClient.download(
        '/deliveries/reports/test-pdf/',
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      return filePath;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Share PDF file using share sheet
  Future<void> sharePDF(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('PDF file not found');
    }

    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Analytics Report',
      text: 'Here is my delivery analytics report',
    );
  }

  /// Open PDF file with default viewer
  Future<void> openPDF(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('PDF file not found');
    }

    final result = await OpenFile.open(filePath);
    if (result.type != ResultType.done) {
      throw Exception('Failed to open PDF: ${result.message}');
    }
  }

  /// Delete PDF file
  Future<void> deletePDF(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Get list of downloaded PDF files
  Future<List<File>> getDownloadedPDFs() async {
    final directory = await _getDownloadsDirectory();
    final files = directory
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.pdf'))
        .toList();

    // Sort by modification date (newest first)
    files.sort((a, b) =>
        b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    return files;
  }

  /// Clear all downloaded PDFs
  Future<void> clearAllPDFs() async {
    final pdfs = await getDownloadedPDFs();
    for (var pdf in pdfs) {
      await pdf.delete();
    }
  }

  Future<Directory> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // Use app's documents directory on Android
      // (external storage requires additional permissions)
      final directory = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${directory.path}/PDFs');
      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }
      return pdfDir;
    } else if (Platform.isIOS) {
      // Use app's documents directory on iOS
      final directory = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${directory.path}/PDFs');
      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }
      return pdfDir;
    } else {
      // Fallback to temporary directory
      return await getTemporaryDirectory();
    }
  }

  String _handleError(DioException e) {
    if (e.response?.statusCode == 404) {
      return 'Driver profile not found';
    } else if (e.response?.statusCode == 400) {
      return e.response?.data['error'] ?? 'Invalid request';
    } else if (e.response?.statusCode == 401) {
      return 'Authentication required';
    } else if (e.response?.statusCode == 500) {
      return 'Failed to generate PDF. Please try again later.';
    }
    return 'Failed to download PDF: ${e.message}';
  }
}
