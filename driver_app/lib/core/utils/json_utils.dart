// lib/core/utils/json_utils.dart
/// Helpers to safely parse numeric values coming from JSON which
/// may be either numbers or strings.
library;


int safeInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) {
    // Protect against NaN / Infinity which would throw on toInt()
    if (v is double && !v.isFinite) return fallback;
    return v.toInt();
  }
  final s = v.toString();
  return int.tryParse(s) ?? fallback;
}

int? safeIntNullable(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) {
    if (v is double && !v.isFinite) return null;
    return v.toInt();
  }
  final s = v.toString();
  return int.tryParse(s);
}

double safeDouble(dynamic v, [double fallback = 0.0]) {
  if (v == null) return fallback;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  final s = v.toString();
  return double.tryParse(s) ?? fallback;
}

double? safeDoubleNullable(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  final s = v.toString();
  return double.tryParse(s);
}
