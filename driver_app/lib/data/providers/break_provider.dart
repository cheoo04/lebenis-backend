import 'dart:developer' as developer;
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/break_status_model.dart';
import '../repositories/break_repository.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/auth_service.dart';

// ========== AUTH SERVICE PROVIDER ==========

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider pour le repository
final breakRepositoryProvider = Provider<BreakRepository>((ref) {
  final authService = ref.read(authServiceProvider);
  final dioClient = DioClient(authService);
  return BreakRepository(dioClient: dioClient);
});

// État des pauses
class BreakState {
  final BreakStatusModel? breakStatus;
  final bool isLoading;
  final bool isStarting;
  final bool isEnding;
  final String? error;
  final Duration currentDuration; // Durée actuelle mise à jour en temps réel

  BreakState({
    this.breakStatus,
    this.isLoading = false,
    this.isStarting = false,
    this.isEnding = false,
    this.error,
    this.currentDuration = Duration.zero,
  });

  BreakState copyWith({
    BreakStatusModel? breakStatus,
    bool? isLoading,
    bool? isStarting,
    bool? isEnding,
    String? error,
    Duration? currentDuration,
  }) {
    return BreakState(
      breakStatus: breakStatus ?? this.breakStatus,
      isLoading: isLoading ?? this.isLoading,
      isStarting: isStarting ?? this.isStarting,
      isEnding: isEnding ?? this.isEnding,
      error: error,
      currentDuration: currentDuration ?? this.currentDuration,
    );
  }
}

// Notifier pour gérer la logique des pauses
class BreakNotifier extends StateNotifier<BreakState> {
  final BreakRepository _repository;
  Timer? _timer;

  BreakNotifier(this._repository) : super(BreakState());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Charge le statut de pause
  Future<void> loadBreakStatus() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final breakStatus = await _repository.getBreakStatus();
      
      state = state.copyWith(
        breakStatus: breakStatus,
        isLoading: false,
        currentDuration: breakStatus.getCurrentBreakDuration(),
      );

      // Démarrer le timer si en pause
      if (breakStatus.isOnBreak) {
        _startTimer();
      } else {
        _stopTimer();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors du chargement du statut',
      );
      developer.log('❌ Erreur loadBreakStatus: $e');
    }
  }

  /// Démarre une pause
  Future<void> startBreak() async {
    state = state.copyWith(isStarting: true, error: null);

    try {
      final breakStatus = await _repository.startBreak();
      
      state = state.copyWith(
        breakStatus: breakStatus,
        isStarting: false,
        currentDuration: Duration.zero,
      );

      // Démarrer le timer
      _startTimer();
    } catch (e) {
      state = state.copyWith(
        isStarting: false,
        error: 'Erreur lors du démarrage de la pause',
      );
      developer.log('❌ Erreur startBreak: $e');
      rethrow;
    }
  }

  /// Termine la pause en cours
  Future<void> endBreak() async {
    state = state.copyWith(isEnding: true, error: null);

    try {
      final result = await _repository.endBreak();
      
      // Mettre à jour le statut
      final updatedStatus = state.breakStatus?.copyWith(
        isOnBreak: false,
        breakStartedAt: null,
        totalBreakToday: BreakStatusModel.parseDuration(result['total_break_today']),
      );

      state = state.copyWith(
        breakStatus: updatedStatus,
        isEnding: false,
        currentDuration: Duration.zero,
      );

      // Arrêter le timer
      _stopTimer();
    } catch (e) {
      state = state.copyWith(
        isEnding: false,
        error: 'Erreur lors de la fin de la pause',
      );
      developer.log('❌ Erreur endBreak: $e');
      rethrow;
    }
  }

  /// Démarre le timer de mise à jour toutes les secondes
  void _startTimer() {
    _stopTimer(); // Arrêter l'ancien timer si existe
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.breakStatus?.isOnBreak == true && state.breakStatus?.breakStartedAt != null) {
        final duration = DateTime.now().difference(state.breakStatus!.breakStartedAt!);
        state = state.copyWith(currentDuration: duration);
      }
    });
  }

  /// Arrête le timer
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Rafraîchit le statut
  Future<void> refresh() async {
    await loadBreakStatus();
  }
}

// Provider principal
final breakProvider = StateNotifierProvider<BreakNotifier, BreakState>((ref) {
  final repository = ref.watch(breakRepositoryProvider);
  return BreakNotifier(repository);
});
