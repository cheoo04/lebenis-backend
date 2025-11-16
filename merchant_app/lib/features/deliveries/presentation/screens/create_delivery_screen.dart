import 'package:flutter/material.dart';

class CreateDeliveryScreen extends StatefulWidget {
  const CreateDeliveryScreen({super.key});

  @override
  State<CreateDeliveryScreen> createState() => _CreateDeliveryScreenState();
}

class _CreateDeliveryScreenState extends State<CreateDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _addressController = TextEditingController();
  final _packageController = TextEditingController();

  @override
  void dispose() {
    _recipientController.dispose();
    _addressController.dispose();
    _packageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Envoyer la livraison au backend
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Livraison créée !')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle livraison')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _recipientController,
                decoration: const InputDecoration(labelText: 'Destinataire'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Adresse de livraison'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _packageController,
                decoration: const InputDecoration(labelText: 'Description du colis'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Créer la livraison'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
