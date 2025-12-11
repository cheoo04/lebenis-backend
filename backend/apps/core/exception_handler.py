# apps/core/exception_handler.py
"""
Handler d'exceptions personnalisé pour l'API LeBeni.
Transforme toutes les exceptions en réponses JSON claires et en français.
"""
from rest_framework.views import exception_handler
from rest_framework.exceptions import ValidationError as DRFValidationError
from rest_framework import status
from rest_framework.response import Response
from django.core.exceptions import ValidationError as DjangoValidationError
from django.core.exceptions import PermissionDenied, ObjectDoesNotExist
from django.http import Http404
import logging

logger = logging.getLogger('django')


def custom_exception_handler(exc, context):
    """
    Handler personnalisé pour transformer toutes les exceptions
    en réponses JSON claires et traduites en français.
    """
    
    # Appeler le handler par défaut de DRF d'abord
    response = exception_handler(exc, context)
    
    # Si DRF a déjà géré l'exception, améliorer la réponse
    if response is not None:
        return format_error_response(response, exc, context)
    
    # Gérer les exceptions Django non gérées par DRF
    if isinstance(exc, DjangoValidationError):
        return handle_django_validation_error(exc, context)
    
    if isinstance(exc, PermissionDenied):
        return Response(
            {'error': "Vous n'avez pas la permission d'effectuer cette action."},
            status=status.HTTP_403_FORBIDDEN
        )
    
    if isinstance(exc, (ObjectDoesNotExist, Http404)):
        return Response(
            {'error': "Ressource introuvable."},
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Pour les autres exceptions, log et retourner erreur générique
    logger.error(f"Unhandled exception: {exc}", exc_info=True)
    return Response(
        {'error': "Une erreur s'est produite. Veuillez réessayer."},
        status=status.HTTP_500_INTERNAL_SERVER_ERROR
    )


def format_error_response(response, exc, context):
    """
    Formate la réponse d'erreur pour être claire et en français.
    """
    error_data = {}
    
    # Extraire les erreurs de validation
    if isinstance(exc, DRFValidationError):
        error_data = format_validation_errors(response.data)
    else:
        # Autres erreurs DRF
        error_data = format_general_error(response.data, exc)
    
    return Response(error_data, status=response.status_code)


def format_validation_errors(data):
    """
    Transforme les erreurs de validation en format lisible.
    """
    if isinstance(data, dict):
        # Cas 1: Erreurs par champ
        if any(key not in ['detail', 'error', 'message'] for key in data.keys()):
            errors = {}
            for field, messages in data.items():
                if isinstance(messages, list):
                    # Traduire les messages communs
                    translated = [translate_field_error(msg, field) for msg in messages]
                    errors[field] = translated
                elif isinstance(messages, dict):
                    # Erreurs imbriquées
                    errors[field] = format_validation_errors(messages)
                else:
                    errors[field] = [translate_field_error(str(messages), field)]
            
            return {'errors': errors}
        
        # Cas 2: Erreur générale avec 'detail'
        if 'detail' in data:
            return {'error': translate_error_message(data['detail'])}
        
        # Cas 3: Déjà au bon format
        if 'error' in data or 'errors' in data:
            return data
    
    elif isinstance(data, list):
        # Liste de messages d'erreur
        return {'error': translate_error_message(data[0]) if data else "Erreur de validation"}
    
    # Format par défaut
    return {'error': translate_error_message(str(data))}


def format_general_error(data, exc):
    """
    Formate les erreurs non-validation (403, 404, etc.)
    """
    if isinstance(data, dict):
        if 'detail' in data:
            return {'error': translate_error_message(data['detail'])}
        if 'error' in data:
            return data
    
    # Message par défaut selon le type d'exception
    error_messages = {
        'NotAuthenticated': "Authentification requise. Veuillez vous connecter.",
        'PermissionDenied': "Vous n'avez pas la permission d'effectuer cette action.",
        'NotFound': "Ressource introuvable.",
        'MethodNotAllowed': "Méthode non autorisée.",
        'Throttled': "Trop de requêtes. Veuillez réessayer plus tard.",
    }
    
    exc_name = exc.__class__.__name__
    return {'error': error_messages.get(exc_name, str(data))}


def handle_django_validation_error(exc, context):
    """
    Gère les ValidationError de Django (pas DRF).
    """
    if hasattr(exc, 'message_dict'):
        # Erreurs par champ
        errors = {}
        for field, messages in exc.message_dict.items():
            errors[field] = [translate_field_error(msg, field) for msg in messages]
        return Response({'errors': errors}, status=status.HTTP_400_BAD_REQUEST)
    
    elif hasattr(exc, 'messages'):
        # Liste de messages
        message = exc.messages[0] if exc.messages else "Erreur de validation"
        return Response({'error': translate_error_message(message)}, status=status.HTTP_400_BAD_REQUEST)
    
    else:
        # Message simple
        return Response(
            {'error': translate_error_message(str(exc))},
            status=status.HTTP_400_BAD_REQUEST
        )


def translate_field_error(message, field_name):
    """
    Traduit les messages d'erreur de champ en français.
    """
    # Messages Django/DRF communs
    translations = {
        'This field is required.': 'Ce champ est obligatoire.',
        'This field may not be blank.': 'Ce champ ne peut pas être vide.',
        'This field may not be null.': 'Ce champ ne peut pas être vide.',
        'Ensure this field has no more than': 'Ce champ ne doit pas dépasser',
        'Ensure this field has at least': 'Ce champ doit contenir au moins',
        'Enter a valid email address.': 'Entrez une adresse email valide.',
        'Enter a valid URL.': 'Entrez une URL valide.',
        'Enter a valid phone number.': 'Entrez un numéro de téléphone valide.',
        'This field must be unique.': 'Cette valeur existe déjà.',
        'Invalid pk': 'Identifiant invalide',
        'A valid integer is required.': 'Un nombre entier est requis.',
        'A valid number is required.': 'Un nombre valide est requis.',
        'Datetime has wrong format.': 'Format de date/heure invalide.',
        'Date has wrong format.': 'Format de date invalide.',
        'Time has wrong format.': 'Format d\'heure invalide.',
        'Not a valid UUID.': 'Identifiant invalide.',
        'This password is too short.': 'Ce mot de passe est trop court.',
        'This password is too common.': 'Ce mot de passe est trop commun.',
        'This password is entirely numeric.': 'Ce mot de passe ne peut pas être entièrement numérique.',
        'Invalid token.': 'Token invalide.',
        'No active account found with the given credentials': 'Email ou mot de passe incorrect.',
    }
    
    message_str = str(message)
    
    # Chercher une correspondance exacte
    for eng, fr in translations.items():
        if eng in message_str:
            return message_str.replace(eng, fr)
    
    # Si déjà en français ou message personnalisé, retourner tel quel
    return message_str


def translate_error_message(message):
    """
    Traduit les messages d'erreur généraux en français.
    """
    message_str = str(message)
    
    # Messages d'authentification
    auth_translations = {
        'Authentication credentials were not provided.': 'Authentification requise. Veuillez vous connecter.',
        'Invalid token.': 'Token d\'authentification invalide.',
        'User inactive or deleted.': 'Compte utilisateur inactif ou supprimé.',
        'Given token not valid for any token type': 'Token invalide.',
        'Token is invalid or expired': 'Token invalide ou expiré.',
        'No active account found with the given credentials': 'Email ou mot de passe incorrect.',
    }
    
    # Messages de permission
    permission_translations = {
        'You do not have permission to perform this action.': "Vous n'avez pas la permission d'effectuer cette action.",
        'Not found.': 'Ressource introuvable.',
        'Method not allowed.': 'Méthode non autorisée.',
        'Unsupported media type': 'Type de média non supporté.',
    }
    
    all_translations = {**auth_translations, **permission_translations}
    
    for eng, fr in all_translations.items():
        if eng.lower() in message_str.lower():
            return fr
    
    # Si déjà en français ou message personnalisé, retourner tel quel
    return message_str
