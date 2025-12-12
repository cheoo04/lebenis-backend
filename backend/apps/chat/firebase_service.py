"""
Service pour synchroniser les messages avec Firebase Realtime Database.
Permet le chat temps réel côté Flutter.
"""

import os
import json
import base64
import logging
from datetime import datetime
from typing import Dict, Any, Optional
from django.conf import settings

logger = logging.getLogger(__name__)

# Import conditionnel de Firebase Admin SDK
try:
    import firebase_admin
    from firebase_admin import credentials, db
    FIREBASE_AVAILABLE = True
except ImportError:
    FIREBASE_AVAILABLE = False
    logger.warning("⚠️ firebase-admin SDK non installé. Chat temps réel désactivé.")


class FirebaseChatService:
    """
    Service pour gérer le chat temps réel via Firebase Realtime Database.
    
    Structure Firebase:
    /chats/{chat_room_id}/
        - metadata: {...}
        - messages/
            - {message_id}: {...}
        - typing/
            - {user_id}: timestamp
    """
    
    _app = None
    _initialized = False
    
    @classmethod
    def initialize(cls):
        """Initialise Firebase Admin SDK une seule fois"""
        if not FIREBASE_AVAILABLE:
            logger.warning("Firebase Admin SDK non disponible")
            return False
        
        if cls._initialized:
            return True
        
        try:
            # Vérifier si déjà initialisé
            if not firebase_admin._apps:
                cred = None
                database_url = getattr(settings, 'FIREBASE_DATABASE_URL', None) or os.environ.get('FIREBASE_DATABASE_URL')
                
                if not database_url:
                    logger.error("❌ FIREBASE_DATABASE_URL non configuré")
                    return False
                
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
                    cred_path = getattr(settings, 'FIREBASE_CREDENTIALS_PATH', None)
                    if cred_path:
                        full_path = os.path.join(settings.BASE_DIR, cred_path) if not os.path.isabs(cred_path) else cred_path
                        if os.path.exists(full_path):
                            cred = credentials.Certificate(full_path)
                            logger.info(f"🔐 Firebase credentials chargés depuis fichier: {cred_path}")
                        else:
                            logger.warning(f"⚠️ Fichier Firebase credentials introuvable: {full_path}")
                
                if not cred:
                    logger.error("❌ Aucune credentials Firebase configurées")
                    return False
                
                firebase_admin.initialize_app(cred, {
                    'databaseURL': database_url
                })
                
                logger.info("✅ Firebase Realtime Database initialisé")
            
            cls._app = firebase_admin.get_app()
            cls._initialized = True
            return True
            
        except Exception as e:
            logger.error(f"❌ Erreur initialisation Firebase: {e}")
            return False
    
    @classmethod
    def send_message(cls, chat_room_id: str, message_data: Dict[str, Any]) -> bool:
        """
        Envoie un message dans Firebase Realtime Database.
        
        Args:
            chat_room_id: ID de la chat room
            message_data: Données du message (id, sender_id, text, type, etc.)
        
        Returns:
            True si succès, False sinon
        """
        if not cls.initialize():
            return False
        
        try:
            message_id = message_data.get('id')
            path = f'/chats/{chat_room_id}/messages/{message_id}'
            
            # Préparer les données
            firebase_message = {
                'id': str(message_id),
                'senderId': str(message_data.get('sender_id')),
                'type': message_data.get('message_type', 'text'),
                'text': message_data.get('text', ''),
                'imageUrl': message_data.get('image_url', ''),
                'latitude': str(message_data.get('latitude', '')) if message_data.get('latitude') else None,
                'longitude': str(message_data.get('longitude', '')) if message_data.get('longitude') else None,
                'timestamp': message_data.get('timestamp', datetime.now().isoformat()),
                'isRead': False,
            }
            
            # Envoyer à Firebase
            ref = db.reference(path)
            ref.set(firebase_message)
            
            # Mettre à jour les métadonnées du chat
            cls._update_chat_metadata(chat_room_id, {
                'lastMessage': firebase_message['text'][:100],
                'lastMessageAt': firebase_message['timestamp'],
                'lastMessageSenderId': firebase_message['senderId'],
            })
            
            logger.info(f"📤 Message envoyé à Firebase: {chat_room_id}/{message_id}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erreur envoi message Firebase: {e}")
            return False
    
    @classmethod
    def _update_chat_metadata(cls, chat_room_id: str, metadata: Dict[str, Any]):
        """Met à jour les métadonnées d'un chat"""
        try:
            path = f'/chats/{chat_room_id}/metadata'
            ref = db.reference(path)
            ref.update(metadata)
        except Exception as e:
            logger.error(f"❌ Erreur mise à jour metadata: {e}")
    
    @classmethod
    def mark_message_as_read(cls, chat_room_id: str, message_id: str) -> bool:
        """Marque un message comme lu dans Firebase"""
        if not cls.initialize():
            return False
        
        try:
            path = f'/chats/{chat_room_id}/messages/{message_id}'
            ref = db.reference(path)
            ref.update({
                'isRead': True,
                'readAt': datetime.now().isoformat()
            })
            
            logger.info(f"✓ Message marqué comme lu: {message_id}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erreur mark as read Firebase: {e}")
            return False
    
    @classmethod
    def set_typing_indicator(cls, chat_room_id: str, user_id: str, is_typing: bool) -> bool:
        """
        Définit l'indicateur "en train d'écrire".
        
        Args:
            chat_room_id: ID de la chat room
            user_id: ID de l'utilisateur
            is_typing: True si en train d'écrire, False sinon
        """
        if not cls.initialize():
            return False
        
        try:
            path = f'/chats/{chat_room_id}/typing/{user_id}'
            ref = db.reference(path)
            
            if is_typing:
                ref.set(datetime.now().isoformat())
            else:
                ref.delete()
            
            return True
            
        except Exception as e:
            logger.error(f"❌ Erreur typing indicator: {e}")
            return False
    
    @classmethod
    def create_chat_room(cls, chat_room_id: str, metadata: Dict[str, Any]) -> bool:
        """
        Crée une nouvelle chat room dans Firebase.
        
        Args:
            chat_room_id: ID de la chat room
            metadata: Métadonnées (participants, type, etc.)
        """
        if not cls.initialize():
            return False
        
        try:
            path = f'/chats/{chat_room_id}'
            ref = db.reference(path)
            
            firebase_data = {
                'metadata': {
                    'id': str(chat_room_id),
                    'type': metadata.get('room_type', 'delivery'),
                    'driverId': str(metadata.get('driver_id')),
                    'otherUserId': str(metadata.get('other_user_id')),
                    'deliveryId': str(metadata.get('delivery_id')) if metadata.get('delivery_id') else None,
                    'createdAt': datetime.now().isoformat(),
                    'isActive': True,
                },
                'messages': {},  # Initialement vide
                'typing': {},    # Indicateurs de saisie
            }
            
            ref.set(firebase_data)
            logger.info(f"🆕 Chat room créée dans Firebase: {chat_room_id}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erreur création chat room Firebase: {e}")
            return False
    
    @classmethod
    def delete_chat_room(cls, chat_room_id: str) -> bool:
        """Supprime une chat room de Firebase"""
        if not cls.initialize():
            return False
        
        try:
            path = f'/chats/{chat_room_id}'
            ref = db.reference(path)
            ref.delete()
            
            logger.info(f"🗑️ Chat room supprimée de Firebase: {chat_room_id}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Erreur suppression chat room: {e}")
            return False
