// lib/core/models/quartier_model.dart
// Modèle pour représenter un quartier avec ses coordonnées GPS

class QuartierModel {
  final String nom;
  final String commune;
  final double latitude;
  final double longitude;
  final String? source; // 'local' ou 'nominatim'

  QuartierModel({
    required this.nom,
    required this.commune,
    required this.latitude,
    required this.longitude,
    this.source,
  });

  /// Crée un QuartierModel depuis une réponse JSON de l'API
  factory QuartierModel.fromJson(Map<String, dynamic> json) {
    // Gère les cas où latitude/longitude sont null
    final lat = json['latitude'];
    final lng = json['longitude'];
    
    return QuartierModel(
      nom: json['nom'] as String? ?? json['quartier'] as String? ?? '',
      commune: json['commune'] as String? ?? '',
      latitude: lat != null ? (lat as num).toDouble() : 0.0,
      longitude: lng != null ? (lng as num).toDouble() : 0.0,
      source: json['source'] as String?,
    );
  }

  /// Convertit en JSON pour les requêtes API
  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'commune': commune,
      'latitude': latitude,
      'longitude': longitude,
      'source': source,
    };
  }

  /// Affichage formaté pour les dropdowns
  String get displayName => '$nom, $commune';

  /// Coordonnées formatées
  String get coordinates => '(${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})';

  /// Vérifie si les coordonnées GPS sont valides (non nulles/zéro)
  bool get hasCoordinates => latitude != 0.0 && longitude != 0.0;

  @override
  String toString() => '$nom ($commune) - $coordinates';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuartierModel &&
          runtimeType == other.runtimeType &&
          nom == other.nom &&
          commune == other.commune;

  @override
  int get hashCode => nom.hashCode ^ commune.hashCode;
}


/// Modèle pour une suggestion d'adresse (autocomplete)
class AddressSuggestion {
  final String displayName;
  final double latitude;
  final double longitude;
  final String source;

  AddressSuggestion({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.source,
  });

  factory AddressSuggestion.fromJson(Map<String, dynamic> json) {
    return AddressSuggestion(
      displayName: json['display_name'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      source: json['source'] as String? ?? 'unknown',
    );
  }
}
