"""
Endpoints sécurisés pour upload de fichiers vers Cloudinary
"""
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.core.exceptions import ValidationError
from core.cloudinary_service import CloudinaryService


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def upload_profile_photo(request):
    """
    POST /api/v1/auth/upload-profile-photo/
    
    Upload une photo de profil vers Cloudinary et met à jour le profil utilisateur.
    
    Request:
        import logging
        logger = logging.getLogger("django.request")
        try:
            logger.debug("[UPLOAD_PROFILE_PHOTO] request.FILES: %s", request.FILES)
            logger.debug("[UPLOAD_PROFILE_PHOTO] request.POST: %s", request.POST)
        - Field: 'photo' (fichier image)
    
    Response Success (200):
        {
            "success": true,
            "message": "Photo de profil mise à jour",
            "profile_photo": "https://res.cloudinary.com/..."
        }
    
    Response Error (400):
        {
            "error": "Message d'erreur détaillé"
        }
    
    Validations:
        - Fichier obligatoire
        - Taille max: 5MB
        - Formats: JPG, PNG, WebP
        - Utilisateur authentifié
    """
    try:
        # Vérifier qu'un fichier est fourni
        if 'photo' not in request.FILES:
            return Response(
                {'error': 'Aucun fichier fourni. Utilisez le champ "photo"'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        photo_file = request.FILES['photo']
        user = request.user
        
        # Upload vers Cloudinary avec validation
        try:
            photo_url = CloudinaryService.upload_profile_photo(
                file=photo_file,
                user_id=str(user.id)
            )
        except ValidationError as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            return Response(
                {'error': f'Erreur lors de l\'upload: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
        
        # Ne pas supprimer l'ancienne photo Cloudinary (évite de supprimer la nouvelle si overwrite=True)
        
        # Mettre à jour le profil utilisateur
        user.profile_photo = photo_url
        user.save(update_fields=['profile_photo', 'updated_at'])
        
        return Response({
            'success': True,
            'message': 'Photo de profil mise à jour avec succès',
            'profile_photo': photo_url,
            'user': {
                'id': str(user.id),
                'email': user.email,
                'full_name': user.full_name,
                'profile_photo': photo_url
            }
        }, status=status.HTTP_200_OK)
    
    except Exception as e:
        return Response(
            {'error': f'Erreur serveur: {str(e)}'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_profile_photo(request):
    """
    DELETE /api/v1/auth/delete-profile-photo/
    
    Supprime la photo de profil de l'utilisateur (local + Cloudinary).
    
    Response Success (200):
        {
            "success": true,
            "message": "Photo de profil supprimée"
        }
    """
    try:
        user = request.user
        
        if not user.profile_photo:
            return Response(
                {'error': 'Aucune photo de profil à supprimer'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Supprimer de Cloudinary
        if 'cloudinary.com' in user.profile_photo:
            try:
                CloudinaryService.delete_image(user.profile_photo)
            except Exception:
                pass  # Ignorer les erreurs
        
        # Supprimer du profil
        user.profile_photo = None
        user.save(update_fields=['profile_photo', 'updated_at'])
        
        return Response({
            'success': True,
            'message': 'Photo de profil supprimée avec succès'
        }, status=status.HTTP_200_OK)
    
    except Exception as e:
        return Response(
            {'error': f'Erreur: {str(e)}'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
