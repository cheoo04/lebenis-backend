import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// Classe pour représenter un fichier sélectionné sur le web
class WebPickedFile {
  final String name;
  final Uint8List? bytes;

  WebPickedFile(this.name, this.bytes);

  Future<Uint8List> readAsBytes() async => bytes ?? Uint8List(0);

  String get path => name;
}

/// Classe utilitaire avec fonctions helpers génériques
class Helpers {
  // ========== NAVIGATION ==========

  /// Afficher un SnackBar
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Afficher SnackBar de succès
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.green,
    );
  }

  /// Afficher SnackBar d'erreur
  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.red,
    );
  }

  /// Afficher SnackBar d'info
  static void showInfoSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.blue,
    );
  }

  /// Afficher une Dialog de confirmation
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              cancelText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Afficher un loading dialog
  static void showLoadingDialog(BuildContext context, {String message = 'Chargement...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      ),
    );
  }

  /// Fermer le loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }

  // ========== IMAGES ==========

  /// Choisir une image depuis la galerie (retourne File ou WebPickedFile)
  static Future<dynamic> pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // Sur le web, retourner WebPickedFile avec les bytes
          final bytes = await pickedFile.readAsBytes();
          return WebPickedFile(pickedFile.name, bytes);
        } else {
          // Sur mobile, retourner File
          return File(pickedFile.path);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Erreur sélection image: $e');
      return null;
    }
  }

  /// Prendre une photo avec la caméra (retourne File ou WebPickedFile)
  static Future<dynamic> takePhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          // Sur le web, retourner WebPickedFile
          final bytes = await pickedFile.readAsBytes();
          return WebPickedFile(pickedFile.name, bytes);
        } else {
          // Sur mobile, retourner File
          return File(pickedFile.path);
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Erreur prise photo: $e');
      return null;
    }
  }

  /// Choisir image avec dialog (galerie ou caméra) - Support web et mobile
  static Future<dynamic> pickImageWithDialog(BuildContext context) async {
    // Sur Linux Desktop et Web, la caméra ne fonctionne pas toujours
    // On propose uniquement la galerie pour éviter les erreurs
    final isLinux = Theme.of(context).platform == TargetPlatform.linux;

    if (isLinux || kIsWeb) {
      // Directement la galerie sur Linux et Web
      return await pickImageFromGallery();
    }

    // Dialog avec choix caméra/galerie sur mobile
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir une source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Caméra'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return null;

    if (source == ImageSource.gallery) {
      return await pickImageFromGallery();
    } else {
      return await takePhoto();
    }
  }

  // ========== FICHIERS ==========

  /// Obtenir le répertoire temporaire
  static Future<Directory> getTempDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Obtenir le répertoire de l'app
  static Future<Directory> getAppDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Sauvegarder un fichier
  static Future<File> saveFile(String filename, List<int> bytes) async {
    final dir = await getAppDirectory();
    final file = File('${dir.path}/$filename');
    return await file.writeAsBytes(bytes);
  }

  /// Supprimer un fichier
  static Future<void> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Erreur suppression fichier: $e');
    }
  }

  // ========== CLIPBOARD ==========

  /// Copier dans le presse-papier
  static Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  /// Coller depuis le presse-papier
  static Future<String?> pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    return data?.text;
  }

  // ========== DATES ==========

  /// Vérifier si une date est aujourd'hui
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Vérifier si une date est hier
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  /// Obtenir le début du jour
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Obtenir la fin du jour
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Ajouter des jours
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// Soustraire des jours
  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  // ========== CALCULS ==========

  /// Générer un nombre aléatoire entre min et max
  static int randomInt(int min, int max) {
    return min + Random().nextInt(max - min + 1);
  }

  /// Générer une chaîne aléatoire
  static String randomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  /// Arrondir un nombre à X décimales
  static double roundToDecimal(double value, int decimals) {
    final mod = pow(10, decimals);
    return (value * mod).round() / mod;
  }

  /// Calculer un pourcentage
  static double calculatePercentage(double value, double total) {
    if (total == 0) return 0;
    return (value / total) * 100;
  }

  // ========== LISTES ==========

  /// Vérifier si une liste est vide ou null
  static bool isListEmpty(List? list) {
    return list == null || list.isEmpty;
  }

  /// Diviser une liste en chunks
  static List<List<T>> chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += chunkSize) {
      final end = (i + chunkSize < list.length) ? i + chunkSize : list.length;
      chunks.add(list.sublist(i, end));
    }
    return chunks;
  }

  // ========== STRINGS ==========

  /// Vérifier si une chaîne est vide ou null
  static bool isStringEmpty(String? str) {
    return str == null || str.trim().isEmpty;
  }

  /// Nettoyer les espaces multiples
  static String cleanSpaces(String str) {
    return str.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Extraire les initiales d'un nom
  static String getInitials(String name, {int maxInitials = 2}) {
    final parts = name.trim().split(' ');
    final initials = parts
        .take(maxInitials)
        .map((part) => part.isNotEmpty ? part[0].toUpperCase() : '')
        .join('');
    return initials;
  }

  // ========== COULEURS ==========

  /// Générer une couleur aléatoire
  static Color randomColor() {
    return Color.fromRGBO(
      randomInt(0, 255),
      randomInt(0, 255),
      randomInt(0, 255),
      1,
    );
  }

  /// Obtenir une couleur depuis une chaîne (hash)
  static Color colorFromString(String str) {
    var hash = 0;
    for (var i = 0; i < str.length; i++) {
      hash = str.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final color = Color(hash & 0x00FFFFFF).withValues(alpha: 1.0);
    return color;
  }

  // ========== DEVICE INFO ==========

  /// Obtenir la plateforme
  static String getPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isLinux) return 'linux';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    return 'unknown';
  }

  /// Vérifier si c'est Android
  static bool isAndroid() => !kIsWeb && Platform.isAndroid;

  /// Vérifier si c'est iOS
  static bool isIOS() => !kIsWeb && Platform.isIOS;

  // ========== FOCUS ==========

  /// Retirer le focus (fermer le clavier)
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Déplacer le focus vers le champ suivant
  static void nextFocus(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  // ========== DEBOUNCE ==========

  /// Fonction de debounce pour limiter les appels
  static void Function() debounce(
    void Function() action, {
    Duration duration = const Duration(milliseconds: 500),
  }) {
    _DebounceTimer? timer;
    return () {
      timer?.cancel();
      timer = _DebounceTimer(duration, action);
    };
  }

  // ========== LOGGING ==========

  /// Logger avec timestamp
  static void log(String message, {String tag = 'APP'}) {
    final timestamp = DateFormat('HH:mm:ss').format(DateTime.now());
    if (kDebugMode) debugPrint('[$timestamp][$tag] $message');
  }

  /// Logger d'erreur
  static void logError(String message, {dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      final timestamp = DateFormat('HH:mm:ss').format(DateTime.now());
      debugPrint('[$timestamp][ERROR] $message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }
}

/// Classe privée pour le debounce timer
class _DebounceTimer {
  final Duration duration;
  final void Function() callback;

  Timer? _timer;

  _DebounceTimer(this.duration, this.callback) {
    _timer = Timer(duration, callback);
  }

  void cancel() {
    _timer?.cancel();
  }
}