import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../network/dio_client.dart';

/// Service pour gérer l'authentification Firebase avec Custom Token.
/// Permet de synchroniser l'auth Django avec Firebase pour le chat temps réel.
class FirebaseAuthService {
  final DioClient _dioClient;
  final FirebaseAuth _firebaseAuth;
  
  static FirebaseAuthService? _instance;
  
  FirebaseAuthService._({
    required DioClient dioClient,
    FirebaseAuth? firebaseAuth,
  })  : _dioClient = dioClient,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;
  
  /// Singleton factory
  factory FirebaseAuthService({
    required DioClient dioClient,
    FirebaseAuth? firebaseAuth,
  }) {
    _instance ??= FirebaseAuthService._(
      dioClient: dioClient,
      firebaseAuth: firebaseAuth,
    );
    return _instance!;
  }
  
  /// Reset l'instance (utile pour les tests ou logout)
  static void reset() {
    _instance = null;
  }
  
  /// L'utilisateur Firebase actuellement connecté
  User? get currentUser => _firebaseAuth.currentUser;
  
  /// Est-ce que l'utilisateur est authentifié sur Firebase ?
  bool get isAuthenticated => currentUser != null;
  
  /// Stream de l'état d'authentification Firebase
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  
  /// Authentifie l'utilisateur sur Firebase avec un Custom Token.
  /// Appelle le backend Django pour obtenir le token, puis l'utilise pour Firebase.
  Future<User?> signInWithCustomToken() async {
    try {
      debugPrint('[FirebaseAuth] Récupération du custom token depuis le backend...');
      
      // 1. Appeler le backend pour obtenir le Firebase Custom Token
      final response = await _dioClient.get(
        '/api/v1/chat/firebase-token/',
      );
      
      final firebaseToken = response.data['firebase_token'] as String?;
      final userId = response.data['user_id'] as String?;
      
      if (firebaseToken == null || firebaseToken.isEmpty) {
        throw Exception('Token Firebase non reçu du serveur');
      }
      
      debugPrint('[FirebaseAuth] Token reçu pour user $userId, connexion à Firebase...');
      
      // 2. S'authentifier sur Firebase avec le custom token
      final userCredential = await _firebaseAuth.signInWithCustomToken(firebaseToken);
      
      debugPrint('[FirebaseAuth] ✅ Authentifié sur Firebase: ${userCredential.user?.uid}');
      
      return userCredential.user;
      
    } catch (e, stackTrace) {
      debugPrint('[FirebaseAuth] ❌ Erreur auth Firebase: $e');
      debugPrint('[FirebaseAuth] StackTrace: $stackTrace');
      // Ne pas propager l'erreur - le chat temps réel sera juste désactivé
      return null;
    }
  }
  
  /// Déconnecte l'utilisateur de Firebase
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      debugPrint('[FirebaseAuth] ✅ Déconnecté de Firebase');
    } catch (e) {
      debugPrint('[FirebaseAuth] ❌ Erreur déconnexion Firebase: $e');
    }
  }
  
  /// Rafraîchit le token Firebase si nécessaire
  Future<void> refreshTokenIfNeeded() async {
    final user = currentUser;
    if (user == null) {
      // Pas connecté, essayer de se connecter
      await signInWithCustomToken();
    } else {
      // Vérifier si le token a besoin d'être rafraîchi
      try {
        final idTokenResult = await user.getIdTokenResult();
        final expirationTime = idTokenResult.expirationTime;
        
        if (expirationTime != null) {
          final now = DateTime.now();
          final timeUntilExpiry = expirationTime.difference(now);
          
          // Rafraîchir si expire dans moins de 5 minutes
          if (timeUntilExpiry.inMinutes < 5) {
            debugPrint('[FirebaseAuth] Token expire bientôt, rafraîchissement...');
            await signInWithCustomToken();
          }
        }
      } catch (e) {
        debugPrint('[FirebaseAuth] Erreur vérification token: $e');
        // En cas d'erreur, essayer de se reconnecter
        await signInWithCustomToken();
      }
    }
  }
}
