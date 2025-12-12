# apps/notifications/firebase_service.py

import os
import json
import base64
import logging
import firebase_admin
from firebase_admin import credentials, messaging
from django.conf import settings

logger = logging.getLogger(__name__)


class FirebaseService:
    """
    Service pour envoyer des notifications push via Firebase Cloud Messaging V1.
    Utilise firebase-admin SDK (moderne et recommandé).
    """
    
    _app = None
    _initialized = False
    
    @classmethod
    def initialize(cls):
        """Initialise Firebase Admin SDK une seule fois"""
        if cls._initialized:
            return
        
        try:
            cred = None
            
            # Méthode 1: JSON direct depuis variable d'environnement
            credentials_json = getattr(settings, 'FIREBASE_CREDENTIALS_JSON', None) or os.environ.get('FIREBASE_CREDENTIALS_JSON')
            if credentials_json:
                try:
                    cred_dict = json.loads(credentials_json)
                    cred = credentials.Certificate(cred_dict)
                    logger.info("🔐 Firebase credentials chargés depuis FIREBASE_CREDENTIALS_JSON")
                except json.JSONDecodeError as e:
                    logger.error(f"❌ FIREBASE_CREDENTIALS_JSON invalide: {e}")
            
            # Méthode 2: Base64 depuis variable d'environnement (recommandé pour Render)
            if not cred:
                credentials_base64 = getattr(settings, 'FIREBASE_CREDENTIALS_BASE64', None) or os.environ.get('FIREBASE_CREDENTIALS_BASE64')
                if credentials_base64:
                    try:
                        decoded = base64.b64decode(credentials_base64)
                        cred_dict = json.loads(decoded)
                        cred = credentials.Certificate(cred_dict)
                        logger.info("🔐 Firebase credentials chargés depuis FIREBASE_CREDENTIALS_BASE64")
                    except Exception as e:
                        logger.error(f"❌ FIREBASE_CREDENTIALS_BASE64 invalide: {e}")
            
            # Méthode 3: Chemin vers fichier (local/dev)
            if not cred:
                credentials_path = getattr(settings, 'FIREBASE_CREDENTIALS_PATH', None)
                if credentials_path:
                    full_path = os.path.join(settings.BASE_DIR, credentials_path)
                    if os.path.exists(full_path):
                        cred = credentials.Certificate(full_path)
                        logger.info(f"🔐 Firebase credentials chargés depuis fichier: {credentials_path}")
                    else:
                        logger.warning(f"⚠️ Fichier Firebase credentials introuvable: {full_path}")
            
            if not cred:
                logger.warning("⚠️ Aucune credentials Firebase configurées")
                logger.info("📝 Configurez FIREBASE_CREDENTIALS_JSON, FIREBASE_CREDENTIALS_BASE64, ou FIREBASE_CREDENTIALS_PATH")
                return
            
            # Initialiser Firebase Admin
            cls._app = firebase_admin.initialize_app(cred)
            cls._initialized = True
            
            logger.info("✅ Firebase Admin SDK initialisé avec succès")
            
        except Exception as e:
            logger.error(f"❌ Erreur initialisation Firebase: {str(e)}")
    
    @classmethod
    def send_notification(cls, fcm_token, title, body, data=None):
        """
        Envoie une notification push à un appareil.
        
        Args:
            fcm_token (str): Token FCM de l'appareil
            title (str): Titre de la notification
            body (str): Corps de la notification
            data (dict): Données supplémentaires (optionnel)
            
        Returns:
            bool: True si succès, False sinon
        """
        if not cls._initialized:
            cls.initialize()
        
        if not cls._initialized:
            logger.warning("⚠️ Firebase non initialisé, notification non envoyée")
            return False
        
        try:
            # Créer le message
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=data or {},
                token=fcm_token,
            )
            
            # Envoyer
            response = messaging.send(message)
            logger.info(f"✅ Notification envoyée: {response}")
            return True
            
        except firebase_admin.exceptions.FirebaseError as e:
            logger.error(f"❌ Erreur Firebase: {str(e)}")
            return False
        except Exception as e:
            logger.error(f"❌ Erreur envoi notification: {str(e)}")
            return False
    
    @classmethod
    def send_multicast(cls, fcm_tokens, title, body, data=None):
        """
        Envoie une notification à plusieurs appareils.
        
        Args:
            fcm_tokens (list): Liste de tokens FCM
            title (str): Titre
            body (str): Corps
            data (dict): Données supplémentaires
            
        Returns:
            dict: Résumé des envois (success_count, failure_count)
        """
        if not cls._initialized:
            cls.initialize()
        
        if not cls._initialized or not fcm_tokens:
            return {'success_count': 0, 'failure_count': 0}
        
        try:
            message = messaging.MulticastMessage(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=data or {},
                tokens=fcm_tokens,
            )
            
            response = messaging.send_multicast(message)
            
            logger.info(
                f"✅ Notifications envoyées: {response.success_count} succès, "
                f"{response.failure_count} échecs"
            )
            
            return {
                'success_count': response.success_count,
                'failure_count': response.failure_count,
                'responses': response.responses
            }
            
        except Exception as e:
            logger.error(f"❌ Erreur multicast: {str(e)}")
            return {'success_count': 0, 'failure_count': len(fcm_tokens)}


# Initialiser au démarrage
FirebaseService.initialize()
