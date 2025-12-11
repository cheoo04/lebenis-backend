import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/dio_client.dart';

/// Offline Service - Gestion du mode hors-ligne
/// 
/// Fonctionnalités:
/// 1. Détection de connectivité
/// 2. Cache des données critiques (livraisons actives)
/// 3. Queue des requêtes en attente
/// 4. Synchronisation automatique à la reconnexion
/// 
/// IMPORTANT: Pour une implémentation complète, considérez:
/// - Hive ou Isar pour le stockage local performant
/// - WorkManager pour la synchronisation en arrière-plan
/// - connectivity_plus pour la détection de connectivité

class OfflineService {
  final DioClient _dioClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Keys for storage
  static const String _keyOfflineQueue = 'offline_queue';
  static const String _keyCachedDeliveries = 'cached_deliveries';
  static const String _keyCachedProfile = 'cached_driver_profile';
  static const String _keyLastSync = 'last_sync_timestamp';
  
  // Singleton
  static OfflineService? _instance;
  factory OfflineService(DioClient dioClient) {
    _instance ??= OfflineService._internal(dioClient);
    return _instance!;
  }
  OfflineService._internal(this._dioClient);
  
  // Connection status
  bool _isOnline = true;
  final _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityStream => _connectivityController.stream;
  
  /// Initialize offline service
  Future<void> initialize() async {
    developer.log('📱 Offline Service initialized');
    // TODO: Ajouter connectivity_plus pour détecter l'état réseau
  }
  
  /// Set connectivity status
  void setOnlineStatus(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      _connectivityController.add(isOnline);
      
      if (isOnline) {
        developer.log('🌐 Back online - Starting sync');
        syncPendingRequests();
      } else {
        developer.log('📴 Offline mode activated');
      }
    }
  }
  
  /// Check if online
  bool get isOnline => _isOnline;
  
  // =========================================================================
  // QUEUE MANAGEMENT - Requêtes en attente
  // =========================================================================
  
  /// Add request to offline queue
  Future<void> queueRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final queue = await _getQueue();
      
      queue.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'method': method,
        'endpoint': endpoint,
        'data': data,
        'queryParams': queryParams,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      await _saveQueue(queue);
      developer.log('📝 Request queued: $method $endpoint');
      
    } catch (e) {
      developer.log('❌ Error queueing request: $e');
    }
  }
  
  /// Sync all pending requests
  Future<void> syncPendingRequests() async {
    if (!_isOnline) {
      developer.log('Cannot sync: offline');
      return;
    }
    
    try {
      final queue = await _getQueue();
      if (queue.isEmpty) {
        developer.log('✅ No pending requests to sync');
        return;
      }
      
      developer.log('🔄 Syncing ${queue.length} pending requests...');
      
      final failedRequests = <Map<String, dynamic>>[];
      
      for (final request in queue) {
        try {
          final method = request['method'] as String;
          final endpoint = request['endpoint'] as String;
          final data = request['data'] as Map<String, dynamic>?;
          
          switch (method.toUpperCase()) {
            case 'POST':
              await _dioClient.post(endpoint, data: data);
              break;
            case 'PUT':
              await _dioClient.put(endpoint, data: data);
              break;
            case 'PATCH':
              await _dioClient.patch(endpoint, data: data);
              break;
            case 'DELETE':
              await _dioClient.delete(endpoint);
              break;
            default:
              developer.log('Unknown method: $method');
          }
          
          developer.log('✅ Synced: $method $endpoint');
          
        } catch (e) {
          developer.log('❌ Failed to sync request: $e');
          failedRequests.add(request);
        }
      }
      
      // Keep only failed requests in queue
      await _saveQueue(failedRequests);
      
      // Update last sync timestamp
      await _storage.write(
        key: _keyLastSync,
        value: DateTime.now().toIso8601String(),
      );
      
      developer.log('🔄 Sync complete. ${failedRequests.length} failed requests remaining');
      
    } catch (e) {
      developer.log('❌ Error during sync: $e');
    }
  }
  
  /// Get pending requests count
  Future<int> getPendingCount() async {
    final queue = await _getQueue();
    return queue.length;
  }
  
  // =========================================================================
  // CACHE MANAGEMENT - Données en cache
  // =========================================================================
  
  /// Cache active deliveries for offline access
  Future<void> cacheDeliveries(List<Map<String, dynamic>> deliveries) async {
    try {
      final jsonString = jsonEncode(deliveries);
      await _storage.write(key: _keyCachedDeliveries, value: jsonString);
      developer.log('💾 Cached ${deliveries.length} deliveries');
    } catch (e) {
      developer.log('❌ Error caching deliveries: $e');
    }
  }
  
  /// Get cached deliveries
  Future<List<Map<String, dynamic>>> getCachedDeliveries() async {
    try {
      final jsonString = await _storage.read(key: _keyCachedDeliveries);
      if (jsonString == null) return [];
      
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      developer.log('❌ Error reading cached deliveries: $e');
      return [];
    }
  }
  
  /// Cache driver profile
  Future<void> cacheDriverProfile(Map<String, dynamic> profile) async {
    try {
      final jsonString = jsonEncode(profile);
      await _storage.write(key: _keyCachedProfile, value: jsonString);
      developer.log('💾 Driver profile cached');
    } catch (e) {
      developer.log('❌ Error caching profile: $e');
    }
  }
  
  /// Get cached driver profile
  Future<Map<String, dynamic>?> getCachedDriverProfile() async {
    try {
      final jsonString = await _storage.read(key: _keyCachedProfile);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      developer.log('❌ Error reading cached profile: $e');
      return null;
    }
  }
  
  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    try {
      final timestamp = await _storage.read(key: _keyLastSync);
      if (timestamp == null) return null;
      return DateTime.parse(timestamp);
    } catch (e) {
      return null;
    }
  }
  
  /// Clear all cached data
  Future<void> clearCache() async {
    await _storage.delete(key: _keyCachedDeliveries);
    await _storage.delete(key: _keyCachedProfile);
    await _storage.delete(key: _keyOfflineQueue);
    await _storage.delete(key: _keyLastSync);
    developer.log('🗑️ Cache cleared');
  }
  
  // =========================================================================
  // PRIVATE HELPERS
  // =========================================================================
  
  Future<List<Map<String, dynamic>>> _getQueue() async {
    try {
      final jsonString = await _storage.read(key: _keyOfflineQueue);
      if (jsonString == null) return [];
      
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }
  
  Future<void> _saveQueue(List<Map<String, dynamic>> queue) async {
    final jsonString = jsonEncode(queue);
    await _storage.write(key: _keyOfflineQueue, value: jsonString);
  }
  
  /// Dispose resources
  void dispose() {
    _connectivityController.close();
    _instance = null;
  }
}

/// Offline-aware wrapper for API calls
/// 
/// Usage:
/// ```dart
/// final result = await offlineAwareCall(
///   onlineCall: () => dioClient.get('/deliveries/'),
///   offlineCall: () => offlineService.getCachedDeliveries(),
///   cacheResult: (data) => offlineService.cacheDeliveries(data),
/// );
/// ```
Future<T> offlineAwareCall<T>({
  required Future<T> Function() onlineCall,
  required Future<T> Function() offlineCall,
  Future<void> Function(T data)? cacheResult,
  required OfflineService offlineService,
}) async {
  if (offlineService.isOnline) {
    try {
      final result = await onlineCall();
      
      // Cache the result for offline use
      if (cacheResult != null) {
        await cacheResult(result);
      }
      
      return result;
    } catch (e) {
      // Network error - fall back to offline
      developer.log('Network error, falling back to cache: $e');
      return offlineCall();
    }
  } else {
    // Already offline - use cache
    return offlineCall();
  }
}
