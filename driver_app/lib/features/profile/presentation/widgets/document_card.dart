import 'package:flutter/material.dart';

class DocumentCard extends StatelessWidget {
  final String title;
  final String? url;
  final VoidCallback onUpload;
  final VoidCallback onDelete;

  const DocumentCard({
    required this.title,
    required this.url,
    required this.onUpload,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isPdf = url != null && url!.toLowerCase().endsWith('.pdf');
    return Card(
      color: url == null ? Colors.red[50] : null,
      child: SizedBox(
        width: 180,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (url != null)
              isPdf
                  ? Icon(Icons.picture_as_pdf, size: 48, color: Colors.red)
                  : Image.network(url!, height: 80, fit: BoxFit.cover)
            else ...[
              Icon(Icons.warning_amber_rounded, size: 48, color: Colors.red),
              const SizedBox(height: 4),
              Text('Document manquant', style: TextStyle(color: Colors.red, fontSize: 12)),
            ],
            Text(title, style: Theme.of(context).textTheme.bodyLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(url == null ? Icons.upload : Icons.refresh),
                  color: url == null ? Colors.red : null,
                  onPressed: onUpload,
                  tooltip: url == null ? 'Uploader' : 'Remplacer',
                ),
                if (url != null)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onDelete,
                    tooltip: 'Supprimer',
                  ),
              ],
            ),
            if (url != null)
              TextButton(
                onPressed: () {
                  // Ouvrir le document (image ou PDF)
                },
                child: const Text('Voir'),
              ),
          ],
        ),
      ),
    );
  }
}
