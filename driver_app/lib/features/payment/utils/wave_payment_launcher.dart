import 'package:url_launcher/url_launcher.dart';

/// Ouvre l'URL de paiement Wave dans le navigateur externe.
Future<void> launchWavePaymentUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw Exception('Impossible d\'ouvrir l\'URL de paiement Wave.');
  }
}
