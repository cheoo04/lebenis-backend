import 'package:flutter/material.dart';

class Helpers {
  // Ajoutez ici vos fonctions utilitaires globales
  static String capitalize(String s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;

  /// Affiche un SnackBar global
  static void showSnackbar(BuildContext context, String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  // Exemples d'autres helpers : formatage, parsing, etc.
}
