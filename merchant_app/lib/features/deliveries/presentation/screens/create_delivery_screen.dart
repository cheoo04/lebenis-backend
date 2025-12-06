import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/providers/quartier_provider.dart';
import '../../../../data/providers/delivery_provider.dart';
import '../../../../data/providers/pricing_provider.dart';
import '../../../../shared/widgets/quartier_search_widget.dart';
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
  
  // Pickup info - SIMPLIFIÉ: juste commune + quartier + GPS optionnel
  String? _pickupCommune;
  String? _pickupQuartier;
  final _pickupStreetController = TextEditingController(); // Rue/précision
  double? _pickupLat;
  double? _pickupLng;
  
  // Delivery info
  String? _deliveryCommune;
  String? _deliveryQuartier;
  final _deliveryStreetController = TextEditingController(); // Rue/précision
  double? _deliveryLat;
  double? _deliveryLng;
  final _deliveryAddressController = TextEditingController();
  
  // Package info
  final _packageDescController = TextEditingController();
  final _packageWeightController = TextEditingController();
  final _packageLengthController = TextEditingController();
  final _packageWidthController = TextEditingController();
  final _packageHeightController = TextEditingController();
  final _packageValueController = TextEditingController();
  bool _isFragile = false;
  
  // Recipient additional info
  final _recipientAltPhoneController = TextEditingController();
  
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
    _recipientAltPhoneController.dispose();
    _pickupStreetController.dispose();
    _deliveryStreetController.dispose();
    _deliveryAddressController.dispose();
    _packageDescController.dispose();
    _packageWeightController.dispose();
    _packageLengthController.dispose();
    _packageWidthController.dispose();
    _packageHeightController.dispose();
    _packageValueController.dispose();
    _codAmountController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Vérifier les permissions d'abord
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Permission GPS refusée. La position GPS est optionnelle.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission GPS désactivée dans les paramètres. Vous pouvez continuer sans GPS.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      
      if (mounted) {
        // Utiliser le reverse geocoding pour obtenir l'adresse
        final address = await ref.read(quartierRepositoryProvider).reverseGeocode(
          position.latitude,
          position.longitude,
        );
        
        setState(() {
          _pickupLat = position.latitude;
          _pickupLng = position.longitude;
          // L'adresse contient généralement la commune
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(address != null 
              ? '✓ Position GPS récupérée - $address'
              : '✓ Position GPS récupérée'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        _estimatePrice();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GPS non disponible. Vous pouvez continuer sans.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _estimatePrice() async {
    if (_pickupCommune == null || _deliveryCommune == null || _packageWeightController.text.isEmpty) {
      print('❌ Estimation impossible: pickup=$_pickupCommune, delivery=$_deliveryCommune, weight=${_packageWeightController.text}');
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
      print('📊 Estimation prix: $data');
      final estimate = await ref.read(pricingRepositoryProvider).estimatePrice(data);
      print('✅ Prix estimé: ${estimate.total} FCFA');
      setState(() => _estimatedPrice = estimate.total);
    } catch (e) {
      print('❌ Erreur estimation: $e');
      setState(() => _estimatedPrice = null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de calcul: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoadingEstimate = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validation stricte des communes et quartiers de pickup
    if (_pickupCommune == null || _pickupCommune!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Veuillez sélectionner la commune de récupération'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_pickupQuartier == null || _pickupQuartier!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Veuillez sélectionner le quartier de récupération'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_deliveryCommune == null || _deliveryCommune!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Veuillez sélectionner la commune de livraison'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final deliveryData = {
        // Recipient
        'recipient_name': _recipientNameController.text.trim(),
        'recipient_phone': _recipientPhoneController.text.trim(),
        if (_recipientAltPhoneController.text.isNotEmpty)
          'recipient_alternative_phone': _recipientAltPhoneController.text.trim(),
        // Pickup - SIMPLIFIÉ: commune + quartier obligatoires, GPS optionnel
        'pickup_commune': _pickupCommune!,
        'pickup_quartier': _pickupQuartier!,
        if (_pickupStreetController.text.isNotEmpty)
          'pickup_street': _pickupStreetController.text.trim(),
        if (_pickupLat != null) 'pickup_latitude': _pickupLat,
        if (_pickupLng != null) 'pickup_longitude': _pickupLng,
        // Delivery
        'delivery_commune': _deliveryCommune!,
        if (_deliveryQuartier != null && _deliveryQuartier!.isNotEmpty)
          'delivery_quartier': _deliveryQuartier,
        if (_deliveryStreetController.text.isNotEmpty)
          'delivery_street': _deliveryStreetController.text.trim(),
        if (_deliveryLat != null) 'delivery_latitude': _deliveryLat,
        if (_deliveryLng != null) 'delivery_longitude': _deliveryLng,
        // Package
        'package_description': _packageDescController.text.trim(),
        'package_weight_kg': double.tryParse(_packageWeightController.text) ?? 1.0,
        'is_fragile': _isFragile,
        if (_packageLengthController.text.isNotEmpty)
          'package_length_cm': double.tryParse(_packageLengthController.text),
        if (_packageWidthController.text.isNotEmpty)
          'package_width_cm': double.tryParse(_packageWidthController.text),
        if (_packageHeightController.text.isNotEmpty)
          'package_height_cm': double.tryParse(_packageHeightController.text),
        if (_packageValueController.text.isNotEmpty)
          'package_value': double.tryParse(_packageValueController.text),
        // Payment
        'payment_method': _paymentMethod,
      };

      if (_paymentMethod == 'cod' && _codAmountController.text.isNotEmpty) {
        deliveryData['cod_amount'] = double.tryParse(_codAmountController.text) ?? 0.0;
      }

      print('✅ Livraison créée avec:');
      print('   pickup: ${deliveryData['pickup_quartier']}, ${deliveryData['pickup_commune']}');
      print('   GPS: ${deliveryData['pickup_latitude']}/${deliveryData['pickup_longitude']}');
      
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
            const SizedBox(height: 16),
            ModernTextField(
              controller: _recipientAltPhoneController,
              label: 'Téléphone alternatif (optionnel)',
              hint: '+225 05 XX XX XX XX',
              prefixIcon: Icons.phone_android,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 32),

            // Section Récupération
            _buildSectionTitle('📍 Point de récupération'),
            const SizedBox(height: 12),
            
            // Widget intégré Commune + Quartier pour le pickup (OBLIGATOIRE)
            QuartierSearchWidget(
              label: 'Localisation de récupération *',
              initialCommune: _pickupCommune,
              initialQuartier: _pickupQuartier,
              showCoordinates: false,
              onLocationSelected: (commune, quartier, lat, lon) {
                setState(() {
                  _pickupCommune = commune.trim();
                  _pickupQuartier = quartier;
                  _pickupLat = lat;
                  _pickupLng = lon;
                });
                _estimatePrice();
              },
            ),
            if (_pickupCommune != null && _pickupQuartier != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '✓ Récupération: $_pickupQuartier, $_pickupCommune',
                        style: TextStyle(color: Colors.green[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            ModernTextField(
              controller: _pickupStreetController,
              label: 'Rue ou repère (optionnel)',
              hint: 'Ex: Rue du marché, à côté de la pharmacie...',
              prefixIcon: Icons.location_on,
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // GPS OPTIONNEL pour affiner la localisation exacte
            _buildSectionTitle('📍 Localisation GPS (optionnel)'),
            const SizedBox(height: 12),
            Text(
              'Utilisez votre GPS actuel si vous êtes le point de récupération',
              style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            ModernButton(
              text: _pickupLat != null ? 'GPS activé ✓' : 'Activer GPS',
              icon: Icons.my_location,
              onPressed: _getCurrentLocation,
              backgroundColor: _pickupLat != null ? Colors.green : AppTheme.accentColor,
              isOutlined: true,
            ),
            if (_pickupLat != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '✓ Position enregistrée : ${_pickupLat!.toStringAsFixed(4)}, ${_pickupLng!.toStringAsFixed(4)}',
                    style: TextStyle(color: Colors.green[700], fontSize: 12),
                  ),
                ),
            ],

            const SizedBox(height: 32),

            // Section Livraison
            _buildSectionTitle('🚚 Adresse de livraison'),
            const SizedBox(height: 12),
            
            // Widget intégré Commune + Quartier avec GPS
            QuartierSearchWidget(
              label: 'Localisation de livraison *',
              initialCommune: _deliveryCommune,
              initialQuartier: _deliveryQuartier,
              showCoordinates: true,
              onLocationSelected: (commune, quartier, lat, lon) {
                setState(() {
                  _deliveryCommune = commune.trim();
                  _deliveryQuartier = quartier;
                  _deliveryLat = lat;
                  _deliveryLng = lon;
                });
                _estimatePrice();
              },
            ),
            
            if (_deliveryCommune != null && _deliveryQuartier != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '✓ Livraison: $_deliveryQuartier, $_deliveryCommune',
                        style: TextStyle(color: Colors.green[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 12),
            ModernTextField(
              controller: _deliveryStreetController,
              label: 'Rue ou repère (optionnel)',
              hint: 'Ex: Rue principale, en face du marché...',
              prefixIcon: Icons.location_on,
              maxLines: 2,
            ),
            
            const SizedBox(height: 16),
            ModernTextField(
              controller: _deliveryAddressController,
              label: 'Adresse complète',
              hint: 'Rue, immeuble, point de repère... (optionnel)',
              prefixIcon: Icons.location_on,
              maxLines: 2,
              validator: (v) => null, // Optionnel - la commune et quartier suffisent
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Poids requis';
                final weight = double.tryParse(v);
                if (weight == null || weight <= 0) return 'Poids invalide';
                return null;
              },
              onChanged: (_) => _estimatePrice(),
            ),
            
            const SizedBox(height: 16),
            
            // Dimensions (optionnel)
            Row(
              children: [
                Expanded(
                  child: ModernTextField(
                    controller: _packageLengthController,
                    label: 'Longueur (cm)',
                    hint: '30',
                    prefixIcon: Icons.straighten,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernTextField(
                    controller: _packageWidthController,
                    label: 'Largeur (cm)',
                    hint: '20',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ModernTextField(
                    controller: _packageHeightController,
                    label: 'Hauteur (cm)',
                    hint: '10',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernTextField(
                    controller: _packageValueController,
                    label: 'Valeur (FCFA)',
                    hint: '50000',
                    prefixIcon: Icons.monetization_on,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Checkbox fragile
            CheckboxListTile(
              value: _isFragile,
              onChanged: (value) {
                setState(() => _isFragile = value ?? false);
                _estimatePrice();
              },
              title: const Text('Colis fragile'),
              subtitle: const Text('Nécessite une manipulation délicate'),
              activeColor: AppTheme.primaryColor,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 32),

            // Section Paiement
            _buildSectionTitle('Mode de paiement'),
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
