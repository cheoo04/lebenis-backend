"""
Core views for production healthcheck and utilities
"""
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from django.db import connection


@api_view(['GET'])
@permission_classes([AllowAny])
def health_check(request):
    """
    Endpoint de santé pour monitoring (Load Balancer, Uptime Robot, etc.)
    
    GET /health/
    
    Response:
    {
        "status": "healthy",
        "database": "connected"
    }
    """
    try:
        # Vérifier connexion DB
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
        
        return Response({
            'status': 'healthy',
            'database': 'connected'
        })
    except Exception as e:
        return Response({
            'status': 'unhealthy',
            'database': 'disconnected',
            'error': str(e)
        }, status=500)
