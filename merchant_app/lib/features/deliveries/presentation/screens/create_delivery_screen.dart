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
  String _pickupMode = 'gps'; // 'gps', 'saved', 'custom'
  String? _selectedSavedAddressId; // UUID de l'adresse sauvegardée
  final _customPickupAddressController = TextEditingController(); // Adresse personnalisée
  String? _pickupCommune;
  double? _pickupLat;
  double? _pickupLng;
  
  // Delivery info
  String? _deliveryCommune;
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
  String? _deliveryQuartier;
  
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
    _customPickupAddressController.dispose();
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
        // Détecter la commune la plus proche
        final commune = await ref.read(geolocationRepositoryProvider).getNearestCommune(
          position.latitude,
          position.longitude,
        );
        
        setState(() {
          _pickupLat = position.latitude;
          _pickupLng = position.longitude;
          if (commune != null) {
            _pickupCommune = commune;
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(commune != null 
              ? '✓ Position GPS récupérée - $commune'
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
        // Recipient
        'recipient_name': _recipientNameController.text.trim(),
        'recipient_phone': _recipientPhoneController.text.trim(),
        if (_recipientAltPhoneController.text.isNotEmpty)
          'recipient_alternative_phone': _recipientAltPhoneController.text.trim(),
        // Pickup - 3 modes : GPS (automatique), Adresse sauvegardée (UUID), Personnalisée (texte)
        'pickup_commune': _pickupCommune!,
        if (_pickupMode == 'saved' && _selectedSavedAddressId != null)
          'pickup_address': _selectedSavedAddressId, // UUID
        if (_pickupMode == 'custom' && _customPickupAddressController.text.isNotEmpty)
          'pickup_address_details': _customPickupAddressController.text.trim(), // Texte
        if (_pickupLat != null) 'pickup_latitude': _pickupLat,
        if (_pickupLng != null) 'pickup_longitude': _pickupLng,
        // Delivery
        'delivery_commune': _deliveryCommune!,
        if (_deliveryQuartier != null && _deliveryQuartier!.isNotEmpty)
          'delivery_quartier': _deliveryQuartier,
        'delivery_address': _deliveryAddressController.text.trim(),
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
            
            // Sélecteur de mode de pickup
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'D\'où voulez-vous envoyer ?',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('📍 Position GPS'),
                        selected: _pickupMode == 'gps',
                        onSelected: (selected) {
                          if (selected) setState(() => _pickupMode = 'gps');
                        },
                      ),
                      ChoiceChip(
                        label: const Text('🏢 Adresse sauvegardée'),
                        selected: _pickupMode == 'saved',
                        onSelected: (selected) {
                          if (selected) setState(() => _pickupMode = 'saved');
                        },
                      ),
                      ChoiceChip(
                        label: const Text('✏️ Adresse personnalisée'),
                        selected: _pickupMode == 'custom',
                        onSelected: (selected) {
                          if (selected) setState(() => _pickupMode = 'custom');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
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
            
            // Affichage conditionnel selon le mode
            if (_pickupMode == 'gps') ...[
              ModernButton(
                text: _pickupLat != null ? 'GPS activé ✓' : 'Utiliser ma position GPS',
                icon: Icons.my_location,
                onPressed: _getCurrentLocation,
                backgroundColor: _pickupLat != null ? Colors.green : AppTheme.accentColor,
                isOutlined: true,
              ),
              if (_pickupLat != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '✓ Position enregistrée : ${_pickupLat!.toStringAsFixed(4)}, ${_pickupLng!.toStringAsFixed(4)}',
                    style: TextStyle(color: Colors.green[700], fontSize: 12),
                  ),
                ),
            ],
            
            if (_pickupMode == 'saved') ...[
              _buildSavedAddressesDropdown(),
              const SizedBox(height: 8),
              Text(
                '💡 Vous pouvez créer des adresses sauvegardées dans votre profil',
                style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
            
            if (_pickupMode == 'custom') ...[
              ModernTextField(
                controller: _customPickupAddressController,
                label: 'Adresse personnalisée *',
                hint: 'Ex: Rue des jardins, Immeuble CCIA, 3ème étage',
                prefixIcon: Icons.location_on,
                maxLines: 2,
                validator: (v) => v == null || v.isEmpty ? 'Adresse requise' : null,
              ),
              const SizedBox(height: 8),
              Text(
                '💡 Cette adresse est pour une livraison ponctuelle',
                style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],

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
              controller: TextEditingController(text: _deliveryQuartier),
              label: 'Quartier (optionnel)',
              hint: 'Ex: Cocody Riviera, Marcory Zone 4...',
              prefixIcon: Icons.location_city,
              onChanged: (value) => _deliveryQuartier = value,
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

  Widget _buildSavedAddressesDropdown() {
    // TODO: Implémenter la récupération des adresses sauvegardées depuis le backend
    // Pour l'instant, affichage d'un placeholder
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.business, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aucune adresse sauvegardée',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Créez des adresses dans votre profil pour les réutiliser',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
