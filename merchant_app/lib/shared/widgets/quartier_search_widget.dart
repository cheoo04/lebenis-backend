// lib/shared/widgets/quartier_search_widget.dart
// Widget de sélection commune + quartier avec recherche et GPS

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/quartier_model.dart';
import '../../core/providers/quartier_provider.dart';

/// Widget complet pour sélectionner une adresse (Commune + Quartier)
/// Retourne les coordonnées GPS via le callback onLocationSelected
class QuartierSearchWidget extends ConsumerStatefulWidget {
  final Function(String commune, String quartier, double lat, double lon)? onLocationSelected;
  final String? initialCommune;
  final String? initialQuartier;
  final String label;
  final bool showCoordinates;

  const QuartierSearchWidget({
    super.key,
    this.onLocationSelected,
    this.initialCommune,
    this.initialQuartier,
    this.label = 'Adresse de livraison',
    this.showCoordinates = false,
  });

  @override
  ConsumerState<QuartierSearchWidget> createState() => _QuartierSearchWidgetState();
}

class _QuartierSearchWidgetState extends ConsumerState<QuartierSearchWidget> {
  String? _selectedCommune;
  String? _selectedQuartier;
  double? _latitude;
  double? _longitude;
  bool _isLoadingGPS = false;
  final TextEditingController _searchController = TextEditingController();
  List<QuartierModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _selectedCommune = widget.initialCommune;
    _selectedQuartier = widget.initialQuartier;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _geocodeQuartier() async {
    if (_selectedQuartier == null || _selectedCommune == null) return;

    setState(() => _isLoadingGPS = true);

    try {
      final repository = ref.read(quartierRepositoryProvider);
      final result = await repository.geocodeQuartier(
        _selectedQuartier!,
        _selectedCommune!,
      );

      if (result != null && mounted) {
        setState(() {
          _latitude = result.latitude;
          _longitude = result.longitude;
          _isLoadingGPS = false;
        });

        // Passer la commune en UPPERCASE (valeur canonique)
        widget.onLocationSelected?.call(
          _selectedCommune!.toUpperCase(),
          _selectedQuartier!,
          result.latitude,
          result.longitude,
        );
      } else {
        setState(() => _isLoadingGPS = false);
        _showError('Coordonnées GPS non trouvées');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingGPS = false);
        _showError('Erreur: $e');
      }
    }
  }

  Future<void> _searchQuartiers(String query) async {
    if (query.length < 2) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final repository = ref.read(quartierRepositoryProvider);
      final results = await repository.searchQuartiers(query);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _selectFromSearch(QuartierModel quartier) {
    setState(() {
      _selectedCommune = quartier.commune;
      _selectedQuartier = quartier.nom;
      _latitude = quartier.latitude;
      _longitude = quartier.longitude;
      _searchController.clear();
      _searchResults = [];
    });

    // Passer la commune en UPPERCASE (valeur canonique)
    widget.onLocationSelected?.call(
      quartier.commune.toUpperCase(),
      quartier.nom,
      quartier.latitude,
      quartier.longitude,
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final communesAsync = ref.watch(quartiersAvailableCommunesProvider);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Text(
              widget.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Recherche rapide
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Recherche rapide',
                hintText: 'Tapez un nom de quartier...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchResults = []);
                            },
                          )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _searchQuartiers,
            ),

            // Résultats de recherche
            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final quartier = _searchResults[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.location_on, size: 20),
                      title: Text(quartier.nom),
                      subtitle: Text(quartier.commune),
                      trailing: quartier.hasCoordinates
                          ? const Icon(Icons.gps_fixed, size: 16, color: Colors.green)
                          : null,
                      onTap: () => _selectFromSearch(quartier),
                    );
                  },
                ),
              ),
            ],

            const Divider(height: 32),

            // OU sélection manuelle
            Text(
              'Ou sélectionnez manuellement:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),

            // Dropdown Commune
            communesAsync.when(
              data: (communes) => DropdownButtonFormField<String>(
                value: _selectedCommune,
                decoration: InputDecoration(
                  labelText: 'Commune',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.location_city),
                ),
                items: communes.map((commune) {
                  return DropdownMenuItem(value: commune, child: Text(commune));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCommune = value;
                    _selectedQuartier = null;
                    _latitude = null;
                    _longitude = null;
                  });
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erreur: $e', style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 12),

            // Dropdown Quartier (si commune sélectionnée)
            if (_selectedCommune != null)
              ref.watch(quartiersByCommuneProvider(_selectedCommune!)).when(
                data: (quartiers) => DropdownButtonFormField<String>(
                  value: _selectedQuartier,
                  isExpanded: true, // ✅ Empêche l'overflow du dropdown
                  decoration: InputDecoration(
                    labelText: 'Quartier',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.home),
                  ),
                  items: quartiers.map((q) {
                    return DropdownMenuItem(
                      value: q.nom,
                      child: Row(
                        children: [
                          // ✅ Flexible pour éviter l'overflow sur les noms longs
                          Flexible(
                            child: Text(
                              q.nom,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (q.hasCoordinates) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.gps_fixed, size: 14, color: Colors.green),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedQuartier = value;
                      _latitude = null;
                      _longitude = null;
                    });
                    // Auto-geocode après sélection
                    if (value != null) {
                      Future.delayed(const Duration(milliseconds: 100), _geocodeQuartier);
                    }
                  },
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Erreur: $e'),
              ),

            // Affichage des coordonnées GPS (optionnel)
            if (widget.showCoordinates && _latitude != null && _longitude != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.gps_fixed, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'GPS: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Indicateur de chargement GPS
            if (_isLoadingGPS)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Récupération des coordonnées GPS...'),
                  ],
                ),
              ),

            // Résumé de l'adresse sélectionnée
            if (_selectedCommune != null && _selectedQuartier != null && !_isLoadingGPS) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$_selectedQuartier, $_selectedCommune',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (_latitude != null)
                      Icon(Icons.gps_fixed, color: Colors.green[700], size: 18),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


/// Widget simplifié - juste un champ de recherche avec autocomplete
class QuartierAutocompleteField extends ConsumerStatefulWidget {
  final Function(QuartierModel quartier)? onSelected;
  final String? labelText;
  final String? hintText;

  const QuartierAutocompleteField({
    super.key,
    this.onSelected,
    this.labelText,
    this.hintText,
  });

  @override
  ConsumerState<QuartierAutocompleteField> createState() => _QuartierAutocompleteFieldState();
}

class _QuartierAutocompleteFieldState extends ConsumerState<QuartierAutocompleteField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<QuartierModel> _suggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(quartierRepositoryProvider);
      final results = await repository.searchQuartiers(query);
      
      if (mounted) {
        setState(() {
          _suggestions = results;
          _showSuggestions = results.isNotEmpty;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _select(QuartierModel quartier) {
    _controller.text = '${quartier.nom}, ${quartier.commune}';
    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });
    _focusNode.unfocus();
    widget.onSelected?.call(quartier);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: widget.labelText ?? 'Quartier',
            hintText: widget.hintText ?? 'Rechercher un quartier...',
            prefixIcon: const Icon(Icons.location_on),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _suggestions = [];
                            _showSuggestions = false;
                          });
                        },
                      )
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: _search,
          onTap: () {
            if (_suggestions.isNotEmpty) {
              setState(() => _showSuggestions = true);
            }
          },
        ),

        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final quartier = _suggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(quartier.nom),
                  subtitle: Text(quartier.commune),
                  trailing: quartier.hasCoordinates
                      ? const Icon(Icons.gps_fixed, size: 16, color: Colors.green)
                      : null,
                  onTap: () => _select(quartier),
                );
              },
            ),
          ),
      ],
    );
  }
}
