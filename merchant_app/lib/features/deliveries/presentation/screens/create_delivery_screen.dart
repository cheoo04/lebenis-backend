import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/providers/pricing_provider.dart';
import '../widgets/price_estimator.dart';

class CreateDeliveryScreen extends ConsumerStatefulWidget {
  const CreateDeliveryScreen({super.key});

  @override
  ConsumerState<CreateDeliveryScreen> createState() => _CreateDeliveryScreenState();
}

class _CreateDeliveryScreenState extends ConsumerState<CreateDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _addressController = TextEditingController();
  final _packageController = TextEditingController();
  double? _estimatedPrice;
  bool _loadingEstimate = false;

  @override
  void dispose() {
    _recipientController.dispose();
    _addressController.dispose();
    _packageController.dispose();
    super.dispose();
  }

  Future<void> _estimatePrice() async {
    final recipient = _recipientController.text.trim();
    final address = _addressController.text.trim();
    final package = _packageController.text.trim();
    if (recipient.isEmpty || address.isEmpty || package.isEmpty) {
      setState(() => _estimatedPrice = null);
      return;
    }
    setState(() => _loadingEstimate = true);
    try {
      final data = {
        'delivery_commune': address, // À adapter selon la structure réelle
        'package_weight_kg': 1.0, // À remplacer par un champ réel
        'pickup_commune': 'Cocody', // À remplacer par la commune du marchand
      };
      final estimate = await ref.read(pricingRepositoryProvider).estimatePrice(data);
      setState(() => _estimatedPrice = estimate.total);
    } catch (e) {
      setState(() => _estimatedPrice = null);
    } finally {
      setState(() => _loadingEstimate = false);
    }
  }

  void _onFieldChanged(String _) {
    _estimatePrice();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Envoyer la livraison au backend avec les champs nécessaires
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
                onChanged: _onFieldChanged,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Adresse de livraison'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                onChanged: _onFieldChanged,
              ),
              TextFormField(
                controller: _packageController,
                decoration: const InputDecoration(labelText: 'Description du colis'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                onChanged: _onFieldChanged,
              ),
              const SizedBox(height: 16),
              _loadingEstimate
                  ? const CircularProgressIndicator()
                  : PriceEstimator(estimatedPrice: _estimatedPrice),
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
