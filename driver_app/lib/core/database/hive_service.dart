import 'dart:developer' as developer;
import 'package:hive_flutter/hive_flutter.dart';

import 'models/delivery_cache.dart';
import 'models/offline_request.dart';
import 'models/driver_profile_cache.dart';

/// Service de gestion de la base de données Hive
/// 
/// Hive est une base de données NoSQL légère et ultra-rapide pour Flutter
/// Parfaite pour le mode offline avec synchronisation automatique
class HiveService {
  static HiveService? _instance;
  static bool _isInitialized = false;
  
  // Box names
  static const String _deliveriesBox = 'deliveries_cache';
  static const String _requestsBox = 'offline_requests';
  static const String _profileBox = 'driver_profile';
  
  // Boxes
  late Box<DeliveryCache> _deliveries;
  late Box<OfflineRequest> _requests;
  late Box<DriverProfileCache> _profile;
  
  HiveService._();
  
  /// Singleton instance
  static HiveService get instance {
    _instance ??= HiveService._();
    return _instance!;
  }
  
  /// Vérifier si initialisé
  static bool get isInitialized => _isInitialized;
  
  /// Initialiser Hive
  /// Doit être appelé au démarrage de l'application (main.dart)
  static Future<void> initialize() async {
    if (_isInitialized) {
      developer.log('📦 Hive already initialized');
      return;
    }
    
    try {
      // Initialize Hive Flutter
      await Hive.initFlutter();
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(DeliveryCacheAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(OfflineRequestAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(DriverProfileCacheAdapter());
      }
      
      // Open boxes
      instance._deliveries = await Hive.openBox<DeliveryCache>(_deliveriesBox);
      instance._requests = await Hive.openBox<OfflineRequest>(_requestsBox);
      instance._profile = await Hive.openBox<DriverProfileCache>(_profileBox);
      
      _isInitialized = true;
      developer.log('📦 Hive initialized successfully');
    } catch (e) {
      developer.log('❌ Error initializing Hive: $e');
      rethrow;
    }
  }
  
  /// Fermer Hive
  static Future<void> close() async {
    await Hive.close();
    _isInitialized = false;
    developer.log('📦 Hive closed');
  }
  
  /// Vider toutes les collections (pour déconnexion)
  Future<void> clearAll() async {
    await _deliveries.clear();
    await _requests.clear();
    await _profile.clear();
    developer.log('🗑️ All Hive boxes cleared');
  }
  
  // ===========================================================================
  // DELIVERY CACHE OPERATIONS
  // ===========================================================================
  
  /// Sauvegarder une livraison en cache
  Future<void> cacheDelivery(DeliveryCache delivery) async {
    // Use serverId as key for easy lookup
    await _deliveries.put(delivery.serverId, delivery);
    developer.log('💾 Delivery cached: ${delivery.trackingNumber}');
  }
  
  /// Sauvegarder plusieurs livraisons
  Future<void> cacheDeliveries(List<DeliveryCache> deliveries) async {
    final map = {for (var d in deliveries) d.serverId: d};
    await _deliveries.putAll(map);
    developer.log('💾 ${deliveries.length} deliveries cached');
  }
  
  /// Récupérer toutes les livraisons en cache
  List<DeliveryCache> getCachedDeliveries() {
    final deliveries = _deliveries.values.toList();
    deliveries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return deliveries;
  }
  
  /// Récupérer les livraisons par statut
  List<DeliveryCache> getDeliveriesByStatus(String status) {
    return _deliveries.values
        .where((d) => d.status == status)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  /// Récupérer les livraisons actives (assigned, picked_up)
  List<DeliveryCache> getActiveDeliveries() {
    return _deliveries.values
        .where((d) => d.status == 'assigned' || d.status == 'picked_up')
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
  
  /// Récupérer une livraison par son ID serveur
  DeliveryCache? getDeliveryByServerId(String serverId) {
    return _deliveries.get(serverId);
  }
  
  /// Récupérer une livraison par tracking number
  DeliveryCache? getDeliveryByTracking(String trackingNumber) {
    try {
      return _deliveries.values.firstWhere(
        (d) => d.trackingNumber == trackingNumber,
      );
    } catch (_) {
      return null;
    }
  }
  
  /// Mettre à jour le statut d'une livraison (en local)
  Future<void> updateDeliveryStatus(String serverId, String newStatus) async {
    final delivery = _deliveries.get(serverId);
    if (delivery != null) {
      delivery.status = newStatus;
      delivery.needsSync = true;
      
      // Update timestamps based on status
      switch (newStatus) {
        case 'picked_up':
          delivery.pickupTime = DateTime.now();
          break;
        case 'delivered':
          delivery.deliveryTime = DateTime.now();
          break;
        case 'cancelled':
          delivery.cancelledAt = DateTime.now();
          break;
      }
      
      await delivery.save();
      developer.log('📝 Delivery $serverId status updated to $newStatus');
    }
  }
  
  /// Marquer une livraison comme synchronisée
  Future<void> markDeliverySynced(String serverId) async {
    final delivery = _deliveries.get(serverId);
    if (delivery != null) {
      delivery.needsSync = false;
      delivery.cachedAt = DateTime.now();
      await delivery.save();
    }
  }
  
  /// Récupérer les livraisons à synchroniser
  List<DeliveryCache> getDeliveriesNeedingSync() {
    return _deliveries.values.where((d) => d.needsSync).toList();
  }
  
  /// Supprimer les anciennes livraisons (plus de 7 jours)
  Future<int> cleanupOldDeliveries({int daysOld = 7}) async {
    final cutoff = DateTime.now().subtract(Duration(days: daysOld));
    int deleted = 0;
    
    final toDelete = _deliveries.values.where((d) =>
        d.createdAt.isBefore(cutoff) &&
        d.status != 'assigned' &&
        d.status != 'picked_up'
    ).toList();
    
    for (final delivery in toDelete) {
      await _deliveries.delete(delivery.serverId);
      deleted++;
    }
    
    developer.log('🗑️ Cleaned up $deleted old deliveries');
    return deleted;
  }
  
  // ===========================================================================
  // OFFLINE REQUEST OPERATIONS
  // ===========================================================================
  
  /// Ajouter une requête à la queue offline
  Future<void> queueRequest(OfflineRequest request) async {
    await _requests.add(request);
    developer.log('📝 Request queued: ${request.method} ${request.endpoint}');
  }
  
  /// Récupérer les requêtes en attente (triées par priorité et date)
  List<OfflineRequest> getPendingRequests() {
    return _requests.values
        .where((r) => r.status == 'pending')
        .toList()
      ..sort((a, b) {
        final priorityCompare = b.priority.compareTo(a.priority);
        if (priorityCompare != 0) return priorityCompare;
        return a.createdAt.compareTo(b.createdAt);
      });
  }
  
  /// Récupérer les requêtes échouées
  List<OfflineRequest> getFailedRequests() {
    return _requests.values.where((r) => r.status == 'failed').toList();
  }
  
  /// Mettre à jour le statut d'une requête
  Future<void> updateRequestStatus(int key, String status, {String? error}) async {
    final request = _requests.getAt(key);
    if (request != null) {
      request.status = status;
      if (error != null) {
        request.lastError = error;
        request.retryCount++;
      }
      await request.save();
    }
  }
  
  /// Supprimer une requête complétée
  Future<void> deleteRequest(OfflineRequest request) async {
    await request.delete();
  }
  
  /// Nettoyer les requêtes complétées
  Future<int> cleanupCompletedRequests() async {
    int deleted = 0;
    final completed = _requests.values.where((r) => r.status == 'completed').toList();
    
    for (final req in completed) {
      await req.delete();
      deleted++;
    }
    return deleted;
  }
  
  /// Nombre de requêtes en attente
  int getPendingRequestCount() {
    return _requests.values.where((r) => r.status == 'pending').length;
  }
  
  // ===========================================================================
  // DRIVER PROFILE OPERATIONS
  // ===========================================================================
  
  /// Sauvegarder le profil driver
  Future<void> cacheDriverProfile(DriverProfileCache profile) async {
    // Clear old profile and save new one
    await _profile.clear();
    await _profile.put('current', profile);
    developer.log('👤 Driver profile cached: ${profile.fullName}');
  }
  
  /// Récupérer le profil en cache
  DriverProfileCache? getCachedDriverProfile() {
    return _profile.get('current');
  }
  
  /// Mettre à jour la disponibilité
  Future<void> updateDriverAvailability(bool isAvailable) async {
    final profile = _profile.get('current');
    if (profile != null) {
      profile.isAvailable = isAvailable;
      profile.cachedAt = DateTime.now();
      await profile.save();
    }
  }
  
  /// Mettre à jour les earnings en local
  Future<void> updateDriverEarnings({
    double? todayEarnings,
    double? weekEarnings,
    double? monthEarnings,
  }) async {
    final profile = _profile.get('current');
    if (profile != null) {
      if (todayEarnings != null) profile.todayEarnings = todayEarnings;
      if (weekEarnings != null) profile.weekEarnings = weekEarnings;
      if (monthEarnings != null) profile.monthEarnings = monthEarnings;
      profile.cachedAt = DateTime.now();
      await profile.save();
    }
  }
  
  // ===========================================================================
  // STATS & DEBUG
  // ===========================================================================
  
  /// Statistiques de la base de données
  Map<String, int> getStats() {
    return {
      'deliveries': _deliveries.length,
      'pendingRequests': getPendingRequestCount(),
      'failedRequests': getFailedRequests().length,
      'hasProfile': _profile.isNotEmpty ? 1 : 0,
    };
  }
  
  /// Exporter les données pour debug
  Map<String, dynamic> exportForDebug() {
    final deliveries = getCachedDeliveries();
    final requests = getPendingRequests();
    final profile = getCachedDriverProfile();
    
    return {
      'deliveries': deliveries.map((d) => d.toJson()).toList(),
      'pendingRequests': requests.length,
      'profile': profile?.toJson(),
    };
  }
}
