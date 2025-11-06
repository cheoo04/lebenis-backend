# Guide d'Intégration GPS Adaptatif

## Vue d'Ensemble

Le système GPS adaptatif optimise la consommation de batterie en ajustant automatiquement la fréquence de suivi selon le statut du chauffeur.

### Intervalles de Suivi

- **En Route (busy + en mouvement)** : 30 secondes
- **Arrêté (busy/available + immobile)** : 10 secondes  
- **Hors Service (offline)** : 5 minutes

### Détection de Mouvement

Le système détecte automatiquement si le chauffeur est en mouvement avec un seuil de **1,0 m/s (~3,6 km/h)**.

---

## Backend (Django)

### 1. Modèles

**LocationUpdate** - Stocke les points GPS individuels
```python
# apps/drivers/location_models.py
- latitude, longitude (avec précision)
- accuracy, speed, heading, altitude
- driver_status, is_moving, battery_level
- timestamp, created_at
```

**LocationTrackingSession** - Sessions de suivi agrégées
```python
# apps/drivers/location_models.py
- started_at, ended_at
- total_updates, average_accuracy, total_distance_km
- initial_battery_level, final_battery_level
- Propriétés: duration, battery_consumption
```

### 2. Service GPS

```python
# apps/drivers/gps_tracking_service.py
GPSTrackingService

# Méthodes principales :
- get_tracking_interval(status, is_moving) → int
- update_driver_location(driver, lat, lng, **kwargs) → LocationUpdate
- end_tracking_session(driver) → None
- get_location_history(driver, start_date, end_date, limit=100)
- get_tracking_statistics(driver, days=7)
- cleanup_old_locations(days_to_keep=30)
```

### 3. API Endpoints

**Mise à jour de localisation** (Principal)
```http
POST /api/v1/drivers/gps/update-location/
Content-Type: application/json

{
  "latitude": 12.345678,
  "longitude": -98.765432,
  "accuracy": 15.5,
  "speed": 5.2,
  "heading": 180.0,
  "altitude": 100.0,
  "battery_level": 85,
  "timestamp": "2024-01-20T10:30:00Z"
}

Response: 201
{
  "id": 123,
  "latitude": 12.345678,
  "longitude": -98.765432,
  ...
  "next_update_interval_seconds": 30
}
```

**Obtenir l'intervalle recommandé**
```http
GET /api/v1/drivers/gps/interval/

Response: 200
{
  "interval_seconds": 30,
  "driver_status": "busy",
  "is_moving": true,
  "recommended_accuracy": "high"
}
```

**Historique des positions**
```http
GET /api/v1/drivers/gps/history/?days=7&limit=100

Response: 200
{
  "count": 42,
  "results": [...]
}
```

**Sessions de suivi**
```http
GET /api/v1/drivers/gps/sessions/?days=7

Response: 200
{
  "count": 5,
  "results": [
    {
      "id": 10,
      "started_at": "2024-01-20T08:00:00Z",
      "ended_at": "2024-01-20T12:00:00Z",
      "total_updates": 480,
      "average_accuracy": 12.5,
      "total_distance_km": 45.2,
      "duration_seconds": 14400,
      "battery_consumption": 15
    }
  ]
}
```

**Statistiques de suivi**
```http
GET /api/v1/drivers/gps/statistics/?days=7

Response: 200
{
  "total_updates": 2340,
  "total_sessions": 12,
  "total_distance_km": 234.5,
  "average_accuracy_m": 14.2,
  "updates_per_day": 334.3
}
```

**Terminer la session**
```http
POST /api/v1/drivers/gps/end-session/

Response: 200
{
  "message": "Tracking session ended successfully"
}
```

---

## Flutter (Driver App)

### 1. Service GPS Adaptatif

```dart
// lib/core/services/adaptive_gps_service.dart
AdaptiveGPSService

// Démarrer le suivi
await gpsService.startTracking(
  driverStatus: 'busy',
  onUpdate: (position) {
    print('Position: ${position.latitude}, ${position.longitude}');
  },
  onErrorCallback: (error) {
    print('Erreur GPS: $error');
  },
);

// Mettre à jour le statut (change automatiquement l'intervalle)
gpsService.updateDriverStatus('available');

// Arrêter le suivi
gpsService.stopTracking();
```

### 2. Provider Riverpod

```dart
// lib/features/delivery/providers/gps_provider.dart
final gpsStateProvider = StateNotifierProvider<GPSStateNotifier, GPSState>

// Utilisation dans un widget
final gpsState = ref.watch(gpsStateProvider);

// Actions
ref.read(gpsStateProvider.notifier).startTracking('busy');
ref.read(gpsStateProvider.notifier).updateDriverStatus('available');
ref.read(gpsStateProvider.notifier).stopTracking();
```

### 3. Intégration avec le Statut du Chauffeur

**Quand le chauffeur change son statut de disponibilité :**

```dart
// Dans le provider du chauffeur
Future<void> updateAvailabilityStatus(String newStatus) async {
  // 1. Mettre à jour le statut dans le backend
  await _updateDriverStatus(newStatus);
  
  // 2. Mettre à jour le GPS (change automatiquement l'intervalle)
  ref.read(gpsStateProvider.notifier).updateDriverStatus(newStatus);
}
```

**Au démarrage de l'application :**

```dart
// Dans main.dart ou driver_home_screen.dart
@override
void initState() {
  super.initState();
  
  // Démarrer le suivi GPS avec le statut actuel
  final currentStatus = ref.read(driverProfileProvider).availabilityStatus;
  ref.read(gpsStateProvider.notifier).startTracking(currentStatus);
}

@override
void dispose() {
  // Arrêter le suivi
  ref.read(gpsStateProvider.notifier).stopTracking();
  super.dispose();
}
```

### 4. Widget de Statut GPS (Optionnel)

```dart
// lib/features/delivery/widgets/gps_status_widget.dart
GPSStatusWidget()

// Affichage dans le dashboard
Column(
  children: [
    // Autres widgets...
    GPSStatusWidget(),
  ],
)
```

Ce widget affiche :
- Statut actif/inactif
- Position actuelle
- Précision GPS
- Vitesse (si en mouvement)
- Intervalle de mise à jour
- Dernière mise à jour
- Messages d'erreur

---

## Permissions Android

### AndroidManifest.xml

```xml
<manifest>
  <!-- Permissions de localisation -->
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  
  <!-- Permission arrière-plan (Android 10+) -->
  <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
  
  <!-- Optionnel : pour la détection de batterie -->
  <uses-permission android:name="android.permission.BATTERY_STATS" />
</manifest>
```

### Demande de Permission dans l'App

Le service GPS demande automatiquement les permissions au démarrage du suivi. Pour demander explicitement :

```dart
final hasPermission = await Geolocator.checkPermission();
if (hasPermission == LocationPermission.denied) {
  await Geolocator.requestPermission();
}

// Pour Android 10+ (arrière-plan)
if (hasPermission == LocationPermission.whileInUse) {
  // Demander la permission arrière-plan si nécessaire
}
```

---

## Permissions iOS

### Info.plist

```xml
<dict>
  <!-- Toujours (iOS 11+) -->
  <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
  <string>Lebenis a besoin de votre localisation pour suivre vos livraisons et vous assigner de nouvelles commandes.</string>
  
  <!-- Pendant l'utilisation -->
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>Lebenis utilise votre localisation pour vous assigner les livraisons les plus proches.</string>
  
  <!-- Arrière-plan -->
  <key>NSLocationAlwaysUsageDescription</key>
  <string>Lebenis suit votre position en arrière-plan pour garantir des livraisons précises.</string>
  
  <!-- Mode arrière-plan -->
  <key>UIBackgroundModes</key>
  <array>
    <string>location</string>
  </array>
</dict>
```

---

## Optimisations et Performances

### 1. Économie de Batterie

**Intervalles adaptatifs** :
- Offline : 5 min → 90% d'économie vs suivi constant
- Stopped : 10 sec → Précision suffisante sans gaspillage
- En route : 30 sec → Équilibre précision/batterie

**Précision ajustée** :
```dart
LocationAccuracy accuracy;
if (driverStatus == 'busy') {
  accuracy = LocationAccuracy.high;       // En livraison
} else if (driverStatus == 'available') {
  accuracy = LocationAccuracy.medium;     // Disponible
} else {
  accuracy = LocationAccuracy.low;        // Hors service
}
```

### 2. Nettoyage Automatique

Le backend nettoie automatiquement les anciennes données :

```python
# apps/drivers/gps_tracking_service.py
GPSTrackingService.cleanup_old_locations(days_to_keep=30)
```

Configurer un cron job ou task Celery :
```python
# config/celery.py
from celery import Celery
from celery.schedules import crontab

app.conf.beat_schedule = {
    'cleanup-old-gps-data': {
        'task': 'drivers.tasks.cleanup_gps_data',
        'schedule': crontab(hour=2, minute=0),  # 2h du matin
    },
}
```

### 3. Index de Base de Données

Déjà configurés dans le modèle :
- `(driver, -timestamp)` - Historique par chauffeur
- `(driver, driver_status)` - Filtrage par statut
- `(-timestamp)` - Queries temporelles

---

## Tests

### Backend

```python
# tests/test_gps_tracking.py
def test_adaptive_interval():
    # En route
    interval = GPSTrackingService.get_tracking_interval('busy', is_moving=True)
    assert interval == 30
    
    # Arrêté
    interval = GPSTrackingService.get_tracking_interval('busy', is_moving=False)
    assert interval == 10
    
    # Hors service
    interval = GPSTrackingService.get_tracking_interval('offline', is_moving=False)
    assert interval == 300

def test_update_location():
    location = GPSTrackingService.update_driver_location(
        driver=driver,
        latitude=12.345,
        longitude=-98.765,
        speed=5.2,
    )
    assert location.is_moving == True  # Speed > 1.0 m/s
```

### Flutter

```dart
// test/gps_service_test.dart
void main() {
  test('GPS service starts tracking', () async {
    final service = AdaptiveGPSService(mockDioClient);
    
    await service.startTracking(driverStatus: 'busy');
    
    expect(service.isTracking, true);
    expect(service.driverStatus, 'busy');
  });
  
  test('Interval changes with status', () {
    final service = AdaptiveGPSService(mockDioClient);
    
    service.updateDriverStatus('offline');
    
    expect(service.driverStatus, 'offline');
    // Next update should be in 5 minutes
  });
}
```

---

## Monitoring et Debugging

### Logs Backend

```python
# Dans views.py ou service
import logging
logger = logging.getLogger(__name__)

logger.info(f'GPS update from driver {driver.id}: {latitude}, {longitude}')
logger.info(f'Tracking session started for driver {driver.id}')
logger.warning(f'Low GPS accuracy: {accuracy}m')
```

### Logs Flutter

```dart
// Dans adaptive_gps_service.dart
print('GPS tracking started with status: $driverStatus');
print('Scheduling next update in $interval seconds');
print('Driver is moving: $isMoving (speed: ${position.speed} m/s)');
```

### Widget de Debug (Dev uniquement)

```dart
// Afficher dans le debug drawer
if (kDebugMode) {
  ListTile(
    leading: Icon(Icons.bug_report),
    title: Text('GPS Debug'),
    subtitle: Text('${gpsState.currentInterval}s interval'),
    trailing: Text(gpsState.isTracking ? 'Active' : 'Inactive'),
  ),
}
```

---

## Dépannage

### Problème : Pas de mise à jour GPS

**Vérifier :**
1. Permissions accordées (localisation)
2. Services de localisation activés sur l'appareil
3. GPS tracking démarré : `service.isTracking == true`
4. Logs d'erreurs dans `gpsState.errorMessage`

**Solution :**
```dart
// Obtenir position unique pour tester
final position = await ref.read(gpsStateProvider.notifier).getCurrentPosition();
if (position != null) {
  print('GPS works: ${position.latitude}');
}
```

### Problème : Batterie se vide rapidement

**Vérifier :**
1. Intervalle actuel : `gpsState.currentInterval`
2. Statut chauffeur correct : `gpsState.driverStatus`
3. Précision GPS : Devrait être `low` ou `medium` quand offline

**Solution :**
```dart
// Forcer un intervalle plus long temporairement
ref.read(gpsStateProvider.notifier).updateDriverStatus('offline');
```

### Problème : Backend ne reçoit pas les updates

**Vérifier :**
1. Token d'authentification valide
2. Endpoint correct : `/api/v1/drivers/gps/update-location/`
3. Logs backend Django
4. Profil driver existe

**Solution :**
```python
# Backend logs
tail -f logs/django.log | grep GPS
```

---

## Roadmap Futures Améliorations

### Phase 4 (Optionnel)

1. **Background Service Android/iOS**
   - Continuer le suivi même app fermée
   - Package : `flutter_background_service`

2. **Détection Batterie**
   - Package : `battery_plus`
   - Ajuster intervalle si batterie < 20%

3. **Mode Économie Extrême**
   - Si batterie < 10% : passer à 10 minutes
   - Désactiver précision haute

4. **Geofencing**
   - Alertes quand chauffeur entre/sort d'une zone
   - Package : `geofence_service`

5. **Analytics Avancées**
   - Temps passé dans chaque zone
   - Vitesse moyenne par statut
   - Carte de chaleur des trajets

---

## Résumé

✅ **Backend complet** :
- 2 modèles (LocationUpdate, LocationTrackingSession)
- Service avec logique adaptative
- 6 endpoints API
- Migration appliquée

✅ **Flutter complet** :
- AdaptiveGPSService avec intervalles adaptatifs
- Provider Riverpod pour state management
- Widget de statut GPS
- Modèles Freezed (en attente de génération)

✅ **Optimisations** :
- 90% d'économie batterie (offline vs constant)
- Détection automatique de mouvement
- Nettoyage auto des données (30 jours)
- Précision ajustée selon statut

📱 **Prochaines étapes** :
1. Intégrer GPS dans le lifecycle de l'app
2. Connecter au changement de statut chauffeur
3. Tester sur appareil réel
4. (Optionnel) Background service pour suivi continu
