# Intégration GPS dans Driver App - Guide Pratique

## Étape 1 : Intégration au Lifecycle de l'App

### Dans `main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/delivery/providers/gps_provider.dart';

class DriverApp extends ConsumerStatefulWidget {
  @override
  ConsumerState<DriverApp> createState() => _DriverAppState();
}

class _DriverAppState extends ConsumerState<DriverApp> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeGPS();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Arrêter le GPS quand l'app se ferme
    ref.read(gpsStateProvider.notifier).stopTracking();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Gérer le tracking GPS selon l'état de l'app
    switch (state) {
      case AppLifecycleState.resumed:
        // App au premier plan - reprendre le tracking
        _resumeGPSTracking();
        break;
      case AppLifecycleState.paused:
        // App en arrière-plan - garder le tracking actif
        // (le service GPS continuera en arrière-plan)
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // App fermée - arrêter le tracking
        ref.read(gpsStateProvider.notifier).stopTracking();
        break;
    }
  }

  Future<void> _initializeGPS() async {
    // Attendre que le profil du chauffeur soit chargé
    await Future.delayed(Duration(milliseconds: 500));
    
    // Récupérer le statut actuel du chauffeur
    final driverProfile = ref.read(driverProfileProvider);
    
    if (driverProfile != null) {
      // Démarrer le GPS avec le statut du chauffeur
      await ref.read(gpsStateProvider.notifier).startTracking(
        driverProfile.availabilityStatus,
      );
    }
  }

  Future<void> _resumeGPSTracking() async {
    final gpsState = ref.read(gpsStateProvider);
    
    // Si le GPS n'est pas actif, le redémarrer
    if (!gpsState.isTracking) {
      final driverProfile = ref.read(driverProfileProvider);
      if (driverProfile != null) {
        await ref.read(gpsStateProvider.notifier).startTracking(
          driverProfile.availabilityStatus,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ... reste de la config
    );
  }
}
```

---

## Étape 2 : Synchroniser GPS avec Statut Chauffeur

### Dans `driver_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/delivery/providers/gps_provider.dart';

class DriverProfileNotifier extends StateNotifier<AsyncValue<DriverProfile?>> {
  final Ref _ref;
  // ... autres dépendances

  DriverProfileNotifier(this._ref) : super(const AsyncValue.loading());

  /// Mettre à jour le statut de disponibilité
  Future<void> updateAvailabilityStatus(String newStatus) async {
    try {
      // 1. Mettre à jour le statut dans le backend
      final response = await _dioClient.patch(
        '/drivers/profile/availability/',
        data: {'availability_status': newStatus},
      );

      // 2. Mettre à jour le state local
      final updatedProfile = DriverProfile.fromJson(response.data);
      state = AsyncValue.data(updatedProfile);

      // 3. ✨ Synchroniser avec le GPS (change automatiquement l'intervalle)
      _ref.read(gpsStateProvider.notifier).updateDriverStatus(newStatus);

      // 4. Log pour debug
      print('Driver status changed to: $newStatus');
      print('GPS interval adjusted automatically');

    } catch (e) {
      print('Error updating availability: $e');
      rethrow;
    }
  }

  /// Passer en pause
  Future<void> startBreak(String breakType) async {
    try {
      await _dioClient.post('/drivers/breaks/start/', data: {
        'break_type': breakType,
      });

      // Passer le GPS en mode "offline" (5 min interval)
      _ref.read(gpsStateProvider.notifier).updateDriverStatus('offline');

    } catch (e) {
      print('Error starting break: $e');
      rethrow;
    }
  }

  /// Reprendre le service
  Future<void> endBreak() async {
    try {
      await _dioClient.post('/drivers/breaks/end/');

      // Remettre le GPS en mode "available"
      _ref.read(gpsStateProvider.notifier).updateDriverStatus('available');

    } catch (e) {
      print('Error ending break: $e');
      rethrow;
    }
  }
}
```

---

## Étape 3 : Afficher le Statut GPS dans l'UI

### Dans `driver_home_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../delivery/providers/gps_provider.dart';
import '../delivery/widgets/gps_status_widget.dart';

class DriverHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gpsState = ref.watch(gpsStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          // Indicateur GPS compact dans l'AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.gps_fixed,
                  color: gpsState.isTracking ? Colors.green : Colors.grey,
                  size: 20,
                ),
                SizedBox(width: 4),
                Text(
                  gpsState.isTracking ? 'GPS ON' : 'GPS OFF',
                  style: TextStyle(
                    fontSize: 12,
                    color: gpsState.isTracking ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Widget complet de statut GPS
          GPSStatusWidget(),

          // Reste du dashboard
          // ...
        ],
      ),
    );
  }
}
```

---

## Étape 4 : Gérer les Erreurs GPS

### Widget d'Alerte GPS

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gps_provider.dart';
import 'package:geolocator/geolocator.dart';

class GPSPermissionWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gpsState = ref.watch(gpsStateProvider);

    // Si erreur GPS, afficher une alerte
    if (gpsState.errorMessage != null) {
      return Container(
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange),
        ),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Problème GPS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[900],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    gpsState.errorMessage!,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                // Ouvrir les paramètres de localisation
                await Geolocator.openLocationSettings();
              },
              child: Text('Régler'),
            ),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }
}
```

### Dans `driver_home_screen.dart`

```dart
body: Column(
  children: [
    // Alerte GPS si problème
    GPSPermissionWidget(),

    // Statut GPS
    GPSStatusWidget(),

    // Reste du contenu
    // ...
  ],
)
```

---

## Étape 5 : Test sur Appareil Réel

### Checklist de Test

**Permissions** :
- [ ] Permission localisation "Toujours" accordée
- [ ] GPS activé sur l'appareil
- [ ] Mode haute précision activé (Android)

**Fonctionnalités** :
- [ ] GPS démarre au lancement de l'app
- [ ] Changement de statut change l'intervalle
  - [ ] `available` → 10s (arrêté) ou 30s (en mouvement)
  - [ ] `busy` → 10s (arrêté) ou 30s (en mouvement)
  - [ ] `offline` → 5 min
- [ ] Position envoyée au backend
- [ ] Widget de statut affiche les bonnes infos
- [ ] GPS s'arrête quand l'app se ferme

**Performance** :
- [ ] Batterie : max 5% / heure en mode `busy`
- [ ] Batterie : max 1% / heure en mode `offline`
- [ ] Pas de lag UI
- [ ] Backend reçoit les updates

### Commandes de Debug

**Backend** :
```bash
# Voir les updates GPS
cd /home/cheoo/lebenis_project/backend
python manage.py shell

from apps.drivers.models import Driver
from apps.drivers.location_models import LocationUpdate

# Dernières positions d'un chauffeur
driver = Driver.objects.first()
locations = LocationUpdate.objects.filter(driver=driver).order_by('-timestamp')[:10]
for loc in locations:
    print(f"{loc.timestamp}: ({loc.latitude}, {loc.longitude}) - {loc.driver_status}")
```

**Flutter** :
```dart
// Dans main.dart (dev mode uniquement)
if (kDebugMode) {
  // Log GPS state toutes les 30 secondes
  Timer.periodic(Duration(seconds: 30), (timer) {
    final gpsState = ref.read(gpsStateProvider);
    print('=== GPS STATUS ===');
    print('Tracking: ${gpsState.isTracking}');
    print('Status: ${gpsState.driverStatus}');
    print('Interval: ${gpsState.currentInterval}s');
    print('Position: ${gpsState.currentPosition?.latitude}, ${gpsState.currentPosition?.longitude}');
    print('Last Update: ${gpsState.lastUpdate}');
    print('==================');
  });
}
```

---

## Étape 6 : Optimisations Finales

### 1. Mode Économie de Batterie

```dart
// Dans adaptive_gps_service.dart
Future<void> _updateLocation() async {
  // Vérifier le niveau de batterie
  final batteryLevel = await _getBatteryLevel();
  
  // Si batterie faible, passer en mode économie
  if (batteryLevel != null && batteryLevel < 15) {
    print('Low battery detected: ${batteryLevel}%. Reducing GPS frequency.');
    
    // Forcer intervalle de 5 minutes si batterie < 15%
    if (_currentDriverStatus != 'offline') {
      updateDriverStatus('offline');
    }
  }
  
  // ... reste du code
}
```

### 2. Implémenter Détection de Batterie

Ajouter à `pubspec.yaml` :
```yaml
dependencies:
  battery_plus: ^6.0.3
```

Dans `adaptive_gps_service.dart` :
```dart
import 'package:battery_plus/battery_plus.dart';

class AdaptiveGPSService {
  final Battery _battery = Battery();
  
  Future<int?> _getBatteryLevel() async {
    try {
      return await _battery.batteryLevel;
    } catch (e) {
      print('Error getting battery level: $e');
      return null;
    }
  }
}
```

### 3. Cleanup Auto au Backend

Créer un Celery task :

```python
# backend/apps/drivers/tasks.py
from celery import shared_task
from .gps_tracking_service import GPSTrackingService

@shared_task
def cleanup_old_gps_data():
    """
    Nettoie les données GPS de plus de 30 jours.
    À exécuter quotidiennement.
    """
    deleted_count = GPSTrackingService.cleanup_old_locations(days_to_keep=30)
    return f"Deleted {deleted_count} old location records"
```

Configurer Celery Beat :
```python
# backend/config/celery.py
from celery.schedules import crontab

app.conf.beat_schedule = {
    'cleanup-gps-daily': {
        'task': 'drivers.tasks.cleanup_old_gps_data',
        'schedule': crontab(hour=2, minute=0),  # 2h du matin
    },
}
```

---

## Résumé de l'Intégration

✅ **Lifecycle** : GPS démarre/arrête avec l'app  
✅ **Synchronisation** : GPS suit le statut chauffeur  
✅ **UI** : Widget de statut + alertes erreurs  
✅ **Performance** : Intervalles adaptatifs, économie batterie  
✅ **Robustesse** : Gestion erreurs, permissions, mode faible batterie  
✅ **Monitoring** : Logs debug, statistiques backend  

🎉 **Le GPS adaptatif est prêt pour la production !**
