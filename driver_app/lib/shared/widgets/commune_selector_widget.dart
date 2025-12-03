// lib/shared/widgets/commune_selector_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/commune/commune_model.dart';
import '../../data/providers/geolocation_provider.dart';

/// Widget de sélection de commune avec coordonnées GPS automatiques
class CommuneSelectorWidget extends ConsumerStatefulWidget {
  final String? initialCommune;
  final Function(CommuneModel) onCommuneSelected;
  final String? label;
  final String? hint;
  final bool enabled;

  const CommuneSelectorWidget({
    Key? key,
    this.initialCommune,
    required this.onCommuneSelected,
    this.label,
    this.hint,
    this.enabled = true,
  }) : super(key: key);

  @override
  ConsumerState<CommuneSelectorWidget> createState() => _CommuneSelectorWidgetState();
}

class _CommuneSelectorWidgetState extends ConsumerState<CommuneSelectorWidget> {
  CommuneModel? _selectedCommune;

  @override
  Widget build(BuildContext context) {
    final communesAsync = ref.watch(communesProvider);

    return communesAsync.when(
      data: (communes) {
        // Si une commune initiale est fournie et pas encore sélectionnée
        if (widget.initialCommune != null && _selectedCommune == null) {
          _selectedCommune = communes.firstWhere(
            (c) => c.commune.toLowerCase() == widget.initialCommune!.toLowerCase(),
            orElse: () => communes.first,
          );
        }

        return DropdownButtonFormField<CommuneModel>(
          value: _selectedCommune,
          decoration: InputDecoration(
            labelText: widget.label ?? 'Commune',
            hintText: widget.hint ?? 'Sélectionnez une commune',
            border: const OutlineInputBorder(),
            enabled: widget.enabled,
            prefixIcon: const Icon(Icons.location_city),
          ),
          items: communes.map((commune) {
            return DropdownMenuItem(
              value: commune,
              child: Text(commune.commune),
            );
          }).toList(),
          onChanged: widget.enabled
              ? (commune) {
                  if (commune != null) {
                    setState(() {
                      _selectedCommune = commune;
                    });
                    widget.onCommuneSelected(commune);
                  }
                }
              : null,
        );
      },
      loading: () => const DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Commune',
          hintText: 'Chargement...',
          border: OutlineInputBorder(),
          prefixIcon: CircularProgressIndicator(),
        ),
        items: [],
        onChanged: null,
      ),
      error: (error, stack) => DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: widget.label ?? 'Commune',
          hintText: 'Erreur de chargement',
          border: const OutlineInputBorder(),
          errorText: 'Impossible de charger les communes',
          prefixIcon: const Icon(Icons.error, color: Colors.red),
        ),
        items: const [],
        onChanged: null,
      ),
    );
  }
}
