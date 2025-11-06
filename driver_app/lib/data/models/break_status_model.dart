class BreakStatusModel {
  final bool isOnBreak;
  final DateTime? breakStartedAt;
  final Duration totalBreakToday;
  final Duration? currentBreakDuration;

  BreakStatusModel({
    required this.isOnBreak,
    this.breakStartedAt,
    required this.totalBreakToday,
    this.currentBreakDuration,
  });

  factory BreakStatusModel.fromJson(Map<String, dynamic> json) {
    return BreakStatusModel(
      isOnBreak: json['is_on_break'] as bool? ?? false,
      breakStartedAt: json['break_started_at'] != null
          ? DateTime.parse(json['break_started_at'])
          : null,
      totalBreakToday: parseDuration(json['total_break_today']),
      currentBreakDuration: json['current_break_duration'] != null
          ? parseDuration(json['current_break_duration'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_on_break': isOnBreak,
      'break_started_at': breakStartedAt?.toIso8601String(),
      'total_break_today': _formatDuration(totalBreakToday),
      'current_break_duration': currentBreakDuration != null
          ? _formatDuration(currentBreakDuration!)
          : null,
    };
  }

  /// Parse une durée depuis le format Python "HH:MM:SS" ou "H:MM:SS.microseconds"
  static Duration parseDuration(dynamic value) {
    if (value == null) return Duration.zero;
    
    final str = value.toString();
    
    // Format: "0:00:00" ou "1:23:45" ou "2:30:15.123456"
    final parts = str.split(':');
    if (parts.length < 3) return Duration.zero;
    
    final hours = int.tryParse(parts[0]) ?? 0;
    final minutes = int.tryParse(parts[1]) ?? 0;
    
    // Gérer les secondes avec microsecondes
    final secondsParts = parts[2].split('.');
    final seconds = int.tryParse(secondsParts[0]) ?? 0;
    
    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }

  /// Formate une durée au format "HH:MM:SS"
  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    return '${hours.toString().padLeft(1, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Retourne la durée formatée en français (ex: "2h 15min")
  String get formattedTotalBreak {
    if (totalBreakToday.inMinutes == 0) return '0min';
    
    final hours = totalBreakToday.inHours;
    final minutes = totalBreakToday.inMinutes.remainder(60);
    
    if (hours == 0) {
      return '${minutes}min';
    } else if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}min';
    }
  }

  /// Retourne la durée de pause actuelle formatée
  String get formattedCurrentBreak {
    if (currentBreakDuration == null || currentBreakDuration!.inMinutes == 0) {
      return '0min';
    }
    
    final hours = currentBreakDuration!.inHours;
    final minutes = currentBreakDuration!.inMinutes.remainder(60);
    
    if (hours == 0) {
      return '${minutes}min';
    } else if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}min';
    }
  }

  /// Calcule la durée actuelle de pause si en pause
  Duration getCurrentBreakDuration() {
    if (!isOnBreak || breakStartedAt == null) {
      return Duration.zero;
    }
    
    return DateTime.now().difference(breakStartedAt!);
  }

  BreakStatusModel copyWith({
    bool? isOnBreak,
    DateTime? breakStartedAt,
    Duration? totalBreakToday,
    Duration? currentBreakDuration,
  }) {
    return BreakStatusModel(
      isOnBreak: isOnBreak ?? this.isOnBreak,
      breakStartedAt: breakStartedAt ?? this.breakStartedAt,
      totalBreakToday: totalBreakToday ?? this.totalBreakToday,
      currentBreakDuration: currentBreakDuration ?? this.currentBreakDuration,
    );
  }
}
