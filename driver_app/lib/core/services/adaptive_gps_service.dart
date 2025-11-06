import 'dart:async';
import 'dart:developer' as developer;
import 'package:battery_plus/battery_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../network/dio_client.dart';

/// GPS Tracking Service with Adaptive Intervals
/// 
/// Tracking intervals based on driver status:
/// - En route (busy + moving): 30 seconds
/// - Stopped (busy/available + not moving): 10 seconds
/// - Offline: 5 minutes (300 seconds)
class AdaptiveGPSService {
  final DioClient _dioClient;
  final Battery _battery = Battery();
  
  // Tracking intervals (in seconds)
  static const int intervalEnRoute = 30;      // En route vers livraison
  static const int intervalStopped = 10;        // Arrêté (pause, attente)
  static const int intervalOffline = 300;       // Hors service (5 minutes)
  
  // Movement detection threshold
  static const double movementThresholdMps = 1.0;  // 1 m/s (~3.6 km/h)
  
  Timer? _trackingTimer;
  Position? _lastPosition;
  String _currentDriverStatus = 'offline';
  bool _isTracking = false;
  
  // Callbacks
  Function(Position)? onLocationUpdate;
  Function(String)? onError;
  
  AdaptiveGPSService(this._dioClient);
  
  /// Start adaptive GPS tracking
  Future<void> startTracking({
    required String driverStatus,
    Function(Position)? onUpdate,
    Function(String)? onErrorCallback,
  }) async {
    if (_isTracking) {
      developer.log('GPS tracking already active');
      return;
    }
    
    _currentDriverStatus = driverStatus;
    onLocationUpdate = onUpdate;
    onError = onErrorCallback;
    _isTracking = true;
    
    // Check and request permissions
    final hasPermission = await _checkAndRequestPermission();
    if (!hasPermission) {
      onError?.call('Location permission denied');
      _isTracking = false;
      return;
    }
    
    // Start initial update
    await _updateLocation();
    
    // Schedule recurring updates
    _scheduleNextUpdate();
    
    developer.log('Adaptive GPS tracking started with status: $driverStatus');
  }
  
  /// Stop GPS tracking
  void stopTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
    _isTracking = false;
    _lastPosition = null;
    
    developer.log('GPS tracking stopped');
  }
  
  /// Update driver status (changes tracking interval)
  void updateDriverStatus(String newStatus) {
    if (_currentDriverStatus == newStatus) return;
    
    developer.log('Driver status changed: $_currentDriverStatus -> $newStatus');
    _currentDriverStatus = newStatus;
    
    // Reschedule with new interval if tracking is active
    if (_isTracking) {
      _trackingTimer?.cancel();
      _scheduleNextUpdate();
    }
  }
  
  /// Get current position once
  Future<Position?> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _getLocationSettings(),
      );
      return position;
    } catch (e) {
      developer.log('Error getting position: $e');
      onError?.call('Failed to get current position');
      return null;
    }
  }
  
  /// Check and request location permissions
  Future<bool> _checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      onError?.call('Location services are disabled');
      return false;
    }
    
    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        onError?.call('Location permissions are denied');
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      onError?.call('Location permissions are permanently denied');
      return false;
    }
    
    return true;
  }
  
  /// Update location and send to backend
  Future<void> _updateLocation() async {
    try {
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _getLocationSettings(),
      );
      
      // Determine if moving
      final isMoving = _isDriverMoving(position);
      
      // Get battery level
      final batteryLevel = await _getBatteryLevel();
      
      // Send to backend
      await _sendLocationToBackend(
        position,
        isMoving: isMoving,
        batteryLevel: batteryLevel,
      );
      
      // Store last position
      _lastPosition = position;
      
      // Callback
      onLocationUpdate?.call(position);
      
    } catch (e) {
      developer.log('Error updating location: $e');
      onError?.call('Failed to update location: $e');
    }
  }
  
  /// Schedule next location update based on current conditions
  void _scheduleNextUpdate() {
    if (!_isTracking) return;
    
    final interval = _calculateTrackingInterval();
    
    developer.log('Scheduling next update in $interval seconds');
    
    _trackingTimer = Timer(
      Duration(seconds: interval),
      () async {
        await _updateLocation();
        _scheduleNextUpdate(); // Reschedule
      },
    );
  }
  
  /// Calculate tracking interval based on driver status and movement
  int _calculateTrackingInterval() {
    if (_currentDriverStatus == 'offline') {
      return intervalOffline;
    }
    
    final isMoving = _lastPosition != null && 
                     _lastPosition!.speed > movementThresholdMps;
    
    if (_currentDriverStatus == 'busy' || _currentDriverStatus == 'available') {
      return isMoving ? intervalEnRoute : intervalStopped;
    }
    
    return intervalStopped;
  }
  
  /// Determine if driver is moving based on speed
  bool _isDriverMoving(Position position) {
    return position.speed > movementThresholdMps;
  }
  
  /// Get location settings based on driver status
  LocationSettings _getLocationSettings() {
    // High accuracy for busy drivers, balanced for available, low power for offline
    LocationAccuracy accuracy;
    
    if (_currentDriverStatus == 'busy') {
      accuracy = LocationAccuracy.high;
    } else if (_currentDriverStatus == 'available') {
      accuracy = LocationAccuracy.medium;
    } else {
      accuracy = LocationAccuracy.low;
    }
    
    return LocationSettings(
      accuracy: accuracy,
      distanceFilter: 10, // Minimum distance (meters) before update
    );
  }
  
  /// Send location to backend
  Future<void> _sendLocationToBackend(
    Position position, {
    required bool isMoving,
    int? batteryLevel,
  }) async {
    try {
      final data = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'speed': position.speed,
        'heading': position.heading,
        'altitude': position.altitude,
        'battery_level': batteryLevel,
        'timestamp': position.timestamp.toIso8601String(),
      };
      
      final response = await _dioClient.post(
        '/drivers/gps/update-location/',
        data: data,
      );
      
      // Update interval if backend recommends different interval
      if (response.data['next_update_interval_seconds'] != null) {
        final recommendedInterval = response.data['next_update_interval_seconds'] as int;
        developer.log('Backend recommends interval: $recommendedInterval seconds');
      }
      
    } catch (e) {
      developer.log('Error sending location to backend: $e');
      // Don't throw - continue tracking even if backend update fails
    }
  }
  
  /// Get battery level (platform-specific implementation needed)
  Future<int?> _getBatteryLevel() async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      developer.log('Battery level: $batteryLevel%');
      return batteryLevel;
    } catch (e) {
      developer.log('Error getting battery level: $e');
      return null;
    }
  }
  
  /// Get recommended tracking interval from backend
  Future<int?> getRecommendedInterval() async {
    try {
      final response = await _dioClient.get('/drivers/gps/interval/');
      return response.data['interval_seconds'] as int?;
    } catch (e) {
      developer.log('Error getting recommended interval: $e');
      return null;
    }
  }
  
  /// Check if tracking is active
  bool get isTracking => _isTracking;
  
  /// Get current driver status
  String get driverStatus => _currentDriverStatus;
  
  /// Get last known position
  Position? get lastPosition => _lastPosition;
}
