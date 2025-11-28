import logging
from django.utils.deprecation import MiddlewareMixin

class DebugAuthMiddleware(MiddlewareMixin):
    def process_request(self, request):
        logger = logging.getLogger('django')
        auth = request.META.get('HTTP_AUTHORIZATION', None)
        user = getattr(request, 'user', None)
        logger.debug(f"[DebugAuthMiddleware] Authorization header: {auth}")
        logger.debug(f"[DebugAuthMiddleware] User: {user} (is_authenticated={getattr(user, 'is_authenticated', None)})")