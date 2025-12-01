// lib/theme/app_radius.dart

import 'package:flutter/material.dart';

/// Constantes de border radius pour l'application
/// Design moderne avec coins très arrondis
class AppRadius {
  // ========== RADIUS DE BASE ==========
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  
  // ========== RADIUS POUR LES CARTES ==========
  static const double card = 16.0;
  static const double cardLarge = 20.0;
  
  // ========== RADIUS POUR LES BOUTONS ==========
  static const double button = 12.0;
  static const double buttonLarge = 16.0;
  static const double buttonRound = 28.0; // Pour boutons très arrondis
  
  // ========== RADIUS POUR LES INPUTS ==========
  static const double input = 12.0;
  static const double inputLarge = 16.0;
  
  // ========== RADIUS POUR LES IMAGES ==========
  static const double image = 12.0;
  static const double imageLarge = 16.0;
  static const double avatar = 50.0; // Circulaire
  
  // ========== RADIUS POUR LES CHIPS/TAGS ==========
  static const double chip = 16.0;
  static const double chipSmall = 12.0;
  
  // ========== BORDER RADIUS OBJECTS ==========
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius cardLargeRadius = BorderRadius.all(Radius.circular(cardLarge));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(button));
  static const BorderRadius buttonLargeRadius = BorderRadius.all(Radius.circular(buttonLarge));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(input));
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(chip));
  
  // ========== RADIUS SPÉCIAUX ==========
  static const BorderRadius topRadius = BorderRadius.only(
    topLeft: Radius.circular(xxl),
    topRight: Radius.circular(xxl),
  );
  
  static const BorderRadius bottomRadius = BorderRadius.only(
    bottomLeft: Radius.circular(xxl),
    bottomRight: Radius.circular(xxl),
  );
}
