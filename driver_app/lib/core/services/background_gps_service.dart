import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../network/dio_client.dart';

/// Background GPS Service
/// 
/// Service pour le tracking GPS en arrière-plan, même quand l'app est fermée.
/// 
/// IMPORTANT: Pour activer le tracking en arrière-plan complet, vous devez:
/// 1. Ajouter `flutter_background_service` dans pubspec.yaml
/// 2. Configurer les permissions Android (foreground service)
/// 3. Configurer les permissions iOS (background location)
/// 
/// Configuration Android (android/app/src/main/AndroidManifest.xml):
/// ```xml
/// <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
/// <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION"/>
/// <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
/// ```
/// 
/// Configuration iOS (ios/Runner/Info.plist):
/// ```xml
/// <key>UIBackgroundModes</key>
/// <array>
///   <string>location</string>
///   <string>fetch</string>
/// </array>
/// <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
/// <string>LeBeni's a besoin de votre position pour le suivi des livraisons</string>
/// ```
class BackgroundGPSService {
  final DioClient _dioClient;
  
  // Singleton pattern
  static BackgroundGPSService? _instance;
  factory BackgroundGPSService(DioClient dioClient) {
    _instance ??= BackgroundGPSService._internal(dioClient);
    return _instance!;
  }
  BackgroundGPSService._internal(this._dioClient);
  
  // Status
  bool _isInitialized = false;
  bool _isRunning = false;
  
  // Stream controller for position updates
  final _positionController = StreamController<Position>.broadcast();
  Stream<Position> get positionStream => _positionController.stream;
  
  // Configuration
  static const int updateIntervalSeconds = 30;
  static const int distanceFilterMeters = 10;
  
  /// Initialize the background service
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        developer.log('Location services are disabled');
        return false;
      }
      
      // Check permissions
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          developer.log('Location permissions are denied');
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        developer.log('Location permissions are permanently denied');
        return false;
      }
      
      // For background location, request "always" permission on Android
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        if (permission != LocationPermission.always) {
          // Note: Sur Android 10+, l'utilisateur doit manuellement autoriser
          // "Toujours autoriser" dans les paramètres de l'app
          developer.log('Background location requires "Always" permission');
        }
      }
      
      _isInitialized = true;
      developer.log('✅ Background GPS Service initialized');
      return true;
      
    } catch (e) {
      developer.log('❌ Error initializing background GPS: $e');
      return false;
    }
  }
  
  /// Start background location tracking
  Future<void> startTracking({
    required String driverId,
    int intervalSeconds = updateIntervalSeconds,
  }) async {
    if (_isRunning) {
      developer.log('Background tracking already running');
      return;
    }
    
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) return;
    }
    
    _isRunning = true;
    
    // Start listening to position stream
    final locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilterMeters,
      intervalDuration: Duration(seconds: intervalSeconds),
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationTitle: "LeBeni's Driver",
        notificationText: "Suivi GPS actif pour les livraisons",
        notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
        enableWakeLock: true,
      ),
    );
    
    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        _positionController.add(position);
        _sendLocationToServer(driverId, position);
      },
      onError: (error) {
        developer.log('Background GPS error: $error');
      },
    );
    
    developer.log('🚀 Background GPS tracking started for driver: $driverId');
  }
  
  /// Stop background location tracking
  void stopTracking() {
    _isRunning = false;
    developer.log('🛑 Background GPS tracking stopped');
  }
  
  /// Send location to server
  Future<void> _sendLocationToServer(String driverId, Position position) async {
    try {
      await _dioClient.post(
        '/api/v1/drivers/gps/update-location/',
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'speed': position.speed,
          'heading': position.heading,
          'timestamp': position.timestamp.toIso8601String(),
        },
      );
      developer.log('📍 Location sent: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      developer.log('❌ Failed to send location: $e');
      // TODO: Queue for offline sync
    }
  }
  
  /// Check if tracking is running
  bool get isRunning => _isRunning;
  
  /// Dispose resources
  void dispose() {
    _positionController.close();
    _isRunning = false;
    _isInitialized = false;
    _instance = null;
  }
}
