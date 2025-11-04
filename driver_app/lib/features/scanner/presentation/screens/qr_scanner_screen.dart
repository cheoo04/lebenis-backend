import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/dimensions.dart';
import '../../../../shared/theme/text_styles.dart';

class QRScannerScreen extends StatefulWidget {
  final Function(String) onCodeScanned;
  final String? title;
  final String? instruction;

  const QRScannerScreen({
    super.key,
    required this.onCodeScanned,
    this.title,
    this.instruction,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  
  bool _isProcessing = false;
  bool _flashOn = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (_isProcessing) return;

    final barcode = barcodes.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() => _isProcessing = true);

    final code = barcode!.rawValue!;
    
    // Vibrate on success
    // HapticFeedback.mediumImpact();

    widget.onCodeScanned(code);
    
    // Pop automatically after scanning
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.of(context).pop(code);
      }
    });
  }

  void _toggleFlash() {
    _controller.toggleTorch();
    setState(() => _flashOn = !_flashOn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title ?? 'Scanner le code'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
            tooltip: 'Lampe torche',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner View
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
            errorBuilder: (context, error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: Dimensions.spacingM),
                    Text(
                      'Erreur de caméra',
                      style: TextStyles.h3.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: Dimensions.spacingS),
                    Text(
                      error.errorDetails?.message ?? 'Impossible d\'accéder à la caméra',
                      style: TextStyles.bodyMedium.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),

          // Scanning Frame Overlay
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: Container(),
          ),

          // Instructions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(Dimensions.pagePadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                children: [
                  if (_isProcessing)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.spacingL,
                        vertical: Dimensions.spacingM,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(Dimensions.radiusL),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                          ),
                          const SizedBox(width: Dimensions.spacingS),
                          Text(
                            'Code scanné avec succès!',
                            style: TextStyles.labelLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          size: 48,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(height: Dimensions.spacingM),
                        Text(
                          widget.instruction ?? 'Placez le code QR dans le cadre',
                          style: TextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Dimensions.spacingS),
                        Text(
                          'Le scan se fera automatiquement',
                          style: TextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;

    // Draw dark overlay
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final scanAreaPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
          const Radius.circular(Dimensions.radiusL),
        ),
      );

    final overlayPath = Path.combine(
      PathOperation.difference,
      path,
      scanAreaPath,
    );

    canvas.drawPath(overlayPath, overlayPaint);

    // Draw corner lines
    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double cornerLength = 30;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top + Dimensions.radiusL),
      Offset(left, top + cornerLength),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + Dimensions.radiusL, top),
      Offset(left + cornerLength, top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + scanAreaSize, top + Dimensions.radiusL),
      Offset(left + scanAreaSize, top + cornerLength),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize - Dimensions.radiusL, top),
      Offset(left + scanAreaSize - cornerLength, top),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + scanAreaSize - Dimensions.radiusL),
      Offset(left, top + scanAreaSize - cornerLength),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + Dimensions.radiusL, top + scanAreaSize),
      Offset(left + cornerLength, top + scanAreaSize),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + scanAreaSize, top + scanAreaSize - Dimensions.radiusL),
      Offset(left + scanAreaSize, top + scanAreaSize - cornerLength),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize - Dimensions.radiusL, top + scanAreaSize),
      Offset(left + scanAreaSize - cornerLength, top + scanAreaSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
