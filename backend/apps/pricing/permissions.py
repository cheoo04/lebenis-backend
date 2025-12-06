from rest_framework.permissions import IsAuthenticated, IsAdminUser, AllowAny

class PricingViewSetPermissionMixin:
    """
    Mixin pour factoriser la logique get_permissions des ViewSets pricing.
    """
    def get_permissions(self):
        if self.action == 'calculate':
            # L'endpoint de calcul est accessible sans authentification
            permission_classes = [AllowAny]
        elif self.action in ['list', 'retrieve', 'with_selection', 'assign']:
            permission_classes = [IsAuthenticated]
        else:
            permission_classes = [IsAdminUser]
        return [permission() for permission in permission_classes]