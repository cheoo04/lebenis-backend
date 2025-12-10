// lib/shared/widgets/address_geocoder_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../data/providers/geolocation_provider.dart';
import '../utils/input_decorations.dart';

/// Widget pour saisir une adresse et la géocoder automatiquement
class AddressGeocoderWidget extends ConsumerStatefulWidget {
  final String? initialAddress;
  final Function(LatLng) onLocationSelected;
  final String? label;
  final String? hint;

  const AddressGeocoderWidget({
    super.key,
    this.initialAddress,
    required this.onLocationSelected,
    this.label,
    this.hint,
  });

  @override
  ConsumerState<AddressGeocoderWidget> createState() => _AddressGeocoderWidgetState();
}

class _AddressGeocoderWidgetState extends ConsumerState<AddressGeocoderWidget> {
  late TextEditingController _addressController;
  LatLng? _coordinates;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.initialAddress);
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> _geocodeAddress() async {
    final messenger = ScaffoldMessenger.of(context);
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une adresse')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Appeler le provider avec les paramètres
      final result = await ref.read(geocodeAddressProvider({
        'address': address,
        'city': 'Abidjan',
      }).future);

      if (!mounted) return;

      if (result != null) {
        setState(() {
          _coordinates = result;
          _isLoading = false;
        });
        widget.onLocationSelected(result);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('✅ Adresse géocodée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => _isLoading = false);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('❌ Impossible de localiser cette adresse'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erreur: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use shared helper to build consistent decoration that can infer compact mode
    final decoration = compactInputDecoration(
      label: widget.label ?? 'Adresse complète',
      hint: widget.hint ?? 'Ex: Rue des Jardins, Cocody',
      prefixIcon: Icons.location_on,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _addressController,
          decoration: decoration.copyWith(
            border: const OutlineInputBorder(),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _geocodeAddress,
                    tooltip: 'Géocoder l\'adresse',
                  ),
          ),
          maxLines: (decoration.isDense ?? false) ? 1 : 2,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _geocodeAddress(),
          style: TextStyle(fontSize: (decoration.isDense ?? false) ? 14 : 15),
        ),
        if (_coordinates != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Position: ${_coordinates!.latitude.toStringAsFixed(6)}, ${_coordinates!.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
