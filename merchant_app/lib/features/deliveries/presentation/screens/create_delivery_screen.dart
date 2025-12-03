import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/providers/geolocation_provider.dart';
import '../../../../data/providers/delivery_provider.dart';
import '../../../../data/providers/pricing_provider.dart';
import '../../../../shared/widgets/commune_selector_widget.dart';
import '../../../../shared/widgets/modern_text_field.dart';
import '../../../../shared/widgets/modern_button.dart';
import '../../../../theme/app_theme.dart';

class CreateDeliveryScreen extends ConsumerStatefulWidget {
  const CreateDeliveryScreen({super.key});

  @override
  ConsumerState<CreateDeliveryScreen> createState() => _CreateDeliveryScreenState();
}

class _CreateDeliveryScreenState extends ConsumerState<CreateDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Recipient info
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  
  // Pickup info
  String? _pickupCommune;
  double? _pickupLat;
  double? _pickupLng;
  final _pickupAddressController = TextEditingController();
  
  // Delivery info
  String? _deliveryCommune;
  double? _deliveryLat;
  double? _deliveryLng;
  final _deliveryAddressController = TextEditingController();
  
  // Package info
  final _packageDescController = TextEditingController();
  final _packageWeightController = TextEditingController();
  
  // Payment
  String _paymentMethod = 'prepaid';
  final _codAmountController = TextEditingController();
  
  // Price
  double? _estimatedPrice;
  bool _isLoadingEstimate = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _pickupAddressController.dispose();
    _deliveryAddressController.dispose();
    _packageDescController.dispose();
    _packageWeightController.dispose();
    _codAmountController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _pickupLat = position.latitude;
        _pickupLng = position.longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Position GPS récupérée ✓'), backgroundColor: Colors.green),
      );
      _estimatePrice();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur GPS: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _estimatePrice() async {
    if (_pickupCommune == null || _deliveryCommune == null || _packageWeightController.text.isEmpty) {
      setState(() => _estimatedPrice = null);
      return;
    }

    setState(() => _isLoadingEstimate = true);
    try {
      final weight = double.tryParse(_packageWeightController.text) ?? 1.0;
      final data = {
        'pickup_commune': _pickupCommune!,
        'delivery_commune': _deliveryCommune!,
        'package_weight_kg': weight,
      };
      final estimate = await ref.read(pricingRepositoryProvider).estimatePrice(data);
      setState(() => _estimatedPrice = estimate.total);
    } catch (e) {
      setState(() => _estimatedPrice = null);
    } finally {
      setState(() => _isLoadingEstimate = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_pickupCommune == null || _deliveryCommune == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner les communes'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final deliveryData = {
        'recipient_name': _recipientNameController.text.trim(),
        'recipient_phone': _recipientPhoneController.text.trim(),
        'pickup_commune': _pickupCommune!,
        'pickup_address': _pickupAddressController.text.trim(),
        'pickup_latitude': _pickupLat,
        'pickup_longitude': _pickupLng,
        'delivery_commune': _deliveryCommune!,
        'delivery_address': _deliveryAddressController.text.trim(),
        'delivery_latitude': _deliveryLat,
        'delivery_longitude': _deliveryLng,
        'package_description': _packageDescController.text.trim(),
        'package_weight_kg': double.tryParse(_packageWeightController.text) ?? 1.0,
        'payment_method': _paymentMethod,
      };

      if (_paymentMethod == 'cod' && _codAmountController.text.isNotEmpty) {
        deliveryData['cod_amount'] = double.tryParse(_codAmountController.text) ?? 0.0;
      }

      await ref.read(deliveryRepositoryProvider).createDelivery(deliveryData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Livraison créée avec succès !'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Nouvelle livraison'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Section Destinataire
            _buildSectionTitle('👤 Informations destinataire'),
            const SizedBox(height: 12),
            ModernTextField(
              controller: _recipientNameController,
              label: 'Nom complet',
              hint: 'Jean Kouadio',
              prefixIcon: Icons.person,
              validator: (v) => v == null || v.isEmpty ? 'Nom requis' : null,
            ),
            const SizedBox(height: 16),
            ModernTextField(
              controller: _recipientPhoneController,
              label: 'Téléphone',
              hint: '+225 07 XX XX XX XX',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Téléphone requis';
                if (v.length < 10) return 'Numéro invalide';
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Section Récupération
            _buildSectionTitle('📍 Point de récupération'),
            const SizedBox(height: 12),
            CommuneSelectorWidget(
              selectedCommune: _pickupCommune,
              label: 'Sélectionner la commune de pickup',
              onCommuneSelected: (commune, lat, lng) {
                setState(() {
                  _pickupCommune = commune;
                  _pickupLat = lat;
                  _pickupLng = lng;
                });
                _estimatePrice();
              },
            ),
            const SizedBox(height: 16),
            ModernTextField(
              controller: _pickupAddressController,
              label: 'Adresse complète',
              hint: 'Rue, immeuble, point de repère...',
              prefixIcon: Icons.location_on,
              maxLines: 2,
              validator: (v) => v == null || v.isEmpty ? 'Adresse requise' : null,
            ),
            const SizedBox(height: 12),
            ModernButton(
              text: _pickupLat != null ? 'GPS activé ✓' : 'Utiliser ma position GPS',
              icon: Icons.my_location,
              onPressed: _getCurrentLocation,
              backgroundColor: _pickupLat != null ? Colors.green : AppTheme.accentColor,
              isOutlined: true,
            ),

            const SizedBox(height: 32),

            // Section Livraison
            _buildSectionTitle('🚚 Adresse de livraison'),
            const SizedBox(height: 12),
            CommuneSelectorWidget(
              selectedCommune: _deliveryCommune,
              label: 'Sélectionner la commune de livraison',
              onCommuneSelected: (commune, lat, lng) {
                setState(() {
                  _deliveryCommune = commune;
                  _deliveryLat = lat;
                  _deliveryLng = lng;
                });
                _estimatePrice();
              },
            ),
            const SizedBox(height: 16),
            ModernTextField(
              controller: _deliveryAddressController,
              label: 'Adresse complète',
              hint: 'Rue, immeuble, point de repère...',
              prefixIcon: Icons.location_on,
              maxLines: 2,
              validator: (v) => v == null || v.isEmpty ? 'Adresse requise' : null,
            ),

            const SizedBox(height: 32),

            // Section Colis
            _buildSectionTitle('📦 Informations colis'),
            const SizedBox(height: 12),
            ModernTextField(
              controller: _packageDescController,
              label: 'Description du colis',
              hint: 'Ex: Vêtements, documents, nourriture...',
              prefixIcon: Icons.inventory_2,
              maxLines: 2,
              validator: (v) => v == null || v.isEmpty ? 'Description requise' : null,
            ),
            const SizedBox(height: 16),
            ModernTextField(
              controller: _packageWeightController,
              label: 'Poids estimé (kg)',
              hint: '1.5',
              prefixIcon: Icons.scale,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Poids requis';
                final weight = double.tryParse(v);
                if (weight == null || weight <= 0) return 'Poids invalide';
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Section Paiement
            _buildSectionTitle('💳 Mode de paiement'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'prepaid',
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      setState(() => _paymentMethod = value!);
                    },
                    title: const Text('Prépayé', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Le merchant paie les frais de livraison'),
                    activeColor: AppTheme.primaryColor,
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  RadioListTile<String>(
                    value: 'cod',
                    groupValue: _paymentMethod,
                    onChanged: (value) {
                      setState(() => _paymentMethod = value!);
                    },
                    title: const Text('Cash on Delivery (COD)', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Le destinataire paie à la réception'),
                    activeColor: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),

            if (_paymentMethod == 'cod') ...[
              const SizedBox(height: 16),
              ModernTextField(
                controller: _codAmountController,
                label: 'Montant à collecter (FCFA)',
                hint: '5000',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (_paymentMethod == 'cod' && (v == null || v.isEmpty)) {
                    return 'Montant requis pour COD';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 32),

            // Estimation prix
            if (_estimatedPrice != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prix estimé',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Frais de livraison',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_estimatedPrice!.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else if (_isLoadingEstimate)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),

            const SizedBox(height: 32),

            // Bouton submit
            ModernButton(
              text: 'Créer la livraison',
              icon: Icons.check_circle,
              onPressed: _submit,
              isLoading: _isSubmitting,
              backgroundColor: AppTheme.primaryColor,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }
}
