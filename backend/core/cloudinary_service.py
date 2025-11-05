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
    
    @classmethod
    def _configure_cloudinary(cls):
        """Configure Cloudinary avec les credentials depuis settings"""
        if not all([
            settings.CLOUDINARY_STORAGE.get('CLOUD_NAME'),
            settings.CLOUDINARY_STORAGE.get('API_KEY'),
            settings.CLOUDINARY_STORAGE.get('API_SECRET'),
        ]):
            raise ValidationError(
                'Cloudinary non configuré. Vérifiez les variables d\'environnement: '
                'CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET'
            )
        
        cloudinary.config(
            cloud_name=settings.CLOUDINARY_STORAGE['CLOUD_NAME'],
            api_key=settings.CLOUDINARY_STORAGE['API_KEY'],
            api_secret=settings.CLOUDINARY_STORAGE['API_SECRET'],
            secure=settings.CLOUDINARY_STORAGE.get('SECURE', True)
        )
    
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
        """
        Upload une photo de profil utilisateur
        
        Args:
            file: Fichier Django UploadedFile
            user_id: ID de l'utilisateur (pour nommage unique)
        
        Returns:
            str: URL sécurisée de l'image uploadée
        
        Raises:
            ValidationError: Si validation échoue
            Exception: Si upload échoue
        """
        # Configuration Cloudinary
        cls._configure_cloudinary()
        
        # Validation
        cls._validate_file(
            file,
            max_size=cls.MAX_PROFILE_PHOTO_SIZE,
            allowed_types=cls.ALLOWED_IMAGE_TYPES
        )
        
        # Nom unique du fichier
        public_id = f"lebenis/profiles/user_{user_id}"
        
        try:
            # Upload avec transformations
            result = cloudinary.uploader.upload(
                file,
                public_id=public_id,
                overwrite=True,  # Remplacer si existe déjà
                resource_type='image',
                folder='lebenis/profiles',
                transformation=settings.CLOUDINARY_PROFILE_PHOTO_OPTIONS.get('transformation', []),
                invalidate=True,  # Invalider cache CDN
            )
            
            # Retourner URL sécurisée
            return result.get('secure_url')
        
        except Exception as e:
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
                transformation=settings.CLOUDINARY_DOCUMENT_OPTIONS.get('transformation', []),
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
            
            # Extraire public_id de l'URL
            # URL format: https://res.cloudinary.com/{cloud}/image/upload/v{version}/{public_id}.{format}
            parts = url.split('/')
            if 'cloudinary.com' not in url:
                return False
            
            # Trouver l'index de 'upload'
            upload_idx = parts.index('upload')
            # Public ID est tout après upload/ (sans l'extension)
            public_id_with_ext = '/'.join(parts[upload_idx + 2:])  # Skip version
            public_id = os.path.splitext(public_id_with_ext)[0]
            
            result = cloudinary.uploader.destroy(public_id)
            return result.get('result') == 'ok'
        
        except Exception:
            return False
