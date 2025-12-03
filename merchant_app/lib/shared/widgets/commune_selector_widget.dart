// lib/shared/widgets/commune_selector_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/geolocation_provider.dart';
import '../../core/models/commune_model.dart';
import '../../theme/app_theme.dart';

class CommuneSelectorWidget extends ConsumerWidget {
  final String? selectedCommune;
  final String label;
  final Function(String commune, double latitude, double longitude) onCommuneSelected;
  final bool isRequired;

  const CommuneSelectorWidget({
    Key? key,
    required this.selectedCommune,
    required this.label,
    required this.onCommuneSelected,
    this.isRequired = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communesAsync = ref.watch(communesProvider);

    return communesAsync.when(
      data: (communes) => _buildDropdown(context, communes),
      loading: () => _buildLoadingIndicator(),
      error: (error, stack) => _buildError(error.toString()),
    );
  }

  Widget _buildDropdown(BuildContext context, List<CommuneModel> communes) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedCommune,
          hint: Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          icon: Icon(Icons.location_on, color: AppTheme.primaryColor),
          items: communes.map((commune) {
            return DropdownMenuItem<String>(
              value: commune.commune,
              child: Text(
                '${commune.commune} - ${commune.zoneName}',
                style: const TextStyle(fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              final commune = communes.firstWhere((c) => c.commune == value);
              onCommuneSelected(
                commune.commune,
                commune.latitude,
                commune.longitude,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Chargement des communes...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[300]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Erreur: $error',
              style: TextStyle(color: Colors.red[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
