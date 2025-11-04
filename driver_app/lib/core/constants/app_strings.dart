// lib/core/constants/app_strings.dart

/// Toutes les chaînes de caractères de l'application (français)
class AppStrings {
  // ========== APP ==========
  static const String appName = 'LeBeni\'s Driver';
  static const String appSlogan = 'Livraison Rapide & Sécurisée';
  
  // ========== AUTHENTIFICATION ==========
  static const String loginTitle = 'Connexion Livreur';
  static const String loginSubtitle = 'Connectez-vous pour commencer à livrer';
  static const String email = 'Email';
  static const String password = 'Mot de passe';
  static const String confirmPassword = 'Confirmer le mot de passe';
  static const String login = 'Se connecter';
  static const String logout = 'Se déconnecter';
  static const String register = 'S\'inscrire';
  static const String noAccount = 'Pas de compte ?';
  static const String alreadyHaveAccount = 'Déjà un compte ?';
  static const String forgotPassword = 'Mot de passe oublié ?';
  
  // ========== NAVIGATION ==========
  static const String home = 'Accueil';
  static const String myRides = 'Mes Courses';
  static const String deliveries = 'Livraisons';
  static const String earnings = 'Gains';
  static const String profile = 'Profil';
  static const String settings = 'Paramètres';
  
  // ========== DASHBOARD ==========
  static const String welcome = 'Bienvenue';
  static const String todayEarnings = 'Gains du jour';
  static const String totalDeliveries = 'Courses totales';
  static const String averageRating = 'Note moyenne';
  static const String goOnline = 'Passer en ligne';
  static const String goOffline = 'Passer hors ligne';
  
  // ========== DELIVERY STATUS ==========
  static const Map<String, String> deliveryStatus = {
    'assigned': 'Assigné',
    'accepted': 'Accepté',
    'pickup_in_progress': 'Récupération',
    'picked_up': 'Récupéré',
    'in_transit': 'En cours',
    'delivered': 'Livré',
    'cancelled': 'Annulé',
    'failed': 'Échec',
  };
  
  // ========== AVAILABILITY STATUS ==========
  static const String available = 'Disponible';
  static const String busy = 'Occupé';
  static const String offline = 'Hors ligne';
  
  // ========== ACTIONS ==========
  static const String accept = 'Accepter';
  static const String reject = 'Refuser';
  static const String confirm = 'Confirmer';
  static const String cancel = 'Annuler';
  static const String save = 'Enregistrer';
  static const String update = 'Mettre à jour';
  static const String delete = 'Supprimer';
  static const String edit = 'Modifier';
  static const String viewDetails = 'Voir détails';
  static const String pickupPackage = 'Récupérer le colis';
  static const String deliverPackage = 'Livrer le colis';
  static const String completeDelivery = 'Terminer la livraison';
  
  // ========== LABELS ==========
  static const String pickupAddress = 'Adresse de récupération';
  static const String deliveryAddress = 'Adresse de livraison';
  static const String recipientName = 'Nom du destinataire';
  static const String recipientPhone = 'Téléphone';
  static const String packageDescription = 'Description du colis';
  static const String weight = 'Poids';
  static const String price = 'Prix';
  static const String distance = 'Distance';
  static const String trackingNumber = 'Numéro de suivi';
  
  // ========== ERRORS ==========
  static const String errorOccurred = 'Une erreur est survenue';
  static const String noInternet = 'Pas de connexion internet';
  static const String serverError = 'Erreur serveur. Réessayez plus tard.';
  static const String sessionExpired = 'Session expirée. Reconnectez-vous.';
  static const String invalidCredentials = 'Email ou mot de passe incorrect';
  static const String fieldRequired = 'Ce champ est requis';
  static const String invalidEmail = 'Email invalide';
  static const String passwordTooShort = 'Mot de passe trop court (min 6 caractères)';
  static const String passwordsDontMatch = 'Les mots de passe ne correspondent pas';
  
  // ========== SUCCESS ==========
  static const String loginSuccess = 'Connexion réussie';
  static const String logoutSuccess = 'Déconnexion réussie';
  static const String profileUpdated = 'Profil mis à jour';
  static const String deliveryAccepted = 'Livraison acceptée';
  static const String deliveryCompleted = 'Livraison terminée avec succès';
  static const String locationUpdated = 'Position mise à jour';
  
  // ========== MESSAGES ==========
  static const String loading = 'Chargement...';
  static const String noData = 'Aucune donnée disponible';
  static const String noDeliveriesFound = 'Aucune livraison trouvée';
  static const String noActiveDeliveries = 'Pas de livraison en cours';
  static const String enableLocationServices = 'Activez les services de localisation';
  static const String gpsRequired = 'Le GPS est requis pour accepter des livraisons';
  
  // ========== CONFIRMATION ==========
  static const String confirmLogout = 'Voulez-vous vraiment vous déconnecter ?';
  static const String confirmReject = 'Refuser cette livraison ?';
  static const String confirmCancel = 'Annuler cette action ?';
}
