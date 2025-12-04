import 'package:flutter/material.dart';

class AppColors {
  // Palette principale - Modern Delivery App
  static const Color primary = Color(0xFF1A237E); // Bleu marine profond
  static const Color secondary = Color(0xFFFF6B9D); // Rose/Corail
  static const Color accent = Color(0xFFFF9800); // Orange pour actions
  
  // Backgrounds
  static const Color background = Color(0xFFF8F9FE); // Fond clair
  static const Color backgroundDark = Color(0xFF1A1A2E); // Fond sombre (splash)
  static const Color cardBackground = Colors.white;
  
  // Texte
  static const Color text = Color(0xFF1A1A1A); // Texte principal
  static const Color textSecondary = Color(0xFF64748B); // Texte secondaire
  static const Color textLight = Colors.white;
  
  // Status colors
  static const Color success = Color(0xFF10B981); // Vert moderne
  static const Color error = Color(0xFFEF4444); // Rouge moderne
  static const Color warning = Color(0xFFFB923C); // Orange warning
  static const Color info = Color(0xFF3B82F6); // Bleu info
  
  // Delivery status colors
  static const Color pending = Color(0xFFFBBF24); // Jaune
  static const Color inTransit = Color(0xFF3B82F6); // Bleu
  static const Color delivered = Color(0xFF10B981); // Vert
  static const Color cancelled = Color(0xFF9CA3AF); // Gris
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF283593)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFF8FB1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
