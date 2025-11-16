import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../widgets/photo_picker.dart';
import '../widgets/signature_capture.dart';

class ConfirmDeliveryScreen extends StatefulWidget {
  final int deliveryId;
  const ConfirmDeliveryScreen({super.key, required this.deliveryId});

  @override
  State<ConfirmDeliveryScreen> createState() => _ConfirmDeliveryScreenState();
}

class _ConfirmDeliveryScreenState extends State<ConfirmDeliveryScreen> {
  File? _photo;
  Uint8List? _signature;
  final _notesController = TextEditingController();
  bool _submitting = false;

  void _submit() async {
    if (_photo == null || _signature == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Photo et signature requises.')));
      return;
    }
    setState(() => _submitting = true);
    // TODO: Envoyer _photo, _signature et _notes à l'API de confirmation de livraison
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preuve de livraison envoyée.')));
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preuve de livraison')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PhotoPicker(onChanged: (f) => setState(() => _photo = f)),
            const SizedBox(height: 16),
            SignatureCapture(onChanged: (s) => setState(() => _signature = s)),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optionnel)'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: const Icon(Icons.check),
                label: _submitting ? const CircularProgressIndicator() : const Text('Envoyer la preuve'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
