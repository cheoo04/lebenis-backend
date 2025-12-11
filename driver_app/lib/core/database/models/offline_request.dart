import 'package:hive/hive.dart';

part 'offline_request.g.dart';

/// Collection pour stocker les requêtes en attente de synchronisation
/// 
/// Quand l'app est hors-ligne, les actions sont stockées ici
/// et synchronisées automatiquement à la reconnexion
@HiveType(typeId: 1)
class OfflineRequest extends HiveObject {
  /// Type de requête HTTP
  @HiveField(0)
  late String method; // GET, POST, PUT, PATCH, DELETE
  
  /// Endpoint API
  @HiveField(1)
  late String endpoint;
  
  /// Données de la requête (JSON string)
  @HiveField(2)
  String? dataJson;
  
  /// Query parameters (JSON string)
  @HiveField(3)
  String? queryParamsJson;
  
  /// Timestamp de création
  @HiveField(4)
  late DateTime createdAt;
  
  /// Nombre de tentatives de synchronisation
  @HiveField(5)
  late int retryCount;
  
  /// Dernière erreur rencontrée
  @HiveField(6)
  String? lastError;
  
  /// Priorité (plus haut = plus prioritaire)
  @HiveField(7)
  late int priority;
  
  /// Status de la requête
  @HiveField(8)
  late String status; // pending, syncing, failed, completed
  
  /// Référence à une entité (ex: delivery_id pour lier à une livraison)
  @HiveField(9)
  String? entityType;
  
  @HiveField(10)
  String? entityId;
  
  OfflineRequest();
  
  /// Factory pour créer une requête en attente
  factory OfflineRequest.create({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
    int priority = 0,
    String? entityType,
    String? entityId,
  }) {
    return OfflineRequest()
      ..method = method
      ..endpoint = endpoint
      ..dataJson = data != null ? _encodeJson(data) : null
      ..queryParamsJson = queryParams != null ? _encodeJson(queryParams) : null
      ..createdAt = DateTime.now()
      ..retryCount = 0
      ..priority = priority
      ..status = 'pending'
      ..entityType = entityType
      ..entityId = entityId;
  }
  
  /// Encoder JSON de manière sécurisée (format simple key:value||key:value)
  static String? _encodeJson(Map<String, dynamic>? data) {
    if (data == null) return null;
    try {
      return data.entries
          .map((e) => '${e.key}=${e.value}')
          .join('||');
    } catch (_) {
      return null;
    }
  }
  
  /// Decoder les données
  Map<String, dynamic>? get data {
    if (dataJson == null) return null;
    try {
      final pairs = dataJson!.split('||');
      return Map.fromEntries(
        pairs.where((p) => p.contains('=')).map((pair) {
          final parts = pair.split('=');
          return MapEntry(parts[0], parts.length > 1 ? parts.sublist(1).join('=') : '');
        }),
      );
    } catch (_) {
      return null;
    }
  }
  
  /// Decoder les query params
  Map<String, dynamic>? get queryParams {
    if (queryParamsJson == null) return null;
    try {
      final pairs = queryParamsJson!.split('||');
      return Map.fromEntries(
        pairs.where((p) => p.contains('=')).map((pair) {
          final parts = pair.split('=');
          return MapEntry(parts[0], parts.length > 1 ? parts.sublist(1).join('=') : '');
        }),
      );
    } catch (_) {
      return null;
    }
  }
  
  /// Incrémenter le compteur de tentatives
  void incrementRetry(String? error) {
    retryCount++;
    lastError = error;
    if (retryCount >= 5) {
      status = 'failed';
    }
  }
  
  /// Marquer comme complété
  void markCompleted() {
    status = 'completed';
  }
}
