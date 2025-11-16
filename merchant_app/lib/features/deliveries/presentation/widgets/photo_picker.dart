import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPicker extends StatefulWidget {
  final void Function(File?) onChanged;
  const PhotoPicker({super.key, required this.onChanged});

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _image = File(picked.path));
      widget.onChanged(_image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Photo de remise du colis', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _image != null
            ? Image.file(_image!, height: 120)
            : const Text('Aucune photo sélectionnée'),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Prendre une photo'),
            ),
            if (_image != null)
              TextButton(
                onPressed: () {
                  setState(() => _image = null);
                  widget.onChanged(null);
                },
                child: const Text('Supprimer'),
              ),
          ],
        ),
      ],
    );
  }
}
