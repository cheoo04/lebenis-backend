from rest_framework.permissions import IsAuthenticated, IsAdminUser

class PricingViewSetPermissionMixin:
    """
    Mixin pour factoriser la logique get_permissions des ViewSets pricing.
    """
    def get_permissions(self):
        if self.action in ['list', 'retrieve', 'with_selection', 'assign', 'calculate']:
            permission_classes = [IsAuthenticated]
        else:
            permission_classes = [IsAdminUser]
        return [permission() for permission in permission_classes]