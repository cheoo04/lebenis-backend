import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service for downloading and managing delivery PDF reports
class PDFReportService {
  // Note: DioClient peut être utilisé plus tard pour télécharger des PDFs

  PDFReportService();

  /// Download a delivery PDF report
  ///
  /// Returns the local file path where the PDF was saved
  // Delivery PDF download removed — feature disabled per request.
  // If needed later, reintroduce a download method here.

  /// Share a downloaded PDF file
  Future<void> sharePDF(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('PDF file not found');
      }

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'LeBeni\'s Delivery Report',
        text: 'Here is your delivery report',
      );
    } catch (e) {
      throw Exception('Failed to share PDF: $e');
    }
  }

  /// Open PDF in system viewer
  Future<void> openPDF(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('PDF file not found');
      }

      // Share with option to open
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'LeBeni\'s Delivery Report',
      );
    } catch (e) {
      throw Exception('Failed to open PDF: $e');
    }
  }

  /// Get list of downloaded PDFs
  Future<List<File>> getDownloadedPDFs() async {
    try {
      final directory = await _getPDFDirectory();
      final files = directory.listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.pdf'))
          .toList();
      
      // Sort by modification date (newest first)
      files.sort((a, b) => 
        b.lastModifiedSync().compareTo(a.lastModifiedSync())
      );
      
      return files;
    } catch (e) {
      throw Exception('Failed to get PDF list: $e');
    }
  }

  /// Delete a specific PDF file
  Future<void> deletePDF(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete PDF: $e');
    }
  }

  /// Clear all downloaded PDFs
  Future<void> clearAllPDFs() async {
    try {
      final files = await getDownloadedPDFs();
      for (final file in files) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to clear PDFs: $e');
    }
  }

  /// Get PDF directory
  Future<Directory> _getPDFDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final pdfDir = Directory('${directory.path}/PDFs');
    
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }
    
    return pdfDir;
  }

  /// Get file size in human-readable format
  static String getFileSize(String filePath) {
    final file = File(filePath);
    final bytes = file.lengthSync();
    
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
