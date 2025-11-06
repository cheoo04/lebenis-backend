import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_provider.dart';
import '../providers/pdf_report_provider.dart';

class PDFReportsScreen extends ConsumerStatefulWidget {
  const PDFReportsScreen({super.key});

  @override
  ConsumerState<PDFReportsScreen> createState() => _PDFReportsScreenState();
}

class _PDFReportsScreenState extends ConsumerState<PDFReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final pdfState = ref.watch(pdfDownloadProvider);
    final dateRange = ref.watch(dateRangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Reports'),
        actions: [
          if (pdfState.filePath != null)
            IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: () => _openPDF(pdfState.filePath!),
              tooltip: 'Open Last Report',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 40,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Analytics Reports',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Generate and download PDF reports',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Current Period Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Date Range',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          _getDateRangeText(dateRange),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Generate Button
            if (!pdfState.isDownloading)
              ElevatedButton.icon(
                onPressed: () => _generatePDF(dateRange),
                icon: const Icon(Icons.download),
                label: const Text('Generate PDF Report'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),

            // Progress Indicator
            if (pdfState.isDownloading) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Generating PDF...',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: pdfState.progress,
                        minHeight: 8,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(pdfState.progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Success Message
            if (pdfState.filePath != null &&
                !pdfState.isDownloading &&
                pdfState.error == null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'PDF Generated Successfully!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _openPDF(pdfState.filePath!),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Open'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _sharePDF(pdfState.filePath!),
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Error Message
            if (pdfState.error != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        pdfState.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(pdfDownloadProvider.notifier).resetState();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Test Report Button
            const Divider(),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: pdfState.isDownloading
                  ? null
                  : () => _generateTestPDF(),
              icon: const Icon(Icons.bug_report),
              label: const Text('Generate Test Report (Last 7 Days)'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 16),

            // Info Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About PDF Reports',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Reports include all analytics data\n'
                            '• Files are saved to your device\n'
                            '• You can share reports via email or messaging\n'
                            '• Reports are formatted for printing',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDateRangeText(DateRangeState dateRange) {
    if (dateRange.period == 'custom' &&
        dateRange.startDate != null &&
        dateRange.endDate != null) {
      return '${_formatDate(dateRange.startDate!)} - ${_formatDate(dateRange.endDate!)}';
    }

    switch (dateRange.period) {
      case 'today':
        return 'Today';
      case 'week':
        return 'Last 7 Days';
      case 'month':
        return 'Last 30 Days';
      case 'year':
        return 'Last 365 Days';
      default:
        return dateRange.period;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _generatePDF(DateRangeState dateRange) {
    ref.read(pdfDownloadProvider.notifier).downloadReport(
          period: dateRange.period,
          startDate: dateRange.startDate != null
              ? _formatDateForAPI(dateRange.startDate!)
              : null,
          endDate: dateRange.endDate != null
              ? _formatDateForAPI(dateRange.endDate!)
              : null,
        );
  }

  void _generateTestPDF() {
    ref.read(pdfDownloadProvider.notifier).downloadTestReport();
  }

  void _openPDF(String filePath) {
    ref.read(pdfDownloadProvider.notifier).openReport(filePath);
  }

  void _sharePDF(String filePath) {
    ref.read(pdfDownloadProvider.notifier).shareReport(filePath);
  }

  String _formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
