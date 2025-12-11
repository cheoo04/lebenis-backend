# 📱 Guide Hive - Mode Offline pour LeBeni Driver

## Introduction

Hive est maintenant intégré dans l'application pour permettre le fonctionnement en mode offline. Ce guide explique comment utiliser les services de cache et de synchronisation.

## Architecture

```
lib/core/database/
├── database.dart           # Exports centralisés
├── hive_service.dart       # Service principal Hive
├── offline_sync_service.dart # Service de synchronisation
└── models/
    ├── delivery_cache.dart     # Modèle livraison cachée
    ├── offline_request.dart    # Modèle requête en attente
    └── driver_profile_cache.dart # Modèle profil driver
```

## Initialisation

L'initialisation est automatique dans `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive est initialisé automatiquement
  await HiveService.initialize();

  runApp(ProviderScope(child: const MyApp()));
}
```

## Utilisation avec Riverpod

### Providers disponibles

```dart
import 'package:lebeni_driver/core/providers/offline_provider.dart';

// État de connectivité
final isOnline = ref.watch(isOnlineProvider);

// Livraisons en cache
final cachedDeliveries = ref.watch(cachedDeliveriesProvider);

// Livraisons actives en cache
final activeDeliveries = ref.watch(activeCachedDeliveriesProvider);

// Profil driver en cache
final profile = ref.watch(cachedDriverProfileProvider);

// Nombre de requêtes en attente
final pendingCount = ref.watch(pendingRequestCountProvider);

// Statistiques offline
final stats = ref.watch(offlineStatsProvider);
```

### Forcer une synchronisation

```dart
ref.read(syncControllerProvider.notifier).forceSync();
```

## Widgets prêts à l'emploi

### OfflineIndicator

Affiche une barre de statut quand l'app est offline ou a des requêtes en attente:

```dart
Scaffold(
  body: Column(
    children: [
      const OfflineIndicator(),
      Expanded(child: YourContent()),
    ],
  ),
)
```

### OfflineAwareScaffold

Scaffold qui inclut automatiquement l'indicateur:

```dart
OfflineAwareScaffold(
  appBar: AppBar(title: Text('Ma Page')),
  body: YourContent(),
)
```

### PendingSyncBadge

Badge qui affiche le nombre de requêtes en attente:

```dart
PendingSyncBadge(
  child: IconButton(
    icon: Icon(Icons.sync),
    onPressed: () => ref.read(syncControllerProvider.notifier).forceSync(),
  ),
)
```

## Service OfflineSyncService

### Cacher les livraisons

```dart
final syncService = ref.read(offlineSyncServiceProvider);

// Après avoir récupéré les livraisons de l'API
await syncService.cacheDeliveriesFromApi(deliveriesJsonList);
```

### Mettre à jour le statut d'une livraison

```dart
// Cette méthode gère automatiquement le mode offline
final success = await syncService.updateDeliveryStatus(
  deliveryId,
  'picked_up',
  photoUrl: 'https://...',
);

if (!success) {
  // Affiché si la mise à jour est en queue
  showOfflineSnackBar(context, message: 'Action enregistrée hors-ligne');
}
```

### Cacher le profil driver

```dart
await syncService.cacheDriverProfile(profileJson);
```

## Intégration dans un Repository

Exemple de repository avec support offline:

```dart
class DeliveryRepository {
  final DioClient _dioClient;
  final OfflineSyncService _syncService;

  Future<List<DeliveryModel>> getMyDeliveries() async {
    if (_syncService.isOnline) {
      try {
        final response = await _dioClient.get('/deliveries/my-deliveries/');
        final deliveries = (response.data as List)
            .map((json) => DeliveryModel.fromJson(json))
            .toList();

        // Cacher pour utilisation offline
        await _syncService.cacheDeliveriesFromApi(response.data);

        return deliveries;
      } catch (e) {
        // En cas d'erreur réseau, utiliser le cache
        return _getCachedDeliveries();
      }
    } else {
      // Offline: utiliser le cache
      return _getCachedDeliveries();
    }
  }

  List<DeliveryModel> _getCachedDeliveries() {
    return _syncService.getDeliveries()
        .map((cache) => DeliveryModel.fromJson(cache.toJson()))
        .toList();
  }
}
```

## Gestion automatique de la connectivité

Le service écoute automatiquement les changements de connectivité:

1. **Passage online → offline**: Les nouvelles actions sont mises en queue
2. **Passage offline → online**: Synchronisation automatique des requêtes en attente

## Nettoyage automatique

- Les livraisons de plus de 7 jours sont supprimées automatiquement
- Les requêtes complétées sont nettoyées après synchronisation
- Les requêtes échouées 5 fois sont marquées comme "failed"

## Déconnexion

Lors de la déconnexion de l'utilisateur:

```dart
await syncService.clearAll();
```

## Debugging

### Voir les statistiques

```dart
final stats = ref.read(offlineStatsProvider);
print('Deliveries: ${stats['deliveries']}');
print('Pending: ${stats['pendingRequests']}');
print('Failed: ${stats['failedRequests']}');
```

### Exporter les données

```dart
final hiveService = ref.read(hiveServiceProvider);
final debug = hiveService.exportForDebug();
print(debug);
```

## Limitations

1. **GPS**: Les mises à jour GPS ne sont pas mises en queue (deviennent obsolètes)
2. **Images**: Les photos doivent être uploadées en ligne (pas de queue pour Cloudinary)
3. **Chat**: Le chat en temps réel nécessite une connexion

## Bonnes pratiques

1. Toujours utiliser `OfflineSyncService` pour les opérations critiques
2. Afficher l'`OfflineIndicator` sur les écrans principaux
3. Informer l'utilisateur quand une action est mise en queue
4. Tester le comportement offline régulièrement

## Exemple complet

```dart
class DeliveryListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    final deliveries = ref.watch(myDeliveriesProvider);

    return OfflineAwareScaffold(
      appBar: AppBar(
        title: const Text('Mes Livraisons'),
        actions: [
          PendingSyncBadge(
            child: IconButton(
              icon: const Icon(Icons.sync),
              onPressed: isOnline
                ? () => ref.read(syncControllerProvider.notifier).forceSync()
                : null,
            ),
          ),
        ],
      ),
      body: deliveries.when(
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) => DeliveryCard(delivery: list[i]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }
}
```

---

**Dernière mise à jour**: 11 Décembre 2025
