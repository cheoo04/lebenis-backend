"""
GPS Tracking API Views
"""
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.viewsets import ViewSet
from django.utils import timezone
from datetime import timedelta

from .gps_tracking_service import GPSTrackingService
from .gps_serializers import (
    LocationUpdateSerializer,
    LocationUpdateCreateSerializer,
    TrackingIntervalSerializer,
    TrackingSessionSerializer,
    TrackingStatisticsSerializer,
)
from .location_models import LocationUpdate, LocationTrackingSession


class GPSTrackingViewSet(ViewSet):
    """ViewSet for GPS tracking operations"""
    permission_classes = [IsAuthenticated]
    
    @action(detail=False, methods=['post'])
    def update_location(self, request):
        """
        Update driver's current location
        
        POST /api/v1/drivers/gps/update_location/
        
        Body:
        {
            "latitude": 36.7538,
            "longitude": 3.0588,
            "accuracy": 10.5,
            "speed": 5.2,
            "heading": 90.0,
            "altitude": 100.0,
            "battery_level": 85,
            "timestamp": "2024-11-06T10:30:00Z"
        }
        """
        # Check if user is a driver
        try:
            driver = request.user.driver_profile
        except AttributeError:
            return Response(
                {'error': 'Driver profile not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Validate input
        serializer = LocationUpdateCreateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
        
        data = serializer.validated_data
        
        # Update location
        try:
            location_update = GPSTrackingService.update_driver_location(
                driver=driver,
                latitude=data['latitude'],
                longitude=data['longitude'],
                accuracy=data.get('accuracy'),
                speed=data.get('speed'),
                heading=data.get('heading'),
                altitude=data.get('altitude'),
                battery_level=data.get('battery_level'),
                timestamp=data.get('timestamp'),
            )
            
            # Return updated location and recommended interval
            interval = GPSTrackingService.get_tracking_interval(
                driver.availability_status,
                location_update.is_moving
            )
            
            return Response({
                'success': True,
                'location': LocationUpdateSerializer(location_update).data,
                'next_update_interval_seconds': interval,
            }, status=status.HTTP_201_CREATED)
            
        except Exception as e:
            return Response(
                {'error': f'Failed to update location: {str(e)}'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=False, methods=['get'])
    def get_interval(self, request):
        """
        Get recommended tracking interval based on driver status
        
        GET /api/v1/drivers/gps/get_interval/
        """
        try:
            driver = request.user.driver_profile
        except AttributeError:
            return Response(
                {'error': 'Driver profile not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Get latest location to determine if moving
        latest_location = LocationUpdate.objects.filter(
            driver=driver
        ).first()
        
        is_moving = latest_location.is_moving if latest_location else False
        
        interval = GPSTrackingService.get_tracking_interval(
            driver.availability_status,
            is_moving
        )
        
        # Determine recommended accuracy
        if driver.availability_status == 'busy':
            recommended_accuracy = 'high'  # Best accuracy
        elif driver.availability_status == 'available':
            recommended_accuracy = 'balanced'  # Balanced
        else:
            recommended_accuracy = 'low'  # Low power
        
        data = {
            'interval_seconds': interval,
            'driver_status': driver.availability_status,
            'is_moving': is_moving,
            'recommended_accuracy': recommended_accuracy,
        }
        
        serializer = TrackingIntervalSerializer(data)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def history(self, request):
        """
        Get location history
        
        GET /api/v1/drivers/gps/history/?days=7&limit=100
        """
        try:
            driver = request.user.driver_profile
        except AttributeError:
            return Response(
                {'error': 'Driver profile not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Parse query parameters
        days = int(request.query_params.get('days', 7))
        limit = int(request.query_params.get('limit', 100))
        
        # Calculate date range
        end_date = timezone.now()
        start_date = end_date - timedelta(days=days)
        
        # Get history
        history = GPSTrackingService.get_location_history(
            driver=driver,
            start_date=start_date,
            end_date=end_date,
            limit=limit
        )
        
        serializer = LocationUpdateSerializer(history, many=True)
        return Response({
            'count': history.count(),
            'history': serializer.data,
        })
    
    @action(detail=False, methods=['get'])
    def sessions(self, request):
        """
        Get tracking sessions
        
        GET /api/v1/drivers/gps/sessions/?days=7
        """
        try:
            driver = request.user.driver_profile
        except AttributeError:
            return Response(
                {'error': 'Driver profile not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        days = int(request.query_params.get('days', 7))
        start_date = timezone.now() - timedelta(days=days)
        
        sessions = LocationTrackingSession.objects.filter(
            driver=driver,
            started_at__gte=start_date
        )
        
        serializer = TrackingSessionSerializer(sessions, many=True)
        return Response({
            'count': sessions.count(),
            'sessions': serializer.data,
        })
    
    @action(detail=False, methods=['get'])
    def statistics(self, request):
        """
        Get tracking statistics
        
        GET /api/v1/drivers/gps/statistics/?days=7
        """
        try:
            driver = request.user.driver_profile
        except AttributeError:
            return Response(
                {'error': 'Driver profile not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        days = int(request.query_params.get('days', 7))
        
        stats = GPSTrackingService.get_tracking_statistics(driver, days)
        serializer = TrackingStatisticsSerializer(stats)
        
        return Response(serializer.data)
    
    @action(detail=False, methods=['post'])
    def end_session(self, request):
        """
        End current tracking session
        
        POST /api/v1/drivers/gps/end_session/
        """
        try:
            driver = request.user.driver_profile
        except AttributeError:
            return Response(
                {'error': 'Driver profile not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        GPSTrackingService.end_tracking_session(driver)
        
        return Response({
            'success': True,
            'message': 'Tracking session ended'
        })
