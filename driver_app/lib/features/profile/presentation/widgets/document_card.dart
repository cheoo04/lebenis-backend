import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentCard extends StatelessWidget {
  final String title;
  final String? url;
  final Uint8List? bytes;
  final VoidCallback onUpload;
  // Suppression du bouton Supprimer : onDelete retiré

  const DocumentCard({
    required this.title,
    required this.url,
    this.bytes,
    required this.onUpload,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isPdf = url != null && url!.toLowerCase().endsWith('.pdf');
    final isValidNetworkUrl = url != null && (url!.startsWith('http://') || url!.startsWith('https://')) && !url!.endsWith('/lebe');
    final isMissing = (url == null || url!.isEmpty || !isValidNetworkUrl) && bytes == null;
    return Card(
      color: isMissing ? Colors.red[50] : null,
      child: SizedBox(
        width: 180,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMissing) ...[
              const SizedBox(height: 8),
              Icon(Icons.warning_amber_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 4),
              Text('Document manquant', style: TextStyle(color: Colors.red, fontSize: 12)),
              const SizedBox(height: 8),
            ]
            else if (bytes != null)
              Image.memory(bytes!, height: 80, fit: BoxFit.cover)
            else if (url != null && isPdf)
              Icon(Icons.picture_as_pdf, size: 48, color: Colors.red)
            else if (isValidNetworkUrl)
              Image.network(url!, height: 80, fit: BoxFit.cover)
            else if (url != null && url!.startsWith('file://'))
              Image.file(
                File(Uri.parse(url!).toFilePath()),
                height: 80,
                fit: BoxFit.cover,
              ),
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isMissing)
                  IconButton(
                    icon: const Icon(Icons.upload),
                    color: Colors.red,
                    onPressed: onUpload,
                    tooltip: 'Uploader',
                  )
                else ...[
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: onUpload,
                    tooltip: 'Remplacer',
                  ),
                ]
              ],
            ),
            if (!isMissing && url != null)
              TextButton(
                onPressed: () async {
                  if (isPdf) {
                    // Ouvre le PDF dans le navigateur
                    if (await canLaunchUrl(Uri.parse(url!))) {
                      await launchUrl(Uri.parse(url!), mode: LaunchMode.externalApplication);
                    }
                  } else if (isValidNetworkUrl) {
                    // Affiche l'image dans un dialog
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final maxW = MediaQuery.of(context).size.width * 0.9;
                            final maxH = MediaQuery.of(context).size.height * 0.8;
                            return SizedBox(
                              width: maxW,
                              height: maxH,
                              child: InteractiveViewer(
                                panEnabled: true,
                                scaleEnabled: true,
                                child: Center(
                                  child: Image.network(
                                    url!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Voir'),
              ),
          ],
        ),
      ),
    );
  }
}
