import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/adaptive_gps_service.dart';
import '../../../data/providers/auth_provider.dart';

/// GPS State
class GPSState {
  final bool isTracking;
  final Position? currentPosition;
  final String driverStatus;
  final int currentInterval;
  final String? errorMessage;
  final DateTime? lastUpdate;
  
  GPSState({
    this.isTracking = false,
    this.currentPosition,
    this.driverStatus = 'offline',
    this.currentInterval = 300,
    this.errorMessage,
    this.lastUpdate,
  });
  
  GPSState copyWith({
    bool? isTracking,
    Position? currentPosition,
    String? driverStatus,
    int? currentInterval,
    String? errorMessage,
    DateTime? lastUpdate,
  }) {
    return GPSState(
      isTracking: isTracking ?? this.isTracking,
      currentPosition: currentPosition ?? this.currentPosition,
      driverStatus: driverStatus ?? this.driverStatus,
      currentInterval: currentInterval ?? this.currentInterval,
      errorMessage: errorMessage,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

/// GPS State Notifier
class GPSStateNotifier extends Notifier<GPSState> {
  late final AdaptiveGPSService _gpsService;

  @override
  GPSState build() {
    _gpsService = ref.read(gpsServiceProvider);
    return GPSState();
  }
  
  /// Start GPS tracking
  Future<void> startTracking(String driverStatus) async {
    await _gpsService.startTracking(
      driverStatus: driverStatus,
      onUpdate: (position) {
        state = state.copyWith(
          currentPosition: position,
          lastUpdate: DateTime.now(),
          errorMessage: null,
        );
      },
      onErrorCallback: (error) {
        state = state.copyWith(
          errorMessage: error,
        );
      },
    );
    
    state = state.copyWith(
      isTracking: _gpsService.isTracking,
      driverStatus: driverStatus,
    );
  }
  
  /// Stop GPS tracking
  void stopTracking() {
    _gpsService.stopTracking();
    state = state.copyWith(
      isTracking: false,
      currentPosition: null,
    );
  }
  
  /// Update driver status (changes tracking interval)
  void updateDriverStatus(String newStatus) {
    _gpsService.updateDriverStatus(newStatus);
    state = state.copyWith(
      driverStatus: newStatus,
    );
  }
  
  /// Get current position
  Future<Position?> getCurrentPosition() async {
    final position = await _gpsService.getCurrentPosition();
    if (position != null) {
      state = state.copyWith(
        currentPosition: position,
        lastUpdate: DateTime.now(),
      );
    }
    return position;
  }
}

/// Provider for AdaptiveGPSService
final gpsServiceProvider = Provider<AdaptiveGPSService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AdaptiveGPSService(dioClient);
});

/// Provider for GPS State
final gpsStateProvider = NotifierProvider<GPSStateNotifier, GPSState>(GPSStateNotifier.new);
