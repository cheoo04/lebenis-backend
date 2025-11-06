"""
Views pour upload fichiers vers Cloudinary
"""
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.parsers import MultiPartParser, FormParser
from django.core.exceptions import ValidationError

from core.cloudinary_service import CloudinaryService


class CloudinaryUploadView(APIView):
    """
    Upload générique vers Cloudinary
    Supporte: photos profil, images chat, documents
    """
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        """
        Upload un fichier vers Cloudinary
        
        POST /api/v1/cloudinary/upload/
        
        Form Data:
            - file: Fichier à uploader (required)
            - upload_type: Type d'upload (profile_photo, chat_image, document)
            - document_type: Type de document si upload_type=document (license, id_card, etc.)
        
        Returns:
            200: {
                "url": "https://res.cloudinary.com/...",
                "upload_type": "chat_image"
            }
        """
        # Récupérer le fichier
        uploaded_file = request.FILES.get('file')
        if not uploaded_file:
            return Response(
                {'error': 'Aucun fichier fourni'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Type d'upload
        upload_type = request.data.get('upload_type', 'chat_image')
        
        try:
            # Router vers la bonne méthode selon le type
            if upload_type == 'profile_photo':
                url = CloudinaryService.upload_profile_photo(
                    uploaded_file,
                    user_id=request.user.id
                )
            
            elif upload_type == 'chat_image':
                # Utiliser la méthode générique pour images
                url = CloudinaryService.upload_profile_photo(
                    uploaded_file,
                    user_id=request.user.id
                )
            
            elif upload_type == 'document':
                document_type = request.data.get('document_type', 'general')
                url = CloudinaryService.upload_document(
                    uploaded_file,
                    user_id=request.user.id,
                    document_type=document_type
                )
            
            else:
                return Response(
                    {'error': f'Type d\'upload inconnu: {upload_type}'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            return Response({
                'url': url,
                'upload_type': upload_type,
            }, status=status.HTTP_200_OK)

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


class CloudinaryDeleteView(APIView):
    """
    Supprimer une image de Cloudinary
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        """
        Supprime une image de Cloudinary
        
        POST /api/v1/cloudinary/delete/
        
        Body:
            {
                "url": "https://res.cloudinary.com/..."
            }
        
        Returns:
            200: {"success": true}
            400: {"error": "..."}
        """
        url = request.data.get('url')
        if not url:
            return Response(
                {'error': 'URL manquante'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            success = CloudinaryService.delete_image(url)
            
            if success:
                return Response(
                    {'success': True},
                    status=status.HTTP_200_OK
                )
            else:
                return Response(
                    {'error': 'Échec de la suppression'},
                    status=status.HTTP_400_BAD_REQUEST
                )
        
        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
