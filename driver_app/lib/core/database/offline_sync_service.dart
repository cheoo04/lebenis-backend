import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';

import '../network/dio_client.dart';
import 'hive_service.dart';
import 'models/delivery_cache.dart';
import 'models/offline_request.dart';
import 'models/driver_profile_cache.dart';

/// Service de synchronisation offline avec Hive
/// 
/// Fonctionnalités:
/// 1. Détection automatique de connectivité
/// 2. Cache des livraisons actives dans Hive
/// 3. Queue des requêtes en attente
/// 4. Synchronisation automatique à la reconnexion
/// 5. Mode dégradé intelligent
class OfflineSyncService {
  final DioClient _dioClient;
  final HiveService _hiveService = HiveService.instance;
  
  // Connectivity
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  // State
  bool _isOnline = true;
  bool _isSyncing = false;
  final _connectivityController = StreamController<bool>.broadcast();
  final _syncProgressController = StreamController<SyncProgress>.broadcast();
  
  // Singleton
  static OfflineSyncService? _instance;
  factory OfflineSyncService(DioClient dioClient) {
    _instance ??= OfflineSyncService._internal(dioClient);
    return _instance!;
  }
  OfflineSyncService._internal(this._dioClient);
  
  // Streams
  Stream<bool> get connectivityStream => _connectivityController.stream;
  Stream<SyncProgress> get syncProgressStream => _syncProgressController.stream;
  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;
  
  /// Initialiser le service
  Future<void> initialize() async {
    // Check initial connectivity
    final results = await _connectivity.checkConnectivity();
    _updateConnectivity(results);
    
    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectivity,
    );
    
    developer.log('📡 OfflineSyncService initialized (online: $_isOnline)');
  }
  
  /// Mettre à jour l'état de connectivité
  void _updateConnectivity(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.isNotEmpty && 
                !results.contains(ConnectivityResult.none);
    
    if (_isOnline != wasOnline) {
      _connectivityController.add(_isOnline);
      
      if (_isOnline) {
        developer.log('🌐 Back online - Starting sync...');
        syncAll();
      } else {
        developer.log('📴 Offline mode activated');
      }
    }
  }
  
  /// Dispose
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityController.close();
    _syncProgressController.close();
  }
  
  // ===========================================================================
  // DELIVERY OPERATIONS
  // ===========================================================================
  
  /// Cache les livraisons depuis l'API
  Future<void> cacheDeliveriesFromApi(List<Map<String, dynamic>> deliveriesJson) async {
    final deliveries = deliveriesJson
        .map((json) => DeliveryCache.fromJson(json))
        .toList();
    
    await _hiveService.cacheDeliveries(deliveries);
    developer.log('💾 ${deliveries.length} deliveries cached from API');
  }
  
  /// Récupérer les livraisons (depuis cache si offline)
  List<DeliveryCache> getDeliveries({String? status}) {
    if (status != null) {
      return _hiveService.getDeliveriesByStatus(status);
    }
    return _hiveService.getCachedDeliveries();
  }
  
  /// Récupérer les livraisons actives
  List<DeliveryCache> getActiveDeliveries() {
    return _hiveService.getActiveDeliveries();
  }
  
  /// Mettre à jour le statut d'une livraison
  /// Si offline, la modification est stockée et synchronisée plus tard
  Future<bool> updateDeliveryStatus(
    String deliveryId, 
    String newStatus, {
    String? cancellationReason,
    String? photoUrl,
    String? signatureUrl,
  }) async {
    // Update local cache immediately
    await _hiveService.updateDeliveryStatus(deliveryId, newStatus);
    
    if (_isOnline) {
      // Try to sync immediately
      try {
        await _syncDeliveryStatusUpdate(
          deliveryId, 
          newStatus,
          cancellationReason: cancellationReason,
          photoUrl: photoUrl,
          signatureUrl: signatureUrl,
        );
        await _hiveService.markDeliverySynced(deliveryId);
        return true;
      } catch (e) {
        developer.log('⚠️ Failed to sync status update: $e');
        // Queue for later
        await _queueStatusUpdate(
          deliveryId, 
          newStatus,
          cancellationReason: cancellationReason,
          photoUrl: photoUrl,
          signatureUrl: signatureUrl,
        );
        return false;
      }
    } else {
      // Queue for later sync
      await _queueStatusUpdate(
        deliveryId, 
        newStatus,
        cancellationReason: cancellationReason,
        photoUrl: photoUrl,
        signatureUrl: signatureUrl,
      );
      return false;
    }
  }
  
  /// Sync status update to server
  Future<void> _syncDeliveryStatusUpdate(
    String deliveryId,
    String status, {
    String? cancellationReason,
    String? photoUrl,
    String? signatureUrl,
  }) async {
    final endpoint = _getStatusEndpoint(status, deliveryId);
    final data = <String, dynamic>{};
    
    if (cancellationReason != null) {
      data['cancellation_reason'] = cancellationReason;
    }
    if (photoUrl != null) {
      data['delivery_photo'] = photoUrl;
    }
    if (signatureUrl != null) {
      data['recipient_signature'] = signatureUrl;
    }
    
    await _dioClient.post(endpoint, data: data.isEmpty ? null : data);
  }
  
  /// Get endpoint for status update
  String _getStatusEndpoint(String status, String deliveryId) {
    switch (status) {
      case 'picked_up':
        return '/deliveries/$deliveryId/pickup/';
      case 'delivered':
        return '/deliveries/$deliveryId/deliver/';
      case 'cancelled':
        return '/deliveries/$deliveryId/cancel/';
      default:
        return '/deliveries/$deliveryId/';
    }
  }
  
  /// Queue status update for later sync
  Future<void> _queueStatusUpdate(
    String deliveryId,
    String status, {
    String? cancellationReason,
    String? photoUrl,
    String? signatureUrl,
  }) async {
    final data = <String, dynamic>{'status': status};
    if (cancellationReason != null) {
      data['cancellation_reason'] = cancellationReason;
    }
    if (photoUrl != null) {
      data['delivery_photo'] = photoUrl;
    }
    if (signatureUrl != null) {
      data['recipient_signature'] = signatureUrl;
    }
    
    final request = OfflineRequest.create(
      method: 'POST',
      endpoint: _getStatusEndpoint(status, deliveryId),
      data: data,
      priority: 10, // High priority for status updates
      entityType: 'delivery',
      entityId: deliveryId,
    );
    
    await _hiveService.queueRequest(request);
    developer.log('📝 Status update queued: $deliveryId -> $status');
  }
  
  // ===========================================================================
  // DRIVER PROFILE OPERATIONS
  // ===========================================================================
  
  /// Cache le profil driver
  Future<void> cacheDriverProfile(Map<String, dynamic> profileJson) async {
    final profile = DriverProfileCache.fromJson(profileJson);
    await _hiveService.cacheDriverProfile(profile);
  }
  
  /// Récupérer le profil (depuis cache si offline)
  DriverProfileCache? getDriverProfile() {
    return _hiveService.getCachedDriverProfile();
  }
  
  /// Mettre à jour la disponibilité
  Future<bool> updateAvailability(bool isAvailable) async {
    await _hiveService.updateDriverAvailability(isAvailable);
    
    if (_isOnline) {
      try {
        await _dioClient.patch('/drivers/me/', data: {
          'is_available': isAvailable,
        });
        return true;
      } catch (e) {
        // Queue for later
        final request = OfflineRequest.create(
          method: 'PATCH',
          endpoint: '/drivers/me/',
          data: {'is_available': isAvailable},
          priority: 5,
          entityType: 'driver_profile',
        );
        await _hiveService.queueRequest(request);
        return false;
      }
    } else {
      final request = OfflineRequest.create(
        method: 'PATCH',
        endpoint: '/drivers/me/',
        data: {'is_available': isAvailable},
        priority: 5,
        entityType: 'driver_profile',
      );
      await _hiveService.queueRequest(request);
      return false;
    }
  }
  
  // ===========================================================================
  // GPS LOCATION OPERATIONS
  // ===========================================================================
  
  /// Envoyer la position GPS (queue si offline)
  Future<bool> sendGPSLocation(double latitude, double longitude) async {
    if (_isOnline) {
      try {
        await _dioClient.post('/gps/update-location/', data: {
          'latitude': latitude,
          'longitude': longitude,
        });
        return true;
      } catch (e) {
        // Don't queue GPS updates if failed - they become stale
        developer.log('⚠️ GPS update failed: $e');
        return false;
      }
    } else {
      // Don't queue GPS updates when offline - they become stale
      developer.log('📴 GPS update skipped (offline)');
      return false;
    }
  }
  
  // ===========================================================================
  // SYNCHRONIZATION
  // ===========================================================================
  
  /// Synchroniser toutes les données en attente
  Future<SyncResult> syncAll() async {
    if (!_isOnline) {
      return SyncResult(success: false, message: 'Offline');
    }
    
    if (_isSyncing) {
      return SyncResult(success: false, message: 'Sync already in progress');
    }
    
    _isSyncing = true;
    _syncProgressController.add(SyncProgress(status: SyncStatus.started));
    
    int synced = 0;
    int failed = 0;
    final errors = <String>[];
    
    try {
      // Get pending requests
      final requests = _hiveService.getPendingRequests();
      final total = requests.length;
      
      developer.log('🔄 Starting sync: $total pending requests');
      
      for (int i = 0; i < requests.length; i++) {
        final request = requests[i];
        
        _syncProgressController.add(SyncProgress(
          status: SyncStatus.syncing,
          current: i + 1,
          total: total,
          message: '${request.method} ${request.endpoint}',
        ));
        
        try {
          await _executeRequest(request);
          await _hiveService.deleteRequest(request);
          synced++;
        } catch (e) {
          failed++;
          errors.add('${request.endpoint}: $e');
          request.incrementRetry(e.toString());
          await request.save();
        }
      }
      
      // Sync deliveries that need sync
      final deliveriesToSync = _hiveService.getDeliveriesNeedingSync();
      for (final delivery in deliveriesToSync) {
        try {
          // Re-fetch from server to get latest state
          await _hiveService.markDeliverySynced(delivery.serverId);
        } catch (e) {
          developer.log('⚠️ Failed to sync delivery ${delivery.serverId}: $e');
        }
      }
      
      // Cleanup old data
      await _hiveService.cleanupOldDeliveries();
      await _hiveService.cleanupCompletedRequests();
      
      _syncProgressController.add(SyncProgress(
        status: SyncStatus.completed,
        current: total,
        total: total,
        message: 'Sync completed: $synced success, $failed failed',
      ));
      
      developer.log('✅ Sync completed: $synced success, $failed failed');
      
      return SyncResult(
        success: failed == 0,
        synced: synced,
        failed: failed,
        errors: errors,
        message: '$synced synced, $failed failed',
      );
      
    } catch (e) {
      developer.log('❌ Sync error: $e');
      _syncProgressController.add(SyncProgress(
        status: SyncStatus.error,
        message: e.toString(),
      ));
      
      return SyncResult(success: false, message: e.toString());
    } finally {
      _isSyncing = false;
    }
  }
  
  /// Exécuter une requête
  Future<void> _executeRequest(OfflineRequest request) async {
    switch (request.method.toUpperCase()) {
      case 'GET':
        await _dioClient.get(
          request.endpoint,
          queryParameters: request.queryParams,
        );
        break;
      case 'POST':
        await _dioClient.post(
          request.endpoint,
          data: request.data,
          queryParameters: request.queryParams,
        );
        break;
      case 'PUT':
        await _dioClient.put(
          request.endpoint,
          data: request.data,
        );
        break;
      case 'PATCH':
        await _dioClient.patch(
          request.endpoint,
          data: request.data,
        );
        break;
      case 'DELETE':
        await _dioClient.delete(request.endpoint);
        break;
    }
  }
  
  // ===========================================================================
  // HELPERS
  // ===========================================================================
  
  /// Nombre de requêtes en attente
  int getPendingCount() {
    return _hiveService.getPendingRequestCount();
  }
  
  /// Statistiques
  Map<String, int> getStats() {
    return _hiveService.getStats();
  }
  
  /// Forcer la synchronisation manuelle
  Future<SyncResult> forceSync() async {
    // First check connectivity
    final results = await _connectivity.checkConnectivity();
    _updateConnectivity(results);
    
    if (!_isOnline) {
      return SyncResult(success: false, message: 'No internet connection');
    }
    
    return await syncAll();
  }
  
  /// Clear all cached data (for logout)
  Future<void> clearAll() async {
    await _hiveService.clearAll();
    developer.log('🗑️ All offline data cleared');
  }
}

// ===========================================================================
// MODELS
// ===========================================================================

/// Résultat de synchronisation
class SyncResult {
  final bool success;
  final int synced;
  final int failed;
  final List<String> errors;
  final String message;
  
  SyncResult({
    required this.success,
    this.synced = 0,
    this.failed = 0,
    this.errors = const [],
    this.message = '',
  });
}

/// Statut de synchronisation
enum SyncStatus {
  started,
  syncing,
  completed,
  error,
}

/// Progression de synchronisation
class SyncProgress {
  final SyncStatus status;
  final int current;
  final int total;
  final String message;
  
  SyncProgress({
    required this.status,
    this.current = 0,
    this.total = 0,
    this.message = '',
  });
  
  double get progress => total > 0 ? current / total : 0;
}
