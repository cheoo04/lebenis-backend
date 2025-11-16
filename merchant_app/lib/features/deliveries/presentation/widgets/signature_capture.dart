import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignatureCapture extends StatefulWidget {
  final void Function(Uint8List?) onChanged;
  const SignatureCapture({super.key, required this.onChanged});

  @override
  State<SignatureCapture> createState() => _SignatureCaptureState();
}

class _SignatureCaptureState extends State<SignatureCapture> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Signature du destinataire', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Signature(
            controller: _controller,
            height: 120,
            backgroundColor: Colors.white,
          ),
        ),
        Row(
          children: [
            TextButton(
              onPressed: () {
                _controller.clear();
                widget.onChanged(null);
              },
              child: const Text('Effacer'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                final data = await _controller.toPngBytes();
                widget.onChanged(data);
              },
              child: const Text('Valider la signature'),
            ),
          ],
        ),
      ],
    );
  }
}
