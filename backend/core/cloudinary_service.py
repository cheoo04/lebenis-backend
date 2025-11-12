"""
Service professionnel pour gestion uploads Cloudinary
Gère: validation, compression, transformation, gestion d'erreurs
"""
import cloudinary
import cloudinary.uploader
from django.conf import settings
from django.core.exceptions import ValidationError
import mimetypes
import os


class CloudinaryService:
    """Service centralisé pour tous les uploads Cloudinary"""
    
    # Tailles maximales (en bytes)
    MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB
    MAX_PROFILE_PHOTO_SIZE = 5 * 1024 * 1024  # 5MB pour photos profil
    
    # MIME types autorisés
    ALLOWED_IMAGE_TYPES = {
        'image/jpeg', 'image/jpg', 'image/png', 'image/webp'
    }
    ALLOWED_DOCUMENT_TYPES = {
        'image/jpeg', 'image/jpg', 'image/png', 'application/pdf'
    }
    
    _cloudinary_configured = False

    @classmethod
    def _configure_cloudinary(cls):
        """Configure Cloudinary avec les credentials depuis settings (une seule fois)"""
        if cls._cloudinary_configured:
            return
        storage = getattr(settings, 'CLOUDINARY_STORAGE', {})
        cloud_name = storage.get('CLOUD_NAME')
        api_key = storage.get('API_KEY')
        api_secret = storage.get('API_SECRET')
        if not all([cloud_name, api_key, api_secret]):
            raise ValidationError(
                "Cloudinary non configuré. Vérifiez les variables d'environnement: "
                "CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET"
            )
        cloudinary.config(
            cloud_name=cloud_name,
            api_key=api_key,
            api_secret=api_secret,
            secure=storage.get('SECURE', True)
        )
        cls._cloudinary_configured = True
    
    @classmethod
    def _validate_file(cls, file, max_size=None, allowed_types=None):
        """
        Valide un fichier uploadé
        
        Args:
            file: Fichier Django UploadedFile
            max_size: Taille max en bytes (optionnel)
            allowed_types: Set de MIME types autorisés (optionnel)
        
        Raises:
            ValidationError: Si validation échoue
        """
        if not file:
            raise ValidationError('Aucun fichier fourni')
        
        # Vérifier la taille
        if max_size and file.size > max_size:
            raise ValidationError(
                f'Fichier trop volumineux. '
                f'Taille maximale: {max_size / (1024*1024):.1f}MB, '
                f'taille actuelle: {file.size / (1024*1024):.1f}MB'
            )
        
        # Vérifier le type MIME
        if allowed_types:
            # Détecter le type MIME
            mime_type, _ = mimetypes.guess_type(file.name)
            if not mime_type:
                # Fallback sur content_type du fichier
                mime_type = getattr(file, 'content_type', None)
            
            if mime_type not in allowed_types:
                raise ValidationError(
                    f'Type de fichier non autorisé: {mime_type}. '
                    f'Types acceptés: {", ".join(allowed_types)}'
                )
    
    @classmethod
    def upload_profile_photo(cls, file, user_id):
        """Upload une photo de profil utilisateur"""
        import logging
        logger = logging.getLogger(__name__)
        
        logger.info(f"🔄 [CLOUDINARY] Starting upload for user {user_id}")
        logger.info(f"   File: {file.name}, Size: {file.size} bytes")
        
        # ✅ VÉRIFIER QUE LE FICHIER A DU CONTENU
        if file.size == 0:
            raise Exception("Le fichier est vide !")
        
        # Configuration Cloudinary
        cls._configure_cloudinary()
        logger.info("✅ [CLOUDINARY] Configuration OK")
        
        # Validation
        cls._validate_file(
            file,
            max_size=cls.MAX_PROFILE_PHOTO_SIZE,
            allowed_types=cls.ALLOWED_IMAGE_TYPES
        )
        logger.info("✅ [CLOUDINARY] Validation OK")
        
        # Nom unique du fichier
        public_id = f"user_{user_id}"
        
        try:
            logger.info(f"🚀 [CLOUDINARY] Uploading to folder: lebenis/profiles, public_id: {public_id}")
            # 🔥 LIRE LE CONTENU DU FICHIER AVANT UPLOAD
            file.seek(0)  # Remettre au début
            file_content = file.read()
            logger.info(f"📄 [CLOUDINARY] File content length: {len(file_content)} bytes")
            
            if len(file_content) == 0:
                raise Exception("Le contenu du fichier est vide après lecture !")
            
            # Remettre au début pour Cloudinary
            file.seek(0)
            
            # Upload SIMPLE (sans transformations pour tester)
            result = cloudinary.uploader.upload(
                file,
                public_id=public_id,
                overwrite=True,
                resource_type='image',
                folder='lebenis/profiles',
                invalidate=True,
            )
            
            secure_url = result.get('secure_url')
            
            # 🔥 VÉRIFIER QUE CLOUDINARY A VRAIMENT RETOURNÉ UNE URL
            if not secure_url:
                logger.error(f"❌ [CLOUDINARY] No secure_url in response: {result}")
                raise Exception("Cloudinary n'a pas retourné d'URL !")
            
            logger.info(f"✅ [CLOUDINARY] Upload SUCCESS!")
            logger.info(f"   URL: {secure_url}")
            logger.info(f"   Public ID: {result.get('public_id')}")
            logger.info(f"   Format: {result.get('format')}")
            logger.info(f"   Width: {result.get('width')}, Height: {result.get('height')}")
            logger.info(f"   Bytes: {result.get('bytes')}")  # ✅ NOUVEAU : Vérifier la taille uploadée
            
            return secure_url
        
        except Exception as e:
            logger.error(f"❌ [CLOUDINARY] Upload FAILED: {str(e)}")
            import traceback
            logger.error(traceback.format_exc())
            raise Exception(f'Erreur lors de l\'upload vers Cloudinary: {str(e)}')
    
    @classmethod
    def upload_document(cls, file, user_id, document_type='general'):
        """
        Upload un document (permis, carte d'identité, etc.)
        
        Args:
            file: Fichier Django UploadedFile
            user_id: ID de l'utilisateur
            document_type: Type de document (license, id_card, etc.)
        
        Returns:
            str: URL sécurisée du document
        
        Raises:
            ValidationError: Si validation échoue
        """
        cls._configure_cloudinary()
        
        cls._validate_file(
            file,
            max_size=cls.MAX_FILE_SIZE,
            allowed_types=cls.ALLOWED_DOCUMENT_TYPES
        )
        
        # Nom unique
        timestamp = int(os.times().system)
        public_id = f"lebenis/documents/{document_type}/user_{user_id}_{timestamp}"
        
        try:
            result = cloudinary.uploader.upload(
                file,
                public_id=public_id,
                resource_type='auto',  # Détection auto (image/pdf)
                folder=f'lebenis/documents/{document_type}',
                transformation=getattr(settings, 'CLOUDINARY_DOCUMENT_OPTIONS', {}).get('transformation', []),
            )
            
            return result.get('secure_url')
        
        except Exception as e:
            raise Exception(f'Erreur upload document: {str(e)}')
    
    @classmethod
    def delete_image(cls, url):
        """
        Supprime une image de Cloudinary
        Args:
            url: URL complète de l'image Cloudinary
        Returns:
            bool: True si suppression réussie
        """
        try:
            cls._configure_cloudinary()
            if 'cloudinary.com' not in url:
                return False
            # Extraire le public_id Cloudinary de l'URL
            # Ex: https://res.cloudinary.com/<cloud>/image/upload/v<version>/<folder>/<public_id>.<ext>
            # On enlève le protocole et on split
            path = url.split('upload/')[-1]
            # Enlever la version si présente (commence par v et chiffres)
            parts = path.split('/')
            if parts[0].startswith('v') and parts[0][1:].isdigit():
                parts = parts[1:]
            public_id_with_ext = '/'.join(parts)
            public_id, _ = os.path.splitext(public_id_with_ext)
            result = cloudinary.uploader.destroy(public_id)
            return result.get('result') == 'ok'
        except Exception:
            return False
