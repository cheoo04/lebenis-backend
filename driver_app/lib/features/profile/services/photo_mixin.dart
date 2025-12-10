import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

mixin PhotoMixin<T extends StatefulWidget> on State<T> {
  Future<void> pickPhoto({
    required BuildContext context,
    required Function(dynamic file, Uint8List bytes) onPhotoPicked,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final localContext = context;
      final ImagePicker picker = ImagePicker();
      final platform = Theme.of(localContext).platform;
      final ImageSource source = kIsWeb || !(platform == TargetPlatform.android || platform == TargetPlatform.iOS)
          ? ImageSource.gallery
          : (await showDialog<ImageSource>(
                context: localContext,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Sélectionner une photo'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('Galerie'),
                        onTap: () => Navigator.pop(dialogContext, ImageSource.gallery),
                      ),
                      if (platform == TargetPlatform.android || platform == TargetPlatform.iOS)
                        ListTile(
                          leading: const Icon(Icons.photo_camera),
                          title: const Text('Caméra'),
                          onTap: () => Navigator.pop(dialogContext, ImageSource.camera),
                        ),
                    ],
                  ),
                ),
              )) ?? ImageSource.gallery;

      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile == null) return;
      if (!mounted) return;

      final bytes = await pickedFile.readAsBytes();
      if (!mounted) return;
      if (bytes.length > 5 * 1024 * 1024) {
        messenger.showSnackBar(const SnackBar(content: Text('Fichier trop volumineux (max 5MB)')));
        return;
      }

      onPhotoPicked(pickedFile, bytes);

      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Photo sélectionnée')));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Widget buildPhotoWidget(dynamic file, Uint8List? bytes, dynamic url) {
    if (file != null && bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: kIsWeb
            ? Image.memory(bytes, width: 90, height: 60, fit: BoxFit.cover)
            : (file is File)
                ? Image.file(file, width: 90, height: 60, fit: BoxFit.cover)
                : (file is XFile)
                    ? Image.file(File(file.path), width: 90, height: 60, fit: BoxFit.cover)
                    : Image.memory(bytes, width: 90, height: 60, fit: BoxFit.cover),
      );
    } else if (url != null && url is String && url.isNotEmpty) {
      if (url.startsWith('http://') || url.startsWith('https://')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: url,
            width: 90,
            height: 60,
            fit: BoxFit.cover,
          ),
        );
      } else if (url.startsWith('file://')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(Uri.parse(url).toFilePath()),
            width: 90,
            height: 60,
            fit: BoxFit.cover,
          ),
        );
      }
    }
    // Par défaut, retourne un placeholder
    return Container(
      width: 90,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, size: 32, color: Colors.grey),
    );
  }
}
