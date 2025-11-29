from rest_framework.permissions import IsAuthenticated

class AssignZonesPermissionMixin:
    def get_permissions(self):
        return [IsAuthenticated()]
