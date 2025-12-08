# core/permissions.py

from rest_framework.permissions import BasePermission


# ============================================================================
# PERMISSION : MERCHANT UNIQUEMENT
# ============================================================================

class IsMerchant(BasePermission):
    """
    Permission qui autorise uniquement les utilisateurs de type 'merchant'.
    
    Utilisation :
    class MaVue(APIView):
        permission_classes = [IsMerchant]
    """
    
    def has_permission(self, request, view):
        # ✅ Vérifie que l'utilisateur est authentifié ET de type merchant
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.user_type == 'merchant'
        )


# ============================================================================
# PERMISSION : DRIVER UNIQUEMENT
# ============================================================================

class IsDriver(BasePermission):
    """
    Permission qui autorise uniquement les utilisateurs de type 'driver'.
    """
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.user_type == 'driver'
        )


# ============================================================================
# PERMISSION : ADMIN UNIQUEMENT
# ============================================================================

class IsAdmin(BasePermission):
    """
    Permission qui autorise uniquement les utilisateurs de type 'admin'.
    """
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.user_type == 'admin'
        )


# ============================================================================
# PERMISSION : PROPRIÉTAIRE OU ADMIN
# ============================================================================

class IsOwnerOrAdmin(BasePermission):
    """
    Permission qui autorise :
    - L'admin (tous les droits)
    - Le propriétaire de l'objet
    
    Nécessite que l'objet ait un champ 'user', 'merchant' ou 'driver'.
    """
    
    def has_object_permission(self, request, view, obj):
        # Admin a tous les droits
        if request.user.user_type == 'admin':
            return True
        
        # Vérifie si l'utilisateur est le propriétaire
        if hasattr(obj, 'user'):
            return obj.user == request.user
        elif hasattr(obj, 'merchant'):
            merchant = getattr(obj, 'merchant')
            if not merchant:
                return False
            return getattr(merchant, 'user', None) == request.user
        elif hasattr(obj, 'driver'):
            return obj.driver.user == request.user
        
        return False


# ============================================================================
# PERMISSION : MERCHANT OU DRIVER
# ============================================================================

class IsMerchantOrDriver(BasePermission):
    """
    Permission qui autorise les merchants ET les drivers.
    Utile pour des endpoints accessibles aux deux types.
    """
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.user_type in ['merchant', 'driver']
        )


# ============================================================================
# PERMISSION : PARTICULIER (INDIVIDUAL)
# ============================================================================

class IsIndividual(BasePermission):
    """
    Permission qui autorise uniquement les utilisateurs de type 'individual' (particulier).
    """
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.user_type == 'individual'
        )


class IsMerchantOrIndividual(BasePermission):
    """
    Permission qui autorise les merchants ET les particuliers.
    Les deux peuvent créer des livraisons.
    """
    
    def has_permission(self, request, view):
        return (
            request.user and 
            request.user.is_authenticated and 
            request.user.user_type in ['merchant', 'individual']
        )
